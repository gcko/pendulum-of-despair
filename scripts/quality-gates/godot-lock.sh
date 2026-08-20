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
# is what makes the floor safe to gate on (#433).
#
# Concurrent imports of one project are separately destructive: two Godots
# importing the same tree write `valid=false` into the .import sidecars, which
# sits beside each asset and survives deleting `.godot`.
#
# gates.sh held this lock and pre-push did not, which is exactly how the two came
# to disagree about one clean tree. One implementation, both callers, so they
# cannot drift apart in what they serialize or how long they wait.

GODOT_LOCK="${GODOT_LOCK:-/tmp/pod-godot.lock}"
GODOT_LOCK_TIMEOUT="${GODOT_LOCK_TIMEOUT:-1800}"
GODOT_LOCK_LABEL="${GODOT_LOCK_LABEL:-}"

godot_lock_say() {
	if [ -n "$GODOT_LOCK_LABEL" ]; then
		echo "[$GODOT_LOCK_LABEL] $*"
	else
		echo "$*"
	fi
}

# A killed agent used to leave the lock held and wedge every sibling for the
# full timeout. The owner PID makes a dead holder's lock reclaimable.
godot_lock_reap_stale() {
	[ -d "$GODOT_LOCK" ] || return 0
	local owner
	owner=$(cat "$GODOT_LOCK/owner.pid" 2>/dev/null || echo "")
	if [ -z "$owner" ] || ! kill -0 "$owner" 2>/dev/null; then
		godot_lock_say "reaping stale lock (owner ${owner:-unknown} is gone)"
		rm -rf "$GODOT_LOCK"
	fi
	return 0
}

# Removes the lock only if THIS process still owns it. An unconditional
# `rm -rf` on EXIT would delete a lock another process had legitimately
# reclaimed after reaping ours.
godot_lock_release() {
	[ -d "$GODOT_LOCK" ] || return 0
	local owner
	owner=$(cat "$GODOT_LOCK/owner.pid" 2>/dev/null || echo "")
	if [ "$owner" = "$$" ]; then
		rm -rf "$GODOT_LOCK" 2>/dev/null || true
	fi
	return 0
}

# Blocks until the mutex is held, or returns 1 on timeout. Callers must treat a
# non-zero return as a failure: running Godot anyway is the contended run this
# exists to prevent.
godot_lock_acquire() {
	local waited=0
	godot_lock_say "waiting for godot lock ($GODOT_LOCK)..."
	godot_lock_reap_stale
	until mkdir "$GODOT_LOCK" 2>/dev/null; do
		sleep 10
		waited=$((waited + 10))
		godot_lock_reap_stale
		if [ "$waited" -gt "$GODOT_LOCK_TIMEOUT" ]; then
			godot_lock_say "GODOT LOCK TIMEOUT after ${waited}s on $GODOT_LOCK"
			godot_lock_say "  Another worktree is running headless Godot. Refusing to start a"
			godot_lock_say "  second one: a contended run collects fewer scripts, and Gate L"
			godot_lock_say "  reads that as a silently-skipped test file and blames a healthy"
			godot_lock_say "  one. Wait for it, or remove the lock if its owner is gone."
			return 1
		fi
	done
	echo "$$" >"$GODOT_LOCK/owner.pid"
	trap 'godot_lock_release' EXIT
	godot_lock_say "godot lock acquired (waited ${waited}s)"
	return 0
}
