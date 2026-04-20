@echo off
setlocal

if exist "%ProgramFiles%\Git\bin\bash.exe" (
  set "BASH_EXE=%ProgramFiles%\Git\bin\bash.exe"
) else (
  for %%I in (bash.exe) do set "BASH_EXE=%%~$PATH:I"
)

if not defined BASH_EXE (
  echo Error: bash was not found. Install Git for Windows or add bash.exe to PATH. 1>&2
  exit /b 1
)

set "MSYS2_ARG_CONV_EXCL=*"
"%BASH_EXE%" "%~dp0agency" %*
