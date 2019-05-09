@echo off


SET WIN10X86PATH=C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\VC\Auxiliary\Build\vcvars32.bat
SET WIN10X64PATH=C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\VC\Auxiliary\Build\vcvars64.bat
SET WIN8PATH=C:\Program Files (x86)\Microsoft Visual Studio 14.0\VC\vcvarsall.bat

rem set PLATFORMID=x86
rem set PLATFORMID=x64
rem set APPVEYOR_BUILD_WORKER_IMAGE=Visual Studio 2017
rem  set APPVEYOR_BUILD_WORKER_IMAGE=Visual Studio 2015

rem SET WIN10X86PATH=D:\MVS2017\VC\Auxiliary\Build\vcvars32.bat
rem SET WIN10X64PATH=D:\MVS2017\VC\Auxiliary\Build\vcvars64.bat
rem SET WIN8PATH=D:\MVS2015\VC\vcvarsall.bat

git clone --recurse-submodules -j8 https://github.com/MediaArea/MediaInfo.git 
IF %ERRORLEVEL% NEQ 0 GOTO :exitError
git clone --recurse-submodules -j8 https://github.com/MediaArea/zlib.git
IF %ERRORLEVEL% NEQ 0 GOTO :exitError
git clone --recurse-submodules -j8 https://github.com/MediaArea/ZenLib.git
IF %ERRORLEVEL% NEQ 0 GOTO :exitError
git clone --recurse-submodules -j8 https://github.com/MediaArea/MediaInfoLib.git
IF %ERRORLEVEL% NEQ 0 GOTO :exitError
git clone --recurse-submodules -j8 https://github.com/wxWidgets/wxWidgets.git
IF %ERRORLEVEL% NEQ 0 GOTO :exitError


if "%APPVEYOR_BUILD_WORKER_IMAGE%"=="Visual Studio 2017" if "%PLATFORMID%"=="x86"  GOTO :Win10x86
if "%APPVEYOR_BUILD_WORKER_IMAGE%"=="Visual Studio 2017" if "%PLATFORMID%"=="x64"  GOTO :Win10x64
if "%APPVEYOR_BUILD_WORKER_IMAGE%"=="Visual Studio 2015" if "%PLATFORMID%"=="x86"  GOTO :Win8x86
if "%APPVEYOR_BUILD_WORKER_IMAGE%"=="Visual Studio 2015" if "%PLATFORMID%"=="x64"  GOTO :Win8x64

ECHO "Error! APPVEYOR_BUILD_WORKER_IMAGE is not set %APPVEYOR_BUILD_WORKER_IMAGE%"
GOTO :exitError

REM ********************* Win10x86 *******************
:Win10x86
set BUILDPROFILE=Win10x86
CALL "%WIN10X86PATH%"
IF %ERRORLEVEL% NEQ 0 GOTO :exitError
pushd  .\zlib\contrib\masmx86
ml /coff /safeseh /Zi /c /Flmatch686.lst match686.asm
IF %ERRORLEVEL% NEQ 0 GOTO :exitError
ml /coff /safeseh /Zi /c /Flinffas32.lst inffas32.asm
IF %ERRORLEVEL% NEQ 0 GOTO :exitError
popd 
msbuild ".\MediaInfo\Project\MSVC2015\CLI\MediaInfo.vcxproj" -maxcpucount:4 /t:Build /p:platform=x86 /p:configuration=Release
IF %ERRORLEVEL% NEQ 0 GOTO :exitError
GOTO :envSuccess

REM ********************* Win10x64 *******************
:Win10x64
set BUILDPROFILE=Win10x64
CALL "%WIN10X64PATH%"
IF %ERRORLEVEL% NEQ 0 GOTO :exitError
pushd .\zlib\contrib\masmx64
IF %ERRORLEVEL% NEQ 0 GOTO :exitError
ml64 /nologo /Zi /c /Flinffasx64 inffasx64.asm
IF %ERRORLEVEL% NEQ 0 GOTO :exitError
ml64 /nologo /Zi /c /Flgvmat64 gvmat64.asm
popd
msbuild ".\MediaInfo\Project\MSVC2015\CLI\MediaInfo.vcxproj" -maxcpucount:4 /t:Build /p:platform=x64 /p:configuration=Release
IF %ERRORLEVEL% NEQ 0 GOTO :exitError
GOTO :envSuccess
 
REM ********************* Win8x86 *******************
:Win8x86
set BUILDPROFILE=Win8x86
CALL "%WIN8PATH%" x86
IF %ERRORLEVEL% NEQ 0 GOTO :exitError
pushd  .\zlib\contrib\masmx86
ml /coff /safeseh /Zi /c /Flmatch686.lst match686.asm
IF %ERRORLEVEL% NEQ 0 GOTO :exitError
ml /coff /safeseh /Zi /c /Flinffas32.lst inffas32.asm
IF %ERRORLEVEL% NEQ 0 GOTO :exitError
popd 
msbuild ".\MediaInfo\Project\MSVC2015\CLI\MediaInfo.vcxproj" -maxcpucount:4 /t:Build /p:platform=x86 /p:configuration=Release
IF %ERRORLEVEL% NEQ 0 GOTO :exitError
GOTO :envSuccess
  
REM ********************* Win8x64 *******************
:Win8x64
set BUILDPROFILE=Win8x64
CALL "%WIN8PATH%" x86_amd64
IF %ERRORLEVEL% NEQ 0 GOTO :exitError
pushd .\zlib\contrib\masmx64
IF %ERRORLEVEL% NEQ 0 GOTO :exitError
ml64 /nologo /Zi /c /Flinffasx64 inffasx64.asm
IF %ERRORLEVEL% NEQ 0 GOTO :exitError
ml64 /nologo /Zi /c /Flgvmat64 gvmat64.asm
popd
msbuild ".\MediaInfo\Project\MSVC2015\CLI\MediaInfo.vcxproj" -maxcpucount:4 /t:Build /p:platform=x64 /p:configuration=Release
IF %ERRORLEVEL% NEQ 0 GOTO :exitError
GOTO :envSuccess

:envSuccess


GOTO :exitSuccess

:exitError
	echo Error!
	exit 1
GOTO :exit1
	
:exitSuccess
	echo Success!
:exit1