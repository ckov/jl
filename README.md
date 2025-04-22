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

The directory where the journal file is saved is configurable with the `$REPO` configuration parameter (default: `$HOME/journal`).

The journal file is named after the script name `$0`, therefore by default  this is `jl.txt`. 

Create a symlink for different files:
```console
$ ln -s /path/to/jl mylog
$ mylog --location
/path/to/repo/mylog.txt
```

## Configuration

Configuration parameters are customizable with `$HOME/.jlrc`. An example `.jlrc` file is found in this repository.

