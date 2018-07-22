setlocal enableextensions
cd /d "%~dp0"
@echo off
:: ===========================================================================
:: RiiConnect24 Patcher for Windows
set version=1.0.4
:: AUTHORS: KcrPL, Larsenv, ApfelTV
:: ***************************************************************************
:: Copyright (c) 2018 KcrPL, RiiConnect24 and it's (Lead) Developers
:: ===========================================================================

if exist temp.bat del /q temp.bat
:script_start
:: Window size (Lines, columns)
set mode=128,37
mode %mode%
set s=NUL
set /a exitmessage=1
set /a errorcopying=0
set /a tempiospatcher=0
set /a tempevcpatcher=0
set /a tempsdcardapps=0
:: Window Title
title RiiConnect24 Patcher v%version% Created by @KcrPL, @Larsenv, @ApfelTV
set last_build=2018/07/22
set at=9:41PM
if exist "C:\Users\%username%\Desktop\RiiConnect24Patcher.txt" goto debug_load
:: ### Auto Update ###
:: 1=Enable 0=Disable
:: Update_Activate - If disabled, patcher will not even check for updates, default=1
:: offlinestorage - Only used while testing of Update function, default=0
:: FilesHostedOn - The website and path to where the files are hosted. WARNING! DON'T END WITH "/"
:: MainFolder/TempStorage - folder that is used to keep version.txt and whatsnew.txt. These two files are deleted every startup but if offlinestorage will be set 1, they won't be deleted.
set /a Update_Activate=1
set /a offlinestorage=0
set FilesHostedOn=https://raw.githubusercontent.com/KcrPL/KcrPL.github.io/master/Patchers_Auto_Update/RiiConnect24Patcher
set MainFolder=%appdata%\RiiConnect24Patcher
set TempStorage=%appdata%\RiiConnect24Patcher\internet\temp

set header=RiiConnect24 Patcher - (C) KcrPL, (C) Larsenv, (C) ApfelTV v%version% (Compiled on %last_build% at %at%)

if not exist "%MainFolder%" md "%MainFolder%"
if not exist "%TempStorage%" md "%TempStorage%"

:: Checking if I have access to files on your computer
if exist %TempStorage%\checkforaccess.txt del /q %TempStorage%\checkforaccess.txt

echo test >>"%TempStorage%\checkforaccess.txt"
set /a file_access=1
if not exist "%TempStorage%\checkforaccess.txt" set /a file_access=0

if exist "%TempStorage%\checkforaccess.txt" del /q "%TempStorage%\checkforaccess.txt"


