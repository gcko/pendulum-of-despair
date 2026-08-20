#!/usr/bin/env bash
# The headless-Godot mutex, shared by `.husky/pre-push` and `scripts/gates.sh`.
#
# SOURCE this file; do not execute it. It defines functions and sets no traps
# until `godot_lock_acquire` is called.
#
# WHY A SECOND HEADLESS GODOT IS A WRONG ANSWER, NOT A SLOW ONE
#
# GUT's collected-script count is not deterministic under contention. A run that
# loses the race collects FEWER scripts and fewer tests, and Gate L
# (check_gut_baseline.py) reads a fallen count as a test file being SILENTLY
# SKIPPED — so it names an innocent, unmodified file and rejects the push.
# Before Gate L was wired into pre-push the same contended run printed
# "All tests passed!" and pushed, so the non-determinism was a nuisance; wiring
# the floor in turned it into a hard rejection with a false diagnosis. The mutex
# is what makes the floor safe to gate on (#430).
#
# Concurrent imports of one project are separately destructive: two Godots
# importing the same tree write `valid=false` into the .import sidecars, which
# sits beside each asset and survives deleting `.godot`.
#
# gates.sh held this lock and pre-push did not, which is exactly how the two came
# to disagree about one clean tree. One implementation, both callers, so they
# cannot drift apart in what they serialize or how long they wait.
#
# WHAT THIS IS, AND THE ONE WINDOW IT DOES NOT CLOSE
#
# It is a `mkdir` lock with an owner pid, not a kernel lock. `mkdir` is the
# atomic part; the pid file exists so a killed agent's lock can be reclaimed
# instead of wedging every sibling for the full timeout. Those are two
# statements, and the gap between them used to be a hole: the reaper read
# `owner.pid` before the acquirer had written it, called the live lock stale,
# `rm -rf`ed it and took it, so two runners both believed they held the mutex.
# Three things close it as far as shell allows:
#
#   * a lock directory with no owner.pid yet is treated as LIVE, not stale,
#     until it is older than GODOT_LOCK_CLAIM_GRACE — the acquirer names itself
#     in the very next statement, so anything younger is mid-acquisition;
#   * the claim is written with `set -C`, so the first writer wins and a second
#     runner cannot overwrite an owner already named; and
#   * the acquirer re-reads owner.pid and requires its own pid before it treats
#     the lock as held, so a runner whose directory was reclaimed underneath it
#     goes back to waiting instead of proceeding.
#
# The residual hole is a holder stopped (SIGSTOP, a laptop suspended, a
# pathological load spike) for longer than GODOT_LOCK_CLAIM_GRACE between
# creating the directory and naming itself in it. Nothing in POSIX shell closes
# that without a kernel lock, and `flock(1)` is not present on macOS. So this is
# not "two Godots cannot start"; it is "two Godots do not start unless a holder
# is frozen mid-acquisition for GODOT_LOCK_CLAIM_GRACE seconds". Every claim
# built on this mutex is bounded by that sentence.
#
# The lock stays a DIRECTORY at a fixed path on purpose. Worktrees sitting on
# older commits run their own copy of gates.sh, which takes the same
# /tmp/pod-godot.lock with `mkdir`. Switching the representation to a symlink or
# a flock'd regular file would be atomic in isolation and would silently stop
# serializing against every one of them.

GODOT_LOCK="${GODOT_LOCK:-/tmp/pod-godot.lock}"
GODOT_LOCK_TIMEOUT="${GODOT_LOCK_TIMEOUT:-1800}"
GODOT_LOCK_POLL="${GODOT_LOCK_POLL:-10}"
GODOT_LOCK_CLAIM_GRACE="${GODOT_LOCK_CLAIM_GRACE:-30}"
GODOT_LOCK_LABEL="${GODOT_LOCK_LABEL:-}"

godot_lock_say() {
	if [ -n "$GODOT_LOCK_LABEL" ]; then
		echo "[$GODOT_LOCK_LABEL] $*"
	else
		echo "$*"
	fi
}

