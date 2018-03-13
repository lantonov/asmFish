@echo off
cls

CALL:create_datestamp

:menu
echo.
echo    EXECUTABLES
echo    ===========
echo.
echo    1 - All
echo    2 - Windows
echo    3 - Linux
echo    4 - Mac
echo    5 - ARM
echo    6 - Base
echo    7 - Matefinder
echo.
echo    Q - Quit
echo.
choice /c:1234567Q>NUL

rem NOTE: to enable errors simply find+replace (ctrl+H) all instances of "2>NUL" with ""

rem OPTIONS
if errorlevel 8 goto done
if errorlevel 7 goto matefinder
if errorlevel 6 goto base
if errorlevel 5 goto arm
if errorlevel 4 goto mac
if errorlevel 3 goto linux
if errorlevel 2 goto windows
if errorlevel 1 goto allBinaries
echo CHOICE missing
goto done

:allBinaries
call:all
goto menu
 
:windows
ECHO === Building Windows Executables ===
cd WindowsOS_binaries
if exist asm* del asm*
cd ..
set include=x86\include\
"fasmg.exe" "x86\fish.asm" "asmFishW_%datestamp%_popcnt.exe" -e 1000 -i "VERSION_OS='W'" -i "PEDANTIC = 1" -i "VERSION_POST = 'popcnt'" 2>NUL
"fasmg.exe" "x86\fish.asm" "asmFishW_%datestamp%_bmi2.exe" -e 1000 -i "VERSION_OS='W'" -i "PEDANTIC = 1" -i "VERSION_POST = 'bmi2'" 2>NUL
copy asmFishW_%datestamp%_popcnt.exe WindowsOS_binaries
copy asmFishW_%datestamp%_bmi2.exe WindowsOS_binaries
echo.
goto menu
 
:linux
cd LinuxOS_binaries
if exist asm* del asm*
cd ..
set include=x86\include\
ECHO === Building Linux Executables ===
"fasmg.exe" "x86\fish.asm" "asmFishL_%datestamp%_popcnt" -e 1000 -i "VERSION_OS='L'" -i "PEDANTIC = 1" -i "VERSION_POST = 'popcnt'" 2>NUL
"fasmg.exe" "x86\fish.asm" "asmFishL_%datestamp%_bmi2" -e 1000 -i "VERSION_OS='L'" -i "PEDANTIC = 1" -i "VERSION_POST = 'bmi2'" 2>NUL
copy asmFishL_%datestamp%_popcnt LinuxOS_binaries
copy asmFishL_%datestamp%_bmi2 LinuxOS_binaries
echo.
goto menu
 
:mac
cd MacOS_binaries
if exist asm* del asm*
cd ..
set include=x86\include\
ECHO === Building MacOS Executables ===
"fasmg.exe" "x86\fish.asm" "asmFishX_%datestamp%_popcnt" -e 1000 -i "VERSION_OS='X'" -i "PEDANTIC = 1" -i "VERSION_POST = 'popcnt'" 2>NUL
"fasmg.exe" "x86\fish.asm" "asmFishX_%datestamp%_bmi2" -e 1000 -i "VERSION_OS='X'" -i "PEDANTIC = 1" -i "VERSION_POST = 'bmi2'" 2>NUL
copy asmFishX_%datestamp%_popcnt MacOS_binaries
copy asmFishX_%datestamp%_bmi2 MacOS_binaries
echo.
goto menu 
 
:arm
cd LinuxOS_binaries
if exist arm* del arm*
cd ..
set include=arm\include\
ECHO === Building ARM Executables ===
"fasmg.exe" "arm\fish.arm" "armFishL_%datestamp%_v8" -e 1000 -i "VERSION_OS='L'" -i "PEDANTIC = 1" -i "VERSION_POST = 'v8'" 2>NUL
copy armFishL_%datestamp%_v8 LinuxOS_binaries
echo.
goto menu
 