:: Trying to prevent running from OS that is not Windows.
if not "%os%"=="Windows_NT" goto not_windows_nt
goto begin_main
:not_windows_nt
cls
echo %header%
echo.
echo Hi,
echo Please don't run RiiConnect24 Patcher in MS-DOS
echo.
echo Press any button or CTRL+C to quit.
pause>NUL
exit
goto not_windows_nt
:begin_main
cls
echo %header%
echo              `..````
echo              yNNNNNNNNMNNmmmmdddhhhyyyysssooo+++/:--.`
echo              ddmNNd:dNMMMMNMMMMMMMMMMMMMMMMMMMMMMMMMMs
echo              hNNNNNNNNMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMd
echo             `mdmNNy dNMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM+    RiiConnect your Wii.
echo             .mmmmNs mNMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM:
echo             :mdmmN+`mNMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM.
echo             /mmmmN:-mNMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMN   1. Start
echo             ommmmN.:mMMMMMMMMMMMMmNMMMMMMMMMMMMMMMMMd   2. Credits
echo             smmmmm`+mMMMMMMMMMNhMNNMNNMMMMMMMMMMMMMMy   3. Access the online annoucement server
echo             hmmmmh omMMMMMMMMMmhNMMMmNNNNMMMMMMMMMMM+
echo             hmmmmh omMMMMMMMMMmhNMMMmNNNNMMMMMMMMMMM+  Do you have problems or want to contact us?  
echo             mmmmms smMMMMMMMMMmddMMmmNmNMMMMMMMMMMMM:  Mail us at support@riiconnect24.net
echo            `mmmmmo hNMMMMMMMMMmddNMMMNNMMMMMMMMMMMMM.
echo            -mmmmm/ dNMMMMMMMMMNmddMMMNdhdMMMMMMMMMMN
echo            :mmmmm-`mNMMMMMMMMNNmmmNMMNmmmMMMMMMMMMMd
echo            +mmmmN.-mNMMMMMMMMMNmmmmMMMMMMMMMMMMMMMMy
echo            smmmmm`/mMMMMMMMMMNNmmmmNMMMMNMMNMMMMMNmy.
echo            hmmmmd`omMMMMMMMMMNNmmmNmMNNMmNNNNMNdhyhh.
echo            mmmmmh ymMMMMMMMMMNNmmmNmNNNMNNMMMMNyyhhh`
echo           `mmmmmy hmMMNMNNMMMNNmmmmmdNMMNmmMMMMhyhhy
echo           -mddmmo`mNMNNNNMMMNNNmdyoo+mMMMNmNMMMNyyys
echo           :mdmmmo-mNNNNNNNNNNdyo++sssyNMMMMMMMMMhs+-
echo          .+mmdhhmmmNNNNNNmdysooooosssomMMMNNNMMMm
echo          o/ossyhdmmNNmdyo+++oooooosssoyNMMNNNMMMM+
echo          o/::::::://++//+++ooooooo+oo++mNMMmNNMMMm
echo         `o//::::::::+////+++++++///:/+shNMMNmNNmMM+
echo         .o////////::+++++++oo++///+syyyymMmNmmmNMMm
echo         -+//////////o+ooooooosydmdddhhsosNMMmNNNmho            `:/
echo         .+++++++++++ssss+//oyyysso/:/shmshhs+:.          `-/oydNNNy
echo           `..-:/+ooss+-`          +mmhdy`           -/shmNNNNNdy+:`
echo                   `.              yddyo++:    `-/oymNNNNNdy+:`
echo                                   -odhhhhyddmmmmmNNmhs/:`
echo                                     :syhdyyyyso+/-`
set /p s=Type a number that you can see above next to the command and hit ENTER: 
if %s%==1 goto begin_main1
if %s%==2 goto credits
if %s%==3 goto annoucement_network_connect
goto begin_main
:annoucement_network_1
:: Display the page 
cls
echo %header%
echo -----------------------------------------------------------------------------------------------------------------------------
type "%TempStorage%\annoucement\%page%.txt"
echo.
set /p s=Choose: 
if %s%==1 call :annoucement_action_1
if %s%==2 call :annoucement_action_2
if %s%==3 call :annoucement_action_3
if %s%==4 call :annoucement_action_4
if %s%==5 call :annoucement_action_5
if %s%==6 call :annoucement_action_6
if %s%==7 call :annoucement_action_7
if %s%==8 call :annoucement_action_8
if %s%==9 call :annoucement_action_9
if %s%==10 call :annoucement_action_10
goto annoucement_network_1
:annoucement_network_connectionerror
cls
echo %header%
echo -----------------------------------------------------------------------------------------------------------------------------
echo.
echo There was an error while connecting to the server.
echo Press any button to go back.
pause>NUL
goto begin_main
:annoucement_network_connect
cls
echo %header%
echo -----------------------------------------------------------------------------------------------------------------------------
echo.
echo Please wait... 
echo We are connecting you to the server and downloading latest info.
if exist "%TempStorage%\annoucement" rmdir "%TempStorage%\annoucement" /s /q
if not exist "%TempStorage%\annoucement" md "%TempStorage%\annoucement"
call powershell -command "(new-object System.Net.WebClient).DownloadFile('"%FilesHostedOn%/annoucement/index.txt"', '"%TempStorage%\annoucement\index.txt"')"
set /a temperrorlev=%errorlevel%
if not %temperrorlev%==0 goto annoucement_network_connectionerror

set page=index

set action1=NUL
set action2=NUL
set action3=NUL
set action4=NUL
set action5=NUL
set action6=NUL
set action7=NUL
set action8=NUL
set action9=NUL
set action10=NUL

::action list
::1 - change page
::2 - go to main menu
::3 - start an url
::howmanyactions - prevents trying to download too much files and waste time

set /a howmanytodownload=10
call powershell -command "(new-object System.Net.WebClient).DownloadFile('"%FilesHostedOn%/annoucement/%page%_howmanyactions.txt"', '"%TempStorage%\annoucement\%page%_howmanyactions.txt"')"
set /p howmanytodownload=<"%TempStorage%\annoucement\%page%_howmanyactions.txt"

call powershell -command "(new-object System.Net.WebClient).DownloadFile('"%FilesHostedOn%/annoucement/%page%_ac1_comm.txt"', '"%TempStorage%\annoucement\%page%_ac1_comm.txt"')" >NUL
set /p action1=<"%TempStorage%\annoucement\%page%_ac1_comm.txt" >NUL
if %howmanytodownload%==1 goto annoucement_network_1

call powershell -command "(new-object System.Net.WebClient).DownloadFile('"%FilesHostedOn%/annoucement/%page%_ac2_comm.txt"', '"%TempStorage%\annoucement\%page%_ac2_comm.txt"')" >NUL
set /p action2=<"%TempStorage%\annoucement\%page%_ac2_comm.txt" >NUL
if %howmanytodownload%==2 goto annoucement_network_1
call powershell -command "(new-object System.Net.WebClient).DownloadFile('"%FilesHostedOn%/annoucement/%page%_ac3_comm.txt"', '"%TempStorage%\annoucement\%page%_ac3_comm.txt"')" >NUL
set /p action3=<"%TempStorage%\annoucement\%page%_ac3_comm.txt" >NUL
if %howmanytodownload%==3 goto annoucement_network_1

call powershell -command "(new-object System.Net.WebClient).DownloadFile('"%FilesHostedOn%/annoucement/%page%_ac4_comm.txt"', '"%TempStorage%\annoucement\%page%_ac4_comm.txt"')" >NUL
set /p action4=<"%TempStorage%\annoucement\%page%_ac4_comm.txt" >NUL
if %howmanytodownload%==4 goto annoucement_network_1

call powershell -command "(new-object System.Net.WebClient).DownloadFile('"%FilesHostedOn%/annoucement/%page%_ac5_comm.txt"', '"%TempStorage%\annoucement\%page%_ac5_comm.txt"')" >NUL
set /p action5=<"%TempStorage%\annoucement\%page%_ac5_comm.txt" >NUL
if %howmanytodownload%==5 goto annoucement_network_1

call powershell -command "(new-object System.Net.WebClient).DownloadFile('"%FilesHostedOn%/annoucement/%page%_ac6_comm.txt"', '"%TempStorage%\annoucement\%page%_ac6_comm.txt"')" >NUL
set /p action6=<"%TempStorage%\annoucement\%page%_ac6_comm.txt" >NUL
if %howmanytodownload%==6 goto annoucement_network_1

call powershell -command "(new-object System.Net.WebClient).DownloadFile('"%FilesHostedOn%/annoucement/%page%_ac7_comm.txt"', '"%TempStorage%\annoucement\%page%_ac7_comm.txt"')" >NUL
set /p action7=<"%TempStorage%\annoucement\%page%_ac7_comm.txt" >NUL
if %howmanytodownload%==7 goto annoucement_network_1

call powershell -command "(new-object System.Net.WebClient).DownloadFile('"%FilesHostedOn%/annoucement/%page%_ac8_comm.txt"', '"%TempStorage%\annoucement\%page%_ac8_comm.txt"')" >NUL
set /p action8=<"%TempStorage%\annoucement\%page%_ac8_comm.txt" >NUL
if %howmanytodownload%==8 goto annoucement_network_1

call powershell -command "(new-object System.Net.WebClient).DownloadFile('"%FilesHostedOn%/annoucement/%page%_ac9_comm.txt"', '"%TempStorage%\annoucement\%page%_ac9_comm.txt"')" >NUL
set /p action9=<"%TempStorage%\annoucement\%page%_ac9_comm.txt" >NUL
if %howmanytodownload%==9 goto annoucement_network_1

call powershell -command "(new-object System.Net.WebClient).DownloadFile('"%FilesHostedOn%/annoucement/%page%_ac10_comm.txt"', '"%TempStorage%\annoucement\%page%_ac10_comm.txt"')" >NUL
set /p action10=<"%TempStorage%\annoucement\%page%_ac10_comm.txt" >NUL
if %howmanytodownload%==10 goto annoucement_network_1

goto annoucement_network_1
:annoucement_network_404
cls
echo %header%
echo -----------------------------------------------------------------------------------------------------------------------------
echo.
echo HTTP 404
echo.
echo Hello? Anybody there?
echo Couldn't find the page that you've requested.
echo.
echo Press any button to go back to main page.
pause>NUL
set page=index
goto annoucement_network_load
:annoucement_network_load
set /a tempvar=0
if not exist "%TempStorage%\annoucement\%page%.txt" set /a tempvar=1

if %tempvar%==1 call powershell -command "(new-object System.Net.WebClient).DownloadFile('"%FilesHostedOn%/annoucement/%page%.txt"', '"%TempStorage%\annoucement\%page%.txt"')"
if %tempvar%==1 set /a temperrorlev=%errorlevel%
if %tempvar%==1 if not %temperrorlev%==0 goto annoucement_network_404

set action1=NUL
set action2=NUL
set action3=NUL
set action4=NUL
set action5=NUL
set action6=NUL
set action7=NUL
set action8=NUL
set action9=NUL
set action10=NUL

set /a howmanytodownload=10
if not exist "%TempStorage%\annoucement\%page%_howmanyactions.txt" call powershell -command "(new-object System.Net.WebClient).DownloadFile('"%FilesHostedOn%/annoucement/%page%_howmanyactions.txt"', '"%TempStorage%\annoucement\%page%_howmanyactions.txt"')"
set /p howmanytodownload=<"%TempStorage%\annoucement\%page%_howmanyactions.txt"

if not exist "%TempStorage%\annoucement\%page%_ac1_comm.txt" call powershell -command "(new-object System.Net.WebClient).DownloadFile('"%FilesHostedOn%/annoucement/%page%_ac1_comm.txt"', '"%TempStorage%\annoucement\%page%_ac1_comm.txt"')"
set /p action1=<"%TempStorage%\annoucement\%page%_ac1_comm.txt
if %howmanytodownload%==1 goto annoucement_network_1

if not exist "%TempStorage%\annoucement\%page%_ac2_comm.txt" call powershell -command "(new-object System.Net.WebClient).DownloadFile('"%FilesHostedOn%/annoucement/%page%_ac2_comm.txt"', '"%TempStorage%\annoucement\%page%_ac2_comm.txt"')"
set /p action2=<"%TempStorage%\annoucement\%page%_ac2_comm.txt"
if %howmanytodownload%==2 goto annoucement_network_1

if not exist "%TempStorage%\annoucement\%page%_ac3_comm.txt" call powershell -command "(new-object System.Net.WebClient).DownloadFile('"%FilesHostedOn%/annoucement/%page%_ac3_comm.txt"', '"%TempStorage%\annoucement\%page%_ac3_comm.txt"')"
set /p action3=<"%TempStorage%\annoucement\%page%_ac3_comm.txt"
if %howmanytodownload%==3 goto annoucement_network_1

if not exist "%TempStorage%\annoucement\%page%_ac4_comm.txt" call powershell -command "(new-object System.Net.WebClient).DownloadFile('"%FilesHostedOn%/annoucement/%page%_ac4_comm.txt"', '"%TempStorage%\annoucement\%page%_ac4_comm.txt"')"
set /p action4=<"%TempStorage%\annoucement\%page%_ac4_comm.txt"
if %howmanytodownload%==4 goto annoucement_network_1

if not exist "%TempStorage%\annoucement\%page%_ac5_comm.txt" call powershell -command "(new-object System.Net.WebClient).DownloadFile('"%FilesHostedOn%/annoucement/%page%_ac5_comm.txt"', '"%TempStorage%\annoucement\%page%_ac5_comm.txt"')"
set /p action5=<"%TempStorage%\annoucement\%page%_ac5_comm.txt"
if %howmanytodownload%==5 goto annoucement_network_1

if not exist "%TempStorage%\annoucement\%page%_ac6_comm.txt" call powershell -command "(new-object System.Net.WebClient).DownloadFile('"%FilesHostedOn%/annoucement/%page%_ac6_comm.txt"', '"%TempStorage%\annoucement\%page%_ac6_comm.txt"')"
set /p action6=<"%TempStorage%\annoucement\%page%_ac6_comm.txt"
if %howmanytodownload%==6 goto annoucement_network_1

if not exist "%TempStorage%\annoucement\%page%_ac7_comm.txt" call powershell -command "(new-object System.Net.WebClient).DownloadFile('"%FilesHostedOn%/annoucement/%page%_ac7_comm.txt"', '"%TempStorage%\annoucement\%page%_ac7_comm.txt"')"
set /p action7=<"%TempStorage%\annoucement\%page%_ac7_comm.txt"
if %howmanytodownload%==7 goto annoucement_network_1

if not exist "%TempStorage%\annoucement\%page%_ac8_comm.txt" call powershell -command "(new-object System.Net.WebClient).DownloadFile('"%FilesHostedOn%/annoucement/%page%_ac8_comm.txt"', '"%TempStorage%\annoucement\%page%_ac8_comm.txt"')"
set /p action8=<"%TempStorage%\annoucement\%page%_ac8_comm.txt"
if %howmanytodownload%==8 goto annoucement_network_1

if not exist "%TempStorage%\annoucement\%page%_ac9_comm.txt" call powershell -command "(new-object System.Net.WebClient).DownloadFile('"%FilesHostedOn%/annoucement/%page%_ac9_comm.txt"', '"%TempStorage%\annoucement\%page%_ac9_comm.txt"')"
set /p action9=<"%TempStorage%\annoucement\%page%_ac9_comm.txt"
if %howmanytodownload%==9 goto annoucement_network_1

if not exist "%TempStorage%\annoucement\%page%_ac10_comm.txt" call powershell -command "(new-object System.Net.WebClient).DownloadFile('"%FilesHostedOn%/annoucement/%page%_ac10_comm.txt"', '"%TempStorage%\annoucement\%page%_ac10_comm.txt"')"
set /p action10=<"%TempStorage%\annoucement\%page%_ac10_comm.txt"
if %howmanytodownload%==10 goto annoucement_network_1

goto annoucement_network_1


:annoucement_action_1

if %action1%==2 goto begin_main

if %action1%==1 if not exist "%TempStorage%\annoucement\%page%_ac1.txt" call powershell -command "(new-object System.Net.WebClient).DownloadFile('"%FilesHostedOn%/annoucement/%page%_ac1.txt"', '"%TempStorage%\annoucement\%page%_ac1.txt"')"
if %action1%==1 set /a temperrorlev=%errorlevel%
if %action1%==1 if not %temperrorlev%==0 goto annoucement_network_404
if %action1%==1 set /p page=<"%TempStorage%\annoucement\%page%_ac1.txt"
if %action1%==1 goto annoucement_network_load

if %action1%==3 if not exist "%TempStorage%\annoucement\%page%_ac1.txt" call powershell -command "(new-object System.Net.WebClient).DownloadFile('"%FilesHostedOn%/annoucement/%page%_ac1.txt"', '"%TempStorage%\annoucement\%page%_ac1.txt"')"
if %action1%==3 set /p tempURLStart=<"%TempStorage%\annoucement\%page%_ac1.txt"
if %action1%==3 start %tempURLStart%
if %action1%==3 goto annoucement_network_1

goto annoucement_network_1
:annoucement_action_2
if %action2%==2 goto begin_main

if %action2%==1 if not exist "%TempStorage%\annoucement\%page%_ac2.txt" call powershell -command "(new-object System.Net.WebClient).DownloadFile('"%FilesHostedOn%/annoucement/%page%_ac2.txt"', '"%TempStorage%\annoucement\%page%_ac2.txt"')"
if %action2%==1 set /a temperrorlev=%errorlevel%
if %action2%==1 if not %temperrorlev%==0 goto annoucement_network_404
if %action2%==1 set /p page=<"%TempStorage%\annoucement\%page%_ac2.txt"
if %action2%==1 goto annoucement_network_load

if %action2%==3 if not exist "%TempStorage%\annoucement\%page%_ac2.txt" call powershell -command "(new-object System.Net.WebClient).DownloadFile('"%FilesHostedOn%/annoucement/%page%_ac2.txt"', '"%TempStorage%\annoucement\%page%_ac2.txt"')"
if %action2%==3 set /p tempURLStart=<"%TempStorage%\annoucement\%page%_ac2.txt"
if %action2%==3 start %tempURLStart%
if %action2%==3 goto annoucement_network_1

goto annoucement_network_1
:annoucement_action_3
if %action3%==2 goto begin_main

if %action3%==1 if not exist "%TempStorage%\annoucement\%page%_ac3.txt" call powershell -command "(new-object System.Net.WebClient).DownloadFile('"%FilesHostedOn%/annoucement/%page%_ac3.txt"', '"%TempStorage%\annoucement\%page%_ac3.txt"')"
if %action3%==1 set /a temperrorlev=%errorlevel%
if %action3%==1 if not %temperrorlev%==0 goto annoucement_network_404
if %action3%==1 set /p page=<"%TempStorage%\annoucement\%page%_ac3.txt"
if %action3%==1 goto annoucement_network_load

if %action3%==3 if not exist "%TempStorage%\annoucement\%page%_ac3.txt" call powershell -command "(new-object System.Net.WebClient).DownloadFile('"%FilesHostedOn%/annoucement/%page%_ac3.txt"', '"%TempStorage%\annoucement\%page%_ac3.txt"')"
if %action3%==3 set /p tempURLStart=<"%TempStorage%\annoucement\%page%_ac3.txt"
if %action3%==3 start %tempURLStart%
if %action3%==3 goto annoucement_network_1

goto annoucement_network_1
:annoucement_action_4
if %action4%==2 goto begin_main

if %action4%==1 if not exist "%TempStorage%\annoucement\%page%_ac4.txt" call powershell -command "(new-object System.Net.WebClient).DownloadFile('"%FilesHostedOn%/annoucement/%page%_ac4.txt"', '"%TempStorage%\annoucement\%page%_ac4.txt"')"
if %action4%==1 set /a temperrorlev=%errorlevel%
if %action4%==1 if not %temperrorlev%==0 goto annoucement_network_404
if %action4%==1 set /p page=<"%TempStorage%\annoucement\%page%_ac4.txt"
if %action4%==1 goto annoucement_network_load

if %action4%==3 if not exist "%TempStorage%\annoucement\%page%_ac4.txt" call powershell -command "(new-object System.Net.WebClient).DownloadFile('"%FilesHostedOn%/annoucement/%page%_ac4.txt"', '"%TempStorage%\annoucement\%page%_ac4.txt"')"
if %action4%==3 set /p tempURLStart=<"%TempStorage%\annoucement\%page%_ac4.txt"
if %action4%==3 start %tempURLStart%
if %action4%==3 goto annoucement_network_1

goto annoucement_network_1
:annoucement_action_5
if %action5%==1 if not exist "%TempStorage%\annoucement\%page%_ac5.txt" call powershell -command "(new-object System.Net.WebClient).DownloadFile('"%FilesHostedOn%/annoucement/%page%_ac5.txt"', '"%TempStorage%\annoucement\%page%_ac5.txt"')"
if %action5%==1 set /a temperrorlev=%errorlevel%
if %action5%==1 if not %temperrorlev%==0 goto annoucement_network_404
if %action5%==1 set /p page=<"%TempStorage%\annoucement\%page%_ac5.txt"
if %action5%==1 goto annoucement_network_load

if %action5%==2 goto begin_main

if %action5%==3 if not exist "%TempStorage%\annoucement\%page%_ac5.txt" call powershell -command "(new-object System.Net.WebClient).DownloadFile('"%FilesHostedOn%/annoucement/%page%_ac5.txt"', '"%TempStorage%\annoucement\%page%_ac5.txt"')"
if %action5%==3 set /p tempURLStart=<"%TempStorage%\annoucement\%page%_ac5.txt"

if %action5%==3 start %tempURLStart%
if %action5%==3 goto annoucement_network_1

goto annoucement_network_1
:annoucement_action_6
if %action6%==2 goto begin_main

if %action6%==1 if not exist "%TempStorage%\annoucement\%page%_ac6.txt" call powershell -command "(new-object System.Net.WebClient).DownloadFile('"%FilesHostedOn%/annoucement/%page%_ac6.txt"', '"%TempStorage%\annoucement\%page%_ac6.txt"')"
if %action6%==1 set /a temperrorlev=%errorlevel%
if %action6%==1 if not %temperrorlev%==0 goto annoucement_network_404
if %action6%==1 set /p page=<"%TempStorage%\annoucement\%page%_ac6.txt"
if %action6%==1 goto annoucement_network_load

if %action6%==3 if not exist "%TempStorage%\annoucement\%page%_ac6.txt" call powershell -command "(new-object System.Net.WebClient).DownloadFile('"%FilesHostedOn%/annoucement/%page%_ac6.txt"', '"%TempStorage%\annoucement\%page%_ac6.txt"')"
if %action6%==3 set /p tempURLStart=<"%TempStorage%\annoucement\%page%_ac6.txt"
if %action6%==3 start %tempURLStart%
if %action6%==3 goto annoucement_network_1

goto annoucement_network_1
:annoucement_action_7
if %action7%==2 goto begin_main

if %action7%==1 if not exist "%TempStorage%\annoucement\%page%_ac7.txt" call powershell -command "(new-object System.Net.WebClient).DownloadFile('"%FilesHostedOn%/annoucement/%page%_ac7.txt"', '"%TempStorage%\annoucement\%page%_ac7.txt"')"
if %action7%==1 set /a temperrorlev=%errorlevel%
if %action7%==1 if not %temperrorlev%==0 goto annoucement_network_404
if %action7%==1 set /p page=<"%TempStorage%\annoucement\%page%_ac7.txt"
if %action7%==1 goto annoucement_network_load

if %action7%==3 if not exist "%TempStorage%\annoucement\%page%_ac7.txt" call powershell -command "(new-object System.Net.WebClient).DownloadFile('"%FilesHostedOn%/annoucement/%page%_ac7.txt"', '"%TempStorage%\annoucement\%page%_ac7.txt"')"
if %action7%==3 set /p tempURLStart=<"%TempStorage%\annoucement\%page%_ac7.txt"
if %action7%==3 start %tempURLStart%
if %action7%==3 goto annoucement_network_1

goto annoucement_network_1
:annoucement_action_8
if %action8%==2 goto begin_main

if %action8%==1 if not exist "%TempStorage%\annoucement\%page%_ac8.txt" call powershell -command "(new-object System.Net.WebClient).DownloadFile('"%FilesHostedOn%/annoucement/%page%_ac8.txt"', '"%TempStorage%\annoucement\%page%_ac8.txt"')"
if %action8%==1 set /a temperrorlev=%errorlevel%
if %action8%==1 if not %temperrorlev%==0 goto annoucement_network_404
if %action8%==1 set /p page=<"%TempStorage%\annoucement\%page%_ac8.txt"
if %action8%==1 goto annoucement_network_load

if %action8%==3 if not exist "%TempStorage%\annoucement\%page%_ac8.txt" call powershell -command "(new-object System.Net.WebClient).DownloadFile('"%FilesHostedOn%/annoucement/%page%_ac8.txt"', '"%TempStorage%\annoucement\%page%_ac8.txt"')"
if %action8%==3 set /p tempURLStart=<"%TempStorage%\annoucement\%page%_ac8.txt"
if %action8%==3 start %tempURLStart%
if %action8%==3 goto annoucement_network_1

goto annoucement_network_1
:annoucement_action_9
if %action9%==2 goto begin_main

if %action9%==1 if not exist "%TempStorage%\annoucement\%page%_ac9.txt" call powershell -command "(new-object System.Net.WebClient).DownloadFile('"%FilesHostedOn%/annoucement/%page%_ac9.txt"', '"%TempStorage%\annoucement\%page%_ac9.txt"')"
if %action9%==1 set /a temperrorlev=%errorlevel%
if %action9%==1 if not %temperrorlev%==0 goto annoucement_network_404
if %action9%==1 set /p page=<"%TempStorage%\annoucement\%page%_ac9.txt"
if %action9%==1 goto annoucement_network_load

if %action9%==3 if not exist "%TempStorage%\annoucement\%page%_ac9.txt" call powershell -command "(new-object System.Net.WebClient).DownloadFile('"%FilesHostedOn%/annoucement/%page%_ac9.txt"', '"%TempStorage%\annoucement\%page%_ac9.txt"')"
if %action9%==3 set /p tempURLStart=<"%TempStorage%\annoucement\%page%_ac9.txt"
if %action9%==3 start %tempURLStart%
if %action9%==3 goto annoucement_network_1

goto annoucement_network_1
:annoucement_action_10
if %action10%==2 goto begin_main

if %action10%==1 if not exist "%TempStorage%\annoucement\%page%_ac10.txt" call powershell -command "(new-object System.Net.WebClient).DownloadFile('"%FilesHostedOn%/annoucement/%page%_ac10.txt"', '"%TempStorage%\annoucement\%page%_ac10.txt"')"
if %action10%==1 set /a temperrorlev=%errorlevel%
if %action10%==1 if not %temperrorlev%==0 goto annoucement_network_404
if %action10%==1 set /p page=<"%TempStorage%\annoucement\%page%_ac10.txt"
if %action10%==1 goto annoucement_network_load

if %action10%==3 if not exist "%TempStorage%\annoucement\%page%_ac10.txt" call powershell -command "(new-object System.Net.WebClient).DownloadFile('"%FilesHostedOn%/annoucement/%page%_ac10.txt"', '"%TempStorage%\annoucement\%page%_ac10.txt"')"
if %action10%==3 set /p tempURLStart=<"%TempStorage%\annoucement\%page%_ac10.txt"
if %action10%==3 start %tempURLStart%
if %action10%==3 goto annoucement_network_1

goto annoucement_network_1
:credits
cls
echo %header%
echo              `..````
echo ---------------------------------------------------------------------------------------------------------------------------
echo RiiConnect24 Patcher for RiiConnect24 v%version% 
echo 	Created by:
echo - KcrPL
echo   Windows Patcher, UI, scripts.
echo.
echo - Larsenv
echo   UNIX Patcher, help with scripts, original IOS Patcher script. Overall help with scripts and commands syntax.
echo.
echo - ApfelTV
echo   Help with Everybody Votes Channel patching and Sharpii syntax.
echo.
echo - Brawl345
echo   Help with resolving ticket issues.
echo.
echo  For the entire RiiConnect24 Community.
echo  Want to contact us? Mail us at support@riiconnect24.net
echo.
echo  Press any button to go back to main menu.
echo ---------------------------------------------------------------------------------------------------------------------------
echo           -mddmmo`mNMNNNNMMMNNNmdyoo+mMMMNmNMMMNyyys
echo           :mdmmmo-mNNNNNNNNNNdyo++sssyNMMMMMMMMMhs+-
echo          .+mmdhhmmmNNNNNNmdysooooosssomMMMNNNMMMm
echo          o/ossyhdmmNNmdyo+++oooooosssoyNMMNNNMMMM+
echo          o/::::::://++//+++ooooooo+oo++mNMMmNNMMMm
echo         `o//::::::::+////+++++++///:/+shNMMNmNNmMM+
echo         .o////////::+++++++oo++///+syyyymMmNmmmNMMm
echo         -+//////////o+ooooooosydmdddhhsosNMMmNNNmho            `:/
echo         .+++++++++++ssss+//oyyysso/:/shmshhs+:.          `-/oydNNNy
echo           `..-:/+ooss+-`          +mmhdy`           -/shmNNNNNdy+:`
echo                   `.              yddyo++:    `-/oymNNNNNdy+:`
echo                                   -odhhhhyddmmmmmNNmhs/:`
echo                                     :syhdyyyyso+/-`
pause>NUL
goto begin_main
:begin_main1
cls
echo %header%
echo.
echo              `..````                                     :-------------------------:
echo              yNNNNNNNNMNNmmmmdddhhhyyyysssooo+++/:--.`    Checking for updates...
echo              hNNNNNNNNMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMd   :-------------------------:
echo              ddmNNd:dNMMMMNMMMMMMMMMMMMMMMMMMMMMMMMMMs
echo             `mdmNNy dNMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM+
echo             .mmmmNs mNMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM:
echo             :mdmmN+`mNMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM.
echo             /mmmmN:-mNMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMN
echo             ommmmN.:mMMMMMMMMMMMMmNMMMMMMMMMMMMMMMMMd
echo             smmmmm`+mMMMMMMMMMNhMNNMNNMMMMMMMMMMMMMMy
echo             hmmmmh omMMMMMMMMMmhNMMMmNNNNMMMMMMMMMMM+
echo             mmmmms smMMMMMMMMMmddMMmmNmNMMMMMMMMMMMM:
echo            `mmmmmo hNMMMMMMMMMmddNMMMNNMMMMMMMMMMMMM.
echo            -mmmmm/ dNMMMMMMMMMNmddMMMNdhdMMMMMMMMMMN
echo            :mmmmm-`mNMMMMMMMMNNmmmNMMNmmmMMMMMMMMMMd
echo            +mmmmN.-mNMMMMMMMMMNmmmmMMMMMMMMMMMMMMMMy
echo            smmmmm`/mMMMMMMMMMNNmmmmNMMMMNMMNMMMMMNmy.
echo            hmmmmd`omMMMMMMMMMNNmmmNmMNNMmNNNNMNdhyhh.
echo            mmmmmh ymMMMMMMMMMNNmmmNmNNNMNNMMMMNyyhhh`
echo           `mmmmmy hmMMNMNNMMMNNmmmmmdNMMNmmMMMMhyhhy
echo           -mddmmo`mNMNNNNMMMNNNmdyoo+mMMMNmNMMMNyyys
echo           :mdmmmo-mNNNNNNNNNNdyo++sssyNMMMMMMMMMhs+-
echo          .+mmdhhmmmNNNNNNmdysooooosssomMMMNNNMMMm
echo          o/ossyhdmmNNmdyo+++oooooosssoyNMMNNNMMMM+
echo          o/::::::://++//+++ooooooo+oo++mNMMmNNMMMm
echo         `o//::::::::+////+++++++///:/+shNMMNmNNmMM+
echo         .o////////::+++++++oo++///+syyyymMmNmmmNMMm
echo         -+//////////o+ooooooosydmdddhhsosNMMmNNNmho            `:/
echo         .+++++++++++ssss+//oyyysso/:/shmshhs+:.          `-/oydNNNy
echo           `..-:/+ooss+-`          +mmhdy`           -/shmNNNNNdy+:`
echo                   `.              yddyo++:    `-/oymNNNNNdy+:`
echo                                   -odhhhhyddmmmmmNNmhs/:`
echo                                     :syhdyyyyso+/-`
powershell /? >NUL
set /a temperrorlev=%errorlevel%
if not %temperrorlev%==0 goto powershell_error

:: Update script.
set updateversion=0.0.0
:: Delete version.txt and whatsnew.txt
if %offlinestorage%==0 if exist "%TempStorage%\version.txt" del "%TempStorage%\version.txt" /q
if %offlinestorage%==0 if exist "%TempStorage%\version.txt`" del "%TempStorage%\version.txt`" /q
if %offlinestorage%==0 if exist "%TempStorage%\whatsnew.txt" del "%TempStorage%\whatsnew.txt" /q
if %offlinestorage%==0 if exist "%TempStorage%\whatsnew.txt`" del "%TempStorage%\whatsnew.txt`" /q

if not exist "%TempStorage%" md "%TempStorage%"
:: Commands to download files from server.

if %Update_Activate%==1 if %offlinestorage%==0 call powershell -command (new-object System.Net.WebClient).DownloadFile('"%FilesHostedOn%/whatsnew.txt"', '"%TempStorage%\whatsnew.txt"')
if %Update_Activate%==1 if %offlinestorage%==0 call powershell -command (new-object System.Net.WebClient).DownloadFile('"%FilesHostedOn%/version.txt"', '"%TempStorage%\version.txt"')
	set /a temperrorlev=%errorlevel%

set /a updateserver=1
	::Bind error codes to errors here
	if not %temperrorlev%==0 set /a updateserver=0

if exist "%TempStorage%\version.txt`" ren "%TempStorage%\version.txt`" "version.txt"
if exist "%TempStorage%\whatsnew.txt`" ren "%TempStorage%\whatsnew.txt`" "whatsnew.txt"
:: Copy the content of version.txt to variable.
if exist "%TempStorage%\version.txt" set /p updateversion=<"%TempStorage%\version.txt"
if not exist "%TempStorage%\version.txt" set /a updateavailable=0
if %Update_Activate%==1 if exist "%TempStorage%\version.txt" set /a updateavailable=1
:: If version.txt doesn't match the version variable stored in this batch file, it means that update is available.
if %updateversion%==%version% set /a updateavailable=0

if exist "%TempStorage%\annoucement.txt" del /q "%TempStorage%\annoucement.txt"
powershell -command "(new-object System.Net.WebClient).DownloadFile('%FilesHostedOn%/annoucement.txt', '%TempStorage%\annoucement.txt')"

if %Update_Activate%==1 if %updateavailable%==1 set /a updateserver=2
if %Update_Activate%==1 if %updateavailable%==1 goto update_notice

goto 1
:powershell_error
cls
echo %header%
echo.                                                                       
echo              `..````                                                  
echo              yNNNNNNNNMNNmmmmdddhhhyyyysssooo+++/:--.`                
echo              hNNNNNNNNMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMd                
echo              ddmNNd:dNMMMMNMMMMMMMMMMMMMMMMMMMMMMMMMMs                
echo             `mdmNNy dNMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM+        
echo             .mmmmNs mNMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM:                
echo             :mdmmN+`mNMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM.                
echo             /mmmmN:-mNMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMN            
echo             ommmmN.:mMMMMMMMMMMMMmNMMMMMMMMMMMMMMMMMd                 
echo             smmmmm`+mMMMMMMMMMNhMNNMNNMMMMMMMMMMMMMMy                 
echo             hmmmmh omMMMMMMMMMmhNMMMmNNNNMMMMMMMMMMM+                 
echo ------------------------------------------------------------------------------------------------------------------------------
echo    /---\   An error has occured..              
echo   /     \  Looks like Powershell wasn't found on your computer.
echo  /   !   \ If you are on an old system like Windows XP, please use our legacy IOS Patcher.
echo  ---------  You can find IOS Patcher at https://github.com/RiiConnect24/IOS-Patcher/releases
echo.
echo.
echo ------------------------------------------------------------------------------------------------------------------------------    
echo           -mddmmo`mNMNNNNMMMNNNmdyoo+mMMMNmNMMMNyyys                  
echo           :mdmmmo-mNNNNNNNNNNdyo++sssyNMMMMMMMMMhs+-                  
echo          .+mmdhhmmmNNNNNNmdysooooosssomMMMNNNMMMm                     
echo          o/ossyhdmmNNmdyo+++oooooosssoyNMMNNNMMMM+                    
echo          o/::::::://++//+++ooooooo+oo++mNMMmNNMMMm                    
echo         `o//::::::::+////+++++++///:/+shNMMNmNNmMM+                   
echo         .o////////::+++++++oo++///+syyyymMmNmmmNMMm                   
echo         -+//////////o+ooooooosydmdddhhsosNMMmNNNmho            `:/    
echo         .+++++++++++ssss+//oyyysso/:/shmshhs+:.          `-/oydNNNy   
echo           `..-:/+ooss+-`          +mmhdy`           -/shmNNNNNdy+:`   
echo                   `.              yddyo++:    `-/oymNNNNNdy+:`        
echo                                   -odhhhhyddmmmmmNNmhs/:`             
echo                                     :syhdyyyyso+/-`
pause>NUL
goto powershell_error
:update_notice
if exist "%MainFolder%\failsafe.txt" del /q "%MainFolder%\failsafe.txt"
if %updateversion%==0.0.0 goto error_update_not_available
set /a update=1
cls
echo %header%
echo.                                                                       
echo              `..````                                                  
echo              yNNNNNNNNMNNmmmmdddhhhyyyysssooo+++/:--.`                
echo              hNNNNNNNNMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMd                
echo              ddmNNd:dNMMMMNMMMMMMMMMMMMMMMMMMMMMMMMMMs                
echo             `mdmNNy dNMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM+        
echo             .mmmmNs mNMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM:                
echo             :mdmmN+`mNMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM.                
echo             /mmmmN:-mNMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMN            
echo             ommmmN.:mMMMMMMMMMMMMmNMMMMMMMMMMMMMMMMMd                 
echo             smmmmm`+mMMMMMMMMMNhMNNMNNMMMMMMMMMMMMMMy                 
echo             hmmmmh omMMMMMMMMMmhNMMMmNNNNMMMMMMMMMMM+                 
echo ------------------------------------------------------------------------------------------------------------------------------
echo    /---\   An Update is available.              
echo   /     \  An Update for this program is available. We suggest updating the RiiConnect24 Patcher to the latest version.
echo  /   !   \ 
echo  ---------  Current version: %version%
echo             New version: %updateversion%
echo                       1. Update                      2. Dismiss               3. What's new in this update?
echo ------------------------------------------------------------------------------------------------------------------------------    
echo           -mddmmo`mNMNNNNMMMNNNmdyoo+mMMMNmNMMMNyyys                  
echo           :mdmmmo-mNNNNNNNNNNdyo++sssyNMMMMMMMMMhs+-                  
echo          .+mmdhhmmmNNNNNNmdysooooosssomMMMNNNMMMm                     
echo          o/ossyhdmmNNmdyo+++oooooosssoyNMMNNNMMMM+                    
echo          o/::::::://++//+++ooooooo+oo++mNMMmNNMMMm                    
echo         `o//::::::::+////+++++++///:/+shNMMNmNNmMM+                   
echo         .o////////::+++++++oo++///+syyyymMmNmmmNMMm                   
echo         -+//////////o+ooooooosydmdddhhsosNMMmNNNmho            `:/    
echo         .+++++++++++ssss+//oyyysso/:/shmshhs+:.          `-/oydNNNy   
echo           `..-:/+ooss+-`          +mmhdy`           -/shmNNNNNdy+:`   
echo                   `.              yddyo++:    `-/oymNNNNNdy+:`        
echo                                   -odhhhhyddmmmmmNNmhs/:`             
echo                                     :syhdyyyyso+/-`
set /p s=
if %s%==1 goto update_files
if %s%==2 goto 1
if %s%==3 goto whatsnew
goto update_notice
:update_files
cls
echo %header%
echo.                                                                       
echo              `..````                                                  
echo              yNNNNNNNNMNNmmmmdddhhhyyyysssooo+++/:--.`                
echo              hNNNNNNNNMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMd                
echo              ddmNNd:dNMMMMNMMMMMMMMMMMMMMMMMMMMMMMMMMs                
echo             `mdmNNy dNMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM+        
echo             .mmmmNs mNMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM:                
echo             :mdmmN+`mNMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM.                
echo             /mmmmN:-mNMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMN            
echo             ommmmN.:mMMMMMMMMMMMMmNMMMMMMMMMMMMMMMMMd                 
echo             smmmmm`+mMMMMMMMMMNhMNNMNNMMMMMMMMMMMMMMy                 
echo             hmmmmh omMMMMMMMMMmhNMMMmNNNNMMMMMMMMMMM+                 
echo ------------------------------------------------------------------------------------------------------------------------------
echo    /---\   Updating.
echo   /     \  Please wait...
echo  /   !   \ 
echo  --------- RiiConnect24 Patcher will restart shortly... 
echo.             
echo.
echo ------------------------------------------------------------------------------------------------------------------------------    
echo           -mddmmo`mNMNNNNMMMNNNmdyoo+mMMMNmNMMMNyyys                  
echo           :mdmmmo-mNNNNNNNNNNdyo++sssyNMMMMMMMMMhs+-                  
echo          .+mmdhhmmmNNNNNNmdysooooosssomMMMNNNMMMm                     
echo          o/ossyhdmmNNmdyo+++oooooosssoyNMMNNNMMMM+                    
echo          o/::::::://++//+++ooooooo+oo++mNMMmNNMMMm                    
echo         `o//::::::::+////+++++++///:/+shNMMNmNNmMM+                   
echo         .o////////::+++++++oo++///+syyyymMmNmmmNMMm                   
echo         -+//////////o+ooooooosydmdddhhsosNMMmNNNmho            `:/    
echo         .+++++++++++ssss+//oyyysso/:/shmshhs+:.          `-/oydNNNy   
echo           `..-:/+ooss+-`          +mmhdy`           -/shmNNNNNdy+:`   
echo                   `.              yddyo++:    `-/oymNNNNNdy+:`        
echo                                   -odhhhhyddmmmmmNNmhs/:`             
echo                                     :syhdyyyyso+/-`
set /a file=1
:update_1
powershell -command "(new-object System.Net.WebClient).DownloadFile('%FilesHostedOn%/howmanyfiles.txt', '%TempStorage%/howmanyfiles.txt')"
set /p update_howmanyfiles=<"%TempStorage%/howmanyfiles.txt"
goto update_2
:update_2
:: Do not count RiiConnect24Patcher.bat in howmanyfiles.txt
if %update_howmanyfiles%==0 goto update_3
powershell -command "(new-object System.Net.WebClient).DownloadFile('%FilesHostedOn%/file_%file%.txt', '%TempStorage%/file_%file%.txt')"
set /p filetemp=<"%TempStorage%/file_%file%.txt"

powershell -command "(new-object System.Net.WebClient).DownloadFile('%FilesHostedOn%/%filetemp%', '%filetemp%`')"
if exist "%filetemp%" del /q "%filetemp%"
ren "%filetemp%`" "%filetemp%"

