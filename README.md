# jl - simple journaling from the terminal

`jl` is a command for saving quick notes along with a timestamp to a text file.

## Example usage

Add a one-line entry by passing arguments:
```console
$ jl This is a one-line entry
```

Use stdin to create a multi-line entry:
```console
$ jl <<EOF
> This is a
> multi-line
> entry
> EOF
```

List entries:
```console
$ jl -l
[2025-04-21 19:49:15] This is a one-line entry

[2025-04-21 19:49:38]
This is a
multi-line
entry

```

## Journal file location

The directory where the journal file is saved is configurable with the `$DIR` configuration parameter (default: `$HOME/journal`).

The journal file is named after the script name `$0`, therefore by default this is `jl.txt`. 

Create a symlink for different files:
```console
$ ln -s /path/to/jl mylog
$ mylog --location
/path/to/repo/mylog.txt
```

The above shows a possible use where different journal files are saved in the same directory. For cases where this use case does not work (e.g. you have different journals in different repositories), you can specify the full path of the journal file, overriding the directory location. This can be done explicitly with a `--file=FILE` option, or with an environment variable:
```console
$ JL_FILE=/path/to/alt/file.txt jl [...]
```
You can turn the above into a bash alias.

## Configuration

Configuration parameters are customizable with `$HOME/.jlrc`. An example `.jlrc` file is found in this repository.

The configuration supports the following parameters:
  DIR,
  FILE,
  VERBOSE,
  QUIET,
  COMMIT,
  PUSH.
Each of these prefixed with "JL_" can be used as an environment variable (e.g. `JL_VERBOSE`).

Set the boolean parameters to 'true' to turn them on. For example, `QUIET=true` has the same effect as the command flag `--quiet`.

Environment variables (e.g. `JL_FILE`) have precendence over configuration parameters in `.jlrc` (e.g. `FILE`).

Command options (e.g. `--file`) have precendece over environment variables (e.g. `JL_FILE`).

## Parameters interference

If the `FILE` parameter is set (or the `JL_FILE` env var, or the `--file` option), then `DIR` is ignored (as well as its relatives `JL_DIR` and `--dir`).

In quiet mode (`QUIET=true` / `JL_QUIET=true` / `--quiet`), `VERBOSE` is ignored and set to false (as well as `JL_VERBOSE` and `--verbose`).

Please note that `COMMIT` and `PUSH` are mutually independent: the `PUSH` will only push previously committed changes. In order to commit and push on each entry, set them both to true. To do it manually, you can use the two short options: `jl -cp [...]`.

## ARGS vs stdin

ARGS are only looked at if nothing came through stdin. Every entry is either one-line (ARGS) or multi-line (stdin), and stdin/multi-line have precencence.
