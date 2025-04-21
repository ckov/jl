#!/bin/bash
DEFAULT_REPO=$HOME/jl
DEFAULT_COMMIT_AND_PUSH=false

# Load .jlrc (silently ignore if missing)
if [ -f "$HOME/.jlrc" ]; then
    source "$HOME/.jlrc"
else
    echo "Warning: ~/.jlrc not found. Using defaults data location: $DEFAULT_REPO." >&2
    REPO=$DEFAULT_REPO
    COMMIT_AND_PUSH=$DEFAULT_COMMIT_AND_PUSH
fi

# Get current date in ISO format (YYYY-MM-DD)
current_date=$(date +%F)
current_time=$(date +%H:%M:%S)

outfile="$REPO/$(basename "$0").txt"

commit_and_push() {
	if [ "$COMMIT_AND_PUSH" = true ]; then
	  cd $REPO
	  git add .
	  git commit -m "Auto commit by $0"
	  git push
	  echo "Committed and pushed repository $REPO" >&2
	fi
}

# GNU getopt is more powerful than built-in getopts
TEMP=$(getopt -o vlhd: --long verbose,list,help: -n "$0" -- "$@")

if [ $? != 0 ]; then
  echo "Terminating..." >&2
  exit 1
fi

eval set -- "$TEMP"

verbose=false
list_entries=false
directory=""

while true; do
  case "$1" in
    -v|--verbose)
      verbose=true
      shift
      ;;
    -l|--list)
      list_entries=true
      shift
      ;;
    -h|--help)
      echo "Usage: $0 [--verbose] [--list]"
      exit 0
      ;;
    --)
      shift
      break
      ;;
    *)
      echo "Internal error!"
      exit 1
      ;;
  esac
done

# Shift processed options out of arguments
#shift $((OPTIND-1))

if [ "$list_entries" = true ]; then
  echo "Listing entries..." >&2
  cat $outfile
  exit 0
fi

exec >> $outfile
exec 2> /dev/stderr

time_head="[$current_date $current_time]" 

# if nothing in stdin
if [ -t 0 ]; then
	short_input=$@
	if [ $# -eq 0 ]; then
	    echo "Error: No argument provided" >&2
	    echo "Usage: $0 \"text to append\"" >&2
	    exit 1
	fi
	echo "$time_head $short_input"
	echo "Added a quick log to $outfile" >&2
	commit_and_push
	exit 0
fi

# else: stdin provided => long log
echo
echo $time_head
cat
echo
echo "Added a multiline log to $outfile" >&2
commit_and_push
exit 0
