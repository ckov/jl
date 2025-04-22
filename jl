#!/bin/bash

DEFAULT_DIR=$HOME/journal

# Load .jlrc (silently ignore if missing)
source "$HOME/.jlrc" 2>/dev/null || true
#if [ -f "$HOME/.jlrc" ]; then
#    source "$HOME/.jlrc"
#else
    #echo "Warning: ~/.jlrc not found." >&2
#fi

# If not set, use env vars
#[[ -z "${DIR:-}" ]] && DIR=$JL_DIR
# below is same effect as above, but more efficient:
: "${DIR:=$JL_DIR}"
: "${FILE:=$JL_FILE}"
: "${COMMIT:=$JL_COMMIT}"
: "${PUSH:=$JL_PUSH}"
: "${VERBOSE:=$JL_VERBOSE}"
: "${QUIET:=$JL_QUIET}"

# If not set by env var either, use hard-coded default dir
: "${DIR:=$DEFAULT_DIR}"

# Get current date in ISO format (YYYY-MM-DD)
current_date=$(date +%F)
current_time=$(date +%H:%M:%S)

# If FILE is not set by now (.jlrc or env var), use default
: "${FILE:="$DIR/$(basename "$0").txt"}"

print_usage() {
	script=$(basename $0)
	cat <<EOF
$script is a simple journaling command. It saves quick notes along with timestamps.


Usage:

  \$ $script [options] ARG

  \$ $script [--file=/path/to/alt/file.txt] --list


Destination:

  Entries are by default saved in a text file named $(basename $FILE) located in the directory
  given by the configuration variable \$DIR (default: \$HOME/journal).
  This can be overridden with the --file option.


Types of entries:

  1) one-line entries are taken from arguments

    \$ $script "This is a one-line entry"

    or, equivalently (since multiple arguments are joined together):

    \$ $script This is a one-line entry


  2) multiple-line entries are taken from stdin

    \$ cat /path/to/some/file.txt | $script

    \$ $script <<EOF
    > This is line1.
    > This is line2.
    > EOF


Options:

  --list, -l	Lists all entries in the journal file.

  --verbose, -v	Prints status info to stderr

  --quiet, -q	Suppresses git output, and overrides verbose to false

  --file FILE, -f FILE	Overrides the output destination to the given file

  --location	Prints the location of the journal file

  --commit, -c	Override for the COMMIT configuration option;
  		Commits the entry (along with any other changes) in the git repo
  		(assuming the journal directory is a git repository)

  --push, -p	Override for the PUSH configuration option;
		Pushes the git repo (assuming the journal directory is a git repository)


Configuration variables:

  DIR
  FILE
  COMMIT
  PUSH
  VERBOSE
  QUIET
  

Environment variables:

  Prefix configuration variables above with "JL_", e.g. "JL_DIR"


Configuration/environment/options priority:

  1. options have the highest priority, they override all other values
  2. environemnt variables can be used to override configuration in .jlrc
  3. configuration variables in .jlrc are lowest priority; these are default values if no other values are specified
  
EOF
}


print_status() {
	message=$1
	[[ "$VERBOSE" == true ]] && echo "$message" >&2
}

commit_and_push() {
	if [ "$COMMIT" = true ]; then
		cd $DIR
		if [ "$QUIET" = true ]; then
		  git add . 1>/dev/null 2>&1
		  git commit -m "Auto commit by $0" 1>/dev/null 2>&1
		else
		  git add . 1>&2
		  git commit -m "Auto commit by $0" 1>&2
		fi
		print_status "Committed and pushed repository $DIR"
	fi
	if [ "$PUSH" = true ]; then
		cd $DIR
		if [ "$QUIET" = true ]; then
		  git push 1>/dev/null 2>&1
		else
		  git push 1>&2
		fi
		print_status "Pushed repository $DIR"
	fi
}


# GNU getopt is more powerful than built-in getopts
TEMP=$(getopt -o vf:dlcpqh --long verbose,file:,list,dir,location,commit,push,quiet,help -n "$0" -- "$@")

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
    -f|--file)
      FILE=$2
      shift 2
      ;;
    -l|--list)
      list_entries=true
      shift
      ;;
    -d|--dir)
      echo "$DIR"
      exit 0
      ;;
    --location)
      echo "$FILE" 
      exit 0
      ;;
    -c|--commit)
      COMMIT=true
      shift
      ;;
    -p|--push)
      PUSH=true
      shift
      ;;
    -q|--quiet)
      QUIET=true
      VERBOSE=false
      shift
      ;;
    -h|--help)
      print_usage
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
  cat $FILE
  exit 0
fi

exec >> $FILE
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
	print_status "Added a quick log to $FILE"
	commit_and_push
	exit 0
fi

# else: stdin provided => long log
echo
echo $time_head
cat
echo
echo "Added a multiline log to $FILE" >&2
commit_and_push
exit 0
