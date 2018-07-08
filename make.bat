@echo off
cls

:: GENERAL NOTES:

:: 1) All executables of a given type are IDENTICAL regardless of which computer assembled them. There is no such thing as automatic profile-guided optimizations for asmFish.

:: 2) Unless you are explicitly adding a non-default build option (i.e. VARIETY = 1), there is no real reason to use this makefile since all executables are assembled and posted to GitHub as commits are pushed.

:: 3) The layout of this batch-file is primarily for the ease-of-use of repository contributers/collaborators. Bulk assembly options (i.e. 1 - All) assume a machine has at least 8 threads available for concurrent assembly. Systems with less than 8 threads may experience moderate to severe lag.

:: 4) To avoid having too many non-functional commits, modifications to this file (and the AppVeyor file) will from now on be silently included with functional patch releases.

CALL:create_datestamp

set "debug=2>NUL"

:menu
echo.
echo    EXECUTABLES
echo    ===========
echo.
echo    1 - All
echo    2 - Windows [ p - popcnt ^| b - bmi2 ]
echo    3 - Linux
echo    4 - Mac
echo    5 - ARM
echo    6 - Base
echo    7 - Matefinder
echo.  
echo    D - Toggle Debug Mode
echo    U - Update fasmg.exe
echo    Q - Quit
echo.
choice /c:1234567QpbDU>NUL

:: Debug = OFF [default]

:: OPTIONS (Note: Descending order of errorlevels is intentional -- do not change this!)
if errorlevel 12 goto update
if errorlevel 11 goto debug
if errorlevel 10 goto WinBmi2
if errorlevel 9  goto WinPopcnt
if errorlevel 8  goto done
if errorlevel 7  goto matefinder
if errorlevel 6  goto base
if errorlevel 5  goto arm
if errorlevel 4  goto mac
if errorlevel 3  goto linux
if errorlevel 2  goto windows
if errorlevel 1  goto allBinaries
echo CHOICE missing
goto done

:allBinaries
call:all
goto menu
 
:windows
ECHO === Building Windows Executables ===
cd WindowsOS_binaries
if exist *bmi2.exe del *bmi2.exe
if exist *bmi1.exe del *bmi1.exe
if exist *popcnt.exe del *popcnt.exe
cd ..
set include=x86\include\
CALL:start_timer
start /min /wait fasmg.exe "x86\fish.asm" "asmFishW_%datestamp%_popcnt.exe" -e 1000 -i "VERSION_OS='W'" -i "PEDANTIC = 1" -i "VERSION_POST = 'popcnt'" %debug%
start /min /wait fasmg.exe "x86\fish.asm" "asmFishW_%datestamp%_bmi1.exe" -e 1000 -i "VERSION_OS='W'" -i "PEDANTIC = 1" -i "VERSION_POST = 'bmi1'" %debug%
start /min /wait fasmg.exe "x86\fish.asm" "asmFishW_%datestamp%_bmi2.exe" -e 1000 -i "VERSION_OS='W'" -i "PEDANTIC = 1" -i "VERSION_POST = 'bmi2'" %debug%
:: NOTE: We use "copy" instead of "move" here since it is convenient to have a copy of the assembled executable in the working directory for bench-taking purposes.
copy asmFishW_%datestamp%_popcnt.exe WindowsOS_binaries
copy asmFishW_%datestamp%_bmi1.exe WindowsOS_binaries
copy asmFishW_%datestamp%_bmi2.exe WindowsOS_binaries
echo.
CALL:stop_timer
echo.
goto menu
 
:linux
cd LinuxOS_binaries
if exist asm* del asm*
cd ..
set include=x86\include\
CALL:start_timer
ECHO === Building Linux Executables ===
start /min /wait fasmg.exe "x86\fish.asm" "asmFishL_%datestamp%_popcnt" -e 1000 -i "VERSION_OS='L'" -i "PEDANTIC = 1" -i "VERSION_POST = 'popcnt'" %debug%
start /min /wait fasmg.exe "x86\fish.asm" "asmFishL_%datestamp%_bmi1" -e 1000 -i "VERSION_OS='L'" -i "PEDANTIC = 1" -i "VERSION_POST = 'bmi1'" %debug%
start /min /wait fasmg.exe "x86\fish.asm" "asmFishL_%datestamp%_bmi2" -e 1000 -i "VERSION_OS='L'" -i "PEDANTIC = 1" -i "VERSION_POST = 'bmi2'" %debug%
copy asmFishL_%datestamp%_popcnt LinuxOS_binaries
copy asmFishL_%datestamp%_bmi1 LinuxOS_binaries
copy asmFishL_%datestamp%_bmi2 LinuxOS_binaries
echo.
CALL:stop_timer
echo.
goto menu
 
