@echo off
setlocal enableextensions
setlocal enableDelayedExpansion
cd /d "%~dp0"
echo 	Starting up...
echo	The program is starting...
:: ===========================================================================
:: RiiConnect24 Patcher for Windows
set version=1.1.3
:: AUTHORS: KcrPL, Larsenv, Apfel
:: ***************************************************************************
:: Copyright (c) 2018-2020 KcrPL, RiiConnect24 and it's (Lead) Developers
:: ===========================================================================

if exist temp.bat del /q temp.bat
if exist update_assistant.bat del /q update_assistant.bat
:script_start
echo 	.. Setting up the variables
:: Window size (Lines, columns)
set mode=128,37
mode %mode%
set s=NUL

::Beta
set /a beta=0
::This variable controls if the current version of the patcher is in the stable or beta branch. It will change updating path.
:: 0 = stable  1 = beta

set /a exitmessage=1
set /a errorcopying=0
set /a tempncpatcher=0
set /a tempiospatcher=0
set /a tempevcpatcher=0
set /a tempsdcardapps=0
set /a troubleshoot_auto_tool_notification=0
set sdcard=NUL
set tempgotonext=begin_main

set mm=0
set ss=0
set cc=0
set hh=0

:: Window Title
if %beta%==0 title RiiConnect24 Patcher v%version% Created by @KcrPL, @Larsenv, @Apfel
if %beta%==1 title RiiConnect24 Patcher v%version% [BETA] Created by @KcrPL, @Larsenv, @Apfel
set last_build=2020/02/05
set at=13:13
:: ### Auto Update ###	
:: 1=Enable 0=Disable
:: Update_Activate - If disabled, patcher will not even check for updates, default=1
:: offlinestorage - Only used while testing of Update function, default=0
:: FilesHostedOn - The website and path to where the files are hosted. WARNING! DON'T END WITH "/"
:: MainFolder/TempStorage - folder that is used to keep version.txt and whatsnew.txt. These two files are deleted every startup but if offlinestorage will be set 1, they won't be deleted.
set /a Update_Activate=1
set /a offlinestorage=0 
if %beta%==0 set FilesHostedOn=https://kcrPL.github.io/Patchers_Auto_Update/RiiConnect24Patcher
if %beta%==1 set FilesHostedOn=https://kcrpl.github.io/Patchers_Auto_Update/RiiConnect24Patcher_Beta

:: Other patchers repositories
set FilesHostedOn_WiiWarePatcher=https://raw.githubusercontent.com/KcrPL/KcrPL.github.io/master/Patchers_Auto_Update/WiiWare-Patcher



set FilesHostedOn_Beta=https://KcrPL.github.io/Patchers_Auto_Update/RiiConnect24Patcher_Beta
set FilesHostedOn_Stable=https://KcrPL.github.io/Patchers_Auto_Update/RiiConnect24Patcher

set MainFolder=%appdata%\RiiConnect24Patcher
set TempStorage=%appdata%\RiiConnect24Patcher\internet\temp

if %beta%==0 set header=RiiConnect24 Patcher - (C) KcrPL, (C) Larsenv, (C) Apfel v%version% (Compiled on %last_build% at %at%)
if %beta%==1 set header=RiiConnect24 Patcher - (C) KcrPL, (C) Larsenv, (C) Apfel v%version% [BETA] (Compiled on %last_build% at %at%)

if not exist "%MainFolder%" md "%MainFolder%"
if not exist "%TempStorage%" md "%TempStorage%"

:: Trying to prevent running from OS that is not Windows.
if not "%os%"=="Windows_NT" goto not_windows_nt

:: Load background color from file if it exists
for /f "usebackq" %%a in ("%TempStorage%\background_color.txt") do color %%a






:: Check for SD Card
echo.
echo .. Checking for SD Card
echo    Can you see an error box? Press `Continue`.
echo    There's nothing to worry about, everything is going ok. This error is normal.
call :detect_sd_card

call :begin_main
goto exception_handler
:exception_handler
echo.
echo :----------------------------------------------------:
echo %header%
echo An error has occurred during execution of the script.
echo The script has exited but the exception was handled.
echo.
echo You cannot continue.
echo Press any key to restart the script.
pause>NUL
goto script_start

:not_windows_nt
cls
echo.
echo Hi,
echo Please don't run RiiConnect24 Patcher in MS-DOS
echo.
echo Press any button or CTRL+C to quit.
pause
exit
goto not_windows_nt
:begin_main
cls
mode %mode%
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
echo             smmmmm`+mMMMMMMMMMNhMNNMNNMMMMMMMMMMMMMMy   3. Settings
echo             hmmmmh omMMMMMMMMMmhNMMMmNNNNMMMMMMMMMMM+   4. Troubleshooting
echo             hmmmmh omMMMMMMMMMmhNMMMmNNNNMMMMMMMMMMM+
echo             mmmmms smMMMMMMMMMmddMMmmNmNMMMMMMMMMMMM:  Do you have problems or want to contact us?  
echo            `mmmmmo hNMMMMMMMMMmddNMMMNNMMMMMMMMMMMMM.  Mail us at support@riiconnect24.net
echo            -mmmmm/ dNMMMMMMMMMNmddMMMNdhdMMMMMMMMMMN
if not %sdcard%==NUL echo            :mmmmm-`mNMMMMMMMMNNmmmNMMNmmmMMMMMMMMMMd   Detected Wii SD Card: %sdcard%:\
if %sdcard%==NUL echo            :mmmmm-`mNMMMMMMMMNNmmmNMMNmmmMMMMMMMMMMd   Could not detect your Wii SD Card.
echo            +mmmmN.-mNMMMMMMMMMNmmmmMMMMMMMMMMMMMMMMy   R. Refresh ^| If incorrect, you can change later.
echo            smmmmm`/mMMMMMMMMMNNmmmmNMMMMNMMNMMMMMNmy.
echo            hmmmmd`omMMMMMMMMMNNmmmNmMNNMmNNNNMNdhyhh.
echo            mmmmmh ymMMMMMMMMMNNmmmNmNNNMNNMMMMNyyhhh`
if %beta%==0 echo           `mmmmmy hmMMNMNNMMMNNmmmmmdNMMNmmMMMMhyhhy
if %beta%==0 echo           -mddmmo`mNMNNNNMMMNNNmdyoo+mMMMNmNMMMNyyys
if %beta%==0 echo           :mdmmmo-mNNNNNNNNNNdyo++sssyNMMMMMMMMMhs+-
if %beta%==0 echo          .+mmdhhmmmNNNNNNmdysooooosssomMMMNNNMMMm
if %beta%==0 echo          o/ossyhdmmNNmdyo+++oooooosssoyNMMNNNMMMM+
if %beta%==0 echo          o/::::::://++//+++ooooooo+oo++mNMMmNNMMMm
if %beta%==0 echo         `o//::::::::+////+++++++///:/+shNMMNmNNmMM+
if %beta%==0 echo         .o////////::+++++++oo++///+syyyymMmNmmmNMMm
if %beta%==0 echo         -+//////////o+ooooooosydmdddhhsosNMMmNNNmho            `:/
if %beta%==0 echo         .+++++++++++ssss+//oyyysso/:/shmshhs+:.          `-/oydNNNy
if %beta%==0 echo           `..-:/+ooss+-`          +mmhdy`           -/shmNNNNNdy+:`
if %beta%==0 echo                   `.              yddyo++:    `-/oymNNNNNdy+:`
if %beta%==0 echo                                   -odhhhhyddmmmmmNNmhs/:`
if %beta%==0 echo                                     :syhdyyyyso+/-`

if %beta%==1 echo ----------------------------------------------------------------------------------------------------:
if %beta%==1 echo            .sho.          
if %beta%==1 echo         .oy: :ys.          Warning^^!
if %beta%==1 echo       -sy-     -ss-      
if %beta%==1 echo    `:ss-   ...   -ss-`   
if %beta%==1 echo  `:ss-`   .ysy     -ss:`   You are using an experimental version of this program.
if %beta%==1 echo /yo.      .ysy       .oy:  That means that this version might contain experimental features
if %beta%==1 echo :yo.      .hhh       .oy:  and bugs that might break your Wii/Wii U console or your computer.
if %beta%==1 echo  `:ss-             -sy:` 
if %beta%==1 echo     -ss-  `\./   -ss-`     If you don't know what you're doing, please go to settings and go back to
if %beta%==1 echo       -ss-     -ss-        stable branch of the patcher.
if %beta%==1 echo         -sy: :ys-        
if %beta%==1 echo           .oho.            
if %beta%==1 echo.
set /p s=Type a number that you can see above next to the command and hit ENTER: 
if %s%==1 goto begin_main1
if %s%==2 goto credits
if %s%==3 goto settings_menu
if %s%==4 goto troubleshooting_menu
if %s%==r goto begin_main_refresh_sdcard
if %s%==R goto begin_main_refresh_sdcard
if %s%==restart goto script_start
if %s%==exit exit
goto begin_main

:begin_main_refresh_sdcard
set sdcard=NUL
set tempgotonext=begin_main
goto detect_sd_card

:troubleshooting_menu
cls
echo %header%
echo -----------------------------------------------------------------------------------------------------------------------------
echo.
echo --- Troubleshooting tools ---
echo These tools should help you diagnose some problems with the patcher and try to repair them automatically.
echo.
echo 1. Could not start PowerShell / Error while checking for updates
echo 2. Could not detect SD Card.
echo 3. Could not copy files to the SD Card.
echo 4. Could not download core runtime files [`Downloading 06.80.delta / Downloading libWiiSharp.dll etc.`]
echo 5. Renaming files error
echo.
echo R. Return to main menu
echo.
echo --- Some of these tools can be used while patching, allowing patcher to recover after a failure without user interraction ---
echo.
set /p s=Choose: 
if %s%==r goto begin_main
if %s%==R goto begin_main

if %s%==1 goto troubleshooting_1
if %s%==2 goto troubleshooting_2
if %s%==3 goto troubleshooting_3
if %s%==4 goto troubleshooting_4
if %s%==5 goto troubleshooting_5
goto troubleshooting_menu
:troubleshooting_5
cls
echo %header%
echo -----------------------------------------------------------------------------------------------------------------------------
echo.
echo Fixing - Renaming files error
echo.
echo [...] Flushing files
rmdir /s /q 0001000148415045v512 >NUL
rmdir /s /q 0001000148415050v512 >NUL
rmdir /s /q 0001000148414A45v512 >NUL
rmdir /s /q 0001000148414A50v512 >NUL
rmdir /s /q 0001000148415450v1792 >NUL
rmdir /s /q 0001000148415445v1792 >NUL
rmdir /s /q IOSPatcher >NUL
rmdir /s /q EVCPatcher >NUL
rmdir /s /q NCPatcher >NUL
rmdir /s /q CMOCPatcher >NUL
del /q 00000001.app >NUL
del /q 00000001_NC.app >NUL
echo [OK] Flushing files

goto troubleshooting_5_2
:troubleshooting_5_2
if "%tempgotonext%"=="2_2" goto 2_2
echo.
echo --- Testing completed ---
pause
goto troubleshooting_menu


:troubleshooting_4
cls
echo %header%
echo -----------------------------------------------------------------------------------------------------------------------------
echo.
echo Testing - Downloading files.
echo.

echo [...] Testing PowerShell
powershell -c "[console]::beep(200,1)" 
set /a temperrorlev=%errorlevel%

if %temperrorlev%==0 echo [OK] Executing PowerShell commmand.
if not %temperrorlev%==0 echo [Error] Testing failure. Please use the "Could not start PowerShell / Error while checking for updates" option.
if not %temperrorlev%==0 goto troubleshooting_4_3

:troubleshooting_4_2
echo.
call curl -s -S --insecure "%FilesHostedOn%/version.txt" --output "%TempStorage%\version.txt"
set /a temperrorlev=%errorlevel%

if %temperrorlev%==0 if %beta%==1 echo [OK] Connection to the server on branch [BETA]
if %temperrorlev%==0 if %beta%==0 echo [OK] Connection to the server on branch [STABLE]

if not %temperrorlev%==0 echo [Error] Connection to the server. Couldn't connect to the update server. Maybe it's down.
if not %temperrorlev%==0 goto troubleshooting_4_3

:troubleshooting_4_3
echo.
echo --- Testing completed ---
pause
goto troubleshooting_menu

:troubleshooting_3
cls
echo %header%
echo -----------------------------------------------------------------------------------------------------------------------------
echo.
echo Testing - Checking SD Card.
echo.
echo [...] Running scanning script.
set tempgotonext=troubleshooting_3_2
goto detect_sd_card
:troubleshooting_3_2
if %sdcard%==NUL echo [Error] Could not find SD Card. Please make sure that it's connected. If it is connected, make a folder called apps on it and try again.
if %sdcard%==NUL goto troubleshooting_3_3

if not %sdcard%==NUL echo [OK] SD Card found: drive letter [%sdcard%:\]. Drive opened for read/write access.
echo.
echo [...] Saving random text file to the SD Card.
echo.
echo %random% >>"%temp%\deleteME.txt"

copy "%temp%\deleteME.txt" "%sdcard%:\" >NUL
set temperrorlev=%errorlevel%
if %temperrorlev%==0 echo [OK] File saved^^!
if not %temperrorlev%==0 echo [Error] The file couldn't be saved. Looks like the drive is write protected. Unlock it and try again
if not %temperrorlev%==0 goto troubleshooting_3_3

if %temperrorlev%==0 del /q %sdcard%:\deleteME.txt
if %temperrorlev%==0 del /q "%temp%\deleteME.txt"
set /a temperrorlev=%errorlevel%

if %temperrorlev%==0 echo [OK] File deleted^^!
if not %temperrorlev%==0 echo [Error] Deleting file.
if not %temperrorlev%==0 goto troubleshooting_3_3

echo Everything is ok^^! Drive is enabled for read/write access.
goto troubleshooting_3_3
:troubleshooting_3_3
echo.
echo --- Testing completed ---
pause
goto troubleshooting_menu

:troubleshooting_2
cls
echo %header%
echo -----------------------------------------------------------------------------------------------------------------------------
echo.
echo Testing - Checking SD Card.
echo.
echo [...] Running scanning script.
set tempgotonext=troubleshooting_2_2
goto detect_sd_card
:troubleshooting_2_2
echo.
if %sdcard%==NUL echo [Error] Could not find SD Card. Please make sure that it's connected. If it is connected, make a folder called apps on it and try again.
if not %sdcard%==NUL echo [OK] SD Card found: drive letter [%sdcard%:\]. Drive opened for read access only.
goto troubleshooting_2_3

:troubleshooting_2_3
echo.
echo --- Testing completed ---
pause
goto troubleshooting_menu


:troubleshooting_1
set /a repeat_1=0
cls
echo %header%
echo -----------------------------------------------------------------------------------------------------------------------------
echo.
echo Testing - PowerShell
:troubleshooting_1_1
powershell -c "[console]::beep(200,1)" 
set /a temperrorlev=%errorlevel%
if %repeat_1%==1 if %temperrorlev%==0 echo [OK] Executing PowerShell commmand.
if %repeat_1%==1 if %temperrorlev%==0 goto troublehooting_1_4
if %repeat_1%==1 if not %temperrorlev%==0 echo [Error] Testing failure.
if %repeat_1%==1 if not %temperrorlev%==0 goto troubleshooting_1_4

if %temperrorlev%==0 echo [OK] - Testing PowerShell command&goto troubleshooting_1_3
if not %temperrorlev%==0 echo [Error] - Testing Powershell command&goto troubleshooting_1_2

goto troubleshooting_1_3

:troubleshooting_1_2
taskkill /im powershell.exe /f /t>>NUL
echo [OK] - Taskkilled PowerShell [at least tried to]
set /a repeat_1=1
goto troubleshooting_1_1

:troubleshooting_1_3
powershell -c "[console]::beep(500,1)" || echo [Error] - Executing PowerShell command&goto troubleshooting_1_4
echo [OK] - Executing PowerShell command
goto troubleshooting_1_4

