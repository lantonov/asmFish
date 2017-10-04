@echo off
for /f "tokens=2 delims==" %%a in ('wmic OS Get localdatetime /value') do set "dt=%%a"
set "YY=%dt:~2,2%" & set "YYYY=%dt:~0,4%" & set "MM=%dt:~4,2%" & set "DD=%dt:~6,2%"
set "HH=%dt:~8,2%" & set "Min=%dt:~10,2%" & set "Sec=%dt:~12,2%"
set "datestamp=%YYYY%-%MM%-%DD%" & set "timestamp=%HH%%Min%%Sec%" & set "fullstamp=%YYYY%-%MM%-%DD%_%HH%%Min%%Sec%"
cls

:menu
echo    EXECUTABLES
echo    ==========
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
choice /c:1234567Q>nul

if errorlevel 8 goto done
if errorlevel 7 goto matefinder
if errorlevel 6 goto base
if errorlevel 5 goto arm
if errorlevel 4 goto mac
if errorlevel 3 goto linux
if errorlevel 2 goto windows
if errorlevel 1 goto all
echo CHOICE missing
goto done
 
:all
set include=arm\include\
"fasmg.exe" "arm\fish.arm" "armFishL_%datestamp%_v8" -e 1000 -i "VERSION_OS='L'" -i "PEDANTIC = 1" -i "VERSION_POST = 'v8'"
set include=x86\include\
"fasmg.exe" "x86\fish.asm" "asmFishW_%datestamp%_popcnt.exe" -e 1000 -i "VERSION_OS='W'" -i "PEDANTIC = 1" -i "VERSION_POST = 'popcnt'"
"fasmg.exe" "x86\fish.asm" "asmFishW_%datestamp%_bmi2.exe" -e 1000 -i "VERSION_OS='W'" -i "PEDANTIC = 1" -i "VERSION_POST = 'bmi2'"
"fasmg.exe" "x86\fish.asm" "asmFishL_%datestamp%_popcnt" -e 1000 -i "VERSION_OS='L'" -i "PEDANTIC = 1" -i "VERSION_POST = 'popcnt'"
"fasmg.exe" "x86\fish.asm" "asmFishL_%datestamp%_bmi2" -e 1000 -i "VERSION_OS='L'" -i "PEDANTIC = 1" -i "VERSION_POST = 'bmi2'"
"fasmg.exe" "x86\fish.asm" "asmFishX_%datestamp%_popcnt" -e 1000 -i "VERSION_OS='X'" -i "PEDANTIC = 1" -i "VERSION_POST = 'popcnt'"
"fasmg.exe" "x86\fish.asm" "asmFishX_%datestamp%_bmi2" -e 1000 -i "VERSION_OS='X'" -i "PEDANTIC = 1" -i "VERSION_POST = 'bmi2'"
goto menu
 
:windows
set include=x86\include\
"fasmg.exe" "x86\fish.asm" "asmFishW_%datestamp%_popcnt.exe" -e 1000 -i "VERSION_OS='W'" -i "PEDANTIC = 1" -i "VERSION_POST = 'popcnt'"
"fasmg.exe" "x86\fish.asm" "asmFishW_%datestamp%_bmi2.exe" -e 1000 -i "VERSION_OS='W'" -i "PEDANTIC = 1" -i "VERSION_POST = 'bmi2'"
goto menu
 
:linux
set include=x86\include\
"fasmg.exe" "x86\fish.asm" "asmFishL_%datestamp%_popcnt" -e 1000 -i "VERSION_OS='L'" -i "PEDANTIC = 1" -i "VERSION_POST = 'popcnt'"
"fasmg.exe" "x86\fish.asm" "asmFishL_%datestamp%_bmi2" -e 1000 -i "VERSION_OS='L'" -i "PEDANTIC = 1" -i "VERSION_POST = 'bmi2'"
goto menu
 
:mac
set include=x86\include\
"fasmg.exe" "x86\fish.asm" "asmFishX_%datestamp%_popcnt" -e 1000 -i "VERSION_OS='X'" -i "PEDANTIC = 1" -i "VERSION_POST = 'popcnt'"
"fasmg.exe" "x86\fish.asm" "asmFishX_%datestamp%_bmi2" -e 1000 -i "VERSION_OS='X'" -i "PEDANTIC = 1" -i "VERSION_POST = 'bmi2'"
goto menu
 
:arm
set include=arm\include\
"fasmg.exe" "arm\fish.arm" "armFishL_%datestamp%_v8" -e 1000 -i "VERSION_OS='L'" -i "PEDANTIC = 1" -i "VERSION_POST = 'v8'"
goto menu
 
:base
set include=x86\include\
"fasmg.exe" "x86\fish.asm" "asmFishW_%datestamp%_base.exe" -e 1000 -i "VERSION_OS='W'" -i "PEDANTIC = 1" -i "VERSION_POST = 'base'"
"fasmg.exe" "x86\fish.asm" "asmFishL_%datestamp%_base" -e 1000 -i "VERSION_OS='L'" -i "PEDANTIC = 1" -i "VERSION_POST = 'base'"
"fasmg.exe" "x86\fish.asm" "asmFishX_%datestamp%_base" -e 1000 -i "VERSION_OS='X'" -i "PEDANTIC = 1" -i "VERSION_POST = 'base'"
goto menu
 
:matefinder
set include=arm\include\
"fasmg.exe" "arm\fish.arm" "mateFishL_%datestamp%_v8" -e 1000 -i "VERSION_OS='L'" -i "PEDANTIC = 1" -i "VERSION_POST = 'v8'" -i "USE_MATEFINDER = 1"
set include=x86\include\
"fasmg.exe" "x86\fish.asm" "mateFishW_%datestamp%_popcnt.exe" -e 1000 -i "VERSION_OS='W'" -i "PEDANTIC = 1" -i "VERSION_POST = 'popcnt'" -i "USE_MATEFINDER = 1"
"fasmg.exe" "x86\fish.asm" "mateFishW_%datestamp%_bmi2.exe" -e 1000 -i "VERSION_OS='W'" -i "PEDANTIC = 1" -i "VERSION_POST = 'bmi2'" -i "USE_MATEFINDER = 1"
"fasmg.exe" "x86\fish.asm" "mateFishL_%datestamp%_popcnt" -e 1000 -i "VERSION_OS='L'" -i "PEDANTIC = 1" -i "VERSION_POST = 'popcnt'" -i "USE_MATEFINDER = 1"
"fasmg.exe" "x86\fish.asm" "mateFishL_%datestamp%_bmi2" -e 1000 -i "VERSION_OS='L'" -i "PEDANTIC = 1" -i "VERSION_POST = 'bmi2'" -i "USE_MATEFINDER = 1"
"fasmg.exe" "x86\fish.asm" "mateFishX_%datestamp%_popcnt" -e 1000 -i "VERSION_OS='X'" -i "PEDANTIC = 1" -i "VERSION_POST = 'popcnt'" -i "USE_MATEFINDER = 1"
"fasmg.exe" "x86\fish.asm" "mateFishX_%datestamp%_bmi2" -e 1000 -i "VERSION_OS='X'" -i "PEDANTIC = 1" -i "VERSION_POST = 'bmi2'" -i "USE_MATEFINDER = 1"
goto menu
 
:done