:mac
cd MacOS_binaries
if exist asm* del asm*
cd ..
set include=x86\include\
CALL:start_timer
ECHO === Building MacOS Executables ===
start /min /wait fasmg.exe "x86\fish.asm" "asmFishX_%datestamp%_popcnt" -e 1000 -i "VERSION_OS='X'" -i "PEDANTIC = 1" -i "VERSION_POST = 'popcnt'" %debug%
start /min /wait fasmg.exe "x86\fish.asm" "asmFishX_%datestamp%_bmi1" -e 1000 -i "VERSION_OS='X'" -i "PEDANTIC = 1" -i "VERSION_POST = 'bmi1'" %debug%
start /min /wait fasmg.exe "x86\fish.asm" "asmFishX_%datestamp%_bmi2" -e 1000 -i "VERSION_OS='X'" -i "PEDANTIC = 1" -i "VERSION_POST = 'bmi2'" %debug%
copy asmFishX_%datestamp%_popcnt MacOS_binaries
copy asmFishX_%datestamp%_bmi1 MacOS_binaries
copy asmFishX_%datestamp%_bmi2 MacOS_binaries
echo.
CALL:stop_timer
echo.
goto menu 
 
:arm
cd LinuxOS_binaries
if exist arm* del arm*
cd ..
set include=arm\include\
CALL:start_timer
ECHO === Building ARM Executables ===
fasmg.exe "arm\fish.arm" "armFishL_%datestamp%_v8" -e 1000 -i "VERSION_OS='L'" -i "PEDANTIC = 1" -i "VERSION_POST = 'v8'" %debug%
copy armFishL_%datestamp%_v8 LinuxOS_binaries
echo.
CALL:stop_timer
echo.
goto menu
 
:base
:: Windows
cd WindowsOS_binaries
if exist *base.exe del *base.exe
cd ..
set include=x86\include\
CALL:start_timer
ECHO === Building Windows Base Executables ===
start /min /wait fasmg.exe "x86\fish.asm" "asmFishW_%datestamp%_base.exe" -e 1000 -i "VERSION_OS='W'" -i "PEDANTIC = 1" -i "VERSION_POST = 'base'" %debug%
copy asmFishW_%datestamp%_base.exe WindowsOS_binaries
start /min /wait fasmg.exe "x86\fish.asm" "mateFishW_%datestamp%_base.exe" -e 1000 -i "VERSION_OS='W'" -i "PEDANTIC = 1" -i "VERSION_POST = 'base'" -i "USE_MATEFINDER = 1" %debug%
copy mateFishW_%datestamp%_base.exe Matefinder_binaries
echo.
:: Linux
cd LinuxOS_binaries
if exist *base del *base
cd ..
set include=x86\include\
ECHO === Building Linux Base Executables ===
start /min /wait fasmg.exe "x86\fish.asm" "asmFishL_%datestamp%_base" -e 1000 -i "VERSION_OS='L'" -i "PEDANTIC = 1" -i "VERSION_POST = 'base'" %debug%
copy asmFishL_%datestamp%_base LinuxOS_binaries
start /min /wait fasmg.exe "x86\fish.asm" "mateFishL_%datestamp%_base" -e 1000 -i "VERSION_OS='L'" -i "PEDANTIC = 1" -i "VERSION_POST = 'base'" -i "USE_MATEFINDER = 1" %debug%
copy mateFishL_%datestamp%_base Matefinder_binaries
echo.
:: MacOS
cd MacOS_binaries
if exist *base del *base
cd ..
set include=x86\include\
ECHO === Building MacOS Base Executables ===
start /min /wait fasmg.exe "x86\fish.asm" "asmFishX_%datestamp%_base" -e 1000 -i "VERSION_OS='X'" -i "PEDANTIC = 1" -i "VERSION_POST = 'base'" %debug%
copy asmFishX_%datestamp%_base MacOS_binaries
start /min /wait fasmg.exe "x86\fish.asm" "mateFishX_%datestamp%_base" -e 1000 -i "VERSION_OS='X'" -i "PEDANTIC = 1" -i "VERSION_POST = 'base'" -i "USE_MATEFINDER = 1" %debug%
copy mateFishX_%datestamp%_base Matefinder_binaries
echo.
CALL:stop_timer
echo.
goto menu
 