:troubleshooting_1_4
echo.
echo --- Testing completed ---
pause
goto troubleshooting_menu
:settings_menu
cls
echo %header%
echo -----------------------------------------------------------------------------------------------------------------------------
echo.
echo RiiConnect24 Patcher Settings.
echo.
echo 1. Go back
echo 2. Set background/text color
if %Update_Activate%==1 echo 3. Turn off/on updating. [Currently:  ON]
if %Update_Activate%==0 echo 3. Turn off/on updating. [Currently: OFF]
if %beta%==0 echo 4. Change updating branch to Beta. [Currently: Stable]
if %beta%==1 echo 4. Change updating branch to Stable. [Currently: Beta]
echo 5. Repair patcher file (Redownload)
echo.
set /p s=Choose:
if %s%==1 goto begin_main
if %s%==2 goto change_color
if %s%==3 goto change_updating
if %s%==4 goto change_updating_branch
if %s%==5 goto update_files
goto settings_menu
:change_updating_branch
cls
echo %header%
echo -----------------------------------------------------------------------------------------------------------------------------
echo.
echo Please wait... fetching data.
echo.
if %beta%==1 goto change_updating_branch_stable
if %beta%==0 goto change_updating_branch_beta
goto settings_menu
:change_updating_branch_stable
set /a stable_available_check=1

	if exist "%TempStorage%\version.txt" del "%TempStorage%\version.txt" /q
	call curl -s -S --insecure "%FilesHostedOn_Stable%/UPDATE/version.txt" --output "%TempStorage%\version.txt"
	echo 1
	set /a temperrorlev=%errorlevel%
		if not %temperrorlev%==0 set /a stable_available_check=0&goto switch_to_stable
	if exist "%TempStorage%\version.txt" set /p updateversion_stable=<"%TempStorage%\version.txt"
	goto switch_to_stable	

:change_updating_branch_beta
set /a beta_available_check=0
	
	if exist "%TempStorage%\beta_available.txt" del "%TempStorage%\beta_available.txt" /q
	call curl -s -S --insecure "%FilesHostedOn_Beta%/UPDATE/beta_available.txt" --output "%TempStorage%\beta_available.txt"
		set /a temperrorlev=%errorlevel%
		if not %temperrorlev%==0 set /a beta_available_check=2&goto switch_to_beta
	if exist "%TempStorage%\beta_available.txt" set /p beta_available=<"%TempStorage%\beta_available.txt"
	
	if %beta_available%==0 set /a beta_available_check=0
	if %beta_available%==1 set /a beta_available_check=1
	
	if %beta_available_check%==0 goto switch_to_beta
	
	if exist "%TempStorage%\version.txt" del "%TempStorage%\version.txt" /q
	call curl -s -S --insecure "%FilesHostedOn_Beta%/UPDATE/version.txt" --output "%TempStorage%\version.txt"
		set /a temperrorlev=%errorlevel%
		if not %temperrorlev%==0 set /a beta_available_check=2&goto switch_to_beta
	if exist "%TempStorage%\version.txt" set /p updateversion_beta=<"%TempStorage%\version.txt"

	goto switch_to_beta
:switch_to_stable
cls
echo %header%
echo -----------------------------------------------------------------------------------------------------------------------------
echo.
echo Do you want to go back to stable version of the patcher?
echo.
echo Current version: %version% [BETA]
if %stable_available_check%==1 echo Stable version: %updateversion_stable%
if %stable_available_check%==0 echo Stable version: Sorry, there was an error while fetching data.
echo.
echo Do you want to switch? (Updating process will start.)
echo.
if %stable_available_check%==1 echo 1. Yes, switch to Stable branch.
if not %stable_available_check%==1 echo 1. [UNABLE TO SWITCH TO STABLE VERSION]
echo 2. No, go back to main menu.
set /p s=Choose: 
if %s%==1 (
	if %stable_available_check%==0 goto switch_to_stable
	set FilesHostedOn=%FilesHostedOn_Stable%
	goto update_files
	)
if %s%==2 goto begin_main
goto switch_to_stable
:switch_to_beta
cls
echo %header%
echo -----------------------------------------------------------------------------------------------------------------------------
echo.
echo Do you want to switch to BETA version of the patcher?
echo.
echo Current version: %version%
if %beta_available_check%==0 echo Beta version: Sorry, there's currently no public beta version available.
if %beta_available_check%==1 echo Beta version: %updateversion_beta% [BETA]
if %beta_available_check%==2 echo Beta version: Sorry, there was an error while fetching data.
echo.
echo Do you want to switch? (Updating process will start.)
echo.
if %beta_available_check%==1 echo 1. Yes, switch to Beta branch.
if not %beta_available_check%==1 echo 1. [UNABLE TO SWITCH TO BETA VERSION]
echo 2. No, go back to main menu.
set /p s=Choose: 
if %s%==1 (
	if not %beta_available_check%==1 goto switch_to_beta
	
	set FilesHostedOn=%FilesHostedOn_Beta%
	goto update_files
	)
if %s%==2 goto begin_main
goto switch_to_beta
:change_updating
if %Update_Activate%==1 goto change_updating_warning_off
set /a Update_Activate=1
goto settings_menu
:change_updating_warning_off
cls
echo %header%
echo -----------------------------------------------------------------------------------------------------------------------------
echo.
echo WAIT^^! Are you trying to disable updating? 
echo Please do remember that updates will keep you safe and updated about the patcher.
echo.
echo Only use this option for debugging and troubleshooting.
echo.
echo Are you sure that you want to disable autoupdating?
echo 1. Yes
echo 2. No, go back.
set /p s=
if %s%==1 set Update_Activate=0
if %s%==1 goto settings_menu
if %s%==2 goto settings_menu
goto change_updating_warning_off

:change_color
cls
echo %header%
echo -----------------------------------------------------------------------------------------------------------------------------
echo.
echo Change color:
echo.
echo 1. Dark theme
echo 2. Light theme *please don't hurt my eyes edition*
echo 3. Light theme *please hurt my eyes edition*
echo 4. Yellow
echo 5. Green
echo 6. Red
echo 7. Blue
echo.
echo E. Go back
set /p s=Choose: 
if %s%==1 set tempcolor=07&goto save_color
if %s%==2 set tempcolor=70&goto save_color
if %s%==3 set tempcolor=f0&goto save_color
if %s%==4 set tempcolor=6&goto save_color
if %s%==5 set tempcolor=a&goto save_color
if %s%==6 set tempcolor=c&goto save_color
if %s%==7 set tempcolor=3&goto save_color
if %s%==e goto begin_main
if %s%==E goto begin_main

goto change_color
:save_color
if exist "%TempStorage%\background_color.txt" del /q "%TempStorage%\background_color.txt"
color %tempcolor%
echo>>"%TempStorage%\background_color.txt" %tempcolor%
goto change_color

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
echo - Apfel
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
:begin_main_download_curl
cls
echo %header%
echo.
echo              `..````                                     :-------------------------:
echo              yNNNNNNNNMNNmmmmdddhhhyyyysssooo+++/:--.`    Downloading curl... Please wait.
echo              hNNNNNNNNMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMd    This can take some time...
echo              ddmNNd:dNMMMMNMMMMMMMMMMMMMMMMMMMMMMMMMMs   :-------------------------:
echo             `mdmNNy dNMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM+   
echo             .mmmmNs mNMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM:   File 1 [3.5MB] out of 1
echo             :mdmmN+`mNMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM.   0%% [          ]
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
call powershell -command (new-object System.Net.WebClient).DownloadFile('"%FilesHostedOn%/curl.exe"', '"curl.exe"')
set /a temperrorlev=%errorlevel%
if not %temperrorlev%==0 goto begin_main_download_curl_error

goto begin_main1
:begin_main_download_curl_error
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
echo   /     \  There was an error while downloading curl.
echo  /   ^^!   \ Curl is used for downloading files from update server and files needed for patching. 
echo  --------- Please restart your PC and try running the patcher again.
echo            If it won't work, please download curl and put it in a folder next to RiiConnect24 Patcher.bat 
echo.
echo       Press any key to open download page in browser and to return to menu.
echo ---------------------------------------------------------------------------------------------------------------------------
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
start %FilesHostedOn%/curl.exe
goto begin_main

:begin_main1
:: For whatever reason, it returns 2
curl
if not %errorlevel%==2 goto begin_main_download_curl

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

:: Update script.
set updateversion=0.0.0
:: Delete version.txt and whatsnew.txt
if %offlinestorage%==0 if exist "%TempStorage%\version.txt" del "%TempStorage%\version.txt" /q
if %offlinestorage%==0 if exist "%TempStorage%\whatsnew.txt" del "%TempStorage%\whatsnew.txt" /q

if not exist "%TempStorage%" md "%TempStorage%"
:: Commands to download files from server.

if %Update_Activate%==1 if %offlinestorage%==0 call curl -s -S --insecure "%FilesHostedOn%/UPDATE/whatsnew.txt" --output "%TempStorage%\whatsnew.txt"
if %Update_Activate%==1 if %offlinestorage%==0 call curl -s -S --insecure "%FilesHostedOn%/UPDATE/version.txt" --output "%TempStorage%\version.txt"
	set /a temperrorlev=%errorlevel%
	
set /a updateserver=1
	::Bind exit codes to errors here
	if "%temperrorlev%"=="6" goto no_internet_connection
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
curl -s -S --insecure "%FilesHostedOn%/UPDATE/annoucement.txt" --output %TempStorage%\annoucement.txt"

if %Update_Activate%==1 if %updateavailable%==1 set /a updateserver=2
if %Update_Activate%==1 if %updateavailable%==1 goto update_notice

goto 1
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
echo  /   ^^!   \ 
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
echo  /   ^^!   \ 
echo  --------- RiiConnect24 Patcher will restart shortly... 
echo.           Now working on: Downloading files from server and replacing old with the new ones. Give me a second, please^^! :)  
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
:update_1
curl -s -S --insecure "%FilesHostedOn%/UPDATE/update_assistant.bat" --output "update_assistant.bat"
	set temperrorlev=%errorlevel%
	if not %temperrorlev%==0 goto error_updating
start update_assistant.bat -RC24_Patcher
exit
:error_updating
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
echo    /---\   ERROR
echo   /     \  There was an error while downloading the update assistant.
echo  /   ^^!   \ 
echo  --------- Press any key to return to main menu.
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
goto begin_main
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
if exist "%TempStorage%\annoucement.txt" echo --- Announcement --- 
if exist "%TempStorage%\annoucement.txt" type "%TempStorage%\annoucement.txt"
if exist "%TempStorage%\annoucement.txt" echo.
if exist "%TempStorage%\annoucement.txt" echo -------------------
echo.
echo Which mode should I run?
echo 1. Install RiiConnect24 on your Wii.
echo   - The patcher will guide you through process of installing RiiConnect24
echo.
echo 2. Uninstall RiiConnect24 from your Wii.
echo   - This will help you uninstall RiiConnect24 from your Wii.
echo.
echo --- Other patchers ---
echo.
echo 3. Patch Wii WAD Games to work with Wiimmfi.
echo   - This will patch WAD Games (WiiWare) for use with Wiimmfi which will allow you to play online with other people.
echo.
echo 4. Patch Mario Kart Wii to work with Wiimmfi.
echo   - This will patch your copy of Mario Kart Wii to work with Wiimmfi which will enable online multiplayer to work again.
echo.
echo 5. Patch other Wii Games to work with Wiimmfi.
echo   - This will patch any other game than Mario Kart Wii to work with Wiimmfi. 
echo.	
set /p s=Choose: 
if %s%==1 goto 2_prepare
if %s%==2 goto 2_prepare_uninstall
if %s%==3 goto wadgames_patch_info
if %s%==4 goto mariokartwii_patch
if %s%==5 goto wiigames_patch
goto 1

:wiigames_patch
cls
echo %header%
echo -----------------------------------------------------------------------------------------------------------------------------
echo.
echo Preparing for use with Wiimmfi Patcher...
echo Please wait...
echo.
echo Progress:

set tempCD=%cd%

if exist Wiimmfi-Patcher rmdir /s /q Wiimmfi-Patcher
md Wiimmfi-Patcher
echo 25%%
curl -s -S --insecure "https://download.wiimm.de/wiimmfi/patcher/wiimmfi-patcher-v4.7z" --output "Wiimmfi-Patcher\wiimmfi-patcher-v4.7z"
echo 50%%
curl -s -S --insecure "%FilesHostedOn%/7z.exe" --output "Wiimmfi-Patcher\7z.exe"
echo 75%%
cd Wiimmfi-Patcher
7z.exe x wiimmfi-patcher-v4.7z>NUL

cd ..

echo 100%%
goto wiigames_patch_ask

:wiigames_patch_ask
cls
echo %header%
echo -----------------------------------------------------------------------------------------------------------------------------
echo.
echo Wiimmfi Patcher is ready^^!
echo Please the game image (can be ISO or WBFS) in a folder where RiiConnect24 Patcher is and choose "Ready".
echo.
if exist "*.ISO" echo ISO Files: Found
if not exist "*.ISO" echo ISO Files: Not Found
if exist "*.WBFS" echo WBFS Files: Found
if not exist "*.WBFS" echo WBFS Files: Not Found
echo.
echo 1. Ready. Start Wiimmfi Patcher.
echo 2. Go back to Main Menu.
set /p s=Choose: 
if %s%==1 goto start_wiimmfi-patcher
if %s%==2 rmdir /s /q Wiimmfi-Patcher&goto begin_main
goto wiigames_patch_ask
:start_wiimmfi-patcher
cls
echo %header%
echo -----------------------------------------------------------------------------------------------------------------------------
echo.

if exist "*.WBFS" move "*.WBFS" "Wiimmfi-Patcher\wiimmfi-patcher-v4\Windows"
if exist "*.ISO" move "*.ISO" "Wiimmfi-Patcher\wiimmfi-patcher-v4\Windows"

cd "Wiimmfi-Patcher\wiimmfi-patcher-v4\Windows"

@echo off

wit cp . --DEST ../wiimmfi-images/ --update --psel=data --wiimmfi -vv

cd ..
cd ..
cd ..

if not exist wiimmfi-images md wiimmfi-images
move "Wiimmfi-Patcher\wiimmfi-patcher-v4\wiimmfi-images\*.iso" "wiimmfi-images"
move "Wiimmfi-Patcher\wiimmfi-patcher-v4\wiimmfi-images\*.wbfs" "wiimmfi-images"
ping localhost -n 2>NUL
rmdir Wiimmfi-Patcher
cls
echo %header%
echo -----------------------------------------------------------------------------------------------------------------------------
echo.
echo The Wiimmfi Patcher is done^^! 
echo The game image file has been moved to the wiimmfi-images folder next to RiiConnect24 Patcher.
echo.
echo Press any button to go back to main menu.
pause>NUL

goto script_start

:mariokartwii_patch
cls
echo %header%
echo -----------------------------------------------------------------------------------------------------------------------------
echo.
echo Preparing for use with Mario Kart Wii Wiimmfi Patcher...
echo Please wait...
echo.
echo Progress:
set tempCD=%cd%
if exist MKWii-Patcher rmdir /s /q MKWii-Patcher
md MKWii-Patcher
echo 25%%
curl -s -S --insecure "https://download.wiimm.de/wiimmfi/patcher/mkw-wiimmfi-patcher-v6.zip" --output "MKWii-Patcher\mkw-wiimmfi-patcher-v6.zip"
echo 50%%
curl -s -S --insecure "%FilesHostedOn%/7z.exe" --output "MKWii-Patcher\7z.exe"
echo 75%%
cd MKWii-Patcher
7z.exe x mkw-wiimmfi-patcher-v6.zip>NUL
cd..
echo 100%%
goto mariokartwii_patch_ask

