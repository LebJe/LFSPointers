# Release Process

1. Update version number in `README.md`, line 202.
2. Update version number in `Sources/LFSPointersExecutable/main.swift`, line 42.
3. Create GitHub release, and wait for builds to finish.
3. Update version number in `Scripts/installDeb.sh`.
4. Update version number in [lfs-pointers.rb](https://github.com/LebJe/homebrew-formulae/blob/master/lfs-pointers.rb).
5. Update version number in `LFSPointers.1.md`.
6. Build Homebrew bottle.
