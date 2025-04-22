#!/bin/bash
DEFAULT_REPO=$HOME/jl

# Load .jlrc (silently ignore if missing)
if [ -f "$HOME/.jlrc" ]; then
    source "$HOME/.jlrc"
else
    echo "Warning: ~/.jlrc not found. Using hard-coded defaults, and directory location $DEFAULT_REPO" >&2
    REPO=$DEFAULT_REPO
    COMMIT_AND_PUSH=false
    VERBOSE=false
    QUIET=false
fi

# Get current date in ISO format (YYYY-MM-DD)
current_date=$(date +%F)
current_time=$(date +%H:%M:%S)

outfile="$REPO/$(basename "$0").txt"

print_status() {
	message=$1
	[[ "$VERBOSE" == true ]] && echo "$message" >&2
}

commit_and_push() {
	if [ "$COMMIT_AND_PUSH" = true ]; then
	  cd $REPO
	  if [ "$QUIET" = true ]; then
		  git add . 1>/dev/null 2>&1
		  git commit -m "Auto commit by $0" 1>/dev/null 2>&1
		  git push 1>/dev/null 2>&1
	  else
		  git add . 1>&2
		  git commit -m "Auto commit by $0" 1>&2
		  git push 1>&2
          fi
	  print_status "Committed and pushed repository $REPO"
	fi
}


# GNU getopt is more powerful than built-in getopts
TEMP=$(getopt -o vlqh: --long verbose,list,location,quiet,help: -n "$0" -- "$@")

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
      VERBOSE=true
      shift
      ;;
    -l|--list)
      list_entries=true
      shift
      ;;
    --location)
      echo "$outfile" 
      exit 0
      ;;
    -q|--quiet)
      QUIET=true
      VERBOSE=false
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
  print_status "Listing entries..."
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
	print_status "Added a quick log to $outfile"
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
