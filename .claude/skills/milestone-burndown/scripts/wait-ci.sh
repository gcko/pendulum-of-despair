#!/usr/bin/env bash
# Wait for a PR's CI to finish, with guards so the wait can never hang.
#
#   bash wait-ci.sh <pr> [expected-head-sha] [timeout-minutes]
#
# Run it with run_in_background: it always exits, and the harness wakes the
# caller on exit. Every poll prints one status line, so the output file shows
# progress while it runs.
#
# Exit codes:
#   0  every check on the head commit passed (SUCCESS, NEUTRAL or SKIPPED)
#   1  at least one check failed; the failing checks are printed
#   2  gh failed 3 polls in a row; the last error is printed, never discarded
#   3  deadline reached with checks still pending
#   4  the PR head is not the expected SHA (someone pushed; re-run for the new head)
#   5  no checks registered on the head within 10 minutes
#   64 usage error
set -u

pr="${1:-}"
expected="${2:-}"
timeout_min="${3:-45}"
interval="${WAIT_CI_INTERVAL:-30}"

if [ -z "$pr" ] || ! [ "$timeout_min" -gt 0 ] 2>/dev/null; then
	echo "usage: wait-ci.sh <pr> [expected-head-sha] [timeout-minutes]" >&2
	exit 64
fi

start=$(date +%s)
deadline=$((start + timeout_min * 60))
no_checks_deadline=$((start + 600))
errors=0

# One line per check: <bucket> <name>. Bucket is pending, pass or fail.
# CheckRun entries carry status/conclusion; StatusContext entries carry state.
jq_classify='
  .headRefOid as $h
  | "HEAD \($h)",
    (.statusCheckRollup[]
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

	if ! out=$(gh pr view "$pr" --json headRefOid,statusCheckRollup -q "$jq_classify" 2>&1); then
		errors=$((errors + 1))
		echo "$stamp gh error ($errors/3): $out"
		if [ "$errors" -ge 3 ]; then
			echo "RESULT gh-error: gh failed 3 polls in a row" >&2
			exit 2
		fi
	else
		errors=0
		head=$(printf '%s\n' "$out" | sed -n 's/^HEAD //p')
		checks=$(printf '%s\n' "$out" | command grep -v '^HEAD ' || true)

		if [ -n "$expected" ] && [ "${head#"$expected"}" = "$head" ]; then
			echo "RESULT head-moved: head is $head, expected $expected" >&2
			exit 4
		fi

		total=$(printf '%s\n' "$checks" | command grep -c . || true)
		pending=$(printf '%s\n' "$checks" | command grep -c '^pending ' || true)
		failed=$(printf '%s\n' "$checks" | command grep '^fail ' || true)
		echo "$stamp head ${head:0:8} checks=$total pending=$pending failed=$(printf '%s' "$failed" | command grep -c . || true)"

		if [ -n "$failed" ]; then
			printf '%s\n' "$failed"
			echo "RESULT fail" >&2
			exit 1
		fi
		if [ "$total" -eq 0 ]; then
			if [ "$now" -ge "$no_checks_deadline" ]; then
				echo "RESULT no-checks: nothing registered on ${head:0:8} in 10 minutes" >&2
				exit 5
			fi
		elif [ "$pending" -eq 0 ]; then
			printf '%s\n' "$checks"
			echo "RESULT pass ($total checks on $head)"
			exit 0
		fi
	fi

	if [ "$now" -ge "$deadline" ]; then
		echo "RESULT timeout: still pending after ${timeout_min}m" >&2
		exit 3
	fi
	sleep "$interval"
done