:mariokartwii_patch_ask
cls
echo %header%
echo -----------------------------------------------------------------------------------------------------------------------------
echo.
echo Mario Kart Wii Wiimmfi Patcher is ready^^!
echo Please put the Mario Kart Wii image file (can be ISO or WBFS) in a folder where RiiConnect24 Patcher is and choose "Ready".
echo.
if exist "*.ISO" echo ISO Files: Found
if not exist "*.ISO" echo ISO Files: Not Found
if exist "*.WBFS" echo WBFS Files: Found
if not exist "*.WBFS" echo WBFS Files: Not Found
echo.
echo 1. Ready. Start Mario Kart Wii Patcher.
echo 2. Go back to Main Menu.
set /p s=Choose: 
if %s%==1 goto start_mkwii-patcher
if %s%==2 rmdir /s /q MKWii-Patcher&goto begin_main
goto mariokartwii_patch_ask
:start_mkwii-patcher
cls
echo %header%
echo -----------------------------------------------------------------------------------------------------------------------------
echo.
set tempCD=%cd%
if exist "*.WBFS" move "*.WBFS" "MKWii-Patcher\mkw-wiimmfi-patcher-v6\"
if exist "*.ISO" move "*.ISO" "MKWii-Patcher\mkw-wiimmfi-patcher-v6\"

cd MKWii-Patcher\mkw-wiimmfi-patcher-v6

@echo off

::Actual patching
set PATH=bin\cygwin;%PATH%
bash ./patch-wiimmfi.sh %1 %2 %3 %4 %5 %6 %7 %8 %9

cd ..
cd ..

if not exist wiimmfi-images md wiimmfi-images
move "MKWii-Patcher\mkw-wiimmfi-patcher-v6\wiimmfi-images\*.iso" "wiimmfi-images"
move "MKWii-Patcher\mkw-wiimmfi-patcher-v6\wiimmfi-images\*.wbfs" "wiimmfi-images"
rmdir MKWii-Patcher

cls
echo %header%
echo -----------------------------------------------------------------------------------------------------------------------------
echo.
echo The Wiimmfi Patcher is done^^! 
echo Mario Kart Wii image file has been moved to the wiimmfi-images folder next to RiiConnect24 Patcher.
echo.
echo %tempCD%
echo Press any button to go back to main menu.
pause>NUL

goto script_start



:wadgames_patch_info
cls
echo %header%
echo -----------------------------------------------------------------------------------------------------------------------------
echo.
echo Preparing for use with WiiWare Patcher...
echo Please wait...
echo.
echo Progress:
if exist WiiWare-Patcher rmdir /s /q WiiWare-Patcher
md WiiWare-Patcher
echo 14%%
curl -s -S --insecure "%FilesHostedOn_WiiWarePatcher%/libWiiSharp.dll" --output WiiWare-Patcher/libWiiSharp.dll
echo 28%%
curl -s -S --insecure "%FilesHostedOn_WiiWarePatcher%/lzx.exe" --output WiiWare-Patcher/lzx.exe
echo 42%%
curl -s -S --insecure "%FilesHostedOn_WiiWarePatcher%/patcher.bat" --output WiiWare-Patcher/patcher.bat
echo 57%%
curl -s -S --insecure "%FilesHostedOn_WiiWarePatcher%/Sharpii.exe" --output WiiWare-Patcher/Sharpii.exe
echo 71%%
curl -s -S --insecure "%FilesHostedOn_WiiWarePatcher%/WadInstaller.dll" --output WiiWare-Patcher/WadInstaller.dll
echo 85%%
curl -s -S --insecure "%FilesHostedOn_WiiWarePatcher%/WiiwarePatcher.exe" --output WiiWare-Patcher/WiiwarePatcher.exe
echo 100%%
goto wadgames_patch_ask
:wadgames_patch_ask
cls
echo %header%
echo -----------------------------------------------------------------------------------------------------------------------------
echo.
echo A WiiWare-Patcher folder has been made. Please put your .WAD files in that folder and choose "Ready" when you're ready.
echo.
echo 1. Ready. Start WiiWare Patcher.
echo 2. Go back to Main Menu.
set /p s=Choose: 
if %s%==1 goto start_wiiware-patcher
if %s%==2 rmdir /s /q WiiWare-Patcher&goto begin_main

:start_wiiware-patcher
if exist WiiWare-Patcher\RC24PATCHER_START_PATCHING_SCRIPT del /q WiiWare-Patcher\RC24PATCHER_START_PATCHING_SCRIPT
echo 1>>WiiWare-Patcher\RC24PATCHER_START_PATCHING_SCRIPT
::
cd WiiWare-Patcher
call patcher
cd..
::
cls
echo Moving files... please wait.
if exist WiiWare-Patcher\backup-wads md backup-wads
if exist WiiWare-Patcher\wiimmfi-wads md wiimmfi-wads
if exist WiiWare-Patcher\backup-wads move "WiiWare-Patcher\backup-wads\*.wad" "backup-wads\"
if exist WiiWare-Patcher\wiimmfi-wads move "WiiWare-Patcher\wiimmfi-wads\*.wad" "wiimmfi-wads\"

cls
echo %header%
echo -----------------------------------------------------------------------------------------------------------------------------
echo.
echo WiiWare Patcher has exited...
echo If the files were patched, you can find the patched .WAD files in the wiimmfi-wads folder next to the RiiConnect24 Patcher.
echo.
echo Press any button to return to main menu.
pause>NUL
goto script_start


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
echo 1. Connected^^!
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
if %sdcardstatus%==1 if not %sdcard%==NUL echo Congrats^^! I've successfully detected your SD Card^^! Drive letter: %sdcard%
if %sdcardstatus%==1 if not %sdcard%==NUL echo I will be able to automatically download and install everything on your SD Card^^!	
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
if %percent%==1 if not exist "IOSPatcher/00000006-31.delta" curl -s -S --insecure "%FilesHostedOn%/IOSPatcher/00000006-31.delta" --output IOSPatcher/00000006-31.delta
if %percent%==1 set /a temperrorlev=%errorlevel%
if %percent%==1 set modul=Downloading 06-31.delta
if %percent%==1 if not %temperrorlev%==0 goto error_patching

if %percent%==3 if not exist "IOSPatcher/00000006-80.delta" curl -s -S --insecure "%FilesHostedOn%/IOSPatcher/00000006-80.delta" --output IOSPatcher/00000006-80.delta
if %percent%==3 set /a temperrorlev=%errorlevel%
if %percent%==3 set modul=Downloading 06-80.delta
if %percent%==3 if not %temperrorlev%==0 goto error_patching

if %percent%==6 if not exist "IOSPatcher/00000006-80.delta" curl -s -S --insecure "%FilesHostedOn%/IOSPatcher/00000006-80.delta" --output IOSPatcher/00000006-80.delta
if %percent%==6 set /a temperrorlev=%errorlevel%
if %percent%==6 set modul=Downloading 06-80.delta
if %percent%==6 if not %temperrorlev%==0 goto error_patching

if %percent%==9 if not exist "IOSPatcher/libWiiSharp.dll" curl -s -S --insecure "%FilesHostedOn%/IOSPatcher/libWiiSharp.dll" --output IOSPatcher/libWiiSharp.dll
if %percent%==9 set /a temperrorlev=%errorlevel%
if %percent%==9 set modul=Downloading libWiiSharp.dll
if %percent%==9 if not %temperrorlev%==0 goto error_patching

if %percent%==12 if not exist "IOSPatcher/Sharpii.exe" curl -s -S --insecure "%FilesHostedOn%/IOSPatcher/Sharpii.exe" --output IOSPatcher/Sharpii.exe
if %percent%==12 set /a temperrorlev=%errorlevel%
if %percent%==12 set modul=Downloading Sharpii.exe
if %percent%==12 if not %temperrorlev%==0 goto error_patching

if %percent%==15 if not exist "IOSPatcher/WadInstaller.dll" curl -s -S --insecure "%FilesHostedOn%/IOSPatcher/WadInstaller.dll" --output IOSPatcher/WadInstaller.dll
if %percent%==15 set /a temperrorlev=%errorlevel%
if %percent%==15 set modul=Downloading WadInstaller.dll
if %percent%==15 if not %temperrorlev%==0 goto error_patching

if %percent%==17 if not exist "IOSPatcher/xdelta3.exe" curl -s -S --insecure "%FilesHostedOn%/IOSPatcher/xdelta3.exe" --output IOSPatcher/xdelta3.exe
if %percent%==17 set /a temperrorlev=%errorlevel%
if %percent%==17 set modul=Downloading xdelta3.exe
if %percent%==17 if not %temperrorlev%==0 goto error_patching


if %percent%==20 if not exist apps md apps

if %percent%==23 if not exist apps/WiiModLite md apps\WiiModLite
if %percent%==23 if not exist apps/WiiXplorer md apps\WiiXplorer
if %percent%==23 if not exist "apps/WiiModLite/boot.dol" curl -s -S --insecure "%FilesHostedOn%/apps/WiiModLite/boot.dol" --output apps/WiiModLite/boot.dol
if %percent%==23 set /a temperrorlev=%errorlevel%
if %percent%==23 set modul=Downloading Wii Mod Lite
if %percent%==23 if not %temperrorlev%==0 goto error_patching

if %percent%==25 if not exist "apps/WiiModLite/database.txt" curl -s -S --insecure "%FilesHostedOn%/apps/WiiModLite/database.txt" --output apps/WiiModLite/database.txt
if %percent%==25 set /a temperrorlev=%errorlevel%
if %percent%==25 set modul=Downloading Wii Mod Lite
if %percent%==25 if not %temperrorlev%==0 goto error_patching

if %percent%==27 if not exist "apps/WiiModLite/icon.png" curl -s -S --insecure "%FilesHostedOn%/apps/WiiModLite/icon.png" --output apps/WiiModLite/icon.png
if %percent%==27 set /a temperrorlev=%errorlevel%
if %percent%==27 set modul=Downloading Wii Mod Lite
if %percent%==27 if not %temperrorlev%==0 goto error_patching

if %percent%==30 if not exist "apps/WiiModLite/icon.png" curl -s -S --insecure "%FilesHostedOn%/apps/WiiModLite/icon.png" --output apps/WiiModLite/icon.png
if %percent%==30 set /a temperrorlev=%errorlevel%
if %percent%==30 set modul=Downloading Wii Mod Lite
if %percent%==30 if not %temperrorlev%==0 goto error_patching

if %percent%==32 if not exist "apps/WiiModLite/meta.xml" curl -s -S --insecure "%FilesHostedOn%/apps/WiiModLite/meta.xml" --output apps/WiiModLite/meta.xml"
if %percent%==32 set /a temperrorlev=%errorlevel%
if %percent%==32 set modul=Downloading Wii Mod Lite
if %percent%==32 if not %temperrorlev%==0 goto error_patching

if %percent%==34 if not exist "apps/WiiModLite/wiimod.txt" curl -s -S --insecure "%FilesHostedOn%/apps/WiiModLite/wiimod.txt" --output apps/WiiModLite/wiimod.txt
if %percent%==34 set /a temperrorlev=%errorlevel%
if %percent%==34 set modul=Downloading Wii Mod Lite
if %percent%==34 if not %temperrorlev%==0 goto error_patching

if %percent%==36 if not exist "apps/WiiXplorer/boot.dol" curl -s -S --insecure "%FilesHostedOn%/apps/WiiXplorer/boot.dol" --output apps/WiiXplorer/boot.dol
if %percent%==36 set /a temperrorlev=%errorlevel%
if %percent%==36 set modul=Downloading WiiXplorer
if %percent%==36 if not %temperrorlev%==0 goto error_patching

if %percent%==38 if not exist "apps/WiiXplorer/icon.png" curl -s -S --insecure "%FilesHostedOn%/apps/WiiXplorer/icon.png" --output apps/WiiXplorer/icon.png
if %percent%==38 set /a temperrorlev=%errorlevel%
if %percent%==38 set modul=Downloading WiiXplorer
if %percent%==38 if not %temperrorlev%==0 goto error_patching

if %percent%==39 if not exist "apps/WiiXplorer/meta.xml" curl -s -S --insecure "%FilesHostedOn%/apps/WiiXplorer/meta.xml" --output apps/WiiXplorer/meta.xml
if %percent%==39 set /a temperrorlev=%errorlevel%
if %percent%==39 set modul=Downloading WiiXplorer
if %percent%==39 if not %temperrorlev%==0 goto error_patching

if %percent%==40 if %uninstall_2_1%==1 if not exist "apps/WiiXplorer/meta.xml" curl -s -S --insecure "%FilesHostedOn%/apps/WiiModLite/meta.xml" --output apps/WiiModLite/meta.xml
if %percent%==40 if %uninstall_2_1%==1 set /a temperrorlev=%errorlevel%
if %percent%==40 if %uninstall_2_1%==1 set modul=Downloading WiiXplorer
if %percent%==40 if %uninstall_2_1%==1 if not %temperrorlev%==0 goto error_patching

if %percent%==45 if %uninstall_2_1%==1 if not exist "apps/WiiXplorer/icon.png" curl -s -S --insecure "%FilesHostedOn%/apps/WiiModLite/meta.xml" --output apps/WiiModLite/meta.xml
if %percent%==45 if %uninstall_2_1%==1 set /a temperrorlev=%errorlevel%
if %percent%==45 if %uninstall_2_1%==1 set modul=Downloading WiiXplorer
if %percent%==45 if %uninstall_2_1%==1 if not %temperrorlev%==0 goto error_patching

if %percent%==48 if %uninstall_2_1%==1 if not exist "apps/WiiXplorer/boot.dol" curl -s -S --insecure "%FilesHostedOn%/apps/WiiModLite/meta.xml" --output apps/WiiModLite/meta.xml
if %percent%==48 if %uninstall_2_1%==1 set /a temperrorlev=%errorlevel%
if %percent%==48 if %uninstall_2_1%==1 set modul=Downloading WiiXplorer
if %percent%==48 if %uninstall_2_1%==1 if not %temperrorlev%==0 goto error_patching

if %percent%==50 if not exist "WAD" md "WAD"
if %percent%==50 call IOSPatcher\Sharpii.exe NUSD -IOS 31 -v latest -o wad\IOS31.wad -wad >NUL
if %percent%==50 set /a temperrorlev=%errorlevel%
if %percent%==50 set modul=Sharpii.exe
if %percent%==50 if not %temperrorlev%==0 goto error_patching

if %percent%==80 call IOSPatcher\Sharpii.exe NUSD -IOS 80 -v latest -o wad\IOS80.wad -wad >NUL
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
echo Patching done^^! Now please follow these instructions:
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
echo    - Remember to turn it on because it's important^^!
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
echo That's it^^! RiiConnect24 should be now gone from your Wii^^!
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
:error_NUS_DOWN
cls
echo %header%                                                                
echo.                 
echo.                 
echo.                 
echo.                 
echo.                 
echo.                 
echo.                 
echo.                 
echo.                 
echo.                 
echo.                 
echo.
echo ---------------------------------------------------------------------------------------------------------------------------
echo    /---\   ERROR             
echo   /     \  The Nintendo Update Server (NUS) is currently down. Patcher needs that server in order to work.
echo  /   ^^!   \ 
echo  --------- This probably means that there is a maintenance currently going on the server.
echo            Please come back later^^!
echo.
echo       Press any key to return to main menu.
echo ---------------------------------------------------------------------------------------------------------------------------
pause>NUL
goto begin_main
:2_prepare_uninstall
cls
echo %header%
echo -----------------------------------------------------------------------------------------------------------------------------
echo.
echo Please wait...
echo Preparing...
:: Check if NUS is up
curl -i -s http://nus.cdn.shop.wii.com/ccs/download/0001000248414741/tmd | findstr "HTTP/1.1" | findstr "500 Internal Server Error"
if %errorlevel%==0 goto error_NUS_DOWN
:: If returns 0, 500 HTTP code it is
goto 2_uninstall

:2_prepare
cls
echo %header%
echo -----------------------------------------------------------------------------------------------------------------------------
echo.
echo Please wait...
echo Preparing...
:: Check if NUS is up
curl -i -s http://nus.cdn.shop.wii.com/ccs/download/0001000248414741/tmd | findstr "HTTP/1.1" | findstr "500 Internal Server Error"
if %errorlevel%==0 goto error_NUS_DOWN
:: If returns 0, 500 HTTP code it is
goto 2_auto_ask


