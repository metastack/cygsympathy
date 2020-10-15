Cygwin Symlink emPathy
======================

[Cygwin](https://cygwin.com) supports various implementations of symbolic links (full details [in
its manual](https://www.cygwin.com/cygwin-ug-net/using.html#pathnames-symlinks)). For various
sensible reasons, Cygwin does not use [NTFS Symbolic Links](https://docs.microsoft.com/en-us/windows/win32/fileio/symbolic-links)
by default. However, its support for opting in to using them has some shortcomings:

- Cygwin’s setup program does not create them;
- There are (reasonable) scenarios where Cygwin falls back to its own symlink support. `tar`, for
  example, will often create a symlink before the target file exists, which makes creating an NTFS
  symlink difficult since the target type is not known;
- At present (October 2020), Docker for Windows does not support the `IO_REPARSE_TAG_LX_SYMLINK`
  reparse tag which Cygwin 3.1.5 started using by default to store symlinks.

This package provides a script intended to be installed as a permanent post-install script (but
which can be invoked manually). It scans the Cygwin root directory for junctions, NTFS symlinks,
magic files and shortcuts and performs the following conversions:

- NTFS symbolic links are used wherever possible;
- Symlinks to `/proc/cygdrive` are translated to the appropriate Windows path and so will appear
  under the normal `/cygdrive/` mount. For NTFS Symbolic Links, this is fine since the actual link
  will contain, for example, `C:\`. The reason to use `/proc/cygdrive` normally is for the case
  where a user changes the mount point for `cygdrive` in `/etc/fstab`, but for NTFS Symbolic Links,
  the target will “magically” update;
- All other links to `/proc` are represented with magic files (files with the system attribute
  beginning `!<symlink>`). This file is used at present to workaround the limitation in Docker;
- The symbolic link is renamed to have a `.exe` extension if the target requires one. Likewise
  `.exe` is added to the target if the target requires it. For example, `ln -sf xz /bin/xzcat` will
  be changed so that `/bin/xzcat.exe` is a symlink to `xz.exe`. This ensures `xzcat` can be executed
  from CMD in the same way as `xz`.