if exist "%TempStorage%\file_%file%.txt" del /q "%TempStorage%\file_%file%.txt"
if %file%==%update_howmanyfiles% goto update_3
set /a file=%file%+1
goto update_2
:update_3

powershell -command "(new-object System.Net.WebClient).DownloadFile('%FilesHostedOn%/RiiConnect24Patcher.bat', 'RiiConnect24Patcher.bat`')"

echo echo off >>temp.bat
echo ping localhost -n 2^>NUL >>temp.bat
echo del RiiConnect24Patcher.bat /q >>temp.bat
echo ren "RiiConnect24Patcher.bat`" "RiiConnect24Patcher.bat" >>temp.bat
echo start RiiConnect24Patcher.bat >>temp.bat
echo exit >>temp.bat

start temp.bat
exit
exit
exit
:whatsnew
cls
if not exist %TempStorage%\whatsnew.txt goto whatsnew_notexist
echo %header%
echo ------------------------------------------------------------------------------------------------------------------------------
echo.
echo What's new in update %updateversion%?
echo.
type "%TempStorage%\whatsnew.txt"
pause>NUL
goto update_notice
:whatsnew_notexist
cls
echo %header%
echo -----------------------------------------------------------------------------------------------------------------------------
echo.
echo Error. What's new file is not available.
echo.
echo Press any button to go back.
pause>NUL
goto update_notice
:1
cls
echo %header%
echo -----------------------------------------------------------------------------------------------------------------------------
if exist "%TempStorage%\annoucement.txt" echo --- Annoucement --- 
if exist "%TempStorage%\annoucement.txt" type "%TempStorage%\annoucement.txt"
if exist "%TempStorage%\annoucement.txt" echo.
if exist "%TempStorage%\annoucement.txt" echo -------------------
echo.
echo Which mode should I run?
echo 1. Automatic Guided Installation (Recommended)
echo   - The patcher will guide you through process of installing RiiConnect24
echo.
echo 2. Manual Install
echo   - In this mode you will be able to choose what you want to do and in which order
echo.
echo 3. Uninstall RiiConnect24 from your Wii.
echo   - This will help you uninstall RiiConnect24 from your Wii.
echo.
set /p s=Choose: 
if %s%==1 goto 2_auto
if %s%==2 goto 2_manual
if %s%==3 goto 2_uninstall
goto 1
:2_uninstall
cls
echo %header%
echo -----------------------------------------------------------------------------------------------------------------------------
echo.
echo :-------------------------------------------------------------------------------------------------------------------:
echo : If you are doing troubleshooting, please keep that in mind that reinstalling RiiConnect24 probably won't help you :
echo : Please contact RiiConnect24 Developers at support@riiconnect24.net for more info.                                 :
echo :-------------------------------------------------------------------------------------------------------------------:
echo.
echo This part of this patcher will help you uninstalling RiiConnect24 from your Wii.
echo By completing these steps you will lose access to:
echo - News Channel
echo - Forecast Channel
echo - Wii Mail
echo.
echo If you have other channels installed on your Wii, you will have to uninstall them manually.
echo.
echo Do you want to proceed with the guide?
echo 1. Yes
echo 2. No, go back.
echo.
set /p s=Choose: 
if %s%==1 goto 2_uninstall_1
if %s%==2 goto 1
goto 2_uninstall
:2_uninstall_1
cls
echo %header%
echo -----------------------------------------------------------------------------------------------------------------------------
echo.
echo Would you like to include tutorial with how to delete your nwc24msg.cfg file?
echo (This is a mail configuration file)
echo.
echo 1. Yes
echo 2. No
set /p uninstall_2_1=Choose: 
if %uninstall_2_1%==1 goto 2_uninstall_2
if %uninstall_2_1%==2 goto 2_uninstall_3
goto 2_uninstall_1
:2_uninstall_2
cls
echo %header%
echo -----------------------------------------------------------------------------------------------------------------------------
echo.
echo Would you like to ask us to delete your mail from our database?
echo (After deleting it from our database, you will be able to patch your Wii again in the future for RiiConnect24,
echo  it is recommended to do that)
echo.
echo 1. Yes, show me the instructions how to do that.
echo 2. No
set /p uninstall_2_2=Choose: 
if %uninstall_2_2%==1 goto 2_uninstall_2_1
if %uninstall_2_2%==2 goto 2_uninstall_3
goto 2_uninstall_2
:2_uninstall_2_1
cls
echo %header%
echo -----------------------------------------------------------------------------------------------------------------------------
echo.
echo Please send a mail to support@riiconnect24.net with a request to delete you from our database.
echo With that email, please include a picture showing your Friend Code in the Address Book.
echo To do that, please open Wii Message Board -^> New Message -^> Address Book -^> Make a picture of your Friend Code and
echo please send it to us to make sure that you are the owner of the Friend Code.
echo.
echo By doing so, you will lose access to the RiiConnect24 Mailing system. You will be able to restore full functionality using
echo the RiiConnect24 Mail Patcher homebrew app on your Wii.
echo.
echo Press any key to continue...
ping localhost -n 2 >NUL
pause>NUL
goto 2_uninstall_3
:2_uninstall_3
cls
echo %header%
echo -----------------------------------------------------------------------------------------------------------------------------
echo.
echo After downloading all the files, do you want to copy them to your SD Card?
echo.
echo Please connect your Wii SD Card to the computer.
echo.
echo 1. Connected!
echo 2. I can't connect an SD Card to the computer.
set sdcard=NUL
set /p sdcard=Choose: 
if %sdcard%==1 set /a sdcardstatus=1& set tempgotonext=2_uninstall_3_summary& goto detect_sd_card
if %sdcard%==2 set /a sdcardstatus=0& set /a sdcard=NUL& goto 2_uninstall_3_summary
goto 2_uninstall_3
:2_uninstall_3_summary
cls
echo %header%
echo -----------------------------------------------------------------------------------------------------------------------------
echo.
if %sdcardstatus%==0 echo Aww, no worries. You will be able to copy files later after patching.
if %sdcardstatus%==1 if %sdcard%==NUL echo Hmm... looks like an SD Card wasn't found in your system. Please choose the `Change drive letter` option
if %sdcardstatus%==1 if %sdcard%==NUL echo to set your SD Card drive letter manually.
if %sdcardstatus%==1 if %sdcard%==NUL echo.
if %sdcardstatus%==1 if %sdcard%==NUL echo Otherwise, starting patching will set copying to manual so you will have to copy them later.
if %sdcardstatus%==1 if not %sdcard%==NUL echo Congrats! I've successfully detected your SD Card! Drive letter: %sdcard%
if %sdcardstatus%==1 if not %sdcard%==NUL echo I will be able to automatically download and install everything on your SD Card!	
echo.
echo The entire patching process will download about 5MB of data.
echo.
echo What's next?
if %sdcardstatus%==0 echo 1. Start Patching  2. Exit
if %sdcardstatus%==1 if %sdcard%==NUL echo 1. Start Patching 2. Exit 3. Change drive letter
if %sdcardstatus%==1 if not %sdcard%==NUL echo 1. Start Patching 2. Exit 3. Change drive letter
set /p s=Choose: 
if %s%==1 goto 2_uninstall_4
if %s%==2 goto begin_main
if %s%==3 goto 2_uninstall_change_drive_letter
goto 2_uninstall_3_summary
:2_uninstall_4
cls
set /a percent=%percent%+1

