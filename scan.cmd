::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Copyright (c) 2020 David Allsopp Ltd.                                                          ::
:: Distributed under clauses 1 and 3 of BSD-3-Clause, see terms at the end of this file.          ::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
@setlocal
@echo off

if "%1" equ ":exe" goto exe
if "%1" equ ":lnk" goto lnk

:: .lnk files will be converted to magic files or native symlinks
for /f "delims=" %%f in ('dir /s/b/ar-d "%1\*.lnk" 2^>nul') do (
  if not exist "%%~dpnf" echo lnk:%%f
)

:: Junctions will be converted to magic files or native symlinks
:: Actual symlinks will be checked and may have .exe-tweaking
for /f "delims=" %%f in ('dir /s/b/al "%1" 2^>nul') do (
  if exist "%%f\*" (
    rem This is either a normal JUNCTION or a SYMLINKD
    echo symlink:%%f
  ) else (
    rem If the directory pointed to by a SYMLINKD doesn't exist, there'll
    rem be File Not Found on stderr. This is fine - it still means that
    rem the symlink was readable to Windows.
    dir "%%f" 2>nul | findstr "<" | findstr /V /L "<SYMLINK" > nul
    if not errorlevel 1 (
      echo junction:%%f
    ) else (
      echo symlink:%%f
    )
  )
)

:: Magic files will be checked and may be converted to native symlinks
for /f "delims=" %%f in ('dir /s/b/as-d "%1" 2^>nul') do (
  %SYSTEMROOT%\system32\find /v /c "" "%%f" | findstr /r " 1$" > nul
  if not errorlevel 1 (
    findstr /r "^!<symlink>" "%%f" > nul
    if not errorlevel 1 echo cookie:%%f
  )
)

goto :EOF

:exe
if exist "%2.exe" exit /b 1
goto :EOF

:lnk
if exist "%2" exit /b 1
goto :EOF

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Copyright (c) 2020 David Allsopp Ltd.                                                          ::
::                                                                                                ::
:: Redistribution and use in source and binary forms, with or without modification, are permitted ::
:: provided that the following two conditions are met:                                            ::
::     1. Redistributions of source code must retain the above copyright notice, this list of     ::
::        conditions and the following disclaimer.                                                ::
::     2. Neither the name of David Allsopp Ltd. nor the names of its contributors may be used to ::
::        endorse or promote products derived from this software without specific prior written   ::
::        permission.                                                                             ::
::                                                                                                ::
:: This software is provided by the Copyright Holder 'as is' and any express or implied           ::
:: warranties including, but not limited to, the implied warranties of merchantability and        ::
:: fitness for a particular purpose are disclaimed. In no event shall the Copyright Holder be     ::
:: liable for any direct, indirect, incidental, special, exemplary, or consequential damages      ::
:: (including, but not limited to, procurement of substitute goods or services; loss of use,      ::
:: data, or profits; or business interruption) however caused and on any theory of liability,     ::
:: whether in contract, strict liability, or tort (including negligence or otherwise) arising in  ::
:: any way out of the use of this software, even if advised of the possibility of such damage.    ::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