:2_auto_ask
cls
echo %header%
echo -----------------------------------------------------------------------------------------------------------------------------
echo.
echo Install RiiConnect24.
echo.
echo Choose instalation type:
echo 1. Express (Recommended)
echo   - This will patch every channel for later use on your Wii. This includes:
echo     - News Channel
echo     - Forecast Channel
echo     - Everybody Votes Channel
echo     - Wii Mail
echo     - Nintendo Channel
echo     - Check Mii Out Channel / Mii Contest Channel
echo.
echo 2. Custom
echo   - You will be asked what you want to patch.
set /p s=
if %s%==1 goto 2_auto
if %s%==2 goto 2_auto_ask_2
goto 2_auto_ask
:2_auto_ask_2
set /a tick=1
set /a anim_1=1
set /a anim_2=1
set /a anim_3=1
set /a anim_4=1
set /a anim_5=1
set /a anim_6=1
set /a anim_7=1
set /a anim_8=1
set /a anim_9=1
set /a anim_10=0
set /a anim_11=1
goto 2_auto_ask_2_anim_show
:2_auto_ask_2_anim_scipt
if %tick%==1 set /a anim_11=0
if %tick%==1 set /a tick=%tick%+1&goto 2_auto_ask_2_anim_show
if %tick%==2 set /a anim_8=0
if %tick%==2 set /a tick=%tick%+1&goto 2_auto_ask_2_anim_show
if %tick%==3 set /a anim_7=0
if %tick%==3 set /a tick=%tick%+1&goto 2_auto_ask_2_anim_show
if %tick%==4 set /a anim_6=0
if %tick%==4 set /a tick=%tick%+1&goto 2_auto_ask_2_anim_show
if %tick%==5 set /a anim_5=0
if %tick%==5 set /a tick=%tick%+1&goto 2_auto_ask_2_anim_show
if %tick%==6 set /a anim_4=0
if %tick%==6 set /a tick=%tick%+1&goto 2_auto_ask_2_anim_show
if %tick%==7 set /a anim_3=0
if %tick%==7 set /a tick=%tick%+1&goto 2_auto_ask_2_anim_show
if %tick%==8 set /a anim_2=0
if %tick%==8 set /a tick=%tick%+1&goto 2_auto_ask_2_anim_show
if %tick%==9 set /a anim_1=0
if %tick%==9 set /a tick=%tick%+1&goto 2_auto_ask_2_anim_show

if %tick%==10 set /a anim_9=0
if %tick%==10 set /a anim_10=1
if %tick%==10 set /a anim_11=0
if %tick%==10 set /a tick=%tick%+1&goto 2_auto_ask_2_anim_show

if %tick%==11 goto 2_choose_custom_instal_type




:2_choose_custom_instal_type
set /a evcregion=1
set /a custominstall_ios=1
set /a custominstall_evc=1
set /a custominstall_nc=1
set /a custominstall_cmoc=1
set /a sdcardstatus=0
set /a errorcopying=0
set sdcard=NUL
goto 2_choose_custom_install_type2

:2_choose_custom_install_type2
cls
echo %header%
echo -----------------------------------------------------------------------------------------------------------------------------
echo.
echo Install RiiConnect24
echo.
echo Choose instalation type:
echo - Custom
echo.
if %evcregion%==1 echo 1. Switch region. Current region: Europe
if %evcregion%==2 echo 1. Switch region. Current region: USA
echo.
if %custominstall_ios%==1 echo 2. [X] Forecast/News Channel and Wii Mail (IOS 31 and IOS 80)
if %custominstall_ios%==0 echo 2. [ ] Forecast/News Channel and Wii Mail (IOS 31 and IOS 80)
if %custominstall_evc%==1 echo 3. [X] Everybody Votes Channel
if %custominstall_evc%==0 echo 3. [ ] Everybody Votes Channel
if %custominstall_nc%==1 echo 4. [X] Nintendo Channel
if %custominstall_nc%==0 echo 4. [ ] Nintendo Channel
if %custominstall_cmoc%==1 echo 5. [X] Check Mii Out Channel / Mii Contest Channel
if %custominstall_cmoc%==0 echo 5. [ ] Check Mii Out Channel / Mii Contest Channel
echo.
echo 6. Begin patching^^!
echo R. Go back.
set /p s=
if %s%==1 goto 2_switch_region
if %s%==2 goto 2_switch_fore-news-wiimail
if %s%==3 goto 2_switch_evc
if %s%==4 goto 2_switch_nc
if %s%==5 goto 2_switch_cmoc
if %s%==6 goto 2_2
if %s%==r goto begin_main
if %s%==R goto begin_main
goto 2_choose_custom_install_type2
:2_switch_region
if %evcregion%==1 set /a evcregion=2&goto 2_choose_custom_install_type2
if %evcregion%==2 set /a evcregion=1&goto 2_choose_custom_install_type2
:2_switch_fore-news-wiimail
if %custominstall_ios%==1 set /a custominstall_ios=0&goto 2_choose_custom_install_type2
if %custominstall_ios%==0 set /a custominstall_ios=1&goto 2_choose_custom_install_type2
:2_switch_evc
if %custominstall_evc%==1 set /a custominstall_evc=0&goto 2_choose_custom_install_type2
if %custominstall_evc%==0 set /a custominstall_evc=1&goto 2_choose_custom_install_type2
:2_switch_nc
if %custominstall_nc%==1 set /a custominstall_nc=0&goto 2_choose_custom_install_type2
if %custominstall_nc%==0 set /a custominstall_nc=1&goto 2_choose_custom_install_type2
:2_switch_cmoc
if %custominstall_cmoc%==1 set /a custominstall_cmoc=0&goto 2_choose_custom_install_type2
if %custominstall_cmoc%==0 set /a custominstall_cmoc=1&goto 2_choose_custom_install_type2
	


:2_auto_ask_2_anim_show
cls
echo %header%
echo -----------------------------------------------------------------------------------------------------------------------------
echo.
echo Install RiiConnect24
echo.
echo Choose instalation type:
if %anim_1%==1 echo 1. Express (Recommended)
if %anim_2%==1 echo   - This will patch every channel for later use on your Wii. This includes:
if %anim_3%==1 echo     - News Channel
if %anim_4%==1 echo     - Forecast Channel
if %anim_5%==1 echo     - Everybody Votes Channel
if %anim_6%==1 echo     - Wii Mail
if %anim_7%==1 echo     - Nintendo Channel
if %anim_8%==1 echo     - Check Mii Out Channel / Mii Contest Channel
if %anim_9%==1 echo 2. Custom
if %anim_10%==1 echo - Custom
if %anim_11%==1 echo   - You will be asked what you want to patch.
goto 2_auto_ask_2_anim_scipt

:2_auto
cls
echo %header%
echo -----------------------------------------------------------------------------------------------------------------------------
echo.
echo Hello %username%, welcome to the express instalation of RiiConnect24.
echo.
echo The patcher will download any files that are required to run the patcher if you are missing them.
echo The entire process should take about 1 to 3 minutes depending on your computer CPU and internet speed.
echo.
echo But before starting, you need to tell me one thing:
echo.
echo For Everybody Votes Channel, Check Mii Out Channel / Mii Contest Channel and Nintendo Channel, which region should I download and patch? 
echo (Where do you live?/Region of your console)
echo.
echo 1. Europe
echo 2. USA
set /p s=Choose one: 
if %s%==1 set /a evcregion=1& goto 2_1
if %s%==2 set /a evcregion=2& goto 2_1
goto 2_auto
:2_1
set /a custominstall_ios=1
set /a custominstall_evc=1
set /a custominstall_nc=1
set /a custominstall_cmoc=1	
cls
echo %header%
echo -----------------------------------------------------------------------------------------------------------------------------
echo.
echo Great^^!
echo After passing this screen, any user interraction won't be needed so you can relax and let me do the work^^! :)
echo.
echo Did I forget about something? Yes^^! To make patching even easier, I can download everything that you need and put it on 
echo your SD Card^^!
echo.
echo Please connect your Wii SD Card to the computer.
echo.
echo 1. Connected^^!
echo 2. I can't connect an SD Card to the computer.
set /p s=
set sdcard=NUL
if %s%==1 set /a sdcardstatus=1& set tempgotonext=2_1_summary& goto detect_sd_card
if %s%==2 set /a sdcardstatus=0& set /a sdcard=NUL& goto 2_1_summary
goto 2_1
:detect_sd_card
set sdcard=NUL
set counter=-1
set letters=ABDEFGHIJKLMNOPQRSTUVWXYZ
set looking_for=
:detect_sd_card_2
set /a counter=%counter%+1
set looking_for=!letters:~%counter%,1!
if exist %looking_for%:/apps (
set sdcard=%looking_for%
call :%tempgotonext%
exit
exit
)

if %looking_for%==Z (
set sdcard=NUL
call :%tempgotonext%
exit
exit
)
goto detect_sd_card_2

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
if %sdcardstatus%==1 if not %sdcard%==NUL echo Congrats^^! I've successfully detected your SD Card^^! Drive letter: %sdcard%
if %sdcardstatus%==1 if not %sdcard%==NUL echo I will be able to automatically download and install everything on your SD Card^^!	
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
set /a troubleshoot_auto_tool_notification=0
set /a temperrorlev=0
set /a counter_done=0
set /a percent=0
set /a temperrorlev=0

::
set /a progress_downloading=0
set /a progress_ios=0
set /a progress_evc=0
set /a progress_nc=0
set /a progress_cmoc=0
set /a progress_finishing=0

goto random_funfact
:random_funfact

:: Get start time:
for /F "tokens=1-4 delims=:.," %%a in ("%time%") do (
   set /A "start=(((%%a*60)+1%%b %% 100)*60+1%%c %% 100)*100+1%%d %% 100"
)
set /a funfact_number=%random% %% (1 + 30)
if /i %funfact_number% LSS 1 goto random_funfact
if /i %funfact_number% GTR 30 goto random_funfact
if %funfact_number%==1 set funfact=Did you know the wii was the best selling game-console of 2006?
if %funfact_number%==2 set funfact=Did you know KcrPL makes these amazing patchers and the updates for the patcher?
if %funfact_number%==3 set funfact=RiiConnect24 originally started out as "CustomConnect24"!
if %funfact_number%==4 set funfact=Did you the RiiConnect24 logo was made by NeoRame, the same person who made the Wiimmfi logo?
if %funfact_number%==5 set funfact=The Wii was nicknamed "Revolution" during its development stage.
if %funfact_number%==6 set funfact=Did you know the letters in the Wii model number RVL stand for the Wii's codename, Revolution?
if %funfact_number%==7 set funfact=The music used in many of the Wii's channels (including the Wii Shop, Mii, Check Mii Out, and Forecast Channel) was composed by Kazumi Totaka.
if %funfact_number%==8 set funfact=The Internet Channel once costed 500 Wii Points.
if %funfact_number%==9 set funfact=It's possible to use candles as a Wii Sensor Bar.
if %funfact_number%==10 set funfact=The blinking blue light that indicates a system message has been received is actually synced to the bird call of the Japanese bush warbler. More info about it on RiiConnect24 YouTube Channel^^!
if %funfact_number%==11 set funfact=Wii sports is the most sold game on the Wii. It sold 82.85 million. Overall it is the 3rd most sold game in the world.
if %funfact_number%==12 set funfact=Did you know that most of the scripts used to make RiiConnect24 work are written in Python?
if %funfact_number%==13 set funfact=Thank you Spotlight for making our mail system secure.
if %funfact_number%==14 set funfact=Did you know that we have an awesome Discord server where you can always stay updated about the project status?
if %funfact_number%==15 set funfact=The Everybody Votes Channel was originally an idea about sending quizzes and questions daily to Wiis.
if %funfact_number%==16 set funfact=The News Channel developers had an idea at some point about making a dad's Mii being the news caster in the Channel, but it probably didn't make it because some stories on there probably aren't appropriate for kids.
if %funfact_number%==17 set funfact=The Everybody Votes Channel was originally called the Questionnaire Channel, then Citizens Vote Channel.
if %funfact_number%==18 set funfact=The Forecast Channel had a "laundry index" (to show how appropriate it is to dry your clothes outside) and a "pollen count" in the Japanese version.
if %funfact_number%==19 set funfact=During the Forecast Channel development, Nintendo's America department got hit by a thunderstorm, and the developers of the Channel in Japan lost contact with them.
if %funfact_number%==20 set funfact=During the News Channel development, Nintendo's Europe department got hit by a big rainstorm, and the developers of the Channel in Japan lost contact with them.
if %funfact_number%==21 set funfact=The News Channel has an alternate slide show song that plays as might.
if %funfact_number%==22 set funfact=During E3 2006, Satoru Iwata said WiiConnect24 uses as much power as a miniature lightbulb while the console is in standby.
if %funfact_number%==23 set funfact=The effect used when rapidly zooming in and out of photos on the Photo Channel was implemented into the News Channel to zoom in and out of text.
if %funfact_number%==24 set funfact=The help cats in the News Channel and the Photo Channel are brothers and sisters (the one in the News Channel being male, and the Photo Channel being a younger female).
if %funfact_number%==25 set funfact=The Japanese version of the Forecast Channel does not show the current forecast.
if %funfact_number%==26 set funfact=The Forecast Channel, News Channel and the Photo Channel were made by nearly the same team.
if %funfact_number%==27 set funfact=The first worldwide Everybody Votes Channel question about if you like dogs or cats more got more than 500,000 votes.
if %funfact_number%==28 set funfact=The night song that plays when viewing the local forecast in the Forecast Channel was made before the day song, that was requested to make people not feel sleepy when it was played during the day.
if %funfact_number%==29 set funfact=The globe in the Forecast and News Channel is based on imagery from NASA, and the same globe was used in Mario Kart Wii.
if %funfact_number%==30 set funfact=You can press the Reset button while the Wii's in standby to turn off the blue light that glows when you receive a message.




set /a percent=%percent%+1
goto 2_3
:2_3
:: Get end time:
for /F "tokens=1-4 delims=:.," %%a in ("%time%") do (
   set /A "end=(((%%a*60)+1%%b %% 100)*60+1%%c %% 100)*100+1%%d %% 100"
)

rem Get elapsed time:
set /A elapsed=end-start


rem Show elapsed time:
set /A hh=elapsed/(60*60*100), rest=elapsed%%(60*60*100), mm=rest/(60*100), rest%%=60*100, ss=rest/100, cc=rest%%100
if %mm% lss 10 set mm=%mm%
if %ss% lss 10 set ss=%ss%
if %cc% lss 10 set cc=%cc%


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
echo  [*] Patching... this can take some time depending on the processing speed (CPU) of your computer.

if %troubleshoot_auto_tool_notification%==1 echo :------------------------------------------------------------------------------------------------------------------------:
if %troubleshoot_auto_tool_notification%==1 echo : Warning: There was an error while patching, but the patcher ran the troubleshooting tool that should automatically fix :
if %troubleshoot_auto_tool_notification%==1 echo : the problem. The patching process has been restarted.                                                                  :
if %troubleshoot_auto_tool_notification%==1 echo :------------------------------------------------------------------------------------------------------------------------:
echo.

set /a refreshing_in=20-"%ss%">>NUL
echo ---------------------------------------------------------------------------------------------------------------------------
echo Fun Fact: %funfact%
echo ---------------------------------------------------------------------------------------------------------------------------
if /i %refreshing_in% GTR 0 echo Next fun fact... %refreshing_in% sec
if /i %refreshing_in% LEQ 0 echo Next fun fact... 0 sec
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
echo.
if %progress_downloading%==0 echo [ ] Downloading files
if %progress_downloading%==1 echo [X] Downloading files
if %custominstall_ios%==1 if %progress_ios%==0 echo [ ] Patching IOS's
if %custominstall_ios%==1 if %progress_ios%==1 echo [X] Patching IOS's
if %custominstall_evc%==1 if %progress_evc%==0 echo [ ] Everybody Votes Channel
if %custominstall_evc%==1 if %progress_evc%==1 echo [X] Everybody Votes Channel
if %custominstall_cmoc%==1 if %evcregion%==1 if %progress_cmoc%==0 echo [ ] Mii Contest Channel
if %custominstall_cmoc%==1 if %evcregion%==1 if %progress_cmoc%==1 echo [X] Mii Contest Channel
if %custominstall_cmoc%==1 if %evcregion%==2 if %progress_cmoc%==0 echo [ ] Check Mii Out Channel
if %custominstall_cmoc%==1 if %evcregion%==2 if %progress_cmoc%==1 echo [X] Check Mii Out Channel
if %custominstall_nc%==1 if %progress_nc%==0 echo [ ] Nintendo Channel
if %custominstall_nc%==1 if %progress_nc%==1 echo [X] Nintendo Channel
if %progress_finishing%==0 echo [ ] Finishing...
if %progress_finishing%==1 echo [X] Finishing...

call :patching_fast_travel_%percent%
goto patching_fast_travel_100

::Download files
:patching_fast_travel_1
if %percent%==1 md WAD
if %percent%==1 if not exist IOSPatcher md IOSPatcher
if %percent%==1 if not exist "IOSPatcher/00000006-31.delta" curl -s -S --insecure "%FilesHostedOn%/IOSPatcher/00000006-31.delta" --output IOSPatcher/00000006-31.delta
if %percent%==1 set /a temperrorlev=%errorlevel%
if %percent%==1 set modul=Downloading 06-31.delta
if %percent%==1 if not %temperrorlev%==0 goto error_patching

if %percent%==1 if not exist "IOSPatcher/00000006-80.delta" curl -s -S --insecure "%FilesHostedOn%/IOSPatcher/00000006-80.delta" --output IOSPatcher/00000006-80.delta
if %percent%==1 set /a temperrorlev=%errorlevel%
if %percent%==1 set modul=Downloading 06-80.delta
if %percent%==1 if not %temperrorlev%==0 goto error_patching
goto patching_fast_travel_100
:patching_fast_travel_2
if %percent%==2 if not exist "IOSPatcher/00000006-80.delta" curl -s -S --insecure "%FilesHostedOn%/IOSPatcher/00000006-80.delta" --output IOSPatcher/00000006-80.delta
if %percent%==2 set /a temperrorlev=%errorlevel%
if %percent%==2 set modul=Downloading 06-80.delta
if %percent%==2 if not %temperrorlev%==0 goto error_patching
goto patching_fast_travel_100
:patching_fast_travel_3
if %percent%==3 if not exist "IOSPatcher/libWiiSharp.dll" curl -s -S --insecure "%FilesHostedOn%/IOSPatcher/libWiiSharp.dll" --output IOSPatcher/libWiiSharp.dll
if %percent%==3 set /a temperrorlev=%errorlevel%
if %percent%==3 set modul=Downloading libWiiSharp.dll
if %percent%==3 if not %temperrorlev%==0 goto error_patching

if %percent%==3 if not exist "IOSPatcher/Sharpii.exe" curl -s -S --insecure "%FilesHostedOn%/IOSPatcher/Sharpii.exe" --output IOSPatcher/Sharpii.exe
if %percent%==3 set /a temperrorlev=%errorlevel%
if %percent%==3 set modul=Downloading Sharpii.exe
if %percent%==3 if not %temperrorlev%==0 goto error_patching
goto patching_fast_travel_100
:patching_fast_travel_4
if %percent%==4 if not exist "IOSPatcher/WadInstaller.dll" curl -s -S --insecure "%FilesHostedOn%/IOSPatcher/WadInstaller.dll" --output IOSPatcher/WadInstaller.dll
if %percent%==4 set /a temperrorlev=%errorlevel%
if %percent%==4 set modul=Downloading WadInstaller.dll
if %percent%==4 if not %temperrorlev%==0 goto error_patching
goto patching_fast_travel_100
:patching_fast_travel_5
if %percent%==5 if not exist "IOSPatcher/xdelta3.exe" curl -s -S --insecure "%FilesHostedOn%/IOSPatcher/xdelta3.exe" --output IOSPatcher/xdelta3.exe
if %percent%==5 set /a temperrorlev=%errorlevel%
if %percent%==5 set modul=Downloading xdelta3.exe
if %percent%==5 if not %temperrorlev%==0 goto error_patching
goto patching_fast_travel_100
::EVC
:patching_fast_travel_6
if %percent%==6 if not exist EVCPatcher/patch md EVCPatcher\patch
if %percent%==6 if not exist EVCPatcher/dwn md EVCPatcher\dwn
if %percent%==6 if not exist EVCPatcher/dwn/0001000148414A45v512 md EVCPatcher\dwn\0001000148414A45v512
if %percent%==6 if not exist EVCPatcher/dwn/0001000148414A50v512 md EVCPatcher\dwn\0001000148414A50v512
if %percent%==6 if not exist EVCPatcher/pack md EVCPatcher\pack
if %percent%==6 if not exist "EVCPatcher/patch/Europe.delta" curl -s -S --insecure "%FilesHostedOn%/EVCPatcher/patch/Europe.delta" --output EVCPatcher/patch/Europe.delta
if %percent%==6 set /a temperrorlev=%errorlevel%
if %percent%==6 set modul=Downloading Europe Delta
if %percent%==6 if not %temperrorlev%==0 goto error_patching
if %percent%==6 if not exist "EVCPatcher/patch/USA.delta" curl -s -S --insecure "%FilesHostedOn%/EVCPatcher/patch/USA.delta" --output EVCPatcher/patch/USA.delta
if %percent%==6 set /a temperrorlev=%errorlevel%
if %percent%==6 set modul=Downloading USA Delta
if %percent%==6 if not %temperrorlev%==0 goto error_patching
goto patching_fast_travel_100
:patching_fast_travel_7
if %percent%==7 if not exist "EVCPatcher/NUS_Downloader_Decrypt.exe" curl -s -S --insecure "%FilesHostedOn%/EVCPatcher/NUS_Downloader_Decrypt.exe" --output EVCPatcher/NUS_Downloader_Decrypt.exe
if %percent%==7 set /a temperrorlev=%errorlevel%
if %percent%==7 set modul=Downloading decrypter
if %percent%==7 if not %temperrorlev%==0 goto error_patching
goto patching_fast_travel_100

:patching_fast_travel_8
if %percent%==8 if not exist "EVCPatcher/patch/xdelta3.exe" curl -s -S --insecure "%FilesHostedOn%/EVCPatcher/patch/xdelta3.exe" --output EVCPatcher/patch/xdelta3.exe
if %percent%==8 set /a temperrorlev=%errorlevel%
if %percent%==8 set modul=Downloading xdelta3.exe
if %percent%==8 if not %temperrorlev%==0 goto error_patching

if %percent%==8 if not exist "EVCPatcher/pack/libWiiSharp.dll" curl -s -S --insecure "%FilesHostedOn%/EVCPatcher/pack/libWiiSharp.dll" --output "EVCPatcher/pack/libWiiSharp.dll"
if %percent%==8 set /a temperrorlev=%errorlevel%
if %percent%==8 set modul=Downloading libWiiSharp.dll
if %percent%==8 if not %temperrorlev%==0 goto error_patching

if %percent%==8 if not exist "EVCPatcher/pack/Sharpii.exe" curl -s -S --insecure "%FilesHostedOn%/EVCPatcher/pack/Sharpii.exe" --output EVCPatcher/pack/Sharpii.exe
if %percent%==8 set /a temperrorlev=%errorlevel%
if %percent%==8 set modul=Downloading Sharpii.exe
if %percent%==8 if not %temperrorlev%==0 goto error_patching
if %percent%==8 if not exist "EVCPatcher/dwn/Sharpii.exe" curl -s -S --insecure "%FilesHostedOn%/EVCPatcher/dwn/Sharpii.exe" --output EVCPatcher/dwn/Sharpii.exe
if %percent%==8 set /a temperrorlev=%errorlevel%
if %percent%==8 set modul=Downloading Sharpii.exe
if %percent%==8 if not %temperrorlev%==0 goto error_patching
goto patching_fast_travel_100
:patching_fast_travel_9
if %percent%==9 if not exist "EVCPatcher/dwn/libWiiSharp.dll" curl -s -S --insecure "%FilesHostedOn%/EVCPatcher/dwn/libWiiSharp.dll" --output EVCPatcher/dwn/libWiiSharp.dll
if %percent%==9 set /a temperrorlev=%errorlevel%
if %percent%==9 set modul=Downloading libWiiSharp.dll
if %percent%==9 if not %temperrorlev%==0 goto error_patching
goto patching_fast_travel_100
:patching_fast_travel_10
if %percent%==10 if not exist "EVCPatcher/dwn/0001000148414A45v512/cetk" curl -s -S --insecure "%FilesHostedOn%/EVCPatcher/dwn/0001000148414A45v512/cetk" --output EVCPatcher/dwn/0001000148414A45v512/cetk
if %percent%==10 set /a temperrorlev=%errorlevel%
if %percent%==10 set modul=Downloading USA CETK
if %percent%==10 if not %temperrorlev%==0 goto error_patching

if %percent%==10 if not exist "EVCPatcher/dwn/0001000148414A50v512/cetk" curl -s -S --insecure "%FilesHostedOn%/EVCPatcher/dwn/0001000148414A50v512/cetk" --output EVCPatcher/dwn/0001000148414A50v512/cetk
if %percent%==10 set /a temperrorlev=%errorlevel%
if %percent%==10 set modul=Downloading EUR CETK
if %percent%==10 if not %temperrorlev%==0 goto error_patching
goto patching_fast_travel_100

::CMOC
:patching_fast_travel_11
if %percent%==11 if not exist CMOCPatcher/patch md CMOCPatcher\patch
if %percent%==11 if not exist CMOCPatcher/dwn md CMOCPatcher\dwn
if %percent%==11 if not exist CMOCPatcher/dwn/0001000148415045v512 md CMOCPatcher\dwn\0001000148415045v512
if %percent%==11 if not exist CMOCPatcher/dwn/0001000148415050v512 md CMOCPatcher\dwn\0001000148415050v512
if %percent%==11 if not exist CMOCPatcher/pack md CMOCPatcher\pack
if %percent%==11 if not exist "CMOCPatcher/patch/00000001_Europe.delta" curl -s -S --insecure "%FilesHostedOn%/CMOCPatcher/patch/00000001_Europe.delta" --output CMOCPatcher/patch/00000001_Europe.delta
if %percent%==11 if not exist "CMOCPatcher/patch/00000004_Europe.delta" curl -s -S --insecure "%FilesHostedOn%/CMOCPatcher/patch/00000004_Europe.delta" --output CMOCPatcher/patch/00000004_Europe.delta
if %percent%==11 set /a temperrorlev=%errorlevel%
if %percent%==11 set modul=Downloading Europe Delta
if %percent%==11 if not %temperrorlev%==0 goto error_patching
goto patching_fast_travel_100
:patching_fast_travel_12
if %percent%==12 if not exist "CMOCPatcher/patch/00000001_USA.delta" curl -s -S --insecure "%FilesHostedOn%/CMOCPatcher/patch/00000001_USA.delta" --output CMOCPatcher/patch/00000001_USA.delta
if %percent%==12 if not exist "CMOCPatcher/patch/00000004_USA.delta" curl -s -S --insecure "%FilesHostedOn%/CMOCPatcher/patch/00000004_USA.delta" --output CMOCPatcher/patch/00000004_USA.delta
if %percent%==12 set /a temperrorlev=%errorlevel%
if %percent%==12 set modul=Downloading USA Delta
if %percent%==12 if not %temperrorlev%==0 goto error_patching
if %percent%==12 if not exist "CMOCPatcher/NUS_Downloader_Decrypt.exe" curl -s -S --insecure "%FilesHostedOn%/CMOCPatcher/NUS_Downloader_Decrypt.exe" --output CMOCPatcher/NUS_Downloader_Decrypt.exe
if %percent%==12 set /a temperrorlev=%errorlevel%
if %percent%==12 set modul=Downloading decrypter
if %percent%==12 if not %temperrorlev%==0 goto error_patching
goto patching_fast_travel_100
:patching_fast_travel_13
if %percent%==13 if not exist "CMOCPatcher/patch/xdelta3.exe" curl -s -S --insecure "%FilesHostedOn%/CMOCPatcher/patch/xdelta3.exe" --output CMOCPatcher/patch/xdelta3.exe
if %percent%==13 set /a temperrorlev=%errorlevel%
if %percent%==13 set modul=Downloading xdelta3.exe
if %percent%==13 if not %temperrorlev%==0 goto error_patching
goto patching_fast_travel_100
:patching_fast_travel_14
if %percent%==14 if not exist "CMOCPatcher/pack/libWiiSharp.dll" curl -s -S --insecure "%FilesHostedOn%/CMOCPatcher/pack/libWiiSharp.dll" --output "CMOCPatcher/pack/libWiiSharp.dll"
if %percent%==14 set /a temperrorlev=%errorlevel%
if %percent%==14 set modul=Downloading libWiiSharp.dll
if %percent%==14 if not %temperrorlev%==0 goto error_patching
goto patching_fast_travel_100
:patching_fast_travel_15
if %percent%==15 if not exist "CMOCPatcher/pack/Sharpii.exe" curl -s -S --insecure "%FilesHostedOn%/CMOCPatcher/pack/Sharpii.exe" --output CMOCPatcher/pack/Sharpii.exe
if %percent%==15 set /a temperrorlev=%errorlevel%
if %percent%==15 set modul=Downloading Sharpii.exe
if %percent%==15 if not %temperrorlev%==0 goto error_patching
goto patching_fast_travel_100
:patching_fast_travel_16
if %percent%==16 if not exist "CMOCPatcher/dwn/Sharpii.exe" curl -s -S --insecure "%FilesHostedOn%/CMOCPatcher/dwn/Sharpii.exe" --output CMOCPatcher/dwn/Sharpii.exe
if %percent%==16 set /a temperrorlev=%errorlevel%
if %percent%==16 set modul=Downloading Sharpii.exe
if %percent%==16 if not %temperrorlev%==0 goto error_patching
goto patching_fast_travel_100
:patching_fast_travel_17
if %percent%==17 if not exist "CMOCPatcher/dwn/libWiiSharp.dll" curl -s -S --insecure "%FilesHostedOn%/CMOCPatcher/dwn/libWiiSharp.dll" --output CMOCPatcher/dwn/libWiiSharp.dll
if %percent%==17 set /a temperrorlev=%errorlevel%
if %percent%==17 set modul=Downloading libWiiSharp.dll
if %percent%==17 if not %temperrorlev%==0 goto error_patching
goto patching_fast_travel_100
:patching_fast_travel_18
if %percent%==18 if not exist "CMOCPatcher/dwn/0001000148415045v512/cetk" curl -s -S --insecure "%FilesHostedOn%/CMOCPatcher/dwn/0001000148415045v512/cetk" --output CMOCPatcher/dwn/0001000148415045v512/cetk
if %percent%==18 if not exist "CMOCPatcher/dwn/0001000148415045v512/cert" curl -s -S --insecure "%FilesHostedOn%/CMOCPatcher/dwn/0001000148415045v512/cert" --output CMOCPatcher/dwn/0001000148415045v512/cert
if %percent%==18 set /a temperrorlev=%errorlevel%
if %percent%==18 set modul=Downloading USA CETK
if %percent%==18 if not %temperrorlev%==0 goto error_patching
goto patching_fast_travel_100
:patching_fast_travel_19
if %percent%==19 if not exist "CMOCPatcher/dwn/0001000148415050v512/cetk" curl -s -S --insecure "%FilesHostedOn%/CMOCPatcher/dwn/0001000148415050v512/cetk" --output CMOCPatcher/dwn/0001000148415050v512/cetk
if %percent%==19 if not exist "CMOCPatcher/dwn/0001000148415050v512/cert" curl -s -S --insecure "%FilesHostedOn%/CMOCPatcher/dwn/0001000148415050v512/cert" --output CMOCPatcher/dwn/0001000148415050v512/cert
if %percent%==19 set /a temperrorlev=%errorlevel%
if %percent%==19 set modul=Downloading EUR CETK
if %percent%==19 if not %temperrorlev%==0 goto error_patching
goto patching_fast_travel_100