if /i %percent% GTR 0 if /i %percent% LSS 10 set /a counter_done=0
if /i %percent% GTR 10 if /i %percent% LSS 20 set /a counter_done=1
if /i %percent% GTR 20 if /i %percent% LSS 30 set /a counter_done=2
if /i %percent% GTR 30 if /i %percent% LSS 40 set /a counter_done=3
if /i %percent% GTR 40 if /i %percent% LSS 50 set /a counter_done=4
if /i %percent% GTR 50 if /i %percent% LSS 60 set /a counter_done=5
if /i %percent% GTR 60 if /i %percent% LSS 70 set /a counter_done=6
if /i %percent% GTR 70 if /i %percent% LSS 80 set /a counter_done=7
if /i %percent% GTR 80 if /i %percent% LSS 90 set /a counter_done=8
if /i %percent% GTR 90 if /i %percent% LSS 100 set /a counter_done=9
if %percent%==100 set /a counter_done=10
if %percent%==100 goto 2_uninstall_5
cls
echo.
echo %header%
echo ---------------------------------------------------------------------------------------------------------------------------
echo  [*] Restoring default IOS's and downloading utilities...
echo.
echo    Progress: 
if %counter_done%==0 echo :          : %percent% %%
if %counter_done%==1 echo :-         : %percent% %%
if %counter_done%==2 echo :--        : %percent% %%
if %counter_done%==3 echo :---       : %percent% %%
if %counter_done%==4 echo :----      : %percent% %%
if %counter_done%==5 echo :-----     : %percent% %%
if %counter_done%==6 echo :------    : %percent% %%
if %counter_done%==7 echo :-------   : %percent% %%
if %counter_done%==8 echo :--------  : %percent% %%
if %counter_done%==9 echo :--------- : %percent% %%
if %counter_done%==10 echo :----------: %percent% %%

::Download files
if %percent%==1 if not exist IOSPatcher md IOSPatcher
if %percent%==1 if not exist "IOSPatcher/00000006-31.delta" powershell -command "(new-object System.Net.WebClient).DownloadFile('"%FilesHostedOn%/IOSPatcher/00000006-31.delta"', 'IOSPatcher/00000006-31.delta"')"
if %percent%==1 set /a temperrorlev=%errorlevel%
if %percent%==1 set modul=Downloading 06-31.delta
if %percent%==1 if not %temperrorlev%==0 goto error_patching

if %percent%==3 if not exist "IOSPatcher/00000006-80.delta" powershell -command "(new-object System.Net.WebClient).DownloadFile('"%FilesHostedOn%/IOSPatcher/00000006-80.delta"', 'IOSPatcher/00000006-80.delta"')"
if %percent%==3 set /a temperrorlev=%errorlevel%
if %percent%==3 set modul=Downloading 06-80.delta
if %percent%==3 if not %temperrorlev%==0 goto error_patching

if %percent%==6 if not exist "IOSPatcher/00000006-80.delta" powershell -command "(new-object System.Net.WebClient).DownloadFile('"%FilesHostedOn%/IOSPatcher/00000006-80.delta"', 'IOSPatcher/00000006-80.delta"')"
if %percent%==6 set /a temperrorlev=%errorlevel%
if %percent%==6 set modul=Downloading 06-80.delta
if %percent%==6 if not %temperrorlev%==0 goto error_patching

if %percent%==9 if not exist "IOSPatcher/libWiiSharp.dll" powershell -command "(new-object System.Net.WebClient).DownloadFile('"%FilesHostedOn%/IOSPatcher/libWiiSharp.dll"', 'IOSPatcher/libWiiSharp.dll"')"
if %percent%==9 set /a temperrorlev=%errorlevel%
if %percent%==9 set modul=Downloading libWiiSharp.dll
if %percent%==9 if not %temperrorlev%==0 goto error_patching

if %percent%==12 if not exist "IOSPatcher/Sharpii.exe" powershell -command "(new-object System.Net.WebClient).DownloadFile('"%FilesHostedOn%/IOSPatcher/Sharpii.exe"', 'IOSPatcher/Sharpii.exe"')"
if %percent%==12 set /a temperrorlev=%errorlevel%
if %percent%==12 set modul=Downloading Sharpii.exe
if %percent%==12 if not %temperrorlev%==0 goto error_patching

if %percent%==15 if not exist "IOSPatcher/WadInstaller.dll" powershell -command "(new-object System.Net.WebClient).DownloadFile('"%FilesHostedOn%/IOSPatcher/WadInstaller.dll"', 'IOSPatcher/WadInstaller.dll"')"
if %percent%==15 set /a temperrorlev=%errorlevel%
if %percent%==15 set modul=Downloading WadInstaller.dll
if %percent%==15 if not %temperrorlev%==0 goto error_patching

if %percent%==17 if not exist "IOSPatcher/xdelta3.exe" powershell -command "(new-object System.Net.WebClient).DownloadFile('"%FilesHostedOn%/IOSPatcher/xdelta3.exe"', 'IOSPatcher/xdelta3.exe"')"
if %percent%==17 set /a temperrorlev=%errorlevel%
if %percent%==17 set modul=Downloading xdelta3.exe
if %percent%==17 if not %temperrorlev%==0 goto error_patching


if %percent%==20 if not exist apps md apps

if %percent%==23 if not exist apps/WiiModLite md apps\WiiModLite
if %percent%==23 if not exist apps/WiiXplorer md apps\WiiXplorer
if %percent%==23 if not exist "apps/WiiModLite/boot.dol" powershell -command "(new-object System.Net.WebClient).DownloadFile('"%FilesHostedOn%/apps/WiiModLite/boot.dol"', 'apps/WiiModLite/boot.dol"')"
if %percent%==23 set /a temperrorlev=%errorlevel%
if %percent%==23 set modul=Downloading Wii Mod Lite
if %percent%==23 if not %temperrorlev%==0 goto error_patching

if %percent%==25 if not exist "apps/WiiModLite/database.txt" powershell -command "(new-object System.Net.WebClient).DownloadFile('"%FilesHostedOn%/apps/WiiModLite/database.txt"', 'apps/WiiModLite/database.txt"')"
if %percent%==25 set /a temperrorlev=%errorlevel%
if %percent%==25 set modul=Downloading Wii Mod Lite
if %percent%==25 if not %temperrorlev%==0 goto error_patching

if %percent%==27 if not exist "apps/WiiModLite/icon.png" powershell -command "(new-object System.Net.WebClient).DownloadFile('"%FilesHostedOn%/apps/WiiModLite/icon.png"', 'apps/WiiModLite/icon.png"')"
if %percent%==27 set /a temperrorlev=%errorlevel%
if %percent%==27 set modul=Downloading Wii Mod Lite
if %percent%==27 if not %temperrorlev%==0 goto error_patching

if %percent%==30 if not exist "apps/WiiModLite/icon.png" powershell -command "(new-object System.Net.WebClient).DownloadFile('"%FilesHostedOn%/apps/WiiModLite/icon.png"', 'apps/WiiModLite/icon.png"')"
if %percent%==30 set /a temperrorlev=%errorlevel%
if %percent%==30 set modul=Downloading Wii Mod Lite
if %percent%==30 if not %temperrorlev%==0 goto error_patching

if %percent%==32 if not exist "apps/WiiModLite/meta.xml" powershell -command "(new-object System.Net.WebClient).DownloadFile('"%FilesHostedOn%/apps/WiiModLite/meta.xml"', 'apps/WiiModLite/meta.xml"')"
if %percent%==32 set /a temperrorlev=%errorlevel%
if %percent%==32 set modul=Downloading Wii Mod Lite
if %percent%==32 if not %temperrorlev%==0 goto error_patching

if %percent%==34 if not exist "apps/WiiModLite/wiimod.txt" powershell -command "(new-object System.Net.WebClient).DownloadFile('"%FilesHostedOn%/apps/WiiModLite/wiimod.txt"', 'apps/WiiModLite/wiimod.txt"')"
if %percent%==34 set /a temperrorlev=%errorlevel%
if %percent%==34 set modul=Downloading Wii Mod Lite
if %percent%==34 if not %temperrorlev%==0 goto error_patching

if %percent%==36 if not exist "apps/WiiXplorer/boot.dol" powershell -command "(new-object System.Net.WebClient).DownloadFile('"%FilesHostedOn%/apps/WiiXplorer/boot.dol"', 'apps/WiiXplorer/boot.dol"')"
if %percent%==36 set /a temperrorlev=%errorlevel%
if %percent%==36 set modul=Downloading WiiXplorer
if %percent%==36 if not %temperrorlev%==0 goto error_patching

if %percent%==38 if not exist "apps/WiiXplorer/icon.png" powershell -command "(new-object System.Net.WebClient).DownloadFile('"%FilesHostedOn%/apps/WiiXplorer/icon.png"', 'apps/WiiXplorer/icon.png"')"
if %percent%==38 set /a temperrorlev=%errorlevel%
if %percent%==38 set modul=Downloading WiiXplorer
if %percent%==38 if not %temperrorlev%==0 goto error_patching

if %percent%==39 if not exist "apps/WiiXplorer/meta.xml" powershell -command "(new-object System.Net.WebClient).DownloadFile('"%FilesHostedOn%/apps/WiiXplorer/meta.xml"', 'apps/WiiXplorer/meta.xml"')"
if %percent%==39 set /a temperrorlev=%errorlevel%
if %percent%==39 set modul=Downloading WiiXplorer
if %percent%==39 if not %temperrorlev%==0 goto error_patching

if %percent%==40 if %uninstall_2_1%==1 if not exist "apps/WiiXplorer/meta.xml" powershell -command "(new-object System.Net.WebClient).DownloadFile('"%FilesHostedOn%/apps/WiiModLite/meta.xml"', 'apps/WiiModLite/meta.xml"')"
if %percent%==40 if %uninstall_2_1%==1 set /a temperrorlev=%errorlevel%
if %percent%==40 if %uninstall_2_1%==1 set modul=Downloading WiiXplorer
if %percent%==40 if %uninstall_2_1%==1 if not %temperrorlev%==0 goto error_patching

if %percent%==45 if %uninstall_2_1%==1 if not exist "apps/WiiXplorer/icon.png" powershell -command "(new-object System.Net.WebClient).DownloadFile('"%FilesHostedOn%/apps/WiiModLite/meta.xml"', 'apps/WiiModLite/meta.xml"')"
if %percent%==45 if %uninstall_2_1%==1 set /a temperrorlev=%errorlevel%
if %percent%==45 if %uninstall_2_1%==1 set modul=Downloading WiiXplorer
if %percent%==45 if %uninstall_2_1%==1 if not %temperrorlev%==0 goto error_patching

if %percent%==48 if %uninstall_2_1%==1 if not exist "apps/WiiXplorer/boot.dol" powershell -command "(new-object System.Net.WebClient).DownloadFile('"%FilesHostedOn%/apps/WiiModLite/meta.xml"', 'apps/WiiModLite/meta.xml"')"
if %percent%==48 if %uninstall_2_1%==1 set /a temperrorlev=%errorlevel%
if %percent%==48 if %uninstall_2_1%==1 set modul=Downloading WiiXplorer
if %percent%==48 if %uninstall_2_1%==1 if not %temperrorlev%==0 goto error_patching

if %percent%==50 if not exist "WAD" md "WAD"
if %percent%==50 call IOSPatcher\Sharpii.exe NUSD -ios 31 -v latest -o wad\IOS31.wad -wad >NUL
if %percent%==50 set /a temperrorlev=%errorlevel%
if %percent%==50 set modul=Sharpii.exe
if %percent%==50 if not %temperrorlev%==0 goto error_patching

if %percent%==80 call IOSPatcher\Sharpii.exe NUSD -ios 80 -v latest -o wad\IOS80.wad -wad >NUL
if %percent%==80 set /a temperrorlev=%errorlevel%
if %percent%==80 set modul=Sharpii.exe
if %percent%==80 if not %temperrorlev%==0 goto error_patching

if %percent%==95 if not %sdcard%==NUL set /a errorcopying=0
if %percent%==95 if not %sdcard%==NUL if not exist "%sdcard%:\WAD" md "%sdcard%:\WAD"
if %percent%==95 if not %sdcard%==NUL if not exist "%sdcard%:\apps" md "%sdcard%:\apps"

if %percent%==98 if not %sdcard%==NUL xcopy /y "WAD" "%sdcard%:\WAD" /e >NUL || set /a errorcopying=1
if %percent%==98 if not %sdcard%==NUL xcopy /y "apps" "%sdcard%:\apps" /e >NUL || set /a errorcopying=1

