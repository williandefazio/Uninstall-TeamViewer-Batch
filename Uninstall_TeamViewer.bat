@echo off
tasklist /FI "IMAGENAME eq TeamViewer.exe" 2>NUL | find /I /N "TeamViewer.exe">NUL
if "%ERRORLEVEL%"=="0" (GOTO :KILL) ELSE (GOTO :REMOVEMSI)

:KILL
taskkill /f /im TeamViewer.exe
TIMEOUT 2
GOTO :REMOVEMSI

:REMOVEMSI
wmic product where vendor="TeamViewer"
if not "%errorlevel%"=="0" GOTO :CHECKOS
for /f "tokens=2 delims==" %%f in ('wmic product Where "vendor like 'TeamViewer'" get IdentifyingNumber /value ^| find "="') do set "id=%%f"
msiexec.exe /x "%id%" /qn
GOTO :CHECKOS

:CHECKOS
reg Query "HKLM\Hardware\Description\System\CentralProcessor\0" | find /i "x86" > NUL && set OS=32BIT || set OS=64BIT

if %OS%==32BIT goto :UNINSTALL32
if %OS%==64BIT goto :UNINSTALL64

:UNINSTALL64
cd\
Set "OLD64=C:\Program Files (x86)\TeamViewer\Version*"
IF EXIST "%OLD64%" (GOTO :PREVIOUS64) ELSE (GOTO :REMOVE64)

:UNINSTALL32
cd\
Set "OLD32=C:\Program Files\TeamViewer\Version*"
IF EXIST "%OLD32%" (GOTO :PREVIOUS32) ELSE (GOTO :REMOVE32)

:PREVIOUS32
cd\
cd %ProgramFiles%\TeamViewer\Version*
IF NOT EXIST "*uninstall*" GOTO :REMOVE32
start uninstall.exe /S 
GOTO :REMOVE32

:REMOVE32
cd\
cd %ProgramFiles%\TeamViewer
IF NOT EXIST "*uninstall*" GOTO :REMOVEFILES32
start uninstall.exe /S
GOTO :REMOVEFILES32

:REMOVEFILES32
reg delete "HKLM\Software\TeamViewer" /f
cd %temp%
rd TeamViewer /s /Q
exit

:PREVIOUS64
cd\
cd %ProgramFiles(x86)%\TeamViewer\Version*
IF NOT EXIST "*uninstall*" GOTO :REMOVE64
start uninstall.exe /S
GOTO :REMOVE64

:REMOVE64
cd\
cd %ProgramFiles(x86)%\TeamViewer
IF NOT EXIST "*uninstall*" GOTO :REMOVEFILES64
start uninstall.exe /S
GOTO :REMOVEFILES64

:REMOVEFILES64
reg delete "HKLM\Software\Wow6432Node\TeamViewer" /f
cd %temp%
rd TeamViewer /s /Q
exit