::NC
:patching_fast_travel_20
if %percent%==20 if not exist NCPatcher/patch md NCPatcher\patch
if %percent%==20 if not exist NCPatcher/dwn md NCPatcher\dwn
if %percent%==20 if not exist NCPatcher/dwn/0001000148415450v1792 md NCPatcher\dwn\0001000148415450v1792
if %percent%==20 if not exist NCPatcher/dwn/0001000148415445v1792 md NCPatcher\dwn\0001000148415445v1792
if %percent%==20 if not exist NCPatcher/pack md NCPatcher\pack
if %percent%==20 if not exist "NCPatcher/patch/Europe.delta" curl -s -S --insecure "%FilesHostedOn%/NCPatcher/patch/Europe.delta" --output NCPatcher/patch/Europe.delta
if %percent%==20 set /a temperrorlev=%errorlevel%
if %percent%==20 set modul=Downloading Europe Delta [NC]
if %percent%==20 if not %temperrorlev%==0 goto error_patching

if %percent%==20 if not exist "NCPatcher/patch/USA.delta" curl -s -S --insecure "%FilesHostedOn%/NCPatcher/patch/USA.delta" --output NCPatcher/patch/USA.delta
if %percent%==20 set /a temperrorlev=%errorlevel%
if %percent%==20 set modul=Downloading USA Delta [NC]
if %percent%==20 if not %temperrorlev%==0 goto error_patching

if %percent%==20 if not exist "NCPatcher/NUS_Downloader_Decrypt.exe" curl -s -S --insecure "%FilesHostedOn%/NCPatcher/NUS_Downloader_Decrypt.exe" --output NCPatcher/NUS_Downloader_Decrypt.exe
if %percent%==20 set /a temperrorlev=%errorlevel%
if %percent%==20 set modul=Downloading Decrypter
if %percent%==20 if not %temperrorlev%==0 goto error_patching
goto patching_fast_travel_100
:patching_fast_travel_21
if %percent%==21 if not exist "NCPatcher/patch/xdelta3.exe" curl -s -S --insecure "%FilesHostedOn%/NCPatcher/patch/xdelta3.exe" --output NCPatcher/patch/xdelta3.exe
if %percent%==21 set /a temperrorlev=%errorlevel%
if %percent%==21 set modul=Downloading xdelta3.exe
if %percent%==21 if not %temperrorlev%==0 goto error_patching

if %percent%==21 if not exist "NCPatcher/pack/libWiiSharp.dll" curl -s -S --insecure "%FilesHostedOn%/NCPatcher/pack/libWiiSharp.dll" --output NCPatcher/pack/libWiiSharp.dll
if %percent%==21 set /a temperrorlev=%errorlevel%
if %percent%==21 set modul=Downloading libWiiSharp.dll
if %percent%==21 if not %temperrorlev%==0 goto error_patching

if %percent%==21 if not exist "NCPatcher/pack/Sharpii.exe" curl -s -S --insecure "%FilesHostedOn%/NCPatcher/pack/Sharpii.exe" --output NCPatcher/pack/Sharpii.exe
if %percent%==21 set /a temperrorlev=%errorlevel%
if %percent%==21 set modul=Downloading Sharpii.exe
if %percent%==21 if not %temperrorlev%==0 goto error_patching
goto patching_fast_travel_100
:patching_fast_travel_22
if %percent%==22 if not exist "NCPatcher/dwn/Sharpii.exe" curl -s -S --insecure "%FilesHostedOn%/NCPatcher/dwn/Sharpii.exe" --output NCPatcher/dwn/Sharpii.exe
if %percent%==22 set /a temperrorlev=%errorlevel%
if %percent%==22 set modul=Downloading Sharpii.exe
if %percent%==22 if not %temperrorlev%==0 goto error_patching
goto patching_fast_travel_100
:patching_fast_travel_23
if %percent%==23 if not exist "NCPatcher/dwn/libWiiSharp.dll" curl -s -S --insecure "%FilesHostedOn%/NCPatcher/dwn/libWiiSharp.dll" --output NCPatcher/dwn/libWiiSharp.dll
if %percent%==23 set /a temperrorlev=%errorlevel%
if %percent%==23 set modul=Downloading libWiiSharp.dll
if %percent%==23 if not %temperrorlev%==0 goto error_patching
goto patching_fast_travel_100
:patching_fast_travel_24
if %percent%==24 if not exist "NCPatcher/dwn/0001000148415445v1792/cetk" curl -s -S --insecure "%FilesHostedOn%/NCPatcher/dwn/0001000148415445v1792/cetk" --output NCPatcher/dwn/0001000148415445v1792/cetk
if %percent%==24 set /a temperrorlev=%errorlevel%
if %percent%==24 set modul=Downloading USA CETK
if %percent%==24 if not %temperrorlev%==0 goto error_patching

if %percent%==24 if not exist "NCPatcher/dwn/0001000148415450v1792/cetk" curl -s -S --insecure "%FilesHostedOn%/NCPatcher/dwn/0001000148415450v1792/cetk" --output NCPatcher/dwn/0001000148415450v1792/cetk
if %percent%==24 set /a temperrorlev=%errorlevel%
if %percent%==24 set modul=Downloading EUR CETK
if %percent%==24 if not %temperrorlev%==0 goto error_patching
goto patching_fast_travel_100

::Everything else
:patching_fast_travel_25
if %percent%==25 if not exist apps md apps
if %percent%==25 if not exist apps/Mail-Patcher md apps\Mail-Patcher
if %percent%==25 if not exist "apps/Mail-Patcher/boot.dol" curl -s -S --insecure "%FilesHostedOn%/apps/Mail-Patcher/boot.dol" --output apps/Mail-Patcher/boot.dol
if %percent%==25 set /a temperrorlev=%errorlevel%
if %percent%==25 set modul=Downloading Mail Patcher
if %percent%==25 if not %temperrorlev%==0 goto error_patching


if %percent%==25 if not exist "apps/Mail-Patcher/icon.png" curl -s -S --insecure "%FilesHostedOn%/apps/Mail-Patcher/icon.png" --output apps/Mail-Patcher/icon.png
if %percent%==25 set /a temperrorlev=%errorlevel%
if %percent%==25 set modul=Downloading Mail Patcher
if %percent%==25 if not %temperrorlev%==0 goto error_patching


if %percent%==25 if not exist "apps/Mail-Patcher/meta.xml" curl -s -S --insecure "%FilesHostedOn%/apps/Mail-Patcher/meta.xml" --output apps/Mail-Patcher/meta.xml
if %percent%==25 set /a temperrorlev=%errorlevel%
if %percent%==25 set modul=Downloading Mail Patcher
if %percent%==25 if not %temperrorlev%==0 goto error_patching
goto patching_fast_travel_100

:patching_fast_travel_26
if %percent%==26 if not exist apps/WiiModLite md apps\WiiModLite
if %percent%==26 if not exist apps/Mail-Patcher md apps\Mail-Patcher
if %percent%==26 if not exist "apps/WiiModLite/boot.dol" curl -s -S --insecure "%FilesHostedOn%/apps/WiiModLite/boot.dol" --output apps/WiiModLite/boot.dol
if %percent%==26 set /a temperrorlev=%errorlevel%
if %percent%==26 set modul=Downloading Wii Mod Lite
if %percent%==26 if not %temperrorlev%==0 goto error_patching

if %percent%==26 if not exist "apps/WiiModLite/database.txt" curl -s -S --insecure "%FilesHostedOn%/apps/WiiModLite/database.txt" --output apps/WiiModLite/database.txt
if %percent%==26 set /a temperrorlev=%errorlevel%
if %percent%==26 set modul=Downloading Wii Mod Lite
if %percent%==26 if not %temperrorlev%==0 goto error_patching
goto patching_fast_travel_100
:patching_fast_travel_27
if %percent%==27 if not exist "apps/WiiModLite/icon.png" curl -s -S --insecure "%FilesHostedOn%/apps/WiiModLite/icon.png" --output apps/WiiModLite/icon.png
if %percent%==27 set /a temperrorlev=%errorlevel%
if %percent%==27 set modul=Downloading Wii Mod Lite
if %percent%==27 if not %temperrorlev%==0 goto error_patching

if %percent%==27 if not exist "apps/WiiModLite/icon.png" curl -s -S --insecure "%FilesHostedOn%/apps/WiiModLite/icon.png" --output apps/WiiModLite/icon.png
if %percent%==27 set /a temperrorlev=%errorlevel%
if %percent%==27 set modul=Downloading Wii Mod Lite
if %percent%==27 if not %temperrorlev%==0 goto error_patching
goto patching_fast_travel_100

:patching_fast_travel_28
if %percent%==28 if not exist "apps/WiiModLite/meta.xml" curl -s -S --insecure "%FilesHostedOn%/apps/WiiModLite/meta.xml" --output apps/WiiModLite/meta.xml
if %percent%==28 set /a temperrorlev=%errorlevel%
if %percent%==28 set modul=Downloading Wii Mod Lite
if %percent%==28 if not %temperrorlev%==0 goto error_patching
if %percent%==28 if not exist "apps/WiiModLite/wiimod.txt" curl -s -S --insecure "%FilesHostedOn%/apps/WiiModLite/wiimod.txt" --output apps/WiiModLite/wiimod.txt
if %percent%==28 set /a temperrorlev=%errorlevel%
if %percent%==28 set modul=Downloading Wii Mod Lite
if %percent%==28 if not %temperrorlev%==0 goto error_patching
goto patching_fast_travel_100
:patching_fast_travel_29
if %percent%==29 if not exist "EVCPatcher/patch/Europe.delta" curl -s -S --insecure "%FilesHostedOn%EVCPatcher/patch/Europe.delta" --output EVCPatcher/patch/Europe.delta
if %percent%==29 set /a temperrorlev=%errorlevel%
if %percent%==29 set modul=Downloading Europe Delta
if %percent%==29 if not %temperrorlev%==0 goto error_patching
goto patching_fast_travel_100
:patching_fast_travel_30
if %percent%==30 if not exist "EVCPatcher/patch/USA.delta" curl -s -S --insecure "%FilesHostedOn%/EVCPatcher/patch/USA.delta" --output EVCPatcher/patch/USA.delta
if %percent%==30 set /a temperrorlev=%errorlevel%
if %percent%==30 set /a progress_downloading=1
if %percent%==30 set modul=Downloading Wii Mod Lite
if %percent%==30 if not %temperrorlev%==0 goto error_patching
goto patching_fast_travel_100

::IOS Patcher
:patching_fast_travel_31
if %custominstall_ios%==1 if %percent%==31 call IOSPatcher\Sharpii.exe NUSD -IOS 31 -v latest -o IOSPatcher\IOS31-old.wad -wad >NUL
if %custominstall_ios%==1 if %percent%==31 set /a temperrorlev=%errorlevel%
if %custominstall_ios%==1 if %percent%==31 set modul=Sharpii.exe
if %custominstall_ios%==1 if %percent%==31 if not %temperrorlev%==0 goto error_patching
if %custominstall_ios%==1 if %percent%==31 call IOSPatcher\Sharpii.exe NUSD -IOS 80 -v latest -o IOSPatcher\IOS80-old.wad -wad >NUL
if %custominstall_ios%==1 if %percent%==31 set /a temperrorlev=%errorlevel%
if %custominstall_ios%==1 if %percent%==31 set modul=Sharpii.exe
if %custominstall_ios%==1 if %percent%==31 if not %temperrorlev%==0 goto error_patching
goto patching_fast_travel_100
:patching_fast_travel_32
if %custominstall_ios%==1 if %percent%==32 call IOSPatcher\Sharpii.exe WAD -u IOSPatcher\IOS31-old.wad IOSPatcher/IOS31/ >NUL
if %custominstall_ios%==1 if %percent%==32 set /a temperrorlev=%errorlevel%
if %custominstall_ios%==1 if %percent%==32 set modul=Sharpii.exe
if %custominstall_ios%==1 if %percent%==32 if not %temperrorlev%==0 goto error_patching
goto patching_fast_travel_100
:patching_fast_travel_33
if %custominstall_ios%==1 if %percent%==33 call IOSPatcher\Sharpii.exe WAD -u IOSPatcher\IOS80-old.wad IOSPatcher\IOS80/ >NUL
if %custominstall_ios%==1 if %percent%==33 set /a temperrorlev=%errorlevel%
if %custominstall_ios%==1 if %percent%==33 set modul=Sharpii.exe
if %custominstall_ios%==1 if %percent%==33 if not %temperrorlev%==0 goto error_patching
goto patching_fast_travel_100
:patching_fast_travel_34
if %custominstall_ios%==1 if %percent%==34 move /y IOSPatcher\IOS31\00000006.app IOSPatcher\00000006.app >NUL
if %custominstall_ios%==1 if %percent%==34 set /a temperrorlev=%errorlevel%
if %custominstall_ios%==1 if %percent%==34 set modul=move.exe
if %custominstall_ios%==1 if %percent%==34 if not %temperrorlev%==0 goto error_patching
goto patching_fast_travel_100
:patching_fast_travel_35
if %custominstall_ios%==1 if %percent%==35 call IOSPatcher\xdelta3.exe -f -d -s IOSPatcher\00000006.app IOSPatcher\00000006-31.delta IOSPatcher\IOS31\00000006.app >NUL
if %custominstall_ios%==1 if %percent%==35 set /a temperrorlev=%errorlevel%
if %custominstall_ios%==1 if %percent%==35 set modul=xdelta.exe
if %custominstall_ios%==1 if %percent%==35 if not %temperrorlev%==0 goto error_patching
goto patching_fast_travel_100
:patching_fast_travel_36
if %custominstall_ios%==1 if %percent%==36 move /y IOSPatcher\IOS80\00000006.app IOSPatcher\00000006.app >NUL
if %custominstall_ios%==1 if %percent%==36 set /a temperrorlev=%errorlevel%
if %custominstall_ios%==1 if %percent%==36 set modul=move.exe
if %custominstall_ios%==1 if %percent%==36 if not %temperrorlev%==0 goto error_patching
goto patching_fast_travel_100
:patching_fast_travel_37
if %custominstall_ios%==1 if %percent%==37 call IOSPatcher\xdelta3.exe -f -d -s IOSPatcher\00000006.app IOSPatcher\00000006-80.delta IOSPatcher\IOS80\00000006.app >NUL
if %custominstall_ios%==1 if %percent%==37 set /a temperrorlev=%errorlevel%
if %custominstall_ios%==1 if %percent%==37 set modul=xdelta3.exe
if %custominstall_ios%==1 if %percent%==37 if not %temperrorlev%==0 goto error_patching
goto patching_fast_travel_100
:patching_fast_travel_38
if %custominstall_ios%==1 if %percent%==38 if not exist IOSPatcher\WAD mkdir IOSPatcher\WAD
if %custominstall_ios%==1 if %percent%==38 set /a temperrorlev=%errorlevel%
if %custominstall_ios%==1 if %percent%==38 set modul=mkdir.exe
if %custominstall_ios%==1 if %percent%==38 if not %temperrorlev%==0 goto error_patching
goto patching_fast_travel_100
:patching_fast_travel_39
if %custominstall_ios%==1 if %percent%==39 call IOSPatcher\Sharpii.exe WAD -p IOSPatcher\IOS31\ IOSPatcher\WAD\IOS31.wad -fs >NUL
if %custominstall_ios%==1 if %percent%==39 set /a temperrorlev=%errorlevel%
if %custominstall_ios%==1 if %percent%==39 set modul=Sharpii.exe
if %custominstall_ios%==1 if %percent%==39 if not %temperrorlev%==0 goto error_patching
goto patching_fast_travel_100
:patching_fast_travel_40
if %custominstall_ios%==1 if %percent%==40 call IOSPatcher\Sharpii.exe WAD -p IOSPatcher\IOS80\ IOSPatcher\WAD\IOS80.wad -fs >NUL
if %custominstall_ios%==1 if %percent%==40 set /a temperrorlev=%errorlevel%
if %custominstall_ios%==1 if %percent%==40 set modul=Sharpii.exe
if %custominstall_ios%==1 if %percent%==40 if not %temperrorlev%==0 goto error_patching
goto patching_fast_travel_100
:patching_fast_travel_40
if %custominstall_ios%==1 if %percent%==40 del IOSPatcher\00000006.app /q >NUL
if %custominstall_ios%==1 if %percent%==40 set /a temperrorlev=%errorlevel%
if %custominstall_ios%==1 if %percent%==40 set modul=del.exe
if %custominstall_ios%==1 if %percent%==40 if not %temperrorlev%==0 goto error_patching
goto patching_fast_travel_100
:patching_fast_travel_41
if %custominstall_ios%==1 if %percent%==41 del IOSPatcher\IOS31-old.wad /q >NUL
if %custominstall_ios%==1 if %percent%==41 set /a temperrorlev=%errorlevel%
if %custominstall_ios%==1 if %percent%==41 set modul=del.exe
if %custominstall_ios%==1 if %percent%==41 if not %temperrorlev%==0 goto error_patching
goto patching_fast_travel_100
:patching_fast_travel_42
if %custominstall_ios%==1 if %percent%==42 del IOSPatcher\IOS80-old.wad /q >NUL
if %custominstall_ios%==1 if %percent%==42 set /a temperrorlev=%errorlevel%
if %custominstall_ios%==1 if %percent%==42 set modul=del.exe
if %custominstall_ios%==1 if %percent%==42 if not %temperrorlev%==0 goto error_patching
goto patching_fast_travel_100
:patching_fast_travel_43
if %custominstall_ios%==1 if %percent%==43 if exist IOSPatcher\IOS31 rmdir /s /q IOSPatcher\IOS31 >NUL
if %custominstall_ios%==1 if %percent%==43 set /a temperrorlev=%errorlevel%
if %custominstall_ios%==1 if %percent%==43 set modul=rmdir.exe
if %custominstall_ios%==1 if %percent%==43 if not %temperrorlev%==0 goto error_patching
goto patching_fast_travel_100
:patching_fast_travel_44
if %custominstall_ios%==1 if %percent%==44 if exist IOSPatcher\IOS80 rmdir /s /q IOSPatcher\IOS80 >NUL
if %custominstall_ios%==1 if %percent%==44 set /a temperrorlev=%errorlevel%
if %custominstall_ios%==1 if %percent%==44 set modul=rmdir.exe
if %custominstall_ios%==1 if %percent%==44 if not %temperrorlev%==0 goto error_patching
goto patching_fast_travel_100
:patching_fast_travel_45
if %custominstall_ios%==1 if %percent%==45 call IOSPatcher\Sharpii.exe IOS IOSPatcher\WAD\IOS31.wad -fs -es -np -vp>NUL
if %custominstall_ios%==1 if %percent%==45 set /a temperrorlev=%errorlevel%
if %custominstall_ios%==1 if %percent%==45 set modul=Sharpii.exe
if %custominstall_ios%==1 if %percent%==45 if not %temperrorlev%==0 goto error_patching
goto patching_fast_travel_100
:patching_fast_travel_46
if %custominstall_ios%==1 if %percent%==46 call IOSPatcher\Sharpii.exe IOS IOSPatcher\WAD\IOS80.wad -fs -es -np -vp>NUL
if %custominstall_ios%==1 if %percent%==46 set /a temperrorlev=%errorlevel%
if %custominstall_ios%==1 if %percent%==46 set modul=Sharpii.exe
if %custominstall_ios%==1 if %percent%==46 if not %temperrorlev%==0 goto error_patching
goto patching_fast_travel_100
:patching_fast_travel_47
if %custominstall_ios%==1 if %percent%==47 if not exist WAD md WAD
if %custominstall_ios%==1 if %percent%==47 move "IOSPatcher\WAD\IOS31.wad" "WAD"
if %custominstall_ios%==1 if %percent%==47 move "IOSPatcher\WAD\IOS80.wad" "WAD"
goto patching_fast_travel_100
:patching_fast_travel_48
if %custominstall_ios%==1 if %percent%==48 if exist IOSPatcher rmdir /s /q IOSPatcher
if %custominstall_ios%==1 if %percent%==48 set /a progress_ios=1
goto patching_fast_travel_100
::EVC Patcher
:patching_fast_travel_50
if %custominstall_evc%==1 if %percent%==50 if not exist 0001000148414A50v512 md 0001000148414A50v512
if %custominstall_evc%==1 if %percent%==50 if not exist 0001000148414A45v512 md 0001000148414A45v512
if %custominstall_evc%==1 if %percent%==50 if not exist 0001000148414A50v512\cetk copy /y "EVCPatcher\dwn\0001000148414A50v512\cetk" "0001000148414A50v512\cetk"