if %percent%==99 if exist "IOSPatcher" rmdir /s /q "IOSPatcher"
if %percent%==100 goto 2_4
ping localhost -n 1 >NUL
goto 2_uninstall_4
:2_uninstall_5
cls
echo %header%
echo -----------------------------------------------------------------------------------------------------------------------------
echo.
echo Patching done! Now please follow these instructions:
echo.
if %sdcard%==NUL echo - Plaese copy the wad and apps folder next to the patcher to your SD Card.
if %sdcard%==NUL echo.
echo Part I - Reinstalling stock IOS 31 and IOS 80
echo 1. Please open Homebrew Channel and start Wii Mod Lite
echo 2. Using the +Control Pad on your Wii Remote, navigate to WAD Manager, and then navigate to the WAD folder.
echo 3. When IOS31.wad is highlighted, press +, then do the same for IOS80.wad and hit the A button.
echo 4. When you're done, press the HOME Button to go back to Homebrew Channel.
echo.
echo What to do now?
echo 1. Next page 2. Exit
set /p s=Choose: 
if %s%==1 goto 2_uninstall_5_2
if %s%==2 goto begin_main
goto 2_uninstall_5
:2_uninstall_5_2
cls
echo %header%
echo -----------------------------------------------------------------------------------------------------------------------------
echo.
echo Part II - Restoring the nwc24msg.cfg to it's factory default.
echo.
echo 1. Please launch WiiXplorer from the Homebrew Channel.
echo 2. In WiiXplorer, press Start -^> Settings -^> Boot Settings -^> NAND Write Access (turn on)
echo    - Remember to turn it on because it's important!
echo 3. Change your device to NAND (on the bar on top)
echo 4. Go to shared2 -^> wc24
echo 5. Hover your cursor over nwc24msg.cfg, press + on your Wii Remote and delete it.
echo 6. Go to Wii Menu (the nwc24msg.cfg file should regenerate with the same Friend Code)
echo.
echo What to do now?
echo 1. Previous page 2. Next page 2. Exit
set /p s=Choose: 
if %s%==1 goto 2_uninstall_5
if %s%==2 goto 2_uninstall_5_3
if %s%==3 goto begin_main
goto 2_uninstall_5_2
:2_uninstall_5_3
cls
echo %header%
echo -----------------------------------------------------------------------------------------------------------------------------
echo.
echo Part III - Disconnecting from RiiConnect24
echo.
echo 1. Go to Wii Options.
echo 2. Go to Wii Settings.
echo 3. Go to Page 2, then click on Internet.
echo 4. Go to Connection Settings.
echo 5. Select your current connection.
echo 6. Go to Change Settings.
echo 7. Go to Auto-Obtain DNS (Not IP Address), then select Yes.
echo 8. Select Save and do the connection test.
echo 9. When asking for update, press No to skip it.
echo.
echo What to do now?
echo 1. Previous page 2. Next page 2. Exit
set /p s=Choose: 
if %s%==1 goto 2_uninstall_5
if %s%==2 goto 2_uninstall_5_4
if %s%==3 goto begin_main
goto 2_uninstall_5_3
:2_uninstall_5_4
cls
echo %header%
echo -----------------------------------------------------------------------------------------------------------------------------
echo.
echo That's it! RiiConnect24 should be now gone from your Wii!
echo Please come back to us soon :)
echo.
echo Press any key to exit the patcher.
set /a exitmessage=0
pause>NUL
goto end
:2_uninstall_change_drive_letter
cls
echo %header%
echo -----------------------------------------------------------------------------------------------------------------------------
echo [*] SD Card
echo.
echo Current SD Card Letter: %sdcard%
echo.
echo Type in the new drive letter (e.g H)
set /p sdcard=
goto 2_uninstall_3_summary
:2_auto
cls
echo %header%
echo -----------------------------------------------------------------------------------------------------------------------------
echo.
echo Hello %username%, welcome to the automatic guided installation of RiiConnect24.
echo.
echo The patcher will download any files that are required to run the patcher if you are missing them.
echo The entire process should take about 1 to 2 minutes.
echo.
echo But before starting, you need to tell me one thing:
echo.
echo For Everybody Votes Channel, which region should I download and patch? (Where do you live?)
echo.
echo 1. Europe
echo 2. USA
set /p s=Choose one: 
if %s%==1 set /a evcregion=1& goto 2_1
if %s%==2 set /a evcregion=2& goto 2_1
goto 2_auto
:2_1
cls
echo %header%
echo -----------------------------------------------------------------------------------------------------------------------------
echo.
echo Great!
echo After passing this screen, any user interraction won't be needed so you can relax and let me do the work! :)
echo.
echo Did I forget about something? Yes! To make patching even easier, I can download everything that you need and put it on 
echo your SD Card!
echo.
echo Please connect your Wii SD Card to the computer.
echo.
echo 1. Connected!
echo 2. I can't connect an SD Card to the computer.
set /p s=
set sdcard=NUL
if %s%==1 set /a sdcardstatus=1& set tempgotonext=2_1_summary& goto detect_sd_card
if %s%==2 set /a sdcardstatus=0& set /a sdcard=NUL& goto 2_1_summary
goto 2_1
:detect_sd_card
set sdcard=NUL
:sd_a
set /a check=0
if exist A:\apps set /a check=%check%+1
if %check%==1 set sdcard=A
goto sd_b
:sd_b
set /a check=0
if exist B:\apps set /a check=%check%+1
if %check%==1 set sdcard=B
goto sd_d
:sd_d
set /a check=0
if exist D:\apps set /a check=%check%+1
if %check%==1 set sdcard=D
goto sd_e
:sd_e
set /a check=0
if exist E:\apps set /a check=%check%+1
if %check%==1 set sdcard=E
goto sd_f
:sd_f
set /a check=0
if exist F:\apps set /a check=%check%+1
if %check%==1 set sdcard=F
goto sd_g
:sd_g
set /a check=0
if exist G:\apps set /a check=%check%+1
if %check%==1 set sdcard=G
goto sd_h
:sd_h
set /a check=0
if exist H:\apps set /a check=%check%+1
if %check%==1 set sdcard=H
goto sd_i
:sd_i
set /a check=0
if exist I:\apps set /a check=%check%+1
if %check%==1 set sdcard=J
goto sd_j
:sd_j
set /a check=0
if exist J:\apps set /a check=%check%+1
if %check%==1 set sdcard=J
goto sd_k
:sd_k
set /a check=0
if exist K:\apps set /a check=%check%+1
if %check%==1 set sdcard=K
goto sd_l
:sd_l
set /a check=0
if exist L:\apps set /a check=%check%+1
if %check%==1 set sdcard=L
goto sd_m
:sd_m
set /a check=0
if exist M:\apps set /a check=%check%+1
if %check%==1 set sdcard=M
goto sd_n
:sd_n
set /a check=0
if exist N:\apps set /a check=%check%+1
if %check%==1 set sdcard=N
goto sd_o
:sd_o
set /a check=0
if exist O:\apps set /a check=%check%+1
if %check%==1 set sdcard=O
goto sd_p
:sd_p
set /a check=0
if exist P:\apps set /a check=%check%+1
if %check%==1 set sdcard=P
goto sd_r
:sd_r
set /a check=0
if exist R:\apps set /a check=%check%+1
if %check%==1 set sdcard=R
goto sd_s
:sd_s
set /a check=0
if exist S:\apps set /a check=%check%+1
if %check%==1 set sdcard=S
goto sd_t
:sd_t
set /a check=0
if exist T:\apps set /a check=%check%+1
if %check%==1 set sdcard=T
goto sd_u
:sd_u
set /a check=0
if exist U:\apps set /a check=%check%+1
if %check%==1 set sdcard=U
goto sd_w
:sd_w
set /a check=0
if exist W:\apps set /a check=%check%+1
if %check%==1 set sdcard=W
goto sd_x
:sd_x
set /a check=0
if exist X:\apps set /a check=%check%+1
if %check%==1 set sdcard=X
goto sd_y
:sd_y
set /a check=0
if exist Y:\apps set /a check=%check%+1
if %check%==1 set sdcard=Y
goto sd_z
:sd_z
set /a check=0
if exist Z:\apps set /a check=%check%+1
if %check%==1 set sdcard=Z
goto %tempgotonext%

:2_1_summary
cls
echo %header%
echo -----------------------------------------------------------------------------------------------------------------------------
echo.
if %sdcardstatus%==0 echo Aww, no worries. You will be able to copy files later after patching.
if %sdcardstatus%==1 if %sdcard%==NUL echo Hmm... looks like an SD Card wasn't found in your system. Please choose the `Change drive letter` option
if %sdcardstatus%==1 if %sdcard%==NUL echo to set your SD Card drive letter manually.
if %sdcardstatus%==1 if %sdcard%==NUL echo.
if %sdcardstatus%==1 if %sdcard%==NUL echo Otherwise, starting patching will set copying to manual so you will have to copy them later.
if %sdcardstatus%==1 if not %sdcard%==NUL echo Congrats! I've successfully detected your SD Card! Drive letter: %sdcard%
if %sdcardstatus%==1 if not %sdcard%==NUL echo I will be able to automatically download and install everything on your SD Card!	
echo.
echo The entire patching process will download about 30MB of data.
echo.
echo What's next?
if %sdcardstatus%==0 echo 1. Start Patching  2. Exit
if %sdcardstatus%==1 if %sdcard%==NUL echo 1. Start Patching 2. Exit 3. Change drive letter
if %sdcardstatus%==1 if not %sdcard%==NUL echo 1. Start Patching 2. Exit 3. Change drive letter

set /p s=Choose: 
if %s%==1 goto 2_2
if %s%==2 goto begin_main
if %s%==3 goto 2_change_drive_letter
goto 2_1_summary
:2_change_drive_letter
cls
echo %header%
echo -----------------------------------------------------------------------------------------------------------------------------
echo [*] SD Card
echo.
echo Current SD Card Letter: %sdcard%
echo.
echo Type in the new drive letter (e.g H)
set /p sdcard=
goto 2_1_summary
:2_2
cls
set /a temperrorlev=0
set /a counter_done=0
set /a percent=0
set /a temperrorlev=0
goto 2_3
:random_funfact
set /a funfact_number=%random% %% (1 + 39)
if /i %funfact_number% LSS 1 goto random_funfact
if /i %funfact_number% GTR 26 goto random_funfact
if %funfact_number%==1 set funfact=Did you know the wii was the best selling game-console of 2006?
if %funfact_number%==2 set funfact=Did you know KcPL makes these amazing pachers and the updates for the patcher?
if %funfact_number%==3 set funfact=In Mario Kart Wii, an unused mission mode was left in the game's files. In august 2017, famous Mario Kart Wii modder MrBean35000vr discovered the code for it.
if %funfact_number%==4 set funfact=The disc art for New Super Mario Bros Wii includes an easter egg: The way Mario, Luigi, and the toads are positioned actually resembled the buttons on an SNES controller.
if %funfact_number%==5 set funfact=RiiConnect24 originally started out as "CustomConnect24"!
if %funfact_number%==6 set funfact=Did you the RiiConnect24 logo was made by NeoRame, the same person who made the Wiimmfi logo?
if %funfact_number%==7 set funfact=The Wii was nicknamed “Revolution” during its development stage.
if %funfact_number%==8 set funfact=Did you know the letters in the Wii model number RVL stand for the Wii's codename, Revolution?
if %funfact_number%==9 set funfact=Super Mario Galaxy 2 was originally going to be an expansion of the first game instead of being a sequal. Its internal name, "Super Mario Galaxy More", reflects that.
if %funfact_number%==10 set funfact=Nintendo WFC wasn't as secure as Wiimmfi, so hackers were all over it before shutdown.
if %funfact_number%==11 set funfact=The Wii can also play Gamecube discs & homebrew.
if %funfact_number%==12 set funfact=The music used in many of the Wii's channels (including the Wii Shop, Mii, Check Mii Out, and Forecast Channel) was composed by Kazumi Totaka.
if %funfact_number%==13 set funfact=The Internet Channel once costed 500 Wii Points.
if %funfact_number%==14 set funfact=There have only been 5 Wii Remote color variants (excluding the Mario series and Special Edition Zelda variants): White, Black, Light Blue, Pink and Red.
if %funfact_number%==15 set funfact=It's possible to use candles as a sensor bar.
if %funfact_number%==16 set funfact=The blinking blue light that indicates a system message has been received is actually synced to the bird call of the Japanese bush warbler. More info about it on RiiConnect24 YouTube Channel!
if %funfact_number%==17 set funfact=On the Photo Channel, the "Undo All" option when doodling makes the same "rocket ship" erase graphic and horn sound effect as an erase option in Mario Paint.
if %funfact_number%==18 set funfact=In the console's BIOS, there is a unused disk graphic which represents a DVD Video. It's possible that there were plans for support of DVD Videos.
if %funfact_number%==19 set funfact=In 2009, publisher THQ gifted Queen Elizabeth a gold plated Wii to mark the release of their game Big Family Games! The Queen played Wii Bowling, but not with the golden Wii THQ gifted her, in fact, the Queen never got the golden Wii.
if %funfact_number%==20 set funfact=Wii sports is the most sold game on the wii. it sold 82.85 million. Overall it is the 3rd most sold game in the world.
if %funfact_number%==21 set funfact=Did you know that they Wii had a service in Japan where you could order food?
if %funfact_number%==22 set funfact=For very mysterious reasons, asking when a service will be released doesn’t actually speed up the time it takes for said service to be released.
if %funfact_number%==23 set funfact=Did you know that most of the scripts used to make RiiConnect24 work are written in Python?
if %funfact_number%==24 set funfact=Thank you Spotlight for making our mail system secure.
if %funfact_number%==25 set funfact=Did you know that RiiConnect24 works with every system version? Only the Wii Mail works on 4.3 because 4.3 runs on IOS 80.
if %funfact_number%==26 set funfact=Did you know that we have an awesome Discord server where you can always stay updated about the project status?
set /a percent=%percent%+1
goto 2_3
:2_3
if %percent%==0 goto random_funfact
if %percent%==50 goto random_funfact
set /a percent=%percent%+1

if /i %percent% GTR 0 if /i %percent% LSS 10 set /a counter_done=0
if /i %percent% GTR 10 if /i %percent% LSS 20 set /a counter_done=1
if /i %percent% GTR 20 if /i %percent% LSS 30 set /a counter_done=2
if /i %percent% GTR 30 if /i %percent% LSS 40 set /a counter_done=3
if /i %percent% GTR 40 if /i %percent% LSS 50 set /a counter_done=4
if /i %percent% GTR 50 if /i %percent% LSS 60 set /a counter_done=5
if /i %percent% GTR 60 if /i %percent% LSS 70 set /a counter_done=6
if /i %percent% GTR 70 if /i %percent% LSS 80 set /a counter_done=7
if /i %percent% GTR 80 if /i %percent% LSS 90 set /a counter_done=8
if /i %percent% GTR 90 if /i %percent% LSS 100 set /a counter_done=9
if %percent%==100 set /a counter_done=10
cls
echo.
echo %header%
echo ---------------------------------------------------------------------------------------------------------------------------
echo  [*] Patching... this can take some time
echo.
echo Fun Fact: %funfact%
echo.
echo    Progress: 
if %counter_done%==0 echo :          : %percent% %%
if %counter_done%==1 echo :-         : %percent% %%
if %counter_done%==2 echo :--        : %percent% %%
if %counter_done%==3 echo :---       : %percent% %%
if %counter_done%==4 echo :----      : %percent% %%
if %counter_done%==5 echo :-----     : %percent% %%
if %counter_done%==6 echo :------    : %percent% %%
if %counter_done%==7 echo :-------   : %percent% %%
if %counter_done%==8 echo :--------  : %percent% %%
if %counter_done%==9 echo :--------- : %percent% %%
if %counter_done%==10 echo :----------: %percent% %%

::Download files
if %percent%==1 if not exist IOSPatcher md IOSPatcher
if %percent%==1 if not exist "IOSPatcher/00000006-31.delta" powershell -command "(new-object System.Net.WebClient).DownloadFile('"%FilesHostedOn%/IOSPatcher/00000006-31.delta"', 'IOSPatcher/00000006-31.delta"')"
if %percent%==1 set /a temperrorlev=%errorlevel%
if %percent%==1 set modul=Downloading 06-31.delta
if %percent%==1 if not %temperrorlev%==0 goto error_patching

if %percent%==2 if not exist "IOSPatcher/00000006-80.delta" powershell -command "(new-object System.Net.WebClient).DownloadFile('"%FilesHostedOn%/IOSPatcher/00000006-80.delta"', 'IOSPatcher/00000006-80.delta"')"
if %percent%==2 set /a temperrorlev=%errorlevel%
if %percent%==2 set modul=Downloading 06-80.delta
if %percent%==2 if not %temperrorlev%==0 goto error_patching

if %percent%==3 if not exist "IOSPatcher/00000006-80.delta" powershell -command "(new-object System.Net.WebClient).DownloadFile('"%FilesHostedOn%/IOSPatcher/00000006-80.delta"', 'IOSPatcher/00000006-80.delta"')"
if %percent%==3 set /a temperrorlev=%errorlevel%
if %percent%==3 set modul=Downloading 06-80.delta
if %percent%==3 if not %temperrorlev%==0 goto error_patching

if %percent%==4 if not exist "IOSPatcher/libWiiSharp.dll" powershell -command "(new-object System.Net.WebClient).DownloadFile('"%FilesHostedOn%/IOSPatcher/libWiiSharp.dll"', 'IOSPatcher/libWiiSharp.dll"')"
if %percent%==4 set /a temperrorlev=%errorlevel%
if %percent%==4 set modul=Downloading libWiiSharp.dll
if %percent%==4 if not %temperrorlev%==0 goto error_patching

if %percent%==5 if not exist "IOSPatcher/Sharpii.exe" powershell -command "(new-object System.Net.WebClient).DownloadFile('"%FilesHostedOn%/IOSPatcher/Sharpii.exe"', 'IOSPatcher/Sharpii.exe"')"
if %percent%==5 set /a temperrorlev=%errorlevel%
if %percent%==5 set modul=Downloading Sharpii.exe
if %percent%==5 if not %temperrorlev%==0 goto error_patching

if %percent%==6 if not exist "IOSPatcher/WadInstaller.dll" powershell -command "(new-object System.Net.WebClient).DownloadFile('"%FilesHostedOn%/IOSPatcher/WadInstaller.dll"', 'IOSPatcher/WadInstaller.dll"')"
if %percent%==6 set /a temperrorlev=%errorlevel%
if %percent%==6 set modul=Downloading WadInstaller.dll
if %percent%==6 if not %temperrorlev%==0 goto error_patching