:matefinder
:: Windows
cd Matefinder_binaries
if exist mateFishW* del mateFishW*
cd ..
set include=x86\include\
CALL:start_timer
ECHO === Building Windows Matefinder Executables ===
start /min /wait fasmg.exe "x86\fish.asm" "mateFishW_%datestamp%_popcnt.exe" -e 1000 -i "VERSION_OS='W'" -i "VERSION_POST = 'popcnt'" -i "USE_MATEFINDER = 1" %debug%
start /min /wait fasmg.exe "x86\fish.asm" "mateFishW_%datestamp%_bmi1.exe" -e 1000 -i "VERSION_OS='W'" -i "VERSION_POST = 'bmi1'" -i "USE_MATEFINDER = 1" %debug%
start /min /wait fasmg.exe "x86\fish.asm" "mateFishW_%datestamp%_bmi2.exe" -e 1000 -i "VERSION_OS='W'" -i "VERSION_POST = 'bmi2'" -i "USE_MATEFINDER = 1" %debug%
copy mateFishW* Matefinder_binaries
echo.
:: Linux
cd Matefinder_binaries
if exist mateFishL* del mateFishL*
cd ..
set include=x86\include\
ECHO === Building Linux Matefinder Executables ===
start /min /wait fasmg.exe "x86\fish.asm" "mateFishL_%datestamp%_popcnt" -e 1000 -i "VERSION_OS='L'" -i "VERSION_POST = 'popcnt'" -i "USE_MATEFINDER = 1" %debug%
start /min /wait fasmg.exe "x86\fish.asm" "mateFishL_%datestamp%_bmi1" -e 1000 -i "VERSION_OS='L'" -i "VERSION_POST = 'bmi1'" -i "USE_MATEFINDER = 1" %debug%
start /min /wait fasmg.exe "x86\fish.asm" "mateFishL_%datestamp%_bmi2" -e 1000 -i "VERSION_OS='L'" -i "VERSION_POST = 'bmi2'" -i "USE_MATEFINDER = 1" %debug%
set include=arm\include\
start /min /wait fasmg.exe "arm\fish.arm" "mateFishL_%datestamp%_v8" -e 1000 -i "VERSION_OS='L'" -i "VERSION_POST = 'v8'" -i "USE_MATEFINDER = 1" %debug%
copy mateFishL_%datestamp%_popcnt Matefinder_binaries
copy mateFishL_%datestamp%_bmi1 Matefinder_binaries
copy mateFishL_%datestamp%_bmi2 Matefinder_binaries
copy mateFishL_%datestamp%_v8 Matefinder_binaries
echo.
:: Mac
set include=x86\include\
cd Matefinder_binaries
if exist mateFishX* del mateFishX*
cd ..
ECHO === Building MacOS Matefinder Executables ===
start /min /wait fasmg.exe "x86\fish.asm" "mateFishX_%datestamp%_popcnt" -e 1000 -i "VERSION_OS='X'" -i "VERSION_POST = 'popcnt'" -i "USE_MATEFINDER = 1" %debug%
start /min /wait fasmg.exe "x86\fish.asm" "mateFishX_%datestamp%_bmi1" -e 1000 -i "VERSION_OS='X'" -i "VERSION_POST = 'bmi1'" -i "USE_MATEFINDER = 1" %debug%
start /min /wait fasmg.exe "x86\fish.asm" "mateFishX_%datestamp%_bmi2" -e 1000 -i "VERSION_OS='X'" -i "VERSION_POST = 'bmi2'" -i "USE_MATEFINDER = 1" %debug%
copy mateFishX_* Matefinder_binaries
CALL:stop_timer
echo.
goto menu

:all

CALL:start_timer
ECHO === Building Windows Executables ===
cd WindowsOS_binaries
if exist *bmi2.exe del *bmi2.exe
if exist *bmi1.exe del *bmi1.exe
if exist *popcnt.exe del *popcnt.exe
cd ..
set include=x86\include\
start /min fasmg.exe "x86\fish.asm" "asmFishW_%datestamp%_popcnt.exe" -e 1000 -i "VERSION_OS='W'" -i "PEDANTIC = 1" -i "VERSION_POST = 'popcnt'" %debug%
start /min fasmg.exe "x86\fish.asm" "asmFishW_%datestamp%_bmi1.exe" -e 1000 -i "VERSION_OS='W'" -i "PEDANTIC = 1" -i "VERSION_POST = 'bmi1'" %debug%
start /min fasmg.exe "x86\fish.asm" "asmFishW_%datestamp%_bmi2.exe" -e 1000 -i "VERSION_OS='W'" -i "PEDANTIC = 1" -i "VERSION_POST = 'bmi2'" %debug%
echo.

 

cd LinuxOS_binaries
if exist asm* del asm*
cd ..
set include=x86\include\
ECHO === Building Linux Executables ===
start /min fasmg.exe "x86\fish.asm" "asmFishL_%datestamp%_popcnt" -e 1000 -i "VERSION_OS='L'" -i "PEDANTIC = 1" -i "VERSION_POST = 'popcnt'" %debug%
start /min fasmg.exe "x86\fish.asm" "asmFishL_%datestamp%_bmi1" -e 1000 -i "VERSION_OS='L'" -i "PEDANTIC = 1" -i "VERSION_POST = 'bmi1'" %debug%
start /min fasmg.exe "x86\fish.asm" "asmFishL_%datestamp%_bmi2" -e 1000 -i "VERSION_OS='L'" -i "PEDANTIC = 1" -i "VERSION_POST = 'bmi2'" %debug%
echo.

 

cd MacOS_binaries
if exist asm* del asm*
cd ..
set include=x86\include\
ECHO === Building MacOS Executables ===
start /min fasmg.exe "x86\fish.asm" "asmFishX_%datestamp%_popcnt" -e 1000 -i "VERSION_OS='X'" -i "PEDANTIC = 1" -i "VERSION_POST = 'popcnt'" %debug%
start /min fasmg.exe "x86\fish.asm" "asmFishX_%datestamp%_bmi1" -e 1000 -i "VERSION_OS='X'" -i "PEDANTIC = 1" -i "VERSION_POST = 'bmi1'" %debug%
start /min fasmg.exe "x86\fish.asm" "asmFishX_%datestamp%_bmi2" -e 1000 -i "VERSION_OS='X'" -i "PEDANTIC = 1" -i "VERSION_POST = 'bmi2'" %debug%
echo.
 
 

cd LinuxOS_binaries
if exist arm* del arm*
cd ..
set include=arm\include\
ECHO === Building ARM Executables ===
start /min fasmg.exe "arm\fish.arm" "armFishL_%datestamp%_v8" -e 1000 -i "VERSION_OS='L'" -i "PEDANTIC = 1" -i "VERSION_POST = 'v8'" %debug%
echo.

 
 
:: Windows
cd Matefinder_binaries
if exist *.7z del *.7z
if exist *.zip del *.zip
if exist *.rar del *.rar
if exist mateFishW* del mateFishW*
if exist *base del *base
cd ..
set include=x86\include\
ECHO === Building Windows Matefinder Executables ===
start /min fasmg.exe "x86\fish.asm" "mateFishW_%datestamp%_popcnt.exe" -e 1000 -i "VERSION_OS='W'" -i "VERSION_POST = 'popcnt'" -i "USE_MATEFINDER = 1" %debug%
start /min fasmg.exe "x86\fish.asm" "mateFishW_%datestamp%_bmi1.exe" -e 1000 -i "VERSION_OS='W'" -i "VERSION_POST = 'bmi1'" -i "USE_MATEFINDER = 1" %debug%
start /min fasmg.exe "x86\fish.asm" "mateFishW_%datestamp%_bmi2.exe" -e 1000 -i "VERSION_OS='W'" -i "VERSION_POST = 'bmi2'" -i "USE_MATEFINDER = 1" %debug%
echo.

