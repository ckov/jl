# jl - simple journaling from the terminal

`jl` is a command for saving quick notes along with a timestamp to a text file.

The directory where the journal file is saved is configurable with the `$REPO` configuration parameter (default: `$HOME/journal`).

The journal file is named after the script name `$0`. By default this is `jl.txt`, or use a symlink for different files:
```console
$ ln -s /path/to/jl mylog
$ mylog --location
/path/to/repo/mylog.txt
```

Configuration parameters are customizable with `$HOME/.jlrc`.

## Example usage

Add a one-line entry:
```console
$ jl This is a one-line entry
```

Add a multi-line entry:
```console
$ jl <<EOF
This is a
multi-line
entry
EOF
```

List entries:
```console
$ jl -l
```
