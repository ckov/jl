# jl - simple journaling from the terminal

`jl` is a command for saving quick notes along with a timestamp to a text file.

The location of the journal file is configurable with the `$REPO` configuration parameter (default: `$HOME/journal`).

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