:: Linux
cd Matefinder_binaries
if exist mateFish* del mateFishL*
cd ..
set include=x86\include\
ECHO === Building Linux Matefinder Executables ===
start /min fasmg.exe "x86\fish.asm" "mateFishL_%datestamp%_popcnt" -e 1000 -i "VERSION_OS='L'" -i "VERSION_POST = 'popcnt'" -i "USE_MATEFINDER = 1" %debug%
start /min fasmg.exe "x86\fish.asm" "mateFishL_%datestamp%_bmi1" -e 1000 -i "VERSION_OS='L'" -i "VERSION_POST = 'bmi1'" -i "USE_MATEFINDER = 1" %debug%
start /min fasmg.exe "x86\fish.asm" "mateFishL_%datestamp%_bmi2" -e 1000 -i "VERSION_OS='L'" -i "VERSION_POST = 'bmi2'" -i "USE_MATEFINDER = 1" %debug%

set include=arm\include\
start /min fasmg.exe "arm\fish.arm" "mateFishL_%datestamp%_v8" -e 1000 -i "VERSION_OS='L'" -i "VERSION_POST = 'v8'" -i "USE_MATEFINDER = 1" %debug%
echo.

:: Mac
set include=x86\include\
cd Matefinder_binaries
if exist mateFishX* del mateFishX*
cd ..
ECHO === Building MacOS Matefinder Executables ===
start /min fasmg.exe "x86\fish.asm" "mateFishX_%datestamp%_popcnt" -e 1000 -i "VERSION_OS='X'" -i "VERSION_POST = 'popcnt'" -i "USE_MATEFINDER = 1" %debug%
start /min fasmg.exe "x86\fish.asm" "mateFishX_%datestamp%_bmi1" -e 1000 -i "VERSION_OS='X'" -i "VERSION_POST = 'bmi1'" -i "USE_MATEFINDER = 1" %debug%
start /min fasmg.exe "x86\fish.asm" "mateFishX_%datestamp%_bmi2" -e 1000 -i "VERSION_OS='X'" -i "VERSION_POST = 'bmi2'" -i "USE_MATEFINDER = 1" %debug%

echo.

:: Windows
cd WindowsOS_binaries
if exist *base.exe del *base.exe
cd ..
set include=x86\include\
ECHO === Building Windows Base Executables ===
start /min fasmg.exe "x86\fish.asm" "asmFishW_%datestamp%_base.exe" -e 1000 -i "VERSION_OS='W'" -i "PEDANTIC = 1" -i "VERSION_POST = 'base'" %debug%
echo.
start /min fasmg.exe "x86\fish.asm" "mateFishW_%datestamp%_base.exe" -e 1000 -i "VERSION_OS='W'" -i "PEDANTIC = 1" -i "VERSION_POST = 'base'" -i "USE_MATEFINDER = 1" %debug%

:: Linux
cd LinuxOS_binaries
if exist *base del *base
cd ..
set include=x86\include\
ECHO === Building Linux Base Executables ===
start /min fasmg.exe "x86\fish.asm" "asmFishL_%datestamp%_base" -e 1000 -i "VERSION_OS='L'" -i "PEDANTIC = 1" -i "VERSION_POST = 'base'" %debug%
start /min fasmg.exe "x86\fish.asm" "mateFishL_%datestamp%_base" -e 1000 -i "VERSION_OS='L'" -i "PEDANTIC = 1" -i "VERSION_POST = 'base'" -i "USE_MATEFINDER = 1" %debug%
echo.

:: MacOS
cd MacOS_binaries
if exist *base del *base
cd ..
set include=x86\include\
ECHO === Building MacOS Base Executables ===
start /min fasmg.exe "x86\fish.asm" "asmFishX_%datestamp%_base" -e 1000 -i "VERSION_OS='X'" -i "PEDANTIC = 1" -i "VERSION_POST = 'base'" %debug%
start /min fasmg.exe "x86\fish.asm" "mateFishX_%datestamp%_base" -e 1000 -i "VERSION_OS='X'" -i "PEDANTIC = 1" -i "VERSION_POST = 'base'" -i "USE_MATEFINDER = 1" %debug%
echo.