:base
rem Windows
cd WindowsOS_binaries
if exist *base.exe del *base.exe
cd ..
set include=x86\include\
ECHO === Building Windows Base Executable ===
"fasmg.exe" "x86\fish.asm" "asmFishW_%datestamp%_base.exe" -e 1000 -i "VERSION_OS='W'" -i "PEDANTIC = 1" -i "VERSION_POST = 'base'" 2>NUL
copy asmFishW_%datestamp%_base.exe WindowsOS_binaries
echo.

rem Linux
cd LinuxOS_binaries
if exist *base del *base
cd ..
set include=x86\include\
ECHO === Building Linux Base Executable ===
"fasmg.exe" "x86\fish.asm" "asmFishL_%datestamp%_base" -e 1000 -i "VERSION_OS='L'" -i "PEDANTIC = 1" -i "VERSION_POST = 'base'" 2>NUL
copy asmFishL_%datestamp%_base LinuxOS_binaries
echo.

rem MacOS
cd MacOS_binaries
if exist *base del *base
cd ..
set include=x86\include\
ECHO === Building MacOS Base Executable ===
"fasmg.exe" "x86\fish.asm" "asmFishX_%datestamp%_base" -e 1000 -i "VERSION_OS='X'" -i "PEDANTIC = 1" -i "VERSION_POST = 'base'" 2>NUL
copy asmFishX_%datestamp%_base MacOS_binaries
echo.
goto menu
 
:matefinder

rem Windows
cd Matefinder_binaries
if exist mateFishW* del mateFishW*
cd ..
set include=x86\include\
ECHO === Building Windows Matefinder Executables ===
"fasmg.exe" "x86\fish.asm" "mateFishW_%datestamp%_popcnt.exe" -e 1000 -i "VERSION_OS='W'" -i "VERSION_POST = 'popcnt'" -i "USE_MATEFINDER = 1" 2>NUL
"fasmg.exe" "x86\fish.asm" "mateFishW_%datestamp%_bmi2.exe" -e 1000 -i "VERSION_OS='W'" -i "VERSION_POST = 'bmi2'" -i "USE_MATEFINDER = 1" 2>NUL
copy mateFishW* Matefinder_binaries
echo.

rem Linux
cd Matefinder_binaries
if exist mateFishL* del mateFishL*
cd ..
set include=x86\include\
ECHO === Building Linux Matefinder Executables ===
"fasmg.exe" "x86\fish.asm" "mateFishL_%datestamp%_popcnt" -e 1000 -i "VERSION_OS='L'" -i "VERSION_POST = 'popcnt'" -i "USE_MATEFINDER = 1" 2>NUL
"fasmg.exe" "x86\fish.asm" "mateFishL_%datestamp%_bmi2" -e 1000 -i "VERSION_OS='L'" -i "VERSION_POST = 'bmi2'" -i "USE_MATEFINDER = 1" 2>NUL
copy mateFishL_%datestamp%_popcnt Matefinder_binaries
copy mateFishL_%datestamp%_bmi2 Matefinder_binaries
set include=arm\include\
"fasmg.exe" "arm\fish.arm" "mateFishL_%datestamp%_v8" -e 1000 -i "VERSION_OS='L'" -i "VERSION_POST = 'v8'" -i "USE_MATEFINDER = 1" 2>NUL
copy mateFishL_%datestamp%_v8 Matefinder_binaries
echo.

rem Mac
set include=x86\include\
cd Matefinder_binaries
if exist mateFishX* del mateFishX*
cd ..
ECHO === Building MacOS Matefinder Executables ===
"fasmg.exe" "x86\fish.asm" "mateFishX_%datestamp%_popcnt" -e 1000 -i "VERSION_OS='X'" -i "VERSION_POST = 'popcnt'" -i "USE_MATEFINDER = 1" 2>NUL
"fasmg.exe" "x86\fish.asm" "mateFishX_%datestamp%_bmi2" -e 1000 -i "VERSION_OS='X'" -i "VERSION_POST = 'bmi2'" -i "USE_MATEFINDER = 1" 2>NUL
copy mateFishX_* Matefinder_binaries
echo.
goto menu