if %percent%==7 if not exist "IOSPatcher/xdelta3.exe" powershell -command "(new-object System.Net.WebClient).DownloadFile('"%FilesHostedOn%/IOSPatcher/xdelta3.exe"', 'IOSPatcher/xdelta3.exe"')"
if %percent%==7 set /a temperrorlev=%errorlevel%
if %percent%==7 set modul=Downloading xdelta3.exe
if %percent%==7 if not %temperrorlev%==0 goto error_patching

if %percent%==9 if not exist EVCPatcher/patch md EVCPatcher\patch
if %percent%==9 if not exist EVCPatcher/dwn md EVCPatcher\dwn
if %percent%==9 if not exist EVCPatcher/dwn/0001000148414A45v512 md EVCPatcher\dwn\0001000148414A45v512
if %percent%==9 if not exist EVCPatcher/dwn/0001000148414A50v512 md EVCPatcher\dwn\0001000148414A50v512
if %percent%==9 if not exist EVCPatcher/pack md EVCPatcher\pack
if %percent%==9 if not exist "EVCPatcher/patch/Europe.delta" powershell -command "(new-object System.Net.WebClient).DownloadFile('"%FilesHostedOn%/EVCPatcher/patch/Europe.delta"', '"EVCPatcher/patch/Europe.delta"')"
if %percent%==9 set /a temperrorlev=%errorlevel%
if %percent%==9 set modul=Downloading Europe Delta
if %percent%==9 if not %temperrorlev%==0 goto error_patching

if %percent%==10 if not exist "EVCPatcher/patch/USA.delta" powershell -command "(new-object System.Net.WebClient).DownloadFile('"%FilesHostedOn%/EVCPatcher/patch/USA.delta"', 'EVCPatcher/patch/USA.delta"')"
if %percent%==10 set /a temperrorlev=%errorlevel%
if %percent%==10 set modul=Downloading Europe Delta
if %percent%==10 if not %temperrorlev%==0 goto error_patching

if %percent%==10 if not exist "EVCPatcher/NUS_Downloader_Decrypt.exe" powershell -command "(new-object System.Net.WebClient).DownloadFile('"%FilesHostedOn%/EVCPatcher/NUS_Downloader_Decrypt.exe"', 'EVCPatcher/NUS_Downloader_Decrypt.exe"')"
if %percent%==10 set /a temperrorlev=%errorlevel%
if %percent%==10 set modul=Downloading EUR evc
if %percent%==10 if not %temperrorlev%==0 goto error_patching

if %percent%==11 if not exist "EVCPatcher/patch/xdelta3.exe" powershell -command "(new-object System.Net.WebClient).DownloadFile('"%FilesHostedOn%/EVCPatcher/patch/xdelta3.exe"', 'EVCPatcher/patch/xdelta3.exe"')"
if %percent%==11 set /a temperrorlev=%errorlevel%
if %percent%==11 set modul=Downloading xdelta3.exe
if %percent%==11 if not %temperrorlev%==0 goto error_patching


if %percent%==12 if not exist "EVCPatcher/pack/libWiiSharp.dll" powershell -command "(new-object System.Net.WebClient).DownloadFile('"%FilesHostedOn%/EVCPatcher/pack/libWiiSharp.dll"', 'EVCPatcher/pack/libWiiSharp.dll"')"
if %percent%==12 set /a temperrorlev=%errorlevel%
if %percent%==12 set modul=Downloading libWiiSharp.dll
if %percent%==12 if not %temperrorlev%==0 goto error_patching

if %percent%==13 if not exist "EVCPatcher/pack/Sharpii.exe" powershell -command "(new-object System.Net.WebClient).DownloadFile('"%FilesHostedOn%/EVCPatcher/pack/Sharpii.exe"', 'EVCPatcher/pack/Sharpii.exe"')"
if %percent%==13 set /a temperrorlev=%errorlevel%
if %percent%==13 set modul=Downloading Sharpii.exe
if %percent%==13 if not %temperrorlev%==0 goto error_patching

if %percent%==14 if not exist "EVCPatcher/dwn/Sharpii.exe" powershell -command "(new-object System.Net.WebClient).DownloadFile('"%FilesHostedOn%/EVCPatcher/dwn/Sharpii.exe"', 'EVCPatcher/dwn/Sharpii.exe"')"
if %percent%==14 set /a temperrorlev=%errorlevel%
if %percent%==14 set modul=Downloading Sharpii.exe
if %percent%==14 if not %temperrorlev%==0 goto error_patching

if %percent%==15 if not exist "EVCPatcher/dwn/libWiiSharp.dll" powershell -command "(new-object System.Net.WebClient).DownloadFile('"%FilesHostedOn%/EVCPatcher/dwn/libWiiSharp.dll"', 'EVCPatcher/dwn/libWiiSharp.dll"')"
if %percent%==15 set /a temperrorlev=%errorlevel%
if %percent%==15 set modul=Downloading libWiiSharp.dll
if %percent%==15 if not %temperrorlev%==0 goto error_patching

if %percent%==16 if not exist "EVCPatcher/dwn/0001000148414A45v512/cetk" powershell -command "(new-object System.Net.WebClient).DownloadFile('"%FilesHostedOn%/EVCPatcher/dwn/0001000148414A45v512/cetk"', 'EVCPatcher/dwn/0001000148414A45v512/cetk"')"
if %percent%==16 set /a temperrorlev=%errorlevel%
if %percent%==16 set modul=Downloading USA CETK
if %percent%==16 if not %temperrorlev%==0 goto error_patching

if %percent%==17 if not exist "EVCPatcher/dwn/0001000148414A50v512/cetk" powershell -command "(new-object System.Net.WebClient).DownloadFile('"%FilesHostedOn%/EVCPatcher/dwn/0001000148414A50v512/cetk"', 'EVCPatcher/dwn/0001000148414A50v512/cetk"')"
if %percent%==17 set /a temperrorlev=%errorlevel%
if %percent%==17 set modul=Downloading EUR CETK
if %percent%==17 if not %temperrorlev%==0 goto error_patching

if %percent%==18 if not exist apps md apps
if %percent%==18 if not exist apps/Mail-Patcher md apps\Mail-Patcher
if %percent%==18 if not exist "apps/Mail-Patcher/boot.dol" powershell -command "(new-object System.Net.WebClient).DownloadFile('"%FilesHostedOn%/apps/Mail-Patcher/boot.dol"', 'apps/Mail-Patcher/boot.dol"')"
if %percent%==18 set /a temperrorlev=%errorlevel%
if %percent%==18 set modul=Downloading Mail Patcher
if %percent%==18 if not %temperrorlev%==0 goto error_patching


if %percent%==19 if not exist "apps/Mail-Patcher/icon.png" powershell -command "(new-object System.Net.WebClient).DownloadFile('"%FilesHostedOn%/apps/Mail-Patcher/icon.png"', 'apps/Mail-Patcher/icon.png"')"
if %percent%==19 set /a temperrorlev=%errorlevel%
if %percent%==19 set modul=Downloading Mail Patcher
if %percent%==19 if not %temperrorlev%==0 goto error_patching


if %percent%==20 if not exist "apps/Mail-Patcher/meta.xml" powershell -command "(new-object System.Net.WebClient).DownloadFile('"%FilesHostedOn%/apps/Mail-Patcher/meta.xml"', 'apps/Mail-Patcher/meta.xml"')"
if %percent%==20 set /a temperrorlev=%errorlevel%
if %percent%==20 set modul=Downloading Mail Patcher
if %percent%==20 if not %temperrorlev%==0 goto error_patching


if %percent%==21 if not exist apps/WiiModLite md apps\WiiModLite
if %percent%==21 if not exist apps/Mail-Patcher md apps\Mail-Patcher
if %percent%==21 if not exist "apps/WiiModLite/boot.dol" powershell -command "(new-object System.Net.WebClient).DownloadFile('"%FilesHostedOn%/apps/WiiModLite/boot.dol"', 'apps/WiiModLite/boot.dol"')"
if %percent%==21 set /a temperrorlev=%errorlevel%
if %percent%==21 set modul=Downloading Wii Mod Lite
if %percent%==21 if not %temperrorlev%==0 goto error_patching

if %percent%==22 if not exist "apps/WiiModLite/database.txt" powershell -command "(new-object System.Net.WebClient).DownloadFile('"%FilesHostedOn%/apps/WiiModLite/database.txt"', 'apps/WiiModLite/database.txt"')"
if %percent%==22 set /a temperrorlev=%errorlevel%
if %percent%==22 set modul=Downloading Wii Mod Lite
if %percent%==22 if not %temperrorlev%==0 goto error_patching

if %percent%==23 if not exist "apps/WiiModLite/icon.png" powershell -command "(new-object System.Net.WebClient).DownloadFile('"%FilesHostedOn%/apps/WiiModLite/icon.png"', 'apps/WiiModLite/icon.png"')"
if %percent%==23 set /a temperrorlev=%errorlevel%
if %percent%==23 set modul=Downloading Wii Mod Lite
if %percent%==23 if not %temperrorlev%==0 goto error_patching

if %percent%==24 if not exist "apps/WiiModLite/icon.png" powershell -command "(new-object System.Net.WebClient).DownloadFile('"%FilesHostedOn%/apps/WiiModLite/icon.png"', 'apps/WiiModLite/icon.png"')"
if %percent%==24 set /a temperrorlev=%errorlevel%
if %percent%==24 set modul=Downloading Wii Mod Lite
if %percent%==24 if not %temperrorlev%==0 goto error_patching

if %percent%==25 if not exist "apps/WiiModLite/meta.xml" powershell -command "(new-object System.Net.WebClient).DownloadFile('"%FilesHostedOn%/apps/WiiModLite/meta.xml"', 'apps/WiiModLite/meta.xml"')"
if %percent%==25 set /a temperrorlev=%errorlevel%
if %percent%==25 set modul=Downloading Wii Mod Lite
if %percent%==25 if not %temperrorlev%==0 goto error_patching

if %percent%==26 if not exist "apps/WiiModLite/wiimod.txt" powershell -command "(new-object System.Net.WebClient).DownloadFile('"%FilesHostedOn%/apps/WiiModLite/wiimod.txt"', 'apps/WiiModLite/wiimod.txt"')"
if %percent%==26 set /a temperrorlev=%errorlevel%
if %percent%==26 set modul=Downloading Wii Mod Lite
if %percent%==26 if not %temperrorlev%==0 goto error_patching

if %percent%==27 if not exist "EVCPatcher/patch/Europe.delta" powershell -command "(new-object System.Net.WebClient).DownloadFile('"%FilesHostedOn%EVCPatcher/patch/Europe.delta"', '"EVCPatcher/patch/Europe.delta"')"
if %percent%==27 set /a temperrorlev=%errorlevel%
if %percent%==27 set modul=Downloading Europe Delta
if %percent%==27 if not %temperrorlev%==0 goto error_patching

if %percent%==28 if not exist "EVCPatcher/patch/USA.delta" powershell -command "(new-object System.Net.WebClient).DownloadFile('"%FilesHostedOn%/EVCPatcher/patch/USA.delta"', 'EVCPatcher/patch/USA.delta"')"
if %percent%==28 set /a temperrorlev=%errorlevel%
if %percent%==28 set modul=Downloading Wii Mod Lite
if %percent%==28 if not %temperrorlev%==0 goto error_patching

::IOS Patcher
if %percent%==29 call IOSPatcher\Sharpii.exe NUSD -ios 31 -v latest -o IOSPatcher\IOS31-old.wad -wad >NUL
if %percent%==29 set /a temperrorlev=%errorlevel%
if %percent%==29 set modul=Sharpii.exe
if %percent%==29 if not %temperrorlev%==0 goto error_patching

if %percent%==30 call IOSPatcher\Sharpii.exe NUSD -ios 80 -v latest -o IOSPatcher\IOS80-old.wad -wad >NUL
if %percent%==30 set /a temperrorlev=%errorlevel%
if %percent%==30 set modul=Sharpii.exe
if %percent%==30 if not %temperrorlev%==0 goto error_patching

if %percent%==31 call IOSPatcher\Sharpii.exe WAD -u IOSPatcher\IOS31-old.wad IOSPatcher/IOS31/ >NUL
if %percent%==31 set /a temperrorlev=%errorlevel%
if %percent%==31 set modul=Sharpii.exe
if %percent%==31 if not %temperrorlev%==0 goto error_patching

if %percent%==32 call IOSPatcher\Sharpii.exe WAD -u IOSPatcher\IOS80-old.wad IOSPatcher\IOS80/ >NUL
if %percent%==32 set /a temperrorlev=%errorlevel%
if %percent%==32 set modul=Sharpii.exe
if %percent%==32 if not %temperrorlev%==0 goto error_patching

if %percent%==34 move /y IOSPatcher\IOS31\00000006.app IOSPatcher\00000006.app >NUL
if %percent%==34 set /a temperrorlev=%errorlevel%
if %percent%==34 set modul=move.exe
if %percent%==34 if not %temperrorlev%==0 goto error_patching

if %percent%==36 call IOSPatcher\xdelta3.exe -f -d -s IOSPatcher\00000006.app IOSPatcher\00000006-31.delta IOSPatcher\IOS31\00000006.app >NUL
if %percent%==36 set /a temperrorlev=%errorlevel%
if %percent%==36 set modul=xdelta.exe
if %percent%==36 if not %temperrorlev%==0 goto error_patching

if %percent%==38 move /y IOSPatcher\IOS80\00000006.app IOSPatcher\00000006.app >NUL
if %percent%==38 set /a temperrorlev=%errorlevel%
if %percent%==38 set modul=move.exe
if %percent%==38 if not %temperrorlev%==0 goto error_patching

if %percent%==40 call IOSPatcher\xdelta3.exe -f -d -s IOSPatcher\00000006.app IOSPatcher\00000006-80.delta IOSPatcher\IOS80\00000006.app >NUL
if %percent%==40 set /a temperrorlev=%errorlevel%
if %percent%==40 set modul=xdelta3.exe
if %percent%==40 if not %temperrorlev%==0 goto error_patching

if %percent%==42 if not exist IOSPatcher\WAD mkdir IOSPatcher\WAD
if %percent%==42 set /a temperrorlev=%errorlevel%
if %percent%==42 set modul=mkdir.exe
if %percent%==42 if not %temperrorlev%==0 goto error_patching

if %percent%==44 call IOSPatcher\Sharpii.exe WAD -p IOSPatcher\IOS31\ IOSPatcher\WAD\IOS31.wad -fs >NUL
if %percent%==44 set /a temperrorlev=%errorlevel%
if %percent%==44 set modul=Sharpii.exe
if %percent%==44 if not %temperrorlev%==0 goto error_patching

if %percent%==45 call IOSPatcher\Sharpii.exe WAD -p IOSPatcher\IOS80\ IOSPatcher\WAD\IOS80.wad -fs >NUL
if %percent%==45 set /a temperrorlev=%errorlevel%
if %percent%==45 set modul=Sharpii.exe
if %percent%==45 if not %temperrorlev%==0 goto error_patching

if %percent%==47 del IOSPatcher\00000006.app /q >NUL
if %percent%==47 set /a temperrorlev=%errorlevel%
if %percent%==47 set modul=del.exe
if %percent%==47 if not %temperrorlev%==0 goto error_patching

if %percent%==48 del IOSPatcher\IOS31-old.wad /q >NUL
if %percent%==48 set /a temperrorlev=%errorlevel%
if %percent%==48 set modul=del.exe
if %percent%==48 if not %temperrorlev%==0 goto error_patching

if %percent%==49 del IOSPatcher\IOS80-old.wad /q >NUL
if %percent%==49 set /a temperrorlev=%errorlevel%
if %percent%==49 set modul=del.exe
if %percent%==49 if not %temperrorlev%==0 goto error_patching

if %percent%==50 if exist IOSPatcher\IOS31 rmdir /s /q IOSPatcher\IOS31 >NUL
if %percent%==50 set /a temperrorlev=%errorlevel%
if %percent%==50 set modul=rmdir.exe
if %percent%==50 if not %temperrorlev%==0 goto error_patching

if %percent%==51 if exist IOSPatcher\IOS80 rmdir /s /q IOSPatcher\IOS80 >NUL
if %percent%==51 set /a temperrorlev=%errorlevel%
if %percent%==51 set modul=rmdir.exe
if %percent%==51 if not %temperrorlev%==0 goto error_patching

if %percent%==52 call IOSPatcher\Sharpii.exe IOS IOSPatcher\WAD\IOS31.wad -fs -es -np -vp>NUL
if %percent%==52 set /a temperrorlev=%errorlevel%
if %percent%==52 set modul=Sharpii.exe
if %percent%==52 if not %temperrorlev%==0 goto error_patching

if %percent%==53 call IOSPatcher\Sharpii.exe IOS IOSPatcher\WAD\IOS80.wad -fs -es -np -vp>NUL
if %percent%==53 set /a temperrorlev=%errorlevel%
if %percent%==53 set modul=Sharpii.exe
if %percent%==53 if not %temperrorlev%==0 goto error_patching

if %percent%==54 if not exist WAD md WAD
if %percent%==54 move "IOSPatcher\WAD\IOS31.wad" "WAD"
if %percent%==54 move "IOSPatcher\WAD\IOS80.wad" "WAD"

