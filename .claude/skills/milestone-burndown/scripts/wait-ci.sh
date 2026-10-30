#!/usr/bin/env bash
# Wait for a PR's CI to finish, with guards so the wait can never hang.
#
#   bash wait-ci.sh <pr> [expected-head-sha] [timeout-minutes] [min-checks]
#
# Run it with run_in_background: it always exits, and the harness wakes the
# caller on exit. Every poll prints one status line, so the output file shows
# progress while it runs.
#
# A pass needs every check on the head to have passed on two polls at least
# 60 seconds apart, and at least <min-checks> checks (default 1). That gives a
# workflow that registers late time to appear. It does not prove that every
# workflow ran: compare the workflow list before you trust a pass
# (stack-and-merge.md section 6 step 5).
#
# Exit codes:
#   0  every check on the head passed (SUCCESS, NEUTRAL or SKIPPED)
#   1  at least one check failed; the failing checks are printed
#   2  gh failed or stalled on 3 polls in a row; the last error is printed
#   3  deadline reached with checks still pending
#   4  the PR head is not the expected SHA (someone pushed; re-run for the new head)
#   5  no checks registered on the head within 10 minutes (or by the deadline)
#   64 usage error
set -u

pr="${1:-}"
expected=$(printf '%s' "${2:-}" | tr 'A-F' 'a-f')
timeout_min="${3:-45}"
min_checks="${4:-1}"
interval="${WAIT_CI_INTERVAL:-30}"
call_limit="${WAIT_CI_CALL_LIMIT:-60}"
settle=60

is_pos_int() { [ "$1" -gt 0 ] 2>/dev/null; }
if [ -z "$pr" ] || ! is_pos_int "$timeout_min" || ! is_pos_int "$min_checks" ||
	! is_pos_int "$interval" || ! is_pos_int "$call_limit"; then
	echo "usage: wait-ci.sh <pr> [expected-head-sha] [timeout-minutes] [min-checks]" >&2
	echo "       WAIT_CI_INTERVAL and WAIT_CI_CALL_LIMIT must be positive integers (seconds)" >&2
	exit 64
fi

# gh has no timeout of its own, so a stalled connection would block a poll,
# and with it the deadline, forever. Every call gets a hard limit.
if command -v timeout >/dev/null 2>&1; then
	limited() { timeout "$call_limit" "$@"; }
elif command -v gtimeout >/dev/null 2>&1; then
	limited() { gtimeout "$call_limit" "$@"; }
else
	limited() { perl -e 'alarm shift; exec @ARGV or die "exec: $!\n"' "$call_limit" "$@"; }
fi

errf=$(mktemp "${TMPDIR:-/tmp}/wait-ci-err.XXXXXX") || exit 2
trap 'rm -f "$errf"' EXIT

start=$(date +%s)
deadline=$((start + timeout_min * 60))
no_checks_deadline=$((start + 600))
[ "$no_checks_deadline" -gt "$deadline" ] && no_checks_deadline=$deadline
errors=0
passed_since=""

# One line per check: <bucket> <name>. Bucket is pending, pass or fail.
# CheckRun entries carry status/conclusion; StatusContext entries carry state.
jq_classify='
  .headRefOid as $h
  | "HEAD \($h)",
    ((.statusCheckRollup // [])[]
     | (.name // .context) as $n
     | (if .__typename == "StatusContext" then
          (if .state == "SUCCESS" then "pass"
           elif (.state == "PENDING" or .state == "EXPECTED") then "pending"
           else "fail" end)
        else
          (if .status != "COMPLETED" then "pending"
           elif (.conclusion == "SUCCESS" or .conclusion == "NEUTRAL" or .conclusion == "SKIPPED") then "pass"
           else "fail" end)
        end) as $b
     | "\($b) \($n)")'

while :; do
	now=$(date +%s)
	stamp="$(date '+%H:%M:%S') +$(((now - start) / 60))m"

	# stderr goes to its own file: a warning on a successful call must never
	# be read as a check.
	if ! out=$(limited gh pr view "$pr" --json headRefOid,statusCheckRollup -q "$jq_classify" 2>"$errf"); then
		errors=$((errors + 1))
		err=$(tr '\n' ' ' <"$errf")
		echo "$stamp gh error or stall ($errors/3): ${err:-no output (killed after ${call_limit}s?)}"
		passed_since=""
		if [ "$errors" -ge 3 ]; then
			echo "RESULT gh-error: gh failed or stalled on 3 polls in a row" >&2
			exit 2
		fi
	else
		errors=0
		head=$(printf '%s\n' "$out" | sed -n 's/^HEAD //p' | head -1)
		checks=$(printf '%s\n' "$out" | command grep -E '^(pass|pending|fail) ' || true)

		if [ -n "$expected" ] && [ "${head#"$expected"}" = "$head" ]; then
			echo "RESULT head-moved: head is ${head:-unknown}, expected $expected" >&2
			exit 4
		fi

		total=$(printf '%s\n' "$checks" | command grep -c . || true)
		pending=$(printf '%s\n' "$checks" | command grep -c '^pending ' || true)
		failed=$(printf '%s\n' "$checks" | command grep '^fail ' || true)
		nfailed=$(printf '%s' "$failed" | command grep -c . || true)
		echo "$stamp head ${head:0:8} checks=$total pending=$pending failed=$nfailed"

		if [ -n "$failed" ]; then
			printf '%s\n' "$failed"
			echo "RESULT fail" >&2
			exit 1
		fi
		if [ "$total" -eq 0 ]; then
			passed_since=""
			if [ "$now" -ge "$no_checks_deadline" ]; then
				echo "RESULT no-checks: nothing registered on ${head:0:8} by +$(((now - start) / 60))m" >&2
				exit 5
			fi
		elif [ "$pending" -eq 0 ] && [ "$total" -ge "$min_checks" ]; then
			if [ -z "$passed_since" ]; then
				passed_since=$now
			elif [ $((now - passed_since)) -ge "$settle" ]; then
				printf '%s\n' "$checks"
				echo "RESULT pass ($total checks on $head)"
				exit 0
			fi
		else
			passed_since=""
		fi
	fi

	if [ "$now" -ge "$deadline" ]; then
		echo "RESULT timeout: still pending after ${timeout_min}m" >&2
		exit 3
	fi
	# Once everything has passed, the confirming poll comes after the settle
	# window, however short the interval is.
	if [ -n "$passed_since" ] && [ "$interval" -lt "$settle" ]; then
		sleep $((settle - (now - passed_since)))
	else
		sleep "$interval"
	fi
done