:all


ECHO === Building Windows Executables ===
cd WindowsOS_binaries
if exist asm* del asm*
cd ..
set include=x86\include\
"fasmg.exe" "x86\fish.asm" "asmFishW_%datestamp%_popcnt.exe" -e 1000 -i "VERSION_OS='W'" -i "PEDANTIC = 1" -i "VERSION_POST = 'popcnt'" 2>NUL
"fasmg.exe" "x86\fish.asm" "asmFishW_%datestamp%_bmi2.exe" -e 1000 -i "VERSION_OS='W'" -i "PEDANTIC = 1" -i "VERSION_POST = 'bmi2'" 2>NUL
copy asmFishW_%datestamp%_popcnt.exe WindowsOS_binaries
copy asmFishW_%datestamp%_bmi2.exe WindowsOS_binaries
echo.

 

cd LinuxOS_binaries
if exist asm* del asm*
cd ..
set include=x86\include\
ECHO === Building Linux Executables ===
"fasmg.exe" "x86\fish.asm" "asmFishL_%datestamp%_popcnt" -e 1000 -i "VERSION_OS='L'" -i "PEDANTIC = 1" -i "VERSION_POST = 'popcnt'" 2>NUL
"fasmg.exe" "x86\fish.asm" "asmFishL_%datestamp%_bmi2" -e 1000 -i "VERSION_OS='L'" -i "PEDANTIC = 1" -i "VERSION_POST = 'bmi2'" 2>NUL
copy asmFishL_%datestamp%_popcnt LinuxOS_binaries
copy asmFishL_%datestamp%_bmi2 LinuxOS_binaries
echo.

 

cd MacOS_binaries
if exist asm* del asm*
cd ..
set include=x86\include\
ECHO === Building MacOS Executables ===
"fasmg.exe" "x86\fish.asm" "asmFishX_%datestamp%_popcnt" -e 1000 -i "VERSION_OS='X'" -i "PEDANTIC = 1" -i "VERSION_POST = 'popcnt'" 2>NUL
"fasmg.exe" "x86\fish.asm" "asmFishX_%datestamp%_bmi2" -e 1000 -i "VERSION_OS='X'" -i "PEDANTIC = 1" -i "VERSION_POST = 'bmi2'" 2>NUL
copy asmFishX_%datestamp%_popcnt MacOS_binaries
copy asmFishX_%datestamp%_bmi2 MacOS_binaries
echo.
 
 

cd LinuxOS_binaries
if exist arm* del arm*
cd ..
set include=arm\include\
ECHO === Building ARM Executables ===
"fasmg.exe" "arm\fish.arm" "armFishL_%datestamp%_v8" -e 1000 -i "VERSION_OS='L'" -i "PEDANTIC = 1" -i "VERSION_POST = 'v8'" 2>NUL
copy armFishL_%datestamp%_v8 LinuxOS_binaries
echo.

 

rem Windows
cd WindowsOS_binaries
if exist *base.exe del *base.exe
cd ..
set include=x86\include\
ECHO === Building Windows Base Executable ===
"fasmg.exe" "x86\fish.asm" "asmFishW_%datestamp%_base.exe" -e 1000 -i "VERSION_OS='W'" -i "PEDANTIC = 1" -i "VERSION_POST = 'base'" 2>NUL
copy asmFishW_%datestamp%_base.exe WindowsOS_binaries
echo.

rem Linux
cd LinuxOS_binaries
if exist *base del *base
cd ..
set include=x86\include\
ECHO === Building Linux Base Executable ===
"fasmg.exe" "x86\fish.asm" "asmFishL_%datestamp%_base" -e 1000 -i "VERSION_OS='L'" -i "PEDANTIC = 1" -i "VERSION_POST = 'base'" 2>NUL
copy asmFishL_%datestamp%_base LinuxOS_binaries
echo.