if %percent%==55 if exist IOSPatcher rmdir /s /q IOSPatcher
::EVC Patcher

if %percent%==57 if not exist 0001000148414A50v512 md 0001000148414A50v512
if %percent%==57 if not exist 0001000148414A45v512 md 0001000148414A45v512
if %percent%==57 if not exist 0001000148414A50v512\cetk copy /y "EVCPatcher\dwn\0001000148414A50v512\cetk" "0001000148414A50v512\cetk"

if %percent%==57 if not exist 0001000148414A45v512\cetk copy /y "EVCPatcher\dwn\0001000148414A45v512\cetk" "0001000148414A45v512\cetk"

::USA
if %percent%==60 if %evcregion%==2 call EVCPatcher\dwn\sharpii.exe NUSD -id 0001000148414A45 -v 512 -encrypt >NUL
::PAL
if %percent%==60 if %evcregion%==1 call EVCPatcher\dwn\sharpii.exe NUSD -id 0001000148414A50 -v 512 -encrypt >NUL
if %percent%==60 set /a temperrorlev=%errorlevel%
if %percent%==60 set modul=Downloading EVC
if %percent%==60 if not %temperrorlev%==0 goto error_patching

if %percent%==61 if %evcregion%==1 copy /y "EVCPatcher\NUS_Downloader_Decrypt.exe" "0001000148414A50v512"
if %percent%==61 if %evcregion%==2 copy /y "EVCPatcher\NUS_Downloader_Decrypt.exe" "0001000148414A45v512"
if %percent%==61 set /a temperrorlev=%errorlevel%
if %percent%==61 set modul=Copying NDC.exe
if %percent%==61 if not %temperrorlev%==0 goto error_patching

if %percent%==62 if %evcregion%==1 ren "0001000148414A50v512\tmd.512" "tmd"
if %percent%==62 if %evcregion%==2 ren "0001000148414A45v512\tmd.512" "tmd"
if %percent%==63 set /a temperrorlev=%errorlevel%
if %percent%==62 set modul=Renaming files
if %percent%==62 if not %temperrorlev%==0 goto error_patching

if %percent%==63 if %evcregion%==1 cd 0001000148414A50v512
if %percent%==63 if %evcregion%==1 call NUS_Downloader_Decrypt.exe >NUL
if %percent%==63 if %evcregion%==2 cd 0001000148414A45v512
if %percent%==63 if %evcregion%==2 call NUS_Downloader_Decrypt.exe >NUL
if %percent%==63 set /a temperrorlev=%errorlevel%
if %percent%==63 set modul=Decrypter error
if %percent%==63 if not %temperrorlev%==0 cd..& goto error_patching
if %percent%==63 cd..

if %percent%==64 if %evcregion%==1 move /y "0001000148414A50v512\HAJP.wad" "EVCPatcher\pack"
if %percent%==64 if %evcregion%==2 move /y "0001000148414A45v512\HAJE.wad" "EVCPatcher\pack"
if %percent%==64 set /a temperrorlev=%errorlevel%
if %percent%==64 set modul=move.exe
if %percent%==64 if not %temperrorlev%==0 goto error_patching

if %percent%==70 if %evcregion%==1 call EVCPatcher\pack\Sharpii.exe WAD -u EVCPatcher\pack\HAJP.wad EVCPatcher\pack\unencrypted >NUL
if %percent%==70 if %evcregion%==2 call EVCPatcher\pack\Sharpii.exe WAD -u EVCPatcher\pack\HAJE.wad EVCPatcher\pack\unencrypted >NUL

if %percent%==71 move /y "EVCPatcher\pack\unencrypted\00000001.app" "00000001.app"
if %percent%==71 set /a temperrorlev=%errorlevel%
if %percent%==71 set modul=move.exe
if %percent%==71 if not %temperrorlev%==0 goto error_patching

if %percent%==72 if %evcregion%==1 call EVCPatcher\patch\xdelta3.exe -f -d -s 00000001.app EVCPatcher\patch\Europe.delta EVCPatcher\pack\unencrypted\00000001.app
if %percent%==72 if %evcregion%==2 call EVCPatcher\patch\xdelta3.exe -f -d -s 00000001.app EVCPatcher\patch\USA.delta EVCPatcher\pack\unencrypted\00000001.app
if %percent%==72 set /a temperrorlev=%errorlevel%
if %percent%==72 set modul=xdelta.exe EVC
if %percent%==72 if not %temperrorlev%==0 goto error_patching

if %percent%==80 if %evcregion%==1 call EVCPatcher\pack\Sharpii.exe WAD -p "EVCPatcher\pack\unencrypted" "WAD\Everybody Votes Channel RiiConnect24 Europe" -f 
if %percent%==80 if %evcregion%==2 call EVCPatcher\pack\Sharpii.exe WAD -p "EVCPatcher\pack\unencrypted" "WAD\Everybody Votes Channel RiiConnect24 USA" -f
if %percent%==80 set /a temperrorlev=%errorlevel%
if %percent%==80 set modul=Packing EVC WAD
if %percent%==80 if not %temperrorlev%==0 goto error_patching

if %percent%==85 if not %sdcard%==NUL set /a errorcopying=0
if %percent%==85 if not %sdcard%==NUL if not exist "%sdcard%:\WAD" md "%sdcard%:\WAD"
if %percent%==85 if not %sdcard%==NUL if not exist "%sdcard%:\apps" md "%sdcard%:\apps"

if %percent%==95 if not %sdcard%==NUL xcopy /y "WAD" "%sdcard%:\WAD" /e >NUL || set /a errorcopying=1
if %percent%==95 if not %sdcard%==NUL xcopy /y "apps" "%sdcard%:\apps" /e >NUL || set /a errorcopying=1

if %percent%==99 rmdir /s /q 0001000148414A45v512
if %percent%==99 rmdir /s /q 0001000148414A50v512
if %percent%==99 rmdir /s /q IOSPatcher
if %percent%==99 rmdir /s /q EVCPatcher
if %percent%==99 del /q 00000001.app

if %percent%==100 goto 2_4
ping localhost -n 1 >NUL
goto 2_3
:2_4
cls
echo.
echo %header%
echo ---------------------------------------------------------------------------------------------------------------------------
echo Patching done!
echo.
if %sdcardstatus%==0 echo Please connect your Wii SD Card and copy apps and WAD folder to the root (main folder) of your SD Card. You can find these folders next to RiiConnect24Patcher.bat
if %sdcardstatus%==1 if %sdcard%==NUL echo Please connect your Wii SD Card and copy apps and WAD folder to the root (main folder) of your SD Card. You can find these folders next to RiiConnect24Patcher.bat

if %sdcardstatus%==1 if not %sdcard%==NUL if %errorcopying%==0 echo Every file is in it's place on your SD Card!
if %sdcardstatus%==1 if not %sdcard%==NUL if %errorcopying%==1 echo Unfortunately, I wasn't able to put some of the files on your SD Card. Please copy WAD and apps folder manually to the root (main folder) of your SD Card. You can find these folders next to RiiConnect24Patcher.bat.
echo.
echo Please proceed with the tutorial that you can find on https://wii.guide/riiconnect24
echo.
echo Press any key to close this patcher.
pause>NUL
goto end
:end
set /a exiting=10
set /a timeouterror=1
timeout 1 /nobreak >NUL && set /a timeouterror=0
goto end1
:end1
cls
echo.
echo %header%
echo ---------------------------------------------------------------------------------------------------------------------------
echo  [*] Thank you very much for using this patcher! :)
echo.
if %exitmessage%==1 echo Have fun using RiiConnect24!
echo Closing the patcher in:
if %exiting%==10 echo :----------: 10
if %exiting%==9 echo :--------- : 9
if %exiting%==8 echo :--------  : 8
if %exiting%==7 echo :-------   : 7
if %exiting%==6 echo :------    : 6
if %exiting%==5 echo :-----     : 5
if %exiting%==4 echo :----      : 4
if %exiting%==3 echo :---       : 3
if %exiting%==2 echo :--        : 2
if %exiting%==1 echo :-         : 1
if %exiting%==0 echo :          :
if %exiting%==0 exit
if %timeouterror%==0 timeout 1 /nobreak >NUL
if %timeouterror%==1 ping localhost -n 2 >NUL
set /a exiting=%exiting%-1
goto end1

