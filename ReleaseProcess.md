# Release Process

1. Update version number in `README.md`, line 202.
2. Update version number in `Sources/LFSPointersExecutable/main.swift`, line 42.
3. Update version number in `LFSPointers.1.md`.
4. Create GitHub release, and wait for builds to finish.
5. Update version number in `Scripts/installDeb.sh`.
6. Update version number in [lfs-pointers.rb](https://github.com/LebJe/homebrew-formulae/blob/master/lfs-pointers.rb).
7. Build Homebrew bottle.
