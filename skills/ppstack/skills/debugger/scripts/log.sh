#!/usr/bin/env bash
# Append a well-formed row to a debugger problems log (TSV).
# Usage: log.sh <logfile> <kind> <problem> <fix> <status> <target> [trace]
set -euo pipefail

if [ "$#" -lt 6 ] || [ "$#" -gt 7 ]; then
	printf 'usage: log.sh <logfile> <kind> <problem> <fix> <status> <target> [trace]\n' >&2
	exit 1
fi

logfile="$1"
shift
trace="${7:--}"

logdir="$(dirname "$logfile")"
if [ -n "$logdir" ] && [ "$logdir" != "." ] && [ ! -d "$logdir" ]; then
	mkdir -p "$logdir"
fi

if [ ! -f "$logfile" ]; then
	printf 'ts\tkind\tproblem\tfix\tstatus\ttarget\ttrace\n' > "$logfile"
fi

ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
# Cells stay on one line, and a cell a spreadsheet would parse as a
# formula (=, +, -, @) gets a leading quote so generated text cannot
# execute when a reviewer opens the file.
clean() {
	local v
	v=$(printf '%s' "$1" | tr '\t\n\r' '   ')
	if [ "$v" = "-" ]; then
		printf '%s' "$v"
		return
	fi
	case "$v" in
		=*|+*|-*|@*) printf "'%s" "$v" ;;
		*) printf '%s' "$v" ;;
	esac
}
printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\n' \
	"$ts" "$(clean "$1")" "$(clean "$2")" "$(clean "$3")" "$(clean "$4")" "$(clean "$5")" "$(clean "$trace")" \
	>> "$logfile"