:error_patching
cls
echo %header%                                                                
echo              `..````                                                  
echo              yNNNNNNNNMNNmmmmdddhhhyyyysssooo+++/:--.`                
echo              hNNNNNNNNMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMd                
echo              ddmNNd:dNMMMMNMMMMMMMMMMMMMMMMMMMMMMMMMMs                
echo             `mdmNNy dNMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM+        
echo             .mmmmNs mNMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM:                
echo             :mdmmN+`mNMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM.                
echo             /mmmmN:-mNMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMN            
echo             ommmmN.:mMMMMMMMMMMMMmNMMMMMMMMMMMMMMMMMd                 
echo             smmmmm`+mMMMMMMMMMNhMNNMNNMMMMMMMMMMMMMMy                 
echo             hmmmmh omMMMMMMMMMmhNMMMmNNNNMMMMMMMMMMM+                 
echo ---------------------------------------------------------------------------------------------------------------------------
echo    /---\   ERROR.              
echo   /     \  There was an error while patching.
echo  /   !   \ Error Code: %temperrorlev%
echo  --------- Failing module: %modul% / %percent%
echo.
echo.
if %temperrorlev%==-532459699 echo Please check your internet connection.
if %temperrorlev%==-2146232576 echo Please install .NET Framework 3.5, than try to patch again.  
echo       Press any key to return to main menu.
echo ---------------------------------------------------------------------------------------------------------------------------
echo           :mdmmmo-mNNNNNNNNNNdyo++sssyNMMMMMMMMMhs+-                  
echo          .+mmdhhmmmNNNNNNmdysooooosssomMMMNNNMMMm                     
echo          o/ossyhdmmNNmdyo+++oooooosssoyNMMNNNMMMM+                    
echo          o/::::::://++//+++ooooooo+oo++mNMMmNNMMMm                    
echo         `o//::::::::+////+++++++///:/+shNMMNmNNmMM+                   
echo         .o////////::+++++++oo++///+syyyymMmNmmmNMMm                   
echo         -+//////////o+ooooooosydmdddhhsosNMMmNNNmho            `:/    
echo         .+++++++++++ssss+//oyyysso/:/shmshhs+:.          `-/oydNNNy   
echo           `..-:/+ooss+-`          +mmhdy`           -/shmNNNNNdy+:`   
echo                   `.              yddyo++:    `-/oymNNNNNdy+:`        
echo                                   -odhhhhyddmmmmmNNmhs/:`             
echo                                     :syhdyyyyso+/-`                   
pause>NUL
goto begin_main
:2_manual
cls
echo %header%
echo ----------------------------------------------------------------------------------------------------------------------------- 
echo.
echo RiiConnect24 Patcher Manual Mode.
if %tempiospatcher%==1 echo --- Patching IOS Complete ---
if %tempiospatcher%==1 echo Please copy IOS31.wad and IOS80.wad inside WAD folder to your Wii SD Card.
if %tempevcpatcher%==1 echo --- Patching Everybody Votes Channel Complete ---
if %tempevcpatcher%==1 echo Please copy Everybody Votes Channel.wad inside WAD folder to your Wii SD Card.
if %tempsdcardapps%==1 echo --- Downloading Apps Complete ---
if %tempsdcardapps%==1 echo Please copy the apps folder to your Wii SD Card.

echo.
echo Please choose what you want to patch.
echo.
echo 1. Patch RiiConnect IOS 31 and IOS 80
echo 2. Patch Everybody Votes Channel
echo 3. Download Wii Mod Lite and Mail Patcher
echo R. Return to previous menu
echo.
set /p s=Choose: 
if %s%==1 goto 3_iospatch
if %s%==2 goto 3_evc_patch
if %s%==3 goto 3_download
if %s%==r goto 1
if %s%==R goto 1
goto 2_manual

:3_iospatch
cls
echo.
echo %header%
echo ---------------------------------------------------------------------------------------------------------------------------
echo  [*] Patching IOS's... this can take some time.
echo.
if not exist IOSPatcher md IOSPatcher
if not exist "IOSPatcher/00000006-31.delta" powershell -command "(new-object System.Net.WebClient).DownloadFile('"%FilesHostedOn%/IOSPatcher/00000006-31.delta"', 'IOSPatcher/00000006-31.delta"')"
set /a temperrorlev=%errorlevel%
set modul=Downloading 06-31.delta
if not %temperrorlev%==0 goto error_patching

if not exist "IOSPatcher/00000006-80.delta" powershell -command "(new-object System.Net.WebClient).DownloadFile('"%FilesHostedOn%/IOSPatcher/00000006-80.delta"', 'IOSPatcher/00000006-80.delta"')"
set /a temperrorlev=%errorlevel%
set modul=Downloading 06-80.delta
if not %temperrorlev%==0 goto error_patching

if not exist "IOSPatcher/00000006-80.delta" powershell -command "(new-object System.Net.WebClient).DownloadFile('"%FilesHostedOn%/IOSPatcher/00000006-80.delta"', 'IOSPatcher/00000006-80.delta"')"
set /a temperrorlev=%errorlevel%
set modul=Downloading 06-80.delta
if not %temperrorlev%==0 goto error_patching

if not exist "IOSPatcher/libWiiSharp.dll" powershell -command "(new-object System.Net.WebClient).DownloadFile('"%FilesHostedOn%/IOSPatcher/libWiiSharp.dll"', 'IOSPatcher/libWiiSharp.dll"')"
set /a temperrorlev=%errorlevel%
set modul=Downloading libWiiSharp.dll
if not %temperrorlev%==0 goto error_patching

if not exist "IOSPatcher/Sharpii.exe" powershell -command "(new-object System.Net.WebClient).DownloadFile('"%FilesHostedOn%/IOSPatcher/Sharpii.exe"', 'IOSPatcher/Sharpii.exe"')"
set /a temperrorlev=%errorlevel%
set modul=Downloading Sharpii.exe
if not %temperrorlev%==0 goto error_patching

if not exist "IOSPatcher/WadInstaller.dll" powershell -command "(new-object System.Net.WebClient).DownloadFile('"%FilesHostedOn%/IOSPatcher/WadInstaller.dll"', 'IOSPatcher/WadInstaller.dll"')"
set /a temperrorlev=%errorlevel%
set modul=Downloading WadInstaller.dll
if not %temperrorlev%==0 goto error_patching

if not exist "IOSPatcher/xdelta3.exe" powershell -command "(new-object System.Net.WebClient).DownloadFile('"%FilesHostedOn%/IOSPatcher/xdelta3.exe"', 'IOSPatcher/xdelta3.exe"')"
set /a temperrorlev=%errorlevel%
set modul=Downloading xdelta3.exe
if not %temperrorlev%==0 goto error_patching


call IOSPatcher\Sharpii.exe NUSD -ios 31 -v latest -o IOSPatcher\IOS31-old.wad -wad >NUL
set /a temperrorlev=%errorlevel%
set modul=Sharpii.exe
if not %temperrorlev%==0 goto error_patching

call IOSPatcher\Sharpii.exe NUSD -ios 80 -v latest -o IOSPatcher\IOS80-old.wad -wad >NUL
set /a temperrorlev=%errorlevel%
set modul=Sharpii.exe
if not %temperrorlev%==0 goto error_patching

call IOSPatcher\Sharpii.exe WAD -u IOSPatcher\IOS31-old.wad IOSPatcher/IOS31/ >NUL
set /a temperrorlev=%errorlevel%
set modul=Sharpii.exe
if not %temperrorlev%==0 goto error_patching

call IOSPatcher\Sharpii.exe WAD -u IOSPatcher\IOS80-old.wad IOSPatcher\IOS80/ >NUL
set /a temperrorlev=%errorlevel%
set modul=Sharpii.exe
if not %temperrorlev%==0 goto error_patching

move /y IOSPatcher\IOS31\00000006.app IOSPatcher\00000006.app >NUL
set /a temperrorlev=%errorlevel%
set modul=move.exe
if not %temperrorlev%==0 goto error_patching

call IOSPatcher\xdelta3.exe -f -d -s IOSPatcher\00000006.app IOSPatcher\00000006-31.delta IOSPatcher\IOS31\00000006.app >NUL
set /a temperrorlev=%errorlevel%
set modul=xdelta.exe
if not %temperrorlev%==0 goto error_patching

move /y IOSPatcher\IOS80\00000006.app IOSPatcher\00000006.app >NUL
set /a temperrorlev=%errorlevel%
set modul=move.exe
if not %temperrorlev%==0 goto error_patching

call IOSPatcher\xdelta3.exe -f -d -s IOSPatcher\00000006.app IOSPatcher\00000006-80.delta IOSPatcher\IOS80\00000006.app >NUL
set /a temperrorlev=%errorlevel%
set modul=xdelta3.exe
if not %temperrorlev%==0 goto error_patching

if not exist IOSPatcher\WAD mkdir IOSPatcher\WAD
set /a temperrorlev=%errorlevel%
set modul=mkdir.exe
if not %temperrorlev%==0 goto error_patching

call IOSPatcher\Sharpii.exe WAD -p IOSPatcher\IOS31\ IOSPatcher\WAD\IOS31.wad -fs >NUL
set /a temperrorlev=%errorlevel%
set modul=Sharpii.exe
if not %temperrorlev%==0 goto error_patching

call IOSPatcher\Sharpii.exe WAD -p IOSPatcher\IOS80\ IOSPatcher\WAD\IOS80.wad -fs >NUL
set /a temperrorlev=%errorlevel%
set modul=Sharpii.exe
if not %temperrorlev%==0 goto error_patching

del IOSPatcher\00000006.app /q >NUL
set /a temperrorlev=%errorlevel%
set modul=del.exe
if not %temperrorlev%==0 goto error_patching

del IOSPatcher\IOS31-old.wad /q >NUL
set /a temperrorlev=%errorlevel%
set modul=del.exe
if not %temperrorlev%==0 goto error_patching

del IOSPatcher\IOS80-old.wad /q >NUL
set /a temperrorlev=%errorlevel%
set modul=del.exe
if not %temperrorlev%==0 goto error_patching

if exist IOSPatcher\IOS31 rmdir /s /q IOSPatcher\IOS31 >NUL
set /a temperrorlev=%errorlevel%
set modul=rmdir.exe
if not %temperrorlev%==0 goto error_patching

if exist IOSPatcher\IOS80 rmdir /s /q IOSPatcher\IOS80 >NUL
set /a temperrorlev=%errorlevel%
set modul=rmdir.exe
if not %temperrorlev%==0 goto error_patching

call IOSPatcher\Sharpii.exe IOS IOSPatcher\WAD\IOS31.wad -fs -es -np -vp>NUL
set /a temperrorlev=%errorlevel%
set modul=Sharpii.exe
if not %temperrorlev%==0 goto error_patching

call IOSPatcher\Sharpii.exe IOS IOSPatcher\WAD\IOS80.wad -fs -es -np -vp>NUL
set /a temperrorlev=%errorlevel%
set modul=Sharpii.exe
if not %temperrorlev%==0 goto error_patching

if not exist WAD md WAD
move "IOSPatcher\WAD\IOS31.wad" "WAD"
move "IOSPatcher\WAD\IOS80.wad" "WAD"

rmdir /s /q "IOSPatcher"

set /a tempiospatcher=1
goto 2_manual

:3_evc_patch
cls
echo.
echo %header%
echo ---------------------------------------------------------------------------------------------------------------------------
echo  [*] Everybody Votes Channel Region
echo.
echo Which region should I patch?
echo.
echo 1. Europe
echo 2. USA
set /p s=Choose: 
if %s%==1 set /a evcregion=1& goto 3_evc_patch_2
if %s%==2 set /a evcregion=2& goto 3_evc_patch_2
goto 3_evc_patch
:3_evc_patch_2
cls
echo.
echo %header%
echo ---------------------------------------------------------------------------------------------------------------------------
echo  [*] Patching Everybody Votes Channel... this can take some time
echo.
set /a temperrorlev=0
if not exist WAD md WAD
if not exist EVCPatcher md EVCPatcher
if not exist EVCPatcher/patch md EVCPatcher\patch
if not exist "EVCPatcher/patch/Europe.delta" powershell -command "(new-object System.Net.WebClient).DownloadFile('"%FilesHostedOn%/EVCPatcher/patch/Europe.delta"', 'EVCPatcher/patch/Europe.delta"')"
set /a temperrorlev=%errorlevel%
set modul=Downloading Europe Delta
if not %temperrorlev%==0 goto error_patching

if not exist "EVCPatcher/patch/USA.delta" powershell -command "(new-object System.Net.WebClient).DownloadFile('"%FilesHostedOn%/EVCPatcher/patch/USA.delta"', 'EVCPatcher/patch/USA.delta"')"
set /a temperrorlev=%errorlevel%
set modul=Downloading USA Delta
if not %temperrorlev%==0 goto error_patching

if not exist "EVCPatcher/NUS_Downloader_Decrypt.exe" powershell -command "(new-object System.Net.WebClient).DownloadFile('"%FilesHostedOn%/EVCPatcher/NUS_Downloader_Decrypt.exe"', 'EVCPatcher/NUS_Downloader_Decrypt.exe"')"
set /a temperrorlev=%errorlevel%
set modul=Downloading EUR evc
if not %temperrorlev%==0 goto error_patching

if not exist "EVCPatcher/patch/xdelta3.exe" powershell -command "(new-object System.Net.WebClient).DownloadFile('"%FilesHostedOn%/EVCPatcher/patch/xdelta3.exe"', 'EVCPatcher/patch/xdelta3.exe"')"
set /a temperrorlev=%errorlevel%
set modul=Downloading xdelta3.exe
if not %temperrorlev%==0 goto error_patching

if not exist EVCPatcher/pack md EVCPatcher\pack
if not exist "EVCPatcher/pack/libWiiSharp.dll" powershell -command "(new-object System.Net.WebClient).DownloadFile('"%FilesHostedOn%/EVCPatcher/pack/libWiiSharp.dll"', 'EVCPatcher/pack/libWiiSharp.dll"')"
set /a temperrorlev=%errorlevel%
set modul=Downloading libWiiSharp.dll
if not %temperrorlev%==0 goto error_patching

if not exist "EVCPatcher/pack/Sharpii.exe" powershell -command "(new-object System.Net.WebClient).DownloadFile('"%FilesHostedOn%/EVCPatcher/pack/Sharpii.exe"', 'EVCPatcher/pack/Sharpii.exe"')"
set /a temperrorlev=%errorlevel%
set modul=Downloading Sharpii.exe
if not %temperrorlev%==0 goto error_patching

if not exist EVCPatcher/dwn md EVCPatcher\dwn
if not exist "EVCPatcher/dwn/Sharpii.exe" powershell -command "(new-object System.Net.WebClient).DownloadFile('"%FilesHostedOn%/EVCPatcher/dwn/Sharpii.exe"', 'EVCPatcher/dwn/Sharpii.exe"')"
set /a temperrorlev=%errorlevel%
set modul=Downloading Sharpii.exe
if not %temperrorlev%==0 goto error_patching

if not exist "EVCPatcher/dwn/libWiiSharp.dll" powershell -command "(new-object System.Net.WebClient).DownloadFile('"%FilesHostedOn%/EVCPatcher/dwn/libWiiSharp.dll"', 'EVCPatcher/dwn/libWiiSharp.dll"')"
set /a temperrorlev=%errorlevel%
set modul=Downloading libWiiSharp.dll
if not %temperrorlev%==0 goto error_patching

if not exist "EVCPatcher/dwn/libWiiSharp.dll" powershell -command "(new-object System.Net.WebClient).DownloadFile('"%FilesHostedOn%/EVCPatcher/dwn/libWiiSharp.dll"', 'EVCPatcher/dwn/libWiiSharp.dll"')"
set /a temperrorlev=%errorlevel%
set modul=Downloading libWiiSharp.dll
if not %temperrorlev%==0 goto error_patching

if not exist EVCPatcher/dwn/0001000148414A45v512 md EVCPatcher\dwn\0001000148414A45v512
if not exist EVCPatcher/dwn/0001000148414A50v512 md EVCPatcher\dwn\0001000148414A50v512
if not exist "EVCPatcher/dwn/0001000148414A45v512/cetk" powershell -command "(new-object System.Net.WebClient).DownloadFile('"%FilesHostedOn%/EVCPatcher/dwn/0001000148414A45v512/cetk"', 'EVCPatcher/dwn/0001000148414A45v512/cetk"')"
set /a temperrorlev=%errorlevel%
set modul=Downloading USA CETK
if not %temperrorlev%==0 goto error_patching

if not exist "EVCPatcher/dwn/0001000148414A50v512/cetk" powershell -command "(new-object System.Net.WebClient).DownloadFile('"%FilesHostedOn%/EVCPatcher/dwn/0001000148414A50v512/cetk"', 'EVCPatcher/dwn/0001000148414A50v512/cetk"')"
set /a temperrorlev=%errorlevel%
set modul=Downloading EUR CETK
if not %temperrorlev%==0 goto error_patching


if not exist "EVCPatcher/patch/Europe.delta" powershell -command "(new-object System.Net.WebClient).DownloadFile('"%FilesHostedOn%/EVCPatcher/patch/Europe.delta"', 'EVCPatcher/patch/Europe.delta"')"
set /a temperrorlev=%errorlevel%
set modul=Downloading Europe Delta
if not %temperrorlev%==0 goto error_patching

if not exist "EVCPatcher/patch/USA.delta" powershell -command "(new-object System.Net.WebClient).DownloadFile('"%FilesHostedOn%/EVCPatcher/patch/USA.delta"', 'EVCPatcher/patch/USA.delta"')"
set /a temperrorlev=%errorlevel%
set modul=Downloading Wii Mod Lite
if not %temperrorlev%==0 goto error_patching


if not exist 0001000148414A50v512 md 0001000148414A50v512
if not exist 0001000148414A45v512 md 0001000148414A45v512
if not exist 0001000148414A50v512\cetk copy /y "EVCPatcher\dwn\0001000148414A50v512\cetk" "0001000148414A50v512\cetk"

if not exist 0001000148414A45v512\cetk copy /y "EVCPatcher\dwn\0001000148414A45v512\cetk" "0001000148414A45v512\cetk"

::USA
if %evcregion%==2 call EVCPatcher\dwn\sharpii.exe NUSD -id 0001000148414A45 -v 512 -encrypt >NUL
::PAL
if %evcregion%==1 call EVCPatcher\dwn\sharpii.exe NUSD -id 0001000148414A50 -v 512 -encrypt >NUL
set /a temperrorlev=%errorlevel%
set modul=Downloading EVC
if not %temperrorlev%==0 goto error_patching

if %evcregion%==1 copy /y "EVCPatcher\NUS_Downloader_Decrypt.exe" "0001000148414A50v512"
if %evcregion%==2 copy /y "EVCPatcher\NUS_Downloader_Decrypt.exe" "0001000148414A45v512"
set /a temperrorlev=%errorlevel%
set modul=Copying NDC.exe
if not %temperrorlev%==0 goto error_patching

if %evcregion%==1 ren "0001000148414A50v512\tmd.512" "tmd"
if %evcregion%==2 ren "0001000148414A45v512\tmd.512" "tmd"
set /a temperrorlev=%errorlevel%
set modul=Renaming files
if not %temperrorlev%==0 goto error_patching

if %evcregion%==1 cd 0001000148414A50v512
if %evcregion%==1 call NUS_Downloader_Decrypt.exe >NUL
if %evcregion%==2 cd 0001000148414A45v512
if %evcregion%==2 call NUS_Downloader_Decrypt.exe >NUL
set /a temperrorlev=%errorlevel%
set modul=Decrypter error
if not %temperrorlev%==0 cd..& goto error_patching
cd..

if %evcregion%==1 move /y "0001000148414A50v512\HAJP.wad" "EVCPatcher\pack"
if %evcregion%==2 move /y "0001000148414A45v512\HAJE.wad" "EVCPatcher\pack"
set /a temperrorlev=%errorlevel%
set modul=move.exe
if not %temperrorlev%==0 goto error_patching

if %evcregion%==1 call EVCPatcher\pack\Sharpii.exe WAD -u EVCPatcher\pack\HAJP.wad EVCPatcher\pack\unencrypted >NUL
if %evcregion%==2 call EVCPatcher\pack\Sharpii.exe WAD -u EVCPatcher\pack\HAJE.wad EVCPatcher\pack\unencrypted >NUL

move /y "EVCPatcher\pack\unencrypted\00000001.app" "00000001.app"
set /a temperrorlev=%errorlevel%
set modul=move.exe
if not %temperrorlev%==0 goto error_patching

if %evcregion%==1 call EVCPatcher\patch\xdelta3.exe -f -d -s 00000001.app EVCPatcher\patch\Europe.delta EVCPatcher\pack\unencrypted\00000001.app
if %evcregion%==2 call EVCPatcher\patch\xdelta3.exe -f -d -s 00000001.app EVCPatcher\patch\USA.delta EVCPatcher\pack\unencrypted\00000001.app
set /a temperrorlev=%errorlevel%
set modul=xdelta.exe EVC
if not %temperrorlev%==0 goto error_patching

if %evcregion%==1 call EVCPatcher\pack\Sharpii.exe WAD -p "EVCPatcher\pack\unencrypted" "WAD\Everybody Votes Channel RiiConnect24 Europe" -f 
if %evcregion%==2 call EVCPatcher\pack\Sharpii.exe WAD -p "EVCPatcher\pack\unencrypted" "WAD\Everybody Votes Channel RiiConnect24 USA" -f
set /a temperrorlev=%errorlevel%
set modul=Packing EVC WAD
if not %temperrorlev%==0 goto error_patching

rmdir /q /s EVCPatcher 
rmdir /q /s 0001000148414A45v512
rmdir /q /s 0001000148414A50v512
del /q 00000001.app

set /a tempevcpatcher=1
goto 2_manual
:3_download
cls
echo.
echo %header%
echo ---------------------------------------------------------------------------------------------------------------------------
echo  [*] Downloading apps... this can take some time.
echo.
if not exist apps/Mail-Patcher md apps\Mail-Patcher
if not exist "apps/Mail-Patcher/boot.dol" powershell -command "(new-object System.Net.WebClient).DownloadFile('"%FilesHostedOn%/apps/Mail-Patcher/boot.dol"', 'apps/Mail-Patcher/boot.dol"')"
set /a temperrorlev=%errorlevel%
set modul=Downloading Mail Patcher
if not %temperrorlev%==0 goto error_patching


if not exist "apps/Mail-Patcher/icon.png" powershell -command "(new-object System.Net.WebClient).DownloadFile('"%FilesHostedOn%/apps/Mail-Patcher/icon.png"', 'apps/Mail-Patcher/icon.png"')"
set /a temperrorlev=%errorlevel%
set modul=Downloading Mail Patcher
if not %temperrorlev%==0 goto error_patching


if not exist "apps/Mail-Patcher/meta.xml" powershell -command "(new-object System.Net.WebClient).DownloadFile('"%FilesHostedOn%/apps/Mail-Patcher/meta.xml"', 'apps/Mail-Patcher/meta.xml"')"
set /a temperrorlev=%errorlevel%
set modul=Downloading Mail Patcher
if not %temperrorlev%==0 goto error_patching

if not exist apps/WiiModLite md apps\WiiModLite
if not exist "apps/WiiModLite/boot.dol" powershell -command "(new-object System.Net.WebClient).DownloadFile('"%FilesHostedOn%/apps/WiiModLite/boot.dol"', 'apps/WiiModLite/boot.dol"')"
set /a temperrorlev=%errorlevel%
set modul=Downloading Wii Mod Lite
if not %temperrorlev%==0 goto error_patching

if not exist "apps/WiiModLite/database.txt" powershell -command "(new-object System.Net.WebClient).DownloadFile('"%FilesHostedOn%/apps/WiiModLite/database.txt"', 'apps/WiiModLite/database.txt"')"
set /a temperrorlev=%errorlevel%
set modul=Downloading Wii Mod Lite
if not %temperrorlev%==0 goto error_patching

if not exist "apps/WiiModLite/icon.png" powershell -command "(new-object System.Net.WebClient).DownloadFile('"%FilesHostedOn%/apps/WiiModLite/icon.png"', 'apps/WiiModLite/icon.png"')"
set /a temperrorlev=%errorlevel%
set modul=Downloading Wii Mod Lite
if not %temperrorlev%==0 goto error_patching

if not exist "apps/WiiModLite/icon.png" powershell -command "(new-object System.Net.WebClient).DownloadFile('"%FilesHostedOn%/apps/WiiModLite/icon.png"', 'apps/WiiModLite/icon.png"')"
set /a temperrorlev=%errorlevel%
set modul=Downloading Wii Mod Lite
if not %temperrorlev%==0 goto error_patching

if not exist "apps/WiiModLite/meta.xml" powershell -command "(new-object System.Net.WebClient).DownloadFile('"%FilesHostedOn%/apps/WiiModLite/meta.xml"', 'apps/WiiModLite/meta.xml"')"
set /a temperrorlev=%errorlevel%
set modul=Downloading Wii Mod Lite
if not %temperrorlev%==0 goto error_patching

if not exist "apps/WiiModLite/wiimod.txt" powershell -command "(new-object System.Net.WebClient).DownloadFile('"%FilesHostedOn%/apps/WiiModLite/wiimod.txt"', 'apps/WiiModLite/wiimod.txt"')"
set /a temperrorlev=%errorlevel%
set modul=Downloading Wii Mod Lite
if not %temperrorlev%==0 goto error_patching

set /a tempsdcardapps=1
goto 2_manual