if %custominstall_evc%==1 if %percent%==50 if not exist 0001000148414A45v512\cetk copy /y "EVCPatcher\dwn\0001000148414A45v512\cetk" "0001000148414A45v512\cetk"

goto patching_fast_travel_100
::USA
:patching_fast_travel_52
if %custominstall_evc%==1 if %percent%==52 if %evcregion%==2 call EVCPatcher\dwn\sharpii.exe NUSD -ID 0001000148414A45 -v 512 -encrypt >NUL
::PAL
if %custominstall_evc%==1 if %percent%==52 if %evcregion%==1 call EVCPatcher\dwn\sharpii.exe NUSD -ID 0001000148414A50 -v 512 -encrypt >NUL
if %custominstall_evc%==1 if %percent%==52 set /a temperrorlev=%errorlevel%
if %custominstall_evc%==1 if %percent%==52 set modul=Downloading EVC
if %custominstall_evc%==1 if %percent%==52 if not %temperrorlev%==0 goto error_patching
goto patching_fast_travel_100
:patching_fast_travel_54
if %custominstall_evc%==1 if %percent%==54 if %evcregion%==1 copy /y "EVCPatcher\NUS_Downloader_Decrypt.exe" "0001000148414A50v512"
if %custominstall_evc%==1 if %percent%==54 if %evcregion%==2 copy /y "EVCPatcher\NUS_Downloader_Decrypt.exe" "0001000148414A45v512"
if %custominstall_evc%==1 if %percent%==54 set /a temperrorlev=%errorlevel%
if %custominstall_evc%==1 if %percent%==54 set modul=Copying NDC.exe
if %custominstall_evc%==1 if %percent%==54 if not %temperrorlev%==0 goto error_patching
goto patching_fast_travel_100
:patching_fast_travel_56
if %custominstall_evc%==1 if %percent%==56 if %evcregion%==1 ren "0001000148414A50v512\tmd.512" "tmd"
if %custominstall_evc%==1 if %percent%==56 if %evcregion%==2 ren "0001000148414A45v512\tmd.512" "tmd"
if %custominstall_evc%==1 if %percent%==56 set /a temperrorlev=%errorlevel%
if %custominstall_evc%==1 if %percent%==56 set modul=Renaming files [Delete everything except RiiConnect24Patcher.bat]
if %custominstall_evc%==1 if %percent%==56 if not %temperrorlev%==0 goto error_patching
goto patching_fast_travel_100
:patching_fast_travel_57
if %custominstall_evc%==1 if %percent%==57 if %evcregion%==1 cd 0001000148414A50v512
if %custominstall_evc%==1 if %percent%==57 if %evcregion%==1 call NUS_Downloader_Decrypt.exe >NUL
if %custominstall_evc%==1 if %percent%==57 if %evcregion%==2 cd 0001000148414A45v512
if %custominstall_evc%==1 if %percent%==57 if %evcregion%==2 call NUS_Downloader_Decrypt.exe >NUL
if %custominstall_evc%==1 if %percent%==57 set /a temperrorlev=%errorlevel%
if %custominstall_evc%==1 if %percent%==57 set modul=Decrypter error
if %custominstall_evc%==1 if %percent%==57 if not %temperrorlev%==0 cd..& goto error_patching
if %custominstall_evc%==1 if %percent%==57 cd..
goto patching_fast_travel_100
:patching_fast_travel_60
if %custominstall_evc%==1 if %percent%==60 if %evcregion%==1 move /y "0001000148414A50v512\HAJP.wad" "EVCPatcher\pack"
if %custominstall_evc%==1 if %percent%==60 if %evcregion%==2 move /y "0001000148414A45v512\HAJE.wad" "EVCPatcher\pack"
if %custominstall_evc%==1 if %percent%==60 set /a temperrorlev=%errorlevel%
if %custominstall_evc%==1 if %percent%==60 set modul=move.exe
if %custominstall_evc%==1 if %percent%==60 if not %temperrorlev%==0 goto error_patching
goto patching_fast_travel_100
:patching_fast_travel_62
if %custominstall_evc%==1 if %percent%==62 if %evcregion%==1 call EVCPatcher\pack\Sharpii.exe WAD -u EVCPatcher\pack\HAJP.wad EVCPatcher\pack\unencrypted >NUL
if %custominstall_evc%==1 if %percent%==62 if %evcregion%==2 call EVCPatcher\pack\Sharpii.exe WAD -u EVCPatcher\pack\HAJE.wad EVCPatcher\pack\unencrypted >NUL
goto patching_fast_travel_100
:patching_fast_travel_63
if %custominstall_evc%==1 if %percent%==63 move /y "EVCPatcher\pack\unencrypted\00000001.app" "00000001.app"
if %custominstall_evc%==1 if %percent%==63 set /a temperrorlev=%errorlevel%
if %custominstall_evc%==1 if %percent%==63 set modul=move.exe
if %custominstall_evc%==1 if %percent%==63 if not %temperrorlev%==0 goto error_patching
goto patching_fast_travel_100
:patching_fast_travel_65
if %custominstall_evc%==1 if %percent%==65 if %evcregion%==1 call EVCPatcher\patch\xdelta3.exe -f -d -s 00000001.app EVCPatcher\patch\Europe.delta EVCPatcher\pack\unencrypted\00000001.app
if %custominstall_evc%==1 if %percent%==65 if %evcregion%==2 call EVCPatcher\patch\xdelta3.exe -f -d -s 00000001.app EVCPatcher\patch\USA.delta EVCPatcher\pack\unencrypted\00000001.app
if %custominstall_evc%==1 if %percent%==65 set /a temperrorlev=%errorlevel%
if %custominstall_evc%==1 if %percent%==65 set modul=xdelta.exe EVC
if %custominstall_evc%==1 if %percent%==65 if not %temperrorlev%==0 goto error_patching
goto patching_fast_travel_100
:patching_fast_travel_67
if %custominstall_evc%==1 if %percent%==67 if %evcregion%==1 call EVCPatcher\pack\Sharpii.exe WAD -p "EVCPatcher\pack\unencrypted" "WAD\Everybody Votes Channel (Europe) (Channel) (RiiConnect24)" -f 
if %custominstall_evc%==1 if %percent%==67 if %evcregion%==2 call EVCPatcher\pack\Sharpii.exe WAD -p "EVCPatcher\pack\unencrypted" "WAD\Everybody Votes Channel (USA) (Channel) (RiiConnect24)" -f
if %custominstall_evc%==1 if %percent%==67 set /a temperrorlev=%errorlevel%
if %custominstall_evc%==1 if %percent%==67 set modul=Packing EVC WAD
if %custominstall_evc%==1 if %percent%==67 set /a progress_evc=1
if %custominstall_evc%==1 if %percent%==67 if not %temperrorlev%==0 goto error_patching
goto patching_fast_travel_100

::CMOC
:patching_fast_travel_68
if %custominstall_cmoc%==1 if %percent%==68 if not exist 0001000148415050v512 md 0001000148415050v512
if %custominstall_cmoc%==1 if %percent%==68 if not exist 0001000148415045v512 md 0001000148415045v512
if %custominstall_cmoc%==1 if %percent%==68 if not exist 0001000148415050v512\cetk copy /y "CMOCPatcher\dwn\0001000148415050v512\cetk" "0001000148415050v512\cetk"

if %custominstall_cmoc%==1 if %percent%==68 if not exist 0001000148415045v512\cetk copy /y "CMOCPatcher\dwn\0001000148415045v512\cetk" "0001000148415045v512\cetk"

goto patching_fast_travel_100
::USA
:patching_fast_travel_70
if %custominstall_cmoc%==1 if %percent%==70 if %evcregion%==2 call CMOCPatcher\dwn\sharpii.exe NUSD -ID 0001000148415045 -v 512 -encrypt >NUL
::PAL
if %custominstall_cmoc%==1 if %percent%==70 if %evcregion%==1 call CMOCPatcher\dwn\sharpii.exe NUSD -ID 0001000148415050 -v 512 -encrypt >NUL
if %custominstall_cmoc%==1 if %percent%==70 set /a temperrorlev=%errorlevel%
if %custominstall_cmoc%==1 if %percent%==70 set modul=Downloading CMOC
if %custominstall_cmoc%==1 if %percent%==70 if not %temperrorlev%==0 goto error_patching
goto patching_fast_travel_100
:patching_fast_travel_71
if %custominstall_cmoc%==1 if %percent%==71 if %evcregion%==1 copy /y "CMOCPatcher\NUS_Downloader_Decrypt.exe" "0001000148415050v512"
if %custominstall_cmoc%==1 if %percent%==71 if %evcregion%==2 copy /y "CMOCPatcher\NUS_Downloader_Decrypt.exe" "0001000148415045v512"
if %custominstall_cmoc%==1 if %percent%==71 set /a temperrorlev=%errorlevel%
if %custominstall_cmoc%==1 if %percent%==71 set modul=Copying NDC.exe
if %custominstall_cmoc%==1 if %percent%==71 if not %temperrorlev%==0 goto error_patching
goto patching_fast_travel_100
:patching_fast_travel_72
if %custominstall_cmoc%==1 if %percent%==72 if %evcregion%==1 ren "0001000148415050v512\tmd.512" "tmd"
if %custominstall_cmoc%==1 if %percent%==72 if %evcregion%==2 ren "0001000148415045v512\tmd.512" "tmd"
if %custominstall_cmoc%==1 if %percent%==72 set /a temperrorlev=%errorlevel%
if %custominstall_cmoc%==1 if %percent%==72 set modul=Renaming files [Delete everything except RiiConnect24Patcher.bat]
if %custominstall_cmoc%==1 if %percent%==72 if not %temperrorlev%==0 goto error_patching

