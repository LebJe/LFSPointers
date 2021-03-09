% LFSPOINTERS(1) Version 4.0.0 | LFSPointers Documentation

NAME
====

**LFSPointers** — Replaces large files in a Git repository directory with Git LFS pointers.

SYNOPSIS
========

|  **LFSPointers** [\--verbose] [\--silent] [\--recursive] [\--all] [\--json] [\--enable-color] [\--disable-color] [\--json-format <json-format>] [\--backup-directory <backup-directory>] \<directory\> [\<files\> ...]

DESCRIPTION
===========

Let's imagine you have a directory of large `png` and `jpg` files called `Project Logos`. If you wanted to convert the files with the extension `png` to LFS pointers, you could run:

```bash
$ LFSPointers path/to/Project\ Logos path/to/Project\ Logos/*.png
```

The first argument is the path to the directory, and the second argument is a regular expression used to search for `png` files that your shell will convert to a list of filenames.\
But wait! It's not safe to run random programs on your computer! To backup your files just in case something goes wrong, add `-b path/to/backup-directory` to the previous command, like this:

```bash
$ LFSPointers -b path/to/backup-directory path/to/Project\ Logos path/to/Project\ Logos/*.png
```

If you want to generate JSON output instead, run:

```bash
$ LFSPointers --json path/to/Project\ Logos path/to/Project\ Logos/*.png
```

Options
-------

-v, \--verbose

: Whether to display verbose output.

\--silent               

: Don't print to standard output or standard error.

-r, \--recursive         

: Repeat this process in all directories.

-a, \--all               

: Convert all files to pointers (USE WITH CAUTION!).

\-j, \--json                  

: Sends JSON to standard output. The JSON is structured as shown above. This will automatically enable \--silent.

\--enable-color/\--disable-color

: Whether to send colorized output to the terminal or not. (default: true)

\--json-format, \-jf <json-format>

: The format in which JSON is printed. You can choose either "compact" or "formatted". (default: compact)

-b, \--backup-directory <backup-directory>

: The directory files will be copied to before being processed. If no directory is specified, no files will be copied. (default: nil)

\--version

: Show the version.

-h, \--help              

: Show help information.

BUGS
====

See GitHub Issues: <https://github.com/LebJe/LFSPointers/issues>

AUTHOR
======

LebJe <51171427+LebJe@users.noreply.github.com>