:: Windows
cd WindowsOS_binaries
if exist *base.exe del *base.exe
cd ..
set include=x86\include\
ECHO === Building Windows Base Executable ===
start /min fasmg.exe "x86\fish.asm" "asmFishW_%datestamp%_base.exe" -e 1000 -i "VERSION_OS='W'" -i "PEDANTIC = 1" -i "VERSION_POST = 'base'" %debug%
echo.
start /min /wait fasmg.exe "x86\fish.asm" "mateFishW_%datestamp%_base.exe" -e 1000 -i "VERSION_OS='W'" -i "PEDANTIC = 1" -i "VERSION_POST = 'base'" -i "USE_MATEFINDER = 1" %debug%

timeout 8

:: Move all files to their respective directories
move asmFishW* WindowsOS_binaries
move asmFishL* LinuxOS_binaries
move armFishL* LinuxOS_binaries
move asmFishX* MacOS_binaries
move mateFish* Matefinder_binaries

echo. 
CALL:stop_timer
echo.
goto:eof

:WinPopcnt
ECHO === Building Windows POPCNT Executable ===
cd WindowsOS_binaries
if exist *popcnt.exe del *popcnt.exe
cd ..
set include=x86\include\
fasmg.exe "x86\fish.asm" "asmFishW_%datestamp%_popcnt.exe" -e 1000 -i "VERSION_OS='W'" -i "PEDANTIC = 1" -i "VERSION_POST = 'popcnt'" %debug%
copy asmFishW_%datestamp%_popcnt.exe WindowsOS_binaries
echo.
goto menu

:: NOTE: BMI1 builds are not as common since only AMD processors benefit from specifically having BMI1 instructions without BMI2 instructions. All BMI-aware Intel Processors should use BMI2 builds for optimal performance.

:WinBmi2
ECHO === Building Windows BMI2 Executable ===
cd WindowsOS_binaries
if exist *bmi2.exe del *bmi2.exe
cd ..
set include=x86\include\
fasmg.exe "x86\fish.asm" "asmFishW_%datestamp%_bmi2.exe" -e 1000 -i "VERSION_OS='W'" -i "PEDANTIC = 1" -i "VERSION_POST = 'bmi2'" %debug%
copy asmFishW_%datestamp%_bmi2.exe WindowsOS_binaries
echo.
goto menu


:create_datestamp
for /f "tokens=2 delims==" %%a in ('wmic OS Get localdatetime /value') do set "dt=%%a"
set "YY=%dt:~2,2%" & set "YYYY=%dt:~0,4%" & set "MM=%dt:~4,2%" & set "DD=%dt:~6,2%"
set "HH=%dt:~8,2%" & set "Min=%dt:~10,2%" & set "Sec=%dt:~12,2%"
set "datestamp=%YYYY%-%MM%-%DD%" & set "timestamp=%HH%%Min%%Sec%" & set "fullstamp=%YYYY%-%MM%-%DD%_%HH%%Min%%Sec%"
goto:eof

:start_timer
:: Capture start time
set t0=%time: =0%
goto:eof

:stop_timer
:: Capture end time
set t=%time: =0%
:: Make t0 into a scaler in 100ths of a second
:: Note: Do not let SET/A misinterpret 08 and 09 as octal
set /a h=1%t0:~0,2%-100
set /a m=1%t0:~3,2%-100
set /a s=1%t0:~6,2%-100
set /a c=1%t0:~9,2%-100
set /a starttime = %h% * 360000 + %m% * 6000 + 100 * %s% + %c%
:: Convert t into a scaler in 100ths of a second
set /a h=1%t:~0,2%-100
set /a m=1%t:~3,2%-100
set /a s=1%t:~6,2%-100
set /a c=1%t:~9,2%-100
set /a endtime = %h% * 360000 + %m% * 6000 + 100 * %s% + %c%
:: Runtime in 100ths is now just end - start
set /a runtime = %endtime% - %starttime%
echo      Build time: %runtime:~0,-2%.%runtime:~-2% seconds
goto:eof

:debug
cls
set "default=2>NUL"
if defined debug (ECHO Debug Mode = ON) else (ECHO Debug Mode = OFF)
if defined debug (SET "debug=") else (SET "debug=%default%")
goto menu

:update
:: Update to latest version of fasmg.exe. Since this makefile is for Windows OS users, we only update fasmg.exe here.
if exist fasmg.exe del fasmg.exe
call cscript /nologo "%~dp0download.vbs" https://flatassembler.net fasmg.zip fasmg.exe fasmg.exe "The latest fasmg assembler"
echo.
goto menu

:END