rem MacOS
cd MacOS_binaries
if exist *base del *base
cd ..
set include=x86\include\
ECHO === Building MacOS Base Executable ===
"fasmg.exe" "x86\fish.asm" "asmFishX_%datestamp%_base" -e 1000 -i "VERSION_OS='X'" -i "PEDANTIC = 1" -i "VERSION_POST = 'base'" 2>NUL
copy asmFishX_%datestamp%_base MacOS_binaries
echo.

 

rem Windows
cd Matefinder_binaries
if exist mateFishW* del mateFishW*
cd ..
set include=x86\include\
ECHO === Building Windows Matefinder Executables ===
"fasmg.exe" "x86\fish.asm" "mateFishW_%datestamp%_popcnt.exe" -e 1000 -i "VERSION_OS='W'" -i "VERSION_POST = 'popcnt'" -i "USE_MATEFINDER = 1" 2>NUL
"fasmg.exe" "x86\fish.asm" "mateFishW_%datestamp%_bmi2.exe" -e 1000 -i "VERSION_OS='W'" -i "VERSION_POST = 'bmi2'" -i "USE_MATEFINDER = 1" 2>NUL
copy mateFishW* Matefinder_binaries
echo.

rem Linux
cd Matefinder_binaries
if exist mateFishL* del mateFishL*
cd ..
set include=x86\include\
ECHO === Building Linux Matefinder Executables ===
"fasmg.exe" "x86\fish.asm" "mateFishL_%datestamp%_popcnt" -e 1000 -i "VERSION_OS='L'" -i "VERSION_POST = 'popcnt'" -i "USE_MATEFINDER = 1" 2>NUL
"fasmg.exe" "x86\fish.asm" "mateFishL_%datestamp%_bmi2" -e 1000 -i "VERSION_OS='L'" -i "VERSION_POST = 'bmi2'" -i "USE_MATEFINDER = 1" 2>NUL
copy mateFishL_%datestamp%_popcnt Matefinder_binaries
copy mateFishL_%datestamp%_bmi2 Matefinder_binaries
set include=arm\include\
"fasmg.exe" "arm\fish.arm" "mateFishL_%datestamp%_v8" -e 1000 -i "VERSION_OS='L'" -i "VERSION_POST = 'v8'" -i "USE_MATEFINDER = 1" 2>NUL
copy mateFishL_%datestamp%_v8 Matefinder_binaries
echo.

rem Mac
set include=x86\include\
cd Matefinder_binaries
if exist mateFishX* del mateFishX*
cd ..
ECHO === Building MacOS Matefinder Executables ===
"fasmg.exe" "x86\fish.asm" "mateFishX_%datestamp%_popcnt" -e 1000 -i "VERSION_OS='X'" -i "VERSION_POST = 'popcnt'" -i "USE_MATEFINDER = 1" 2>NUL
"fasmg.exe" "x86\fish.asm" "mateFishX_%datestamp%_bmi2" -e 1000 -i "VERSION_OS='X'" -i "VERSION_POST = 'bmi2'" -i "USE_MATEFINDER = 1" 2>NUL
copy mateFishX_* Matefinder_binaries
echo.
goto:eof


:create_datestamp
for /f "tokens=2 delims==" %%a in ('wmic OS Get localdatetime /value') do set "dt=%%a"
set "YY=%dt:~2,2%" & set "YYYY=%dt:~0,4%" & set "MM=%dt:~4,2%" & set "DD=%dt:~6,2%"
set "HH=%dt:~8,2%" & set "Min=%dt:~10,2%" & set "Sec=%dt:~12,2%"
set "datestamp=%YYYY%-%MM%-%DD%" & set "timestamp=%HH%%Min%%Sec%" & set "fullstamp=%YYYY%-%MM%-%DD%_%HH%%Min%%Sec%"
goto:eof

:END