if %custominstall_cmoc%==1 if %percent%==72 if %evcregion%==1 cd 0001000148415050v512
if %custominstall_cmoc%==1 if %percent%==72 if %evcregion%==1 call NUS_Downloader_Decrypt.exe >NUL
if %custominstall_cmoc%==1 if %percent%==72 if %evcregion%==2 cd 0001000148415045v512
if %custominstall_cmoc%==1 if %percent%==72 if %evcregion%==2 call NUS_Downloader_Decrypt.exe >NUL
if %custominstall_cmoc%==1 if %percent%==72 set /a temperrorlev=%errorlevel%
if %custominstall_cmoc%==1 if %percent%==72 set modul=Decrypter error
if %custominstall_cmoc%==1 if %percent%==72 if not %temperrorlev%==0 cd..& goto error_patching
if %custominstall_cmoc%==1 if %percent%==72 cd..
goto patching_fast_travel_100
:patching_fast_travel_74
if %custominstall_cmoc%==1 if %percent%==74 if %evcregion%==1 move /y "0001000148415050v512\HAPP.wad" "CMOCPatcher\pack"
if %custominstall_cmoc%==1 if %percent%==74 if %evcregion%==2 move /y "0001000148415045v512\HAPE.wad" "CMOCPatcher\pack"
if %custominstall_cmoc%==1 if %percent%==74 set /a temperrorlev=%errorlevel%
if %custominstall_cmoc%==1 if %percent%==74 set modul=move.exe
if %custominstall_cmoc%==1 if %percent%==74 if not %temperrorlev%==0 goto error_patching
goto patching_fast_travel_100
:patching_fast_travel_75
if %custominstall_cmoc%==1 if %percent%==75 if %evcregion%==1 call CMOCPatcher\pack\Sharpii.exe WAD -u CMOCPatcher\pack\HAPP.wad CMOCPatcher\pack\unencrypted >NUL
if %custominstall_cmoc%==1 if %percent%==75 if %evcregion%==2 call CMOCPatcher\pack\Sharpii.exe WAD -u CMOCPatcher\pack\HAPE.wad CMOCPatcher\pack\unencrypted >NUL
goto patching_fast_travel_100
:patching_fast_travel_76
if %custominstall_cmoc%==1 if %percent%==76 move /y "CMOCPatcher\pack\unencrypted\00000001.app" "00000001.app"
if %custominstall_cmoc%==1 if %percent%==76 move /y "CMOCPatcher\pack\unencrypted\00000004.app" "00000004.app"
if %custominstall_cmoc%==1 if %percent%==76 set /a temperrorlev=%errorlevel%
if %custominstall_cmoc%==1 if %percent%==76 set modul=move.exe
if %custominstall_cmoc%==1 if %percent%==76 if not %temperrorlev%==0 goto error_patching
goto patching_fast_travel_100
:patching_fast_travel_77
if %custominstall_cmoc%==1 if %percent%==77 if %evcregion%==1 call CMOCPatcher\patch\xdelta3.exe -f -d -s 00000001.app CMOCPatcher\patch\00000001_Europe.delta CMOCPatcher\pack\unencrypted\00000001.app
if %custominstall_cmoc%==1 if %percent%==77 if %evcregion%==1 call CMOCPatcher\patch\xdelta3.exe -f -d -s 00000004.app CMOCPatcher\patch\00000004_Europe.delta CMOCPatcher\pack\unencrypted\00000004.app
if %custominstall_cmoc%==1 if %percent%==77 if %evcregion%==2 call CMOCPatcher\patch\xdelta3.exe -f -d -s 00000001.app CMOCPatcher\patch\00000001_USA.delta CMOCPatcher\pack\unencrypted\00000001.app
if %custominstall_cmoc%==1 if %percent%==77 if %evcregion%==2 call CMOCPatcher\patch\xdelta3.exe -f -d -s 00000004.app CMOCPatcher\patch\00000004_USA.delta CMOCPatcher\pack\unencrypted\00000004.app
if %custominstall_cmoc%==1 if %percent%==77 set /a temperrorlev=%errorlevel%
if %custominstall_cmoc%==1 if %percent%==77 set modul=xdelta.exe CMOC
if %custominstall_cmoc%==1 if %percent%==77 if not %temperrorlev%==0 goto error_patching
goto patching_fast_travel_100
:patching_fast_travel_79
if %custominstall_cmoc%==1 if %percent%==79 if %evcregion%==1 call CMOCPatcher\pack\Sharpii.exe WAD -p "CMOCPatcher\pack\unencrypted" "WAD\Mii Contest Channel (Europe) (Channel) (RiiConnect24)" -f 
if %custominstall_cmoc%==1 if %percent%==79 if %evcregion%==2 call CMOCPatcher\pack\Sharpii.exe WAD -p "CMOCPatcher\pack\unencrypted" "WAD\Check Mii Out Channel (USA) (Channel) (RiiConnect24)" -f
if %custominstall_cmoc%==1 if %percent%==79 set /a temperrorlev=%errorlevel%
if %custominstall_cmoc%==1 if %percent%==79 set modul=Packing CMOC WAD
if %custominstall_cmoc%==1 if %percent%==79 set /a progress_cmoc=1
if %custominstall_cmoc%==1 if %percent%==79 if not %temperrorlev%==0 goto error_patching
goto patching_fast_travel_100










::NC

:patching_fast_travel_81
if %custominstall_nc%==1 if %percent%==81 if not exist 0001000148415450v1792 md 0001000148415450v1792
if %custominstall_nc%==1 if %percent%==81 if not exist 0001000148415445v1792 md 0001000148415445v1792
if %custominstall_nc%==1 if %percent%==81 if not exist 0001000148415450v1792\cetk copy /y "NCPatcher\dwn\0001000148415450v1792\cetk" "0001000148415450v1792\cetk"

if %custominstall_nc%==1 if %percent%==81 if not exist 0001000148415445v1792\cetk copy /y "NCPatcher\dwn\0001000148415445v1792\cetk" "0001000148415445v1792\cetk"

:patching_fast_travel_85
::USA
if %custominstall_nc%==1 if %percent%==85 if %evcregion%==2 call NCPatcher\dwn\sharpii.exe NUSD -ID 0001000148415445 -v 1792 -encrypt >NUL
::PAL
if %custominstall_nc%==1 if %percent%==85 if %evcregion%==1 call NCPatcher\dwn\sharpii.exe NUSD -ID 0001000148415450 -v 1792 -encrypt >NUL
if %custominstall_nc%==1 if %percent%==85 set /a temperrorlev=%errorlevel%
if %custominstall_nc%==1 if %percent%==85 set modul=Downloading NC
if %custominstall_nc%==1 if %percent%==85 if not %temperrorlev%==0 goto error_patching
goto patching_fast_travel_100
:patching_fast_travel_86
if %custominstall_nc%==1 if %percent%==86 if %evcregion%==1 copy /y "NCPatcher\NUS_Downloader_Decrypt.exe" "0001000148415450v1792"
if %custominstall_nc%==1 if %percent%==86 if %evcregion%==2 copy /y "NCPatcher\NUS_Downloader_Decrypt.exe" "0001000148415445v1792"
if %custominstall_nc%==1 if %percent%==86 set /a temperrorlev=%errorlevel%
if %custominstall_nc%==1 if %percent%==86 set modul=Copying NDC.exe
if %custominstall_nc%==1 if %percent%==86 if not %temperrorlev%==0 goto error_patching
goto patching_fast_travel_100
:patching_fast_travel_87
if %custominstall_nc%==1 if %percent%==87 if %evcregion%==1 ren "0001000148415450v1792\tmd.1792" "tmd"
if %custominstall_nc%==1 if %percent%==87 if %evcregion%==2 ren "0001000148415445v1792\tmd.1792" "tmd"
if %custominstall_nc%==1 if %percent%==87 set /a temperrorlev=%errorlevel%
if %custominstall_nc%==1 if %percent%==87 set modul=Renaming files
if %custominstall_nc%==1 if %percent%==87 if not %temperrorlev%==0 goto error_patching
goto patching_fast_travel_100
:patching_fast_travel_88
if %custominstall_nc%==1 if %percent%==88 if %evcregion%==1 cd 0001000148415450v1792
if %custominstall_nc%==1 if %percent%==88 if %evcregion%==1 call NUS_Downloader_Decrypt.exe >NUL
if %custominstall_nc%==1 if %percent%==88 if %evcregion%==2 cd 0001000148415445v1792
if %custominstall_nc%==1 if %percent%==88 if %evcregion%==2 call NUS_Downloader_Decrypt.exe >NUL
if %custominstall_nc%==1 if %percent%==88 set /a temperrorlev=%errorlevel%
if %custominstall_nc%==1 if %percent%==88 set modul=Decrypter error
if %custominstall_nc%==1 if %percent%==88 if not %temperrorlev%==0 cd..& goto error_patching
if %custominstall_nc%==1 if %percent%==88 cd..
goto patching_fast_travel_100
:patching_fast_travel_89
if %custominstall_nc%==1 if %percent%==89 if %evcregion%==1 move /y "0001000148415450v1792\HATP.wad" "NCPatcher\pack"
if %custominstall_nc%==1 if %percent%==89 if %evcregion%==2 move /y "0001000148415445v1792\HATE.wad" "NCPatcher\pack"
if %custominstall_nc%==1 if %percent%==89 set /a temperrorlev=%errorlevel%
if %custominstall_nc%==1 if %percent%==89 set modul=move.exe
if %custominstall_nc%==1 if %percent%==89 if not %temperrorlev%==0 goto error_patching
goto patching_fast_travel_100
:patching_fast_travel_90
if %custominstall_nc%==1 if %percent%==90 if %evcregion%==1 call NCPatcher\pack\Sharpii.exe WAD -u NCPatcher\pack\HATP.wad NCPatcher\pack\unencrypted >NUL
if %custominstall_nc%==1 if %percent%==90 if %evcregion%==2 call NCPatcher\pack\Sharpii.exe WAD -u NCPatcher\pack\HATE.wad NCPatcher\pack\unencrypted >NUL
goto patching_fast_travel_100
:patching_fast_travel_93
if %custominstall_nc%==1 if %percent%==93 move /y "NCPatcher\pack\unencrypted\00000001.app" "00000001_NC.app"
if %custominstall_nc%==1 if %percent%==93 set /a temperrorlev=%errorlevel%
if %custominstall_nc%==1 if %percent%==93 set modul=move.exe
if %custominstall_nc%==1 if %percent%==93 if not %temperrorlev%==0 goto error_patching
goto patching_fast_travel_100
:patching_fast_travel_94
if %custominstall_nc%==1 if %percent%==94 if %evcregion%==1 call NCPatcher\patch\xdelta3.exe -f -d -s 00000001_NC.app NCPatcher\patch\Europe.delta NCPatcher\pack\unencrypted\00000001.app
if %custominstall_nc%==1 if %percent%==94 if %evcregion%==2 call NCPatcher\patch\xdelta3.exe -f -d -s 00000001_NC.app NCPatcher\patch\USA.delta NCPatcher\pack\unencrypted\00000001.app
if %custominstall_nc%==1 if %percent%==94 set /a temperrorlev=%errorlevel%
if %custominstall_nc%==1 if %percent%==94 set modul=xdelta.exe NC
if %custominstall_nc%==1 if %percent%==94 if not %temperrorlev%==0 goto error_patching
goto patching_fast_travel_100
:patching_fast_travel_95
if %custominstall_nc%==1 if %percent%==95 if %evcregion%==1 call NCPatcher\pack\Sharpii.exe WAD -p "NCPatcher\pack\unencrypted" "WAD\Nintendo Channel (Europe) (Channel) (RiiConnect24)" -f 
if %custominstall_nc%==1 if %percent%==95 if %evcregion%==2 call NCPatcher\pack\Sharpii.exe WAD -p "NCPatcher\pack\unencrypted" "WAD\Nintendo Channel (USA) (Channel) (RiiConnect24)" -f
if %custominstall_nc%==1 if %percent%==95 set /a temperrorlev=%errorlevel%
if %custominstall_nc%==1 if %percent%==95 set modul=Packing NC WAD
if %custominstall_nc%==1 if %percent%==95 if not %temperrorlev%==0 goto error_patching
if %custominstall_nc%==1 if %percent%==95 set /a progress_nc=1
goto patching_fast_travel_100

::Final commands
:patching_fast_travel_98
if %percent%==98 if not %sdcard%==NUL set /a errorcopying=0
if %percent%==98 if not %sdcard%==NUL if not exist "%sdcard%:\WAD" md "%sdcard%:\WAD"
if %percent%==98 if not %sdcard%==NUL if not exist "%sdcard%:\apps" md "%sdcard%:\apps"
goto patching_fast_travel_100

:patching_fast_travel_99
if %percent%==99 echo.&echo Don't worry^^! It might take some time... Now copying files to your SD Card...
if %percent%==99 if not %sdcard%==NUL xcopy /y "WAD" "%sdcard%:\WAD" /e|| set /a errorcopying=1
if %percent%==99 if not %sdcard%==NUL xcopy /y "apps" "%sdcard%:\apps" /e|| set /a errorcopying=1

if %percent%==99 if exist 0001000148415045v512 rmdir /s /q 0001000148415045v512
if %percent%==99 if exist 0001000148415050v512 rmdir /s /q 0001000148415050v512

if %percent%==99 if exist 0001000148414A45v512 rmdir /s /q 0001000148414A45v512
if %percent%==99 if exist 0001000148414A50v512 rmdir /s /q 0001000148414A50v512
if %percent%==99 if exist 0001000148415450v1792 rmdir /s /q 0001000148415450v1792
if %percent%==99 if exist 0001000148415445v1792 rmdir /s /q 0001000148415445v1792 
if %percent%==99 if exist IOSPatcher rmdir /s /q IOSPatcher
if %percent%==99 if exist EVCPatcher rmdir /s /q EVCPatcher
if %percent%==99 if exist NCPatcher rmdir /s /q NCPatcher
if %percent%==99 if exist CMOCPatcher rmdir /s /q CMOCPatcher
if %percent%==99 del /q 00000001.app
if %percent%==99 del /q 00000004.app
if %percent%==99 del /q 00000001_NC.app
if %percent%==99 set /a progress_finishing=1
goto patching_fast_travel_100


:patching_fast_travel_100

if %percent%==100 goto 2_4
::ping localhost -n 1 >NUL

if /i %ss% GEQ 20 goto random_funfact
set /a percent=%percent%+1
goto 2_3
:2_4
cls
echo.
echo %header%
echo ---------------------------------------------------------------------------------------------------------------------------
echo Patching done^^!
echo.
if %sdcardstatus%==0 echo Please connect your Wii SD Card and copy apps and WAD folder to the root (main folder) of your SD Card. You can find these folders next to RiiConnect24Patcher.bat
if %sdcardstatus%==1 if %sdcard%==NUL echo Please connect your Wii SD Card and copy apps and WAD folder to the root (main folder) of your SD Card. You can find these folders next to RiiConnect24Patcher.bat

if %sdcardstatus%==1 if not %sdcard%==NUL if %errorcopying%==0 echo Every file is in it's place on your SD Card^^!
if %sdcardstatus%==1 if not %sdcard%==NUL if %errorcopying%==1 echo Unfortunately, I wasn't able to put some of the files on your SD Card. Please copy WAD and apps folder manually to the root (main folder) of your SD Card. You can find these folders next to RiiConnect24Patcher.bat.
echo.
echo Please proceed with the tutorial that you can find on https://wii.guide/riiconnect24
echo.
echo What to do next?
echo.
echo 1. Return to main menu
echo 2. Close the patcher
echo 3. Close the patcher and cleanup all temporary data created by the patcher.
set /p s=Choose: 
if %s%==1 goto script_start
if %s%==2 goto end
if %s%==3 rmdir /s /q "%MainFolder%"&goto end
goto 2_4
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
echo  [*] Thank you very much for using this patcher^^! :)
echo.
if %exitmessage%==1 echo Have fun using RiiConnect24^^!
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

:troubleshooting_auto_tool
if "%modul%"=="Renaming files [Delete everything except RiiConnect24Patcher.bat]" set tempgotonext=2_2&set /a troubleshoot_auto_tool_notification=1& goto troubleshooting_5
if "%modul%"=="Decrypter error" set tempgotonext=2_2&set /a troubleshoot_auto_tool_notification=1& goto troubleshooting_5
if "%modul%"=="move.exe" set tempgotonext=2_2&set /a troubleshoot_auto_tool_notification=1& goto troubleshooting_5
if "%percent%"=="1" set tempgotonext=2_2&set /a troubleshoot_auto_tool_notification=1& goto troubleshooting_5


set /a modul=0
goto error_patching


:no_internet_connection
cls
echo %header%                                                                
echo.                 
echo.                 
echo.                 
echo.                 
echo.                 
echo.                 
echo.                 
echo.                 
echo.                 
echo.                 
echo.                 
echo.
echo ---------------------------------------------------------------------------------------------------------------------------
echo    /---\   ERROR             
echo   /     \  There is no internet connection.
echo  /   ^^!   \ 
echo  --------- Could not connect to remote server. 
echo            Check your internet connection or check if your firewall isn't blocking curl.
echo.
echo       Press any key to return to main menu.
echo ---------------------------------------------------------------------------------------------------------------------------
pause>NUL
goto begin_main

:error_patching
if "%temperrorlev%"=="6" goto no_internet_connection
if "%temperrorlev%"=="7" goto no_internet_connection
if "%modul%"=="Renaming files [Delete everything except RiiConnect24Patcher.bat]" goto troubleshooting_auto_tool
if "%percent%"=="1" goto troubleshooting_auto_tool
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
echo  /   ^^!   \ Error Code: %temperrorlev%
echo  --------- Failing module: %modul% / %percent%
echo.
echo TIP: Consider turning off your antivirus temporarily.
if %temperrorlev%==-532459699 echo SOLUTION: Please check your internet connection.
if %temperrorlev%==23 echo ERROR DETAILS: Curl write error. Try moving the patcher to desktop and try again.
if %temperrorlev%==-2146232576 echo SOLUTION: Please install latest .NET Framework, then try again.  
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


:: The end - what did you expect? Join our Discord server! https://discord.gg/b4Y7jfD 
:: Find me as KcrPL#4625 ;)
