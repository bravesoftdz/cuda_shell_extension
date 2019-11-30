@echo off & setlocal

::------------------------------------------------------------------------------
:: Basic configuration
::------------------------------------------------------------------------------
::Path for temporary elevation script
set "ElevateScript=%Temp%\ElevateCudaTextShellInstaller.vbs"

::Name of context menu handler DLL file
set "ShellHandler=cudatext_shell64.dll"


::------------------------------------------------------------------------------
:: Startup sequence
::------------------------------------------------------------------------------
::Set working directory to script's path
pushd "%~dp0"

::Check for admin permissions and restart elevated if required
call :CheckForAdminPermissions || (
  call :RestartElevated "%~f0"
  goto :Terminate
)


::------------------------------------------------------------------------------
:: Shell context menu handler installation
::------------------------------------------------------------------------------
regsvr32 /s "%CD%\%ShellHandler%"

::Clean up
del "%ElevateScript%" 1>NUL 2>&1


::------------------------------------------------------------------------------
:: Script termination
::------------------------------------------------------------------------------

:Terminate
popd
exit /b 0



::==============================================================================
:: Subroutines
::==============================================================================

:CheckForAdminPermissions
  net session 1>NUL 2>&1
  if ERRORLEVEL 1 exit /b 1
exit /b 0


:RestartElevated
  ::Get system's ANSI and OEM code page and set console's code page to ANSI code page
  ::This is required if this script is stored in a path that contains characters
  ::with different code points in those code pages.
  for /f "tokens=2 delims==" %%a in ('wmic OS get CodeSet /format:list') do set /a "ACP=%%~a"
  for /f "tokens=2 delims=.:" %%a in ('chcp') do set /a "OEMCP=%%a"
  if "%ACP%" neq "" if "%ACP%" neq "0" chcp %ACP% > NUL

  > "%ElevateScript%" echo.Set objShell = CreateObject("Shell.Application")
  >>"%ElevateScript%" echo.
  >>"%ElevateScript%" echo.strApplication = "cmd.exe"
  >>"%ElevateScript%" echo.strArguments   = "/c """"%~1"" %~2"""
  >>"%ElevateScript%" echo.
  >>"%ElevateScript%" echo.objShell.ShellExecute strApplication, strArguments, "", "runas", 1

  ::Restore OEM code page
  if "%OEMCP%" neq "" if "%OEMCP%" neq "0" chcp %OEMCP% > NUL

  cscript /nologo "%ElevateScript%"
exit /b 0