godot_lock_owner() {
	cat "$GODOT_LOCK/owner.pid" 2>/dev/null || true
}

# Modification time in epoch seconds, or EMPTY if neither stat dialect answers.
# GNU first: BSD `stat -f` is filesystem-status with an entirely different
# format language, and `stat -f %m` SUCCEEDS on Linux printing a mount point.
# Empty means unknown, and nothing is ever reaped on unknown.
godot_lock_mtime() {
	local m
	m=$(stat -c %Y "$1" 2>/dev/null || true)
	case "$m" in '' | *[!0-9]*) m=$(stat -f %m "$1" 2>/dev/null || true) ;; esac
	case "$m" in '' | *[!0-9]*) m="" ;; esac
	echo "$m"
}

# A killed agent used to leave the lock held and wedge every sibling for the
# full timeout. The owner PID makes a dead holder's lock reclaimable — but only
# a holder PROVEN dead. Absent evidence is not evidence of death: a lock with no
# owner yet, or one this shell cannot date, is left alone.
godot_lock_reap_stale() {
	[ -d "$GODOT_LOCK" ] || return 0
	local owner mtime age
	owner=$(godot_lock_owner)
	if [ -z "$owner" ]; then
		mtime=$(godot_lock_mtime "$GODOT_LOCK")
		if [ -z "$mtime" ]; then
			return 0
		fi
		age=$(($(date +%s) - mtime))
		if [ "$age" -lt "$GODOT_LOCK_CLAIM_GRACE" ]; then
			return 0
		fi
		godot_lock_say "reaping unclaimed lock (no owner named after ${age}s)"
		rm -rf "$GODOT_LOCK"
		return 0
	fi
	if ! kill -0 "$owner" 2>/dev/null; then
		godot_lock_say "reaping stale lock (owner $owner is gone)"
		rm -rf "$GODOT_LOCK"
	fi
	return 0
}

# Removes the lock only if THIS process still owns it. An unconditional
# `rm -rf` on EXIT would delete a lock another process had legitimately
# reclaimed after reaping ours.
godot_lock_release() {
	[ -d "$GODOT_LOCK" ] || return 0
	if [ "$(godot_lock_owner)" = "$$" ]; then
		rm -rf "$GODOT_LOCK" 2>/dev/null || true
	fi
	return 0
}

# Names this process in a lock directory it has just created. `set -C` makes the
# write fail rather than clobber, so the first claimant wins; the re-read then
# rejects the case where our directory was reaped and rebuilt by someone else
# between the two. Returns non-zero for "I did not get it", never for "maybe".
godot_lock_claim() {
	(set -C; echo "$$" >"$GODOT_LOCK/owner.pid") 2>/dev/null || return 1
	[ "$(godot_lock_owner)" = "$$" ] || return 1
	return 0
}

# Blocks until the mutex is held, or returns 1 on timeout. Callers must treat a
# non-zero return as a failure: running Godot anyway is the contended run this
# exists to prevent.
godot_lock_acquire() {
	local waited=0
	godot_lock_say "waiting for godot lock ($GODOT_LOCK)..."
	while :; do
		godot_lock_reap_stale
		if mkdir "$GODOT_LOCK" 2>/dev/null && godot_lock_claim; then
			break
		fi
		if [ "$waited" -ge "$GODOT_LOCK_TIMEOUT" ]; then
			godot_lock_say "GODOT LOCK TIMEOUT after ${waited}s on $GODOT_LOCK"
			godot_lock_say "  Another worktree is running headless Godot. Refusing to start a"
			godot_lock_say "  second one: a contended run collects fewer scripts, and Gate L"
			godot_lock_say "  reads that as a silently-skipped test file and blames a healthy"
			godot_lock_say "  one. Wait for it, or remove the lock if its owner is gone."
			return 1
		fi
		sleep "$GODOT_LOCK_POLL"
		waited=$((waited + GODOT_LOCK_POLL))
	done
	trap 'godot_lock_release' EXIT
	godot_lock_say "godot lock acquired (waited ${waited}s)"
	return 0
}
