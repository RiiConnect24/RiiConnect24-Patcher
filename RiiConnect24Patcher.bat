@echo off
setlocal enableextensions
setlocal enableDelayedExpansion
cd /d "%~dp0"
echo 	Starting up...
echo	The program is starting...
:: ===========================================================================
:: RiiConnect24 Patcher for Windows
set version=1.2.5.3
:: AUTHORS: KcrPL
:: ***************************************************************************
:: Copyright (c) 2018-2020 KcrPL, RiiConnect24 and it's (Lead) Developers
:: ===========================================================================

if exist temp.bat del /q temp.bat
::if exist update_assistant.bat del /q update_assistant.bat
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

set user_name=%userprofile:~9%
set /a dolphin=0
set /a exitmessage=1
set /a errorcopying=0
set /a tempncpatcher=0
set /a tempiospatcher=0
set /a tempevcpatcher=0
set /a tempsdcardapps=0
set /a wiiu_return=0
set /a sdcardstatus=0
set /a troubleshoot_auto_tool_notification=0
set sdcard=NUL
set tempgotonext=begin_main
set direct_install_del_done=0
set direct_install_bulk_files_error=0

set mm=0
set ss=0
set cc=0
set hh=0

:: Window Title
if %beta%==0 title RiiConnect24 Patcher v%version% Created by @KcrPL
if %beta%==1 title RiiConnect24 Patcher v%version% [BETA] Created by @KcrPL
set last_build=2020/09/06
set at=23:52
:: ### Auto Update ###	
:: 1=Enable 0=Disable
:: Update_Activate - If disabled, patcher will not even check for updates, default=1
:: offlinestorage - Only used while testing of Update function, default=0
:: FilesHostedOn - The website and path to where the files are hosted. WARNING! DON'T END WITH "/"
:: MainFolder/TempStorage - folder that is used to keep version.txt and whatsnew.txt. These two files are deleted every startup but if offlinestorage will be set 1, they won't be deleted.
set /a Update_Activate=1
set /a offlinestorage=0 
if %beta%==0 set FilesHostedOn=https://kcrpl.github.io/Patchers_Auto_Update/RiiConnect24Patcher
if %beta%==1 set FilesHostedOn=https://kcrpl.github.io/Patchers_Auto_Update/RiiConnect24Patcher_Beta

:: Other patchers repositories
set FilesHostedOn_WiiWarePatcher=https://KcrPL.github.io/Patchers_Auto_Update/WiiWare-Patcher



set FilesHostedOn_Beta=https://kcrpl.github.io/Patchers_Auto_Update/RiiConnect24Patcher_Beta
set FilesHostedOn_Stable=https://kcrpl.github.io/Patchers_Auto_Update/RiiConnect24Patcher

set MainFolder=%appdata%\RiiConnect24Patcher
set TempStorage=%appdata%\RiiConnect24Patcher\internet\temp

if %beta%==0 set header=RiiConnect24 Patcher - (C) KcrPL v%version% (Compiled on %last_build% at %at%)
if %beta%==1 set header=RiiConnect24 Patcher - (C) KcrPL v%version% [BETA] (Compiled on %last_build% at %at%)

set header_for_loops=RiiConnect24 Patcher - KcrPL v%version% - Compiled on %last_build% at %at%

if not exist "%MainFolder%" md "%MainFolder%"
if not exist "%TempStorage%" md "%TempStorage%"

:: Trying to prevent running from OS that is not Windows.
if not "%os%"=="Windows_NT" goto not_windows_nt

:: Load background color from file if it exists
for /f "usebackq" %%a in ("%TempStorage%\background_color.txt") do color %%a





cls
:: Check for SD Card
echo.
echo .. Checking for SD Card
echo   :--------------------------------------------------------------------------------:
echo   : Can you see an error box? Press `Continue`.                                    :
echo   : There's nothing to worry about, everything is going ok. This error is normal.  :
echo   :--------------------------------------------------------------------------------:
echo.
echo Checking now...
call :detect_sd_card

goto begin_main

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
if not exist "%userprofile%\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\VFF-Downloader-for-Dolphin.exe" echo             smmmmm`+mMMMMMMMMMNhMNNMNNMMMMMMMMMMMMMMy   3. Settings
if exist "%userprofile%\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\VFF-Downloader-for-Dolphin.exe" echo             smmmmm`+mMMMMMMMMMNhMNNMNNMMMMMMMMMMMMMMy   3. Settings (manage VFF Downloader for Dolphin here)
echo             hmmmmh omMMMMMMMMMmhNMMMmNNNNMMMMMMMMMMM+   4. Troubleshooting
if exist "%appdata%\VFF-Downloader-for-Dolphin\VFF-Downloader-for-Dolphin.exe" echo             hmmmmh omMMMMMMMMMmhNMMMmNNNNMMMMMMMMMMM+   5. Run the VFF Downloader once.
if not exist "%appdata%\VFF-Downloader-for-Dolphin\VFF-Downloader-for-Dolphin.exe" echo             hmmmmh omMMMMMMMMMmhNMMMmNNNNMMMMMMMMMMM+
echo             mmmmms smMMMMMMMMMmddMMmmNmNMMMMMMMMMMMM:  
echo            `mmmmmo hNMMMMMMMMMmddNMMMNNMMMMMMMMMMMMM.  Do you have problems or want to contact us?  
echo            -mmmmm/ dNMMMMMMMMMNmddMMMNdhdMMMMMMMMMMN   Mail us at support@riiconnect24.net
echo            :mmmmm-`mNMMMMMMMMNNmmmNMMNmmmMMMMMMMMMMd   
if not %sdcard%==NUL echo            :mmmmm-`mNMMMMMMMMNNmmmNMMNmmmMMMMMMMMMMd   Detected Wii SD Card: %sdcard%:\
if %sdcard%==NUL echo            +mmmmN.-mNMMMMMMMMMNmmmmMMMMMMMMMMMMMMMMy     Could not detect your Wii SD Card.
echo            smmmmm`/mMMMMMMMMMNNmmmmNMMMMNMMNMMMMMNmy.    R. Refresh ^| If incorrect, you can change later.
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
if %s%==5 if exist "%appdata%\VFF-Downloader-for-Dolphin\VFF-Downloader-for-Dolphin.exe" start "" "%appdata%\VFF-Downloader-for-Dolphin\VFF-Downloader-for-Dolphin.exe" -run_once
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
call curl -f -L -s -S --insecure "%FilesHostedOn%/version.txt" --output "%TempStorage%\version.txt"
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
set /a vff_settings=0
if exist "%userprofile%\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\VFF-Downloader-for-Dolphin.exe" set /a vff_settings=1
if exist "%appdata%\VFF-Downloader-for-Dolphin\VFF-Downloader-for-Dolphin.exe" set /a vff_settings=1
::
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
if "%vff_settings%"=="1" echo -----------------------------------------------------------------------------------------------------------------------------
echo.
if "%vff_settings%"=="1" echo VFF Downloader for Dolphin Settings. 
if "%vff_settings%"=="1" echo.
if "%vff_settings%"=="1" echo 6. Completely delete VFF Downloader for Dolphin from your computer.
if "%vff_settings%"=="1" echo 7. Delete VFF Downloader from startup
if "%vff_settings%"=="1" echo 8. If VFF Downloader is running, shut it down.
if %vff_settings%==1 echo.
set /p s=Choose:
if %s%==1 goto begin_main
if %s%==2 goto change_color
if %s%==3 goto change_updating
if %s%==4 goto change_updating_branch
if %s%==5 goto update_files
if %s%==6 if %vff_settings%==1 goto settings_del_config_VFF
if %s%==7 if %vff_settings%==1 goto settings_del_vff_downloader
if %s%==8 if %vff_settings%==1 goto settings_taskkill_vff

goto settings_menu
:settings_del_config_VFF
::Stop the downloader
taskkill /im VFF-Downloader-for-Dolphin.exe /f
::Delete it's direcory
rmdir /s /q "%appdata%\VFF-Downloader-for-Dolphin"
::And delete it out of the autostart dir
del /q "%appdata%\Microsoft\Windows\Start Menu\Programs\Startup\VFF-Downloader-for-Dolphin.exe"
del /q "%appdata%\VFF-Downloader-for-Dolphin\VFF-Downloader-for-Dolphin.exe"
echo Done^^!
pause
goto settings_menu

:settings_del_vff_downloader
::Stop the downloader
taskkill /im VFF-Downloader-for-Dolphin.exe /f
::And delete it out of the autostart dir
del /q "%appdata%\Microsoft\Windows\Start Menu\Programs\Startup\VFF-Downloader-for-Dolphin.exe"

echo Done^^!
pause
goto settings_menu

:settings_taskkill_vff
::Stop the downloader
taskkill /im VFF-Downloader-for-Dolphin.exe /f

echo Done^^!
pause
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
	call curl -f -L -s -S --insecure "%FilesHostedOn_Stable%/UPDATE/version.txt" --output "%TempStorage%\version.txt"
	echo 1
	set /a temperrorlev=%errorlevel%
		if not %temperrorlev%==0 set /a stable_available_check=0&goto switch_to_stable
	if exist "%TempStorage%\version.txt" set /p updateversion_stable=<"%TempStorage%\version.txt"
	goto switch_to_stable	

:change_updating_branch_beta
set /a beta_available_check=0
	
	if exist "%TempStorage%\beta_available.txt" del "%TempStorage%\beta_available.txt" /q
	call curl -f -L -s -S --insecure "%FilesHostedOn_Beta%/UPDATE/beta_available.txt" --output "%TempStorage%\beta_available.txt"
		set /a temperrorlev=%errorlevel%
		if not %temperrorlev%==0 set /a beta_available_check=2&goto switch_to_beta
	if exist "%TempStorage%\beta_available.txt" set /p beta_available=<"%TempStorage%\beta_available.txt"
	
	if %beta_available%==0 set /a beta_available_check=0
	if %beta_available%==1 set /a beta_available_check=1
	
	if %beta_available_check%==0 goto switch_to_beta
	
	if exist "%TempStorage%\version.txt" del "%TempStorage%\version.txt" /q
	call curl -f -L -s -S --insecure "%FilesHostedOn_Beta%/UPDATE/version.txt" --output "%TempStorage%\version.txt"
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
	curl -f -L -s -S --insecure "%FilesHostedOn_Stable%/UPDATE/update_assistant.bat" --output "update_assistant.bat"
	start update_assistant.bat -RC24_Patcher
	exit
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

	curl -f -L -s -S --insecure "%FilesHostedOn_Stable%/UPDATE/update_assistant.bat" --output "update_assistant.bat"
	start update_assistant.bat -RC24_Patcher -beta
	exit
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
echo   Windows Patcher, WiiWare Patcher, UI, scripts.
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
echo - unowe
echo   Wii U patching help, providing instructions and all the files.
echo.
echo - DarkMatterCore
echo   wad2bin
echo.
echo - Wiimm, Leseratte
echo   Wiimmfi, Wiimmfi Patcher.
echo.
echo  For the entire RiiConnect24 Community.
echo  Want to contact us? Mail us at support@riiconnect24.net
echo.
echo  Press any button to go back to main menu.
echo ---------------------------------------------------------------------------------------------------------------------------
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
call powershell -command (new-object System.Net.WebClient).DownloadFile('%FilesHostedOn%/curl.exe', 'curl.exe')
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
echo  /   ^^!   \ 
echo  --------- We will now open a website that will download curl.exe.
echo            Please move curl.exe to the folder where RiiConnect24 Patcher is and restart the patcher.
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

if %Update_Activate%==1 if %offlinestorage%==0 call curl -f -L -s -S --insecure "%FilesHostedOn%/UPDATE/whatsnew.txt" --output "%TempStorage%\whatsnew.txt"
if %Update_Activate%==1 if %offlinestorage%==0 call curl -f -L -s -S --insecure "%FilesHostedOn%/UPDATE/version.txt" --output "%TempStorage%\version.txt"
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
curl -f -L -s -S --insecure "%FilesHostedOn%/UPDATE/annoucement.txt" --output %TempStorage%\annoucement.txt"

if %Update_Activate%==1 if %updateavailable%==1 set /a updateserver=2
if %Update_Activate%==1 if %updateavailable%==1 goto update_notice

goto select_device
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
if %s%==2 goto select_device
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
curl -f -L -s -S --insecure "%FilesHostedOn%/UPDATE/update_assistant.bat" --output "update_assistant.bat"
	set temperrorlev=%errorlevel%
	if not %temperrorlev%==0 goto error_updating
if %beta%==0 start update_assistant.bat -RC24_Patcher
if %beta%==1 start update_assistant.bat -RC24_Patcher -beta
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

:open_shop_sdcarddetect
cls
echo %header%
echo -----------------------------------------------------------------------------------------------------------------------------
echo.
echo Welcome to the Homebrew Shop.
echo Before downloading any homebrew, do you want to enable automatic installation on your SD Card?
echo.
echo 1. Yes, detect the SD Card.
echo 2. No, I'll install them manually.
echo.
set /p s=Choose: 
if %s%==1 set /a sdcardstatus=1& set tempgotonext=open_shop_summarysdcard& goto detect_sd_card
if %s%==2 set /a sdcardstatus=0& goto open_shop_getexecutable
goto open_shop_sdcarddetect
:open_shop_summarysdcard
cls
echo %header%
echo -----------------------------------------------------------------------------------------------------------------------------
echo.
if %sdcardstatus%==1 if %sdcard%==NUL echo Hmm... looks like an SD Card wasn't found in your system. Please choose the `Change drive letter` option
if %sdcardstatus%==1 if %sdcard%==NUL echo to set your SD Card drive letter manually.
if %sdcardstatus%==1 if %sdcard%==NUL echo.
if %sdcardstatus%==1 if %sdcard%==NUL echo Otherwise, you will have to copy the homebrew manually to the SD Card.
if %sdcardstatus%==1 if not %sdcard%==NUL echo Congrats^^! I've successfully detected your SD Card^^! Drive letter: %sdcard%
if %sdcardstatus%==1 if not %sdcard%==NUL echo I will be able to automatically download and install everything on your SD Card^^!	
echo.
echo What's next?
if %sdcardstatus%==1 if %sdcard%==NUL echo 1. Continue 2. Exit 3. Change drive letter
if %sdcardstatus%==1 if not %sdcard%==NUL echo 1. Continue 2. Exit 3. Change drive letter
echo.
set /p s=Choose: 
if %s%==1 goto open_shop_getexecutable
if %s%==2 goto begin_main
if %s%==3 goto open_shop_change_drive_letter
goto open_shop_summarysdcard
:open_shop_change_drive_letter
cls
echo %header%
echo -----------------------------------------------------------------------------------------------------------------------------
echo [*] SD Card
echo.
echo Current SD Card Letter: %sdcard%
echo.
echo Type in the new drive letter (e.g H)
set /p sdcard=
goto open_shop_summarysdcard
:open_shop_getexecutable
cls
if exist osc-dl.exe del /q osc-dl.exe
echo %header%
echo -----------------------------------------------------------------------------------------------------------------------------
echo.
echo Preparing for use with Open Shop Channel downloader...
echo Please wait...
echo.	
curl -f -L -s -S --insecure "%FilesHostedOn%/osc-dl.exe" --output "osc-dl.exe"
set /a temperrorlev=%errorlevel%
if not %temperrorlev%==0 goto open_shop_getexecutable_fail
goto open_shop_mainmenu
:open_shop_getexecutable_fail
cls
echo %header%
echo -----------------------------------------------------------------------------------------------------------------------------
echo.
echo There was an error while downloading the Open Shop Channel downloader.
echo CURL Exit Code: %temperrorlev%
echo.
echo Press any key to go back.
pause>NUL
goto begin_main
:open_shop_mainmenu
cls
set /a homebrew_online_var=0
echo %header%
echo -----------------------------------------------------------------------------------------------------------------------------
echo.
echo Welcome to the Homebrew Shop.
echo Open Shop Channel Downloader is ready^^! What next?
echo.
echo 1. Show list of homebrew available.
echo 2. Download homebrew.
echo.
echo R. Return to main menu
echo.
set /p s=Choose: 
if %s%==1 goto open_shop_list
if %s%==2 goto open_shop_homebrew
if %s%==r goto begin_main
if %s%==R goto begin_main
goto open_shop_mainmenu
:open_shop_list
cls
echo %header%
echo -----------------------------------------------------------------------------------------------------------------------------
echo.
echo One second please...
echo %header%>"Open Shop Channel Homebrew List.txt"
echo.>>"Open Shop Channel Homebrew List.txt"
echo TIP: Remember the name of the homebrew that you're interrested in, return to the program, select "Download homebrew" and type it in.>>"Open Shop Channel Homebrew List.txt"
echo      It will show you a description and some other useful info about homebrew that you've chosen.>>"Open Shop Channel Homebrew List.txt"
echo.>>"Open Shop Channel Homebrew List.txt"
echo List of homebrew available:>>"Open Shop Channel Homebrew List.txt"
echo.>>"Open Shop Channel Homebrew List.txt"
osc-dl.exe list>>"Open Shop Channel Homebrew List.txt"

start "" "Open Shop Channel Homebrew List.txt"
goto open_shop_mainmenu

:open_shop_homebrew
cls
echo %header%
echo -----------------------------------------------------------------------------------------------------------------------------
echo.
echo Type the name of your homebrew.
echo.
if %homebrew_online_var%==1 echo :-----------------------------------------------------------------------------------------------------------------------:
if %homebrew_online_var%==1 echo  "%homebrew_name%" is not available on the server.
if %homebrew_online_var%==1 echo  For the list of homebrew that's on the server, please go back and choose "Show list of homebrew available".
if %homebrew_online_var%==1 echo :-----------------------------------------------------------------------------------------------------------------------:
if %homebrew_online_var%==1 echo.
set /a homebrew_online_var=0
echo R. Go back.
echo.
set /p homebrew_name=Type here: 
if %homebrew_name%==r goto open_shop_mainmenu
if %homebrew_name%==R goto open_shop_mainmenu
goto open_shop_homebrew_download

:open_shop_homebrew_download
cls
echo %header%
echo -----------------------------------------------------------------------------------------------------------------------------
echo.
echo Fetching data...

::Check if on server
For /F "Delims=" %%A In ('osc-dl.exe query -n "%homebrew_name%" --verify') do set "homebrew_online=%%A"
if "%homebrew_online%"=="False" set /a homebrew_online_var=1&goto open_shop_homebrew

::For /F "Delims=" %%A In ('osc-dl.exe meta -n "%homebrew_name%" -t display_name') do set "homebrew_app_name=%%A"
::For /F "Delims=" %%A In ('osc-dl.exe meta -n "%homebrew_name%" -t version') do set "homebrew_version=%%A"
::For /F "Delims=" %%A In ('osc-dl.exe meta -n "%homebrew_name%" -t coder') do set "homebrew_creator=%%A"
::For /F "Delims=" %%A In ('osc-dl.exe meta -n "%homebrew_name%" -t short_description') do set "homebrew_short_description=%%A"

goto open_shop_homebrew_show_info
:open_shop_homebrew_show_info
cls
echo %header%
echo -----------------------------------------------------------------------------------------------------------------------------
echo You requested...
osc-dl.exe meta -n "%homebrew_name%" -t name
echo.
echo Long description:
echo.
osc-dl.exe meta -n "%homebrew_name%" -t long_description
echo -----------------------------------------------------------------------------------------------------------------------------
echo.
echo Would you like to download this app?
echo (If enabled, it will be automatically installed to the SD Card.)
echo.
echo 1. Yes.
echo 2. No, return.
set /p s=Choose: 
if %s%==1 goto open_shop_homebrew_download
if %s%==2 goto open_shop_mainmenu
goto open_shop_homebrew_show_info
:open_shop_homebrew_finishnosdcard
cls
echo %header%
echo -----------------------------------------------------------------------------------------------------------------------------
echo Downloading %homebrew_app_name%...
echo.
echo [OK] Downloading .ZIP
echo.
echo Done^^!
echo The .ZIP file is in the directory where RiiConnect24 Patcher is.
echo Press any key to go back.
pause>NUL
goto open_shop_mainmenu

:open_shop_homebrew_download
cls
echo %header%
echo -----------------------------------------------------------------------------------------------------------------------------
echo Downloading %homebrew_app_name%...
echo.
echo [..] Downloading .ZIP
osc-dl.exe get -n "%homebrew_name%" --noconfirm --output "%homebrew_name%.zip"
set /a temperrorlev=%errorlevel%
if not %temperrorlev%==0 set /a reason=1&goto open_shop_homebrew_download_error
if %sdcardstatus%==0 goto open_shop_homebrew_finishnosdcard
cls
echo %header%
echo -----------------------------------------------------------------------------------------------------------------------------
echo Downloading %homebrew_app_name%...
echo.
echo [OK] Downloading .ZIP
echo [..] Downloading 7zip CLI
curl -f -L -s -S --insecure "%FilesHostedOn%/7z.exe" --output "7z.exe"
set /a temperrorlev=%errorlevel%
if not %temperrorlev%==0 set /a reason=2&goto open_shop_homebrew_download_error
cls
echo %header%
echo -----------------------------------------------------------------------------------------------------------------------------
echo Downloading %homebrew_app_name%...
echo.
echo [OK] Downloading .ZIP
echo [OK] Downloading 7zip CLI
echo [..] Extracting the homebrew app to your SD Card...
7z x "%homebrew_name%.zip" -aoa -o%sdcard%:
set /a temperrorlev=%errorlevel%
if not %temperrorlev%==0 set /a reason=3&goto open_shop_homebrew_download_error
cls
echo %header%
echo -----------------------------------------------------------------------------------------------------------------------------
echo Downloading %homebrew_app_name%...
echo.
echo [OK] Downloading .ZIP
echo [OK] Downloading 7zip CLI
echo [OK] Extracting the homebrew app to your SD Card...
echo.
echo Done^^!
echo Press any key to go back.
del /q "%homebrew_name%.zip"
pause>NUL
goto open_shop_mainmenu
:open_shop_homebrew_download_error
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
echo   /     \  There was an error while downloading your homebrew.
echo  /   ^^!   \ 
echo  --------- 
echo.
if %reason%==1 echo There was an error while downloading the homebrew from Open Shop Channel servers.
if %reason%==2 echo There was an error while downloading 7zip.
if %reason%==3 echo There was an error while copying the files to your SD Card.
echo.
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
:select_device
cls
echo %header%
echo -----------------------------------------------------------------------------------------------------------------------------
if exist "%TempStorage%\annoucement.txt" echo --- Announcement --- 
if exist "%TempStorage%\annoucement.txt" type "%TempStorage%\annoucement.txt"
if exist "%TempStorage%\annoucement.txt" echo.
if exist "%TempStorage%\annoucement.txt" echo -------------------
echo.
echo Welcome to the RiiConnect24 Patcher^^!
echo With this program, you can patch your Wii or Wii U for use with RiiConnect24.
echo You can also use such tools as Wiimmfi Patcher for all Wii games to play them online again.
echo.
echo So, what device are we patching today?
echo.
echo 1. Wii
echo 2. Wii U (vWii, Wii Mode)
echo 3. Dolphin Emulator
echo.
set /p s=Choose wisely: 
if %s%==1 set device=1&goto 1
if %s%==2 set device=1_wiiu&goto 1_wiiu
if %s%==3 set device=1_dolphin&goto 1_dolphin
goto select_device

:1_dolphin
cls
echo %header%
echo -----------------------------------------------------------------------------------------------------------------------------
if exist "%TempStorage%\annoucement.txt" echo --- Announcement --- 
if exist "%TempStorage%\annoucement.txt" type "%TempStorage%\annoucement.txt"
if exist "%TempStorage%\annoucement.txt" echo.
if exist "%TempStorage%\annoucement.txt" echo --------------------
echo.
echo Which mode should I run?
echo 1. Install RiiConnect24 on your Dolphin Emulator
echo   - The patcher will guide you through process of installing RiiConnect24
echo.
echo --- Other tools ---
echo.
echo 2. Patch Wii WAD Games to work with Wiimmfi.
echo   - This will patch WAD Games (WiiWare) for use with Wiimmfi which will allow you to play online with other people.
echo.
echo 3. Patch Mario Kart Wii to work with Wiimmfi.
echo   - This will patch your copy of Mario Kart Wii to work with Wiimmfi which will enable online multiplayer to work again.
echo.
echo 4. Patch other Wii Games to work with Wiimmfi.
echo   - This will patch any other game than Mario Kart Wii to work with Wiimmfi. 
echo.	
echo 5. Visit Homebrew Shop
echo   - Download and install homebrew on your SD Card using Open Shop Channel.
set /p s=Choose: 
if %s%==1 goto 2_prepare_dolphin
if %s%==2 goto wadgames_patch_info
if %s%==3 goto mariokartwii_patch
if %s%==4 goto wiigames_patch
if %s%==5 goto open_shop_sdcarddetect
goto 1_dolphin
:2_prepare_dolphin
cls
echo %header%
echo -----------------------------------------------------------------------------------------------------------------------------
echo.
echo Hey %username%, welcome to RiiConnect24 installation process for Dolphin Emulator.
echo.
echo First, I need to download the VFF-Downloader. This will make Forecast and News Channel work.
echo.
echo Press any key to download and start the VFF Downloader for Dolphin.
pause>NUL
goto 2_download_vff

:2_download_vff
curl -f -L -s -S --insecure "https://kcrpl.github.io/Patchers_Auto_Update/VFF-Downloader-for-Dolphin/UPDATE/Install.bat" --output "Install.bat"

call Install.bat -RC24Patcher_assisted

if exist Install.bat del /q Install.bat
goto 2_after_vff
:2_after_vff
cls
echo %header%
echo -----------------------------------------------------------------------------------------------------------------------------
echo.
echo Alright! I see that you've exited VFF Downloader Installer.
echo.
echo If you installed it correctly and choose: 
echo - Manual - there will be an option in the main menu of RiiConnect24 Patcher to start it. Start it every time you want to 
echo   access Forecast and News Channel. There will be an option in the main menu to manage VFF Downloader.
echo.
echo - Startup - the program will run in background and will download the files automatically every hour.
echo   There will be an option in the main menu of RiiConnect24 Patcher to manage it.
echo.
echo What now?
echo 1. Continue with the installation process.
echo 2. Try installing VFF Downloader again.
echo 3. Exit
set /p s=Choose: 
if %s%==1 goto 2_install_dolphin_1
if %s%==2 goto 2_prepare_dolphin
if %s%==3 goto begin_main
goto 2_after_vff
:2_install_dolphin_1
cls
echo %header%
echo -----------------------------------------------------------------------------------------------------------------------------
echo.
echo We will now need to run the patcher to get Check Mii Out Channel and Everybody Votes Channel.
echo.
echo What region should I download?
echo.
echo 1. Europe
echo 2. USA
set /p evcregion=Choose: 
if "%evcregion%"=="1" goto 2_install_dolphin_2
if "%evcregion%"=="2" goto 2_install_dolphin_2

goto 2_install_dolphin_1
:2_install_dolphin_2
set /a custominstall_ios=0
set /a custominstall_evc=1
set /a custominstall_nc=0
set /a custominstall_cmoc=1
set /a custominstall_news_fore=0
set /a sdcardstatus=0
set /a errorcopying=0
set sdcard=NUL

set /a dolphin=1
goto 2_2

:2_install_dolphin_3
cls
echo %header%
echo -----------------------------------------------------------------------------------------------------------------------------
echo.
echo We're done^^! Now please open Dolphin, press on Tools and install the WAD file that has been downloaded to the WAD folder 
echo next to the RiiConnect24 Patcher.
echo.
echo That's it^^!
echo What to do next?
echo.
echo 1. Return to main menu
echo 2. Close the patcher
set /p s=Choose: 
if %s%==1 goto script_start
if %s%==2 goto end
goto 2_install_dolphin_3
:1_wiiu
cls
echo %header%
echo -----------------------------------------------------------------------------------------------------------------------------
if exist "%TempStorage%\annoucement.txt" echo --- Announcement --- 
if exist "%TempStorage%\annoucement.txt" type "%TempStorage%\annoucement.txt"
if exist "%TempStorage%\annoucement.txt" echo.
if exist "%TempStorage%\annoucement.txt" echo -------------------
echo.
echo Which mode should I run?
echo 1. Install RiiConnect24 on your Wii U
echo   - The patcher will guide you through process of installing RiiConnect24
echo.
echo --- Other tools ---
echo.
echo 2. Install WAD files directly to the SD Card.
echo   - This will allow you to directly install a channel to your SD Card instead of you having to move it from NAND.
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
echo 6. Visit Homebrew Shop
echo   - Download and install homebrew on your SD Card using Open Shop Channel.
set /p s=Choose: 
if %s%==1 goto 2_prepare_wiiu
if %s%==2 goto direct_install_download_binary
if %s%==3 goto wadgames_patch_info
if %s%==4 goto mariokartwii_patch
if %s%==5 goto wiigames_patch
if %s%==6 goto open_shop_sdcarddetect
goto 1_wiiu
:2_prepare_wiiu
cls
echo %header%
echo -----------------------------------------------------------------------------------------------------------------------------
echo.
echo Install RiiConnect24 on your Wii U.
echo.
echo Choose instalation type:
echo 1. Express (Recommended)
echo   - This will patch every channel for later use on your Wii U. This includes:
echo     - News Channel
echo     - Everybody Votes Channel
echo     - Nintendo Channel
echo     - Check Mii Out Channel / Mii Contest Channel
echo.
echo 2. Custom
echo   - You will be asked what you want to patch.
set /p s=
if %s%==1 goto 2_auto_wiiu
if %s%==2 goto 2_choose_custom_instal_type_wiiu
goto 2_prepare_wiiu
:2_choose_custom_instal_type_wiiu
set /a evcregion=1
set /a custominstall_news=1
set /a custominstall_evc=1
set /a custominstall_nc=1
set /a custominstall_cmoc=1
set /a sdcardstatus=0
set /a errorcopying=0
set sdcard=NUL
goto 2_choose_custom_install_type2_wiiu
:2_choose_custom_install_type2_wiiu
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
if %custominstall_news%==1 echo 2. [X] News Channel
if %custominstall_news%==0 echo 2. [ ] News Channel
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
if %s%==1 goto 2_switch_region_wiiu
if %s%==2 goto 2_switch_news_wiiu
if %s%==3 goto 2_switch_evc_wiiu
if %s%==4 goto 2_switch_nc_wiiu
if %s%==5 goto 2_switch_cmoc_wiiu
if %s%==6 goto 2_2_wiiu
if %s%==r goto begin_main
if %s%==R goto begin_main
goto 2_choose_custom_install_type2_wiiu
:2_switch_news_wiiu
if %custominstall_news%==1 set /a custominstall_news=0&goto 2_choose_custom_install_type2_wiiu
if %custominstall_news%==0 set /a custominstall_news=1&goto 2_choose_custom_install_type2_wiiu
:2_switch_region_wiiu
if %evcregion%==1 set /a evcregion=2&goto 2_choose_custom_install_type2_wiiu
if %evcregion%==2 set /a evcregion=1&goto 2_choose_custom_install_type2_wiiu
:2_switch_evc_wiiu
if %custominstall_evc%==1 set /a custominstall_evc=0&goto 2_choose_custom_install_type2_wiiu
if %custominstall_evc%==0 set /a custominstall_evc=1&goto 2_choose_custom_install_type2_wiiu
:2_switch_nc_wiiu
if %custominstall_nc%==1 set /a custominstall_nc=0&goto 2_choose_custom_install_type2_wiiu
if %custominstall_nc%==0 set /a custominstall_nc=1&goto 2_choose_custom_install_type2_wiiu
:2_switch_cmoc_wiiu
if %custominstall_cmoc%==1 set /a custominstall_cmoc=0&goto 2_choose_custom_install_type2_wiiu
if %custominstall_cmoc%==0 set /a custominstall_cmoc=1&goto 2_choose_custom_install_type2_wiiu


:2_auto_wiiu
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
echo For News Channel, Everybody Votes Channel, Check Mii Out Channel / Mii Contest Channel and Nintendo Channel, which region should I download and patch? 
echo (Where do you live?/Region of your console)
echo.
echo 1. Europe
echo 2. USA
set /p s=Choose one: 
if %s%==1 set /a evcregion=1& goto 2_1_wiiu
if %s%==2 set /a evcregion=2& goto 2_1_wiiu
goto 2_auto
:2_1_wiiu
set /a custominstall_evc=1
set /a custominstall_nc=1
set /a custominstall_cmoc=1	
set /a custominstall_news=1
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
echo Please connect your Wii U SD Card to the computer.
echo.
echo 1. Connected^^!
echo 2. I can't connect an SD Card to the computer.
set /p s=
set sdcard=NUL
if %s%==1 set /a sdcardstatus=1& set tempgotonext=2_1_summary_wiiu& goto detect_sd_card
if %s%==2 set /a sdcardstatus=0& set /a sdcard=NUL& goto 2_1_summary_wiiu
goto 2_1_wiiu
:2_1_summary_wiiu
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
echo Everything is ready^^!
echo.
echo What's next?
if %sdcardstatus%==0 echo 1. Start Patching  2. Exit
if %sdcardstatus%==1 if %sdcard%==NUL echo 1. Start Patching 2. Exit 3. Change drive letter
if %sdcardstatus%==1 if not %sdcard%==NUL echo 1. Start Patching 2. Exit 3. Change drive letter

set /p s=Choose: 
if %s%==1 goto check_for_wad_folder
if %s%==2 goto begin_main
if %s%==3 goto 2_change_drive_letter_wiiu
goto 2_1_summary_wiiu
:check_for_wad_folder
if not exist "WAD" goto 2_2_wiiu
cls
echo %header%
echo -----------------------------------------------------------------------------------------------------------------------------
echo.
echo One more thing^^! I've detected WAD folder.
echo I need to delete it.
echo.
echo Can I?
echo 1. Yes
echo 2. No
set /p s=Choose: 
if %s%==1 rmdir /s /q "WAD"
if %s%==1 goto 2_2_wiiu
if %s%==2 goto 2_1_summary_wiiu
goto check_for_wad_folder

:2_2_wiiu
cls
set /a troubleshoot_auto_tool_notification=0
set /a temperrorlev=0
set /a counter_done=0
set /a percent=0
set /a temperrorlev=0

::
set /a progress_downloading=0
set /a progress_news=0
set /a progress_ios=0
set /a progress_evc=0
set /a progress_nc=0
set /a progress_cmoc=0
set /a progress_finishing=0
set /a wiiu_return=1

goto random_funfact

:2_3_wiiu
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
if %custominstall_news%==1 if %progress_news%==0 echo [ ] News Channel
if %custominstall_news%==1 if %progress_news%==1 echo [X] News Channel
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

call :wiiu_patching_fast_travel_%percent%
goto wiiu_patching_fast_travel_100



::Download files
:wiiu_patching_fast_travel_1
if exist NewsChannelPatcher rmdir /s /q NewsChannelPatcher
if exist unpacked-temp rmdir /s /q unpacked-temp
if %percent%==1 if exist 0001000148415045v512 rmdir /s /q 0001000148415045v512
if %percent%==1 if exist 0001000148415050v512 rmdir /s /q 0001000148415050v512
if %percent%==1 if exist 0001000148414A45v512 rmdir /s /q 0001000148414A45v512
if %percent%==1 if exist 0001000148414A50v512 rmdir /s /q 0001000148414A50v512
if %percent%==1 if exist 0001000148415450v1792 rmdir /s /q 0001000148415450v1792
if %percent%==1 if exist 0001000148415445v1792 rmdir /s /q 0001000148415445v1792 
if %percent%==1 if exist IOSPatcher rmdir /s /q IOSPatcher
if %percent%==1 if exist EVCPatcher rmdir /s /q EVCPatcher
if %percent%==1 if exist NCPatcher rmdir /s /q NCPatcher
if %percent%==1 if exist CMOCPatcher rmdir /s /q CMOCPatcher
if %percent%==1 if exist "apps/ftpiuu-cbhc" rmdir /s /q "apps/ftpiuu-cbhc"
if %percent%==1 if exist "apps/WiiModLite" rmdir /s /q "apps/WiiModLite"
if %percent%==1 if exist "apps/WiiXplorer" rmdir /s /q "apps/WiiXplorer"
if %percent%==1 if exist "apps/Mail-Patcher" rmdir /s /q "apps/Mail-Patcher"
if %percent%==1 if exist "apps/ww-43db-patcher" rmdir /s /q "apps/ww-43db-patcher"



if %percent%==1 del /q 0001000248414745v7.wad
if %percent%==1 del /q 0001000248414750v7.wad
if %percent%==1 del /q 00000001.app
if %percent%==1 del /q source.app
if %percent%==1 del /q 00000004.app
if %percent%==1 del /q 00000001_NC.app


if %percent%==1 if not exist "WAD" md WAD
::EVC
:wiiu_patching_fast_travel_4
if %percent%==4 if not exist EVCPatcher/patch md EVCPatcher\patch
if %percent%==4 if not exist EVCPatcher/dwn md EVCPatcher\dwn
if %percent%==4 if not exist EVCPatcher/dwn/0001000148414A45v512 md EVCPatcher\dwn\0001000148414A45v512
if %percent%==4 if not exist EVCPatcher/dwn/0001000148414A50v512 md EVCPatcher\dwn\0001000148414A50v512
if %percent%==4 if not exist EVCPatcher/pack md EVCPatcher\pack
if %percent%==4 if not exist "EVCPatcher/patch/Europe.delta" curl -f -L -s -S --insecure "%FilesHostedOn%/EVCPatcher/patch/Europe.delta" --output EVCPatcher/patch/Europe.delta
if %percent%==4 set /a temperrorlev=%errorlevel%	
if %percent%==4 set modul=Downloading Europe Delta
if %percent%==4 if not %temperrorlev%==0 goto error_patching
if %percent%==4 if not exist "EVCPatcher/patch/USA.delta" curl -f -L -s -S --insecure "%FilesHostedOn%/EVCPatcher/patch/USA.delta" --output EVCPatcher/patch/USA.delta
if %percent%==4 set /a temperrorlev=%errorlevel%
if %percent%==4 set modul=Downloading USA Delta
if %percent%==4 if not %temperrorlev%==0 goto error_patching
goto wiiu_patching_fast_travel_100
:wiiu_patching_fast_travel_7
if %percent%==7 if not exist "EVCPatcher/NUS_Downloader_Decrypt.exe" curl -f -L -s -S --insecure "%FilesHostedOn%/EVCPatcher/NUS_Downloader_Decrypt.exe" --output EVCPatcher/NUS_Downloader_Decrypt.exe
if %percent%==7 set /a temperrorlev=%errorlevel%
if %percent%==7 set modul=Downloading decrypter
if %percent%==7 if not %temperrorlev%==0 goto error_patching
goto wiiu_patching_fast_travel_100

:wiiu_patching_fast_travel_8
if %percent%==8 if not exist "EVCPatcher/patch/xdelta3.exe" curl -f -L -s -S --insecure "%FilesHostedOn%/EVCPatcher/patch/xdelta3.exe" --output EVCPatcher/patch/xdelta3.exe
if %percent%==8 set /a temperrorlev=%errorlevel%
if %percent%==8 set modul=Downloading xdelta3.exe
if %percent%==8 if not %temperrorlev%==0 goto error_patching

if %percent%==8 if not exist "EVCPatcher/pack/libWiiSharp.dll" curl -f -L -s -S --insecure "%FilesHostedOn%/EVCPatcher/pack/libWiiSharp.dll" --output "EVCPatcher/pack/libWiiSharp.dll"
if %percent%==8 set /a temperrorlev=%errorlevel%
if %percent%==8 set modul=Downloading libWiiSharp.dll
if %percent%==8 if not %temperrorlev%==0 goto error_patching

if %percent%==8 if not exist "EVCPatcher/pack/Sharpii.exe" curl -f -L -s -S --insecure "%FilesHostedOn%/EVCPatcher/pack/Sharpii.exe" --output EVCPatcher/pack/Sharpii.exe
if %percent%==8 set /a temperrorlev=%errorlevel%
if %percent%==8 set modul=Downloading Sharpii.exe
if %percent%==8 if not %temperrorlev%==0 goto error_patching
if %percent%==8 if not exist "EVCPatcher/dwn/Sharpii.exe" curl -f -L -s -S --insecure "%FilesHostedOn%/EVCPatcher/dwn/Sharpii.exe" --output EVCPatcher/dwn/Sharpii.exe
if %percent%==8 set /a temperrorlev=%errorlevel%
if %percent%==8 set modul=Downloading Sharpii.exe
if %percent%==8 if not %temperrorlev%==0 goto error_patching
goto wiiu_patching_fast_travel_100
:wiiu_patching_fast_travel_9
if %percent%==9 if not exist "EVCPatcher/dwn/libWiiSharp.dll" curl -f -L -s -S --insecure "%FilesHostedOn%/EVCPatcher/dwn/libWiiSharp.dll" --output EVCPatcher/dwn/libWiiSharp.dll
if %percent%==9 set /a temperrorlev=%errorlevel%
if %percent%==9 set modul=Downloading libWiiSharp.dll
if %percent%==9 if not %temperrorlev%==0 goto error_patching
goto wiiu_patching_fast_travel_100
:wiiu_patching_fast_travel_10
if %percent%==10 if not exist "EVCPatcher/dwn/0001000148414A45v512/cetk" curl -f -L -s -S --insecure "%FilesHostedOn%/EVCPatcher/dwn/0001000148414A45v512/cetk" --output EVCPatcher/dwn/0001000148414A45v512/cetk
if %percent%==10 set /a temperrorlev=%errorlevel%
if %percent%==10 set modul=Downloading USA CETK
if %percent%==10 if not %temperrorlev%==0 goto error_patching

if %percent%==10 if not exist "EVCPatcher/dwn/0001000148414A50v512/cetk" curl -f -L -s -S --insecure "%FilesHostedOn%/EVCPatcher/dwn/0001000148414A50v512/cetk" --output EVCPatcher/dwn/0001000148414A50v512/cetk
if %percent%==10 set /a temperrorlev=%errorlevel%
if %percent%==10 set modul=Downloading EUR CETK
if %percent%==10 if not %temperrorlev%==0 goto error_patching
goto wiiu_patching_fast_travel_100

::CMOC
:wiiu_patching_fast_travel_11
if %percent%==11 if not exist CMOCPatcher/patch md CMOCPatcher\patch
if %percent%==11 if not exist CMOCPatcher/dwn md CMOCPatcher\dwn
if %percent%==11 if not exist CMOCPatcher/dwn/0001000148415045v512 md CMOCPatcher\dwn\0001000148415045v512
if %percent%==11 if not exist CMOCPatcher/dwn/0001000148415050v512 md CMOCPatcher\dwn\0001000148415050v512
if %percent%==11 if not exist CMOCPatcher/pack md CMOCPatcher\pack
if %percent%==11 if not exist "CMOCPatcher/patch/00000001_Europe.delta" curl -f -L -s -S --insecure "%FilesHostedOn%/CMOCPatcher/patch/00000001_Europe.delta" --output CMOCPatcher/patch/00000001_Europe.delta
if %percent%==11 if not exist "CMOCPatcher/patch/00000004_Europe.delta" curl -f -L -s -S --insecure "%FilesHostedOn%/CMOCPatcher/patch/00000004_Europe.delta" --output CMOCPatcher/patch/00000004_Europe.delta
if %percent%==11 set /a temperrorlev=%errorlevel%
if %percent%==11 set modul=Downloading Europe Delta
if %percent%==11 if not %temperrorlev%==0 goto error_patching
goto wiiu_patching_fast_travel_100
:wiiu_patching_fast_travel_12
if %percent%==12 if not exist "CMOCPatcher/patch/00000001_USA.delta" curl -f -L -s -S --insecure "%FilesHostedOn%/CMOCPatcher/patch/00000001_USA.delta" --output CMOCPatcher/patch/00000001_USA.delta
if %percent%==12 if not exist "CMOCPatcher/patch/00000004_USA.delta" curl -f -L -s -S --insecure "%FilesHostedOn%/CMOCPatcher/patch/00000004_USA.delta" --output CMOCPatcher/patch/00000004_USA.delta
if %percent%==12 set /a temperrorlev=%errorlevel%
if %percent%==12 set modul=Downloading USA Delta
if %percent%==12 if not %temperrorlev%==0 goto error_patching
if %percent%==12 if not exist "CMOCPatcher/NUS_Downloader_Decrypt.exe" curl -f -L -s -S --insecure "%FilesHostedOn%/CMOCPatcher/NUS_Downloader_Decrypt.exe" --output CMOCPatcher/NUS_Downloader_Decrypt.exe
if %percent%==12 set /a temperrorlev=%errorlevel%
if %percent%==12 set modul=Downloading decrypter
if %percent%==12 if not %temperrorlev%==0 goto error_patching
goto wiiu_patching_fast_travel_100
:wiiu_patching_fast_travel_13
if %percent%==13 if not exist "CMOCPatcher/patch/xdelta3.exe" curl -f -L -s -S --insecure "%FilesHostedOn%/CMOCPatcher/patch/xdelta3.exe" --output CMOCPatcher/patch/xdelta3.exe
if %percent%==13 set /a temperrorlev=%errorlevel%
if %percent%==13 set modul=Downloading xdelta3.exe
if %percent%==13 if not %temperrorlev%==0 goto error_patching
goto wiiu_patching_fast_travel_100
:wiiu_patching_fast_travel_14
if %percent%==14 if not exist "CMOCPatcher/pack/libWiiSharp.dll" curl -f -L -s -S --insecure "%FilesHostedOn%/CMOCPatcher/pack/libWiiSharp.dll" --output "CMOCPatcher/pack/libWiiSharp.dll"
if %percent%==14 set /a temperrorlev=%errorlevel%
if %percent%==14 set modul=Downloading libWiiSharp.dll
if %percent%==14 if not %temperrorlev%==0 goto error_patching
goto wiiu_patching_fast_travel_100
:wiiu_patching_fast_travel_15
if %percent%==15 if not exist "CMOCPatcher/pack/Sharpii.exe" curl -f -L -s -S --insecure "%FilesHostedOn%/CMOCPatcher/pack/Sharpii.exe" --output CMOCPatcher/pack/Sharpii.exe
if %percent%==15 set /a temperrorlev=%errorlevel%
if %percent%==15 set modul=Downloading Sharpii.exe
if %percent%==15 if not %temperrorlev%==0 goto error_patching
goto wiiu_patching_fast_travel_100
:wiiu_patching_fast_travel_16
if %percent%==16 if not exist "CMOCPatcher/dwn/Sharpii.exe" curl -f -L -s -S --insecure "%FilesHostedOn%/CMOCPatcher/dwn/Sharpii.exe" --output CMOCPatcher/dwn/Sharpii.exe
if %percent%==16 set /a temperrorlev=%errorlevel%
if %percent%==16 set modul=Downloading Sharpii.exe
if %percent%==16 if not %temperrorlev%==0 goto error_patching
goto wiiu_patching_fast_travel_100
:wiiu_patching_fast_travel_17
if %percent%==17 if not exist "CMOCPatcher/dwn/libWiiSharp.dll" curl -f -L -s -S --insecure "%FilesHostedOn%/CMOCPatcher/dwn/libWiiSharp.dll" --output CMOCPatcher/dwn/libWiiSharp.dll
if %percent%==17 set /a temperrorlev=%errorlevel%
if %percent%==17 set modul=Downloading libWiiSharp.dll
if %percent%==17 if not %temperrorlev%==0 goto error_patching
goto wiiu_patching_fast_travel_100
:wiiu_patching_fast_travel_18
if %percent%==18 if not exist "CMOCPatcher/dwn/0001000148415045v512/cetk" curl -f -L -s -S --insecure "%FilesHostedOn%/CMOCPatcher/dwn/0001000148415045v512/cetk" --output CMOCPatcher/dwn/0001000148415045v512/cetk
if %percent%==18 if not exist "CMOCPatcher/dwn/0001000148415045v512/cert" curl -f -L -s -S --insecure "%FilesHostedOn%/CMOCPatcher/dwn/0001000148415045v512/cert" --output CMOCPatcher/dwn/0001000148415045v512/cert
if %percent%==18 set /a temperrorlev=%errorlevel%
if %percent%==18 set modul=Downloading USA CETK
if %percent%==18 if not %temperrorlev%==0 goto error_patching
goto wiiu_patching_fast_travel_100
:wiiu_patching_fast_travel_19
if %percent%==19 if not exist "CMOCPatcher/dwn/0001000148415050v512/cetk" curl -f -L -s -S --insecure "%FilesHostedOn%/CMOCPatcher/dwn/0001000148415050v512/cetk" --output CMOCPatcher/dwn/0001000148415050v512/cetk
if %percent%==19 if not exist "CMOCPatcher/dwn/0001000148415050v512/cert" curl -f -L -s -S --insecure "%FilesHostedOn%/CMOCPatcher/dwn/0001000148415050v512/cert" --output CMOCPatcher/dwn/0001000148415050v512/cert
if %percent%==19 set /a temperrorlev=%errorlevel%
if %percent%==19 set modul=Downloading EUR CETK
if %percent%==19 if not %temperrorlev%==0 goto error_patching
goto wiiu_patching_fast_travel_100


::NC
:wiiu_patching_fast_travel_20
if %percent%==20 if not exist NCPatcher/patch md NCPatcher\patch
if %percent%==20 if not exist NCPatcher/dwn md NCPatcher\dwn
if %percent%==20 if not exist NCPatcher/dwn/0001000148415450v1792 md NCPatcher\dwn\0001000148415450v1792
if %percent%==20 if not exist NCPatcher/dwn/0001000148415445v1792 md NCPatcher\dwn\0001000148415445v1792
if %percent%==20 if not exist NCPatcher/pack md NCPatcher\pack
if %percent%==20 if not exist "NCPatcher/patch/Europe.delta" curl -f -L -s -S --insecure "%FilesHostedOn%/NCPatcher/patch/Europe.delta" --output NCPatcher/patch/Europe.delta
if %percent%==20 set /a temperrorlev=%errorlevel%
if %percent%==20 set modul=Downloading Europe Delta [NC]
if %percent%==20 if not %temperrorlev%==0 goto error_patching

if %percent%==20 if not exist "NCPatcher/patch/USA.delta" curl -f -L -s -S --insecure "%FilesHostedOn%/NCPatcher/patch/USA.delta" --output NCPatcher/patch/USA.delta
if %percent%==20 set /a temperrorlev=%errorlevel%
if %percent%==20 set modul=Downloading USA Delta [NC]
if %percent%==20 if not %temperrorlev%==0 goto error_patching

if %percent%==20 if not exist "NCPatcher/NUS_Downloader_Decrypt.exe" curl -f -L -s -S --insecure "%FilesHostedOn%/NCPatcher/NUS_Downloader_Decrypt.exe" --output NCPatcher/NUS_Downloader_Decrypt.exe
if %percent%==20 set /a temperrorlev=%errorlevel%
if %percent%==20 set modul=Downloading Decrypter
if %percent%==20 if not %temperrorlev%==0 goto error_patching
goto wiiu_patching_fast_travel_100
:wiiu_patching_fast_travel_21
if %percent%==21 if not exist "NCPatcher/patch/xdelta3.exe" curl -f -L -s -S --insecure "%FilesHostedOn%/NCPatcher/patch/xdelta3.exe" --output NCPatcher/patch/xdelta3.exe
if %percent%==21 set /a temperrorlev=%errorlevel%
if %percent%==21 set modul=Downloading xdelta3.exe
if %percent%==21 if not %temperrorlev%==0 goto error_patching

if %percent%==21 if not exist "NCPatcher/pack/libWiiSharp.dll" curl -f -L -s -S --insecure "%FilesHostedOn%/NCPatcher/pack/libWiiSharp.dll" --output NCPatcher/pack/libWiiSharp.dll
if %percent%==21 set /a temperrorlev=%errorlevel%
if %percent%==21 set modul=Downloading libWiiSharp.dll
if %percent%==21 if not %temperrorlev%==0 goto error_patching

if %percent%==21 if not exist "NCPatcher/pack/Sharpii.exe" curl -f -L -s -S --insecure "%FilesHostedOn%/NCPatcher/pack/Sharpii.exe" --output NCPatcher/pack/Sharpii.exe
if %percent%==21 set /a temperrorlev=%errorlevel%
if %percent%==21 set modul=Downloading Sharpii.exe
if %percent%==21 if not %temperrorlev%==0 goto error_patching
goto wiiu_patching_fast_travel_100
:wiiu_patching_fast_travel_22
if %percent%==22 if not exist "NCPatcher/dwn/Sharpii.exe" curl -f -L -s -S --insecure "%FilesHostedOn%/NCPatcher/dwn/Sharpii.exe" --output NCPatcher/dwn/Sharpii.exe
if %percent%==22 set /a temperrorlev=%errorlevel%
if %percent%==22 set modul=Downloading Sharpii.exe
if %percent%==22 if not %temperrorlev%==0 goto error_patching
goto wiiu_patching_fast_travel_100
:wiiu_patching_fast_travel_23
if %percent%==23 if not exist "NCPatcher/dwn/libWiiSharp.dll" curl -f -L -s -S --insecure "%FilesHostedOn%/NCPatcher/dwn/libWiiSharp.dll" --output NCPatcher/dwn/libWiiSharp.dll
if %percent%==23 set /a temperrorlev=%errorlevel%
if %percent%==23 set modul=Downloading libWiiSharp.dll
if %percent%==23 if not %temperrorlev%==0 goto error_patching
goto wiiu_patching_fast_travel_100
:wiiu_patching_fast_travel_24
if %percent%==24 if not exist "NCPatcher/dwn/0001000148415445v1792/cetk" curl -f -L -s -S --insecure "%FilesHostedOn%/NCPatcher/dwn/0001000148415445v1792/cetk" --output NCPatcher/dwn/0001000148415445v1792/cetk
if %percent%==24 set /a temperrorlev=%errorlevel%
if %percent%==24 set modul=Downloading USA CETK
if %percent%==24 if not %temperrorlev%==0 goto error_patching

if %percent%==24 if not exist "NCPatcher/dwn/0001000148415450v1792/cetk" curl -f -L -s -S --insecure "%FilesHostedOn%/NCPatcher/dwn/0001000148415450v1792/cetk" --output NCPatcher/dwn/0001000148415450v1792/cetk
if %percent%==24 set /a temperrorlev=%errorlevel%
if %percent%==24 set modul=Downloading EUR CETK
if %percent%==24 if not %temperrorlev%==0 goto error_patching
goto wiiu_patching_fast_travel_100

::Everything else
:wiiu_patching_fast_travel_25
if %percent%==25 if not exist apps md apps
goto wiiu_patching_fast_travel_100

:wiiu_patching_fast_travel_26
if %percent%==26 if not exist apps/WiiModLite md apps\WiiModLite
if %percent%==26 if not exist "apps/WiiModLite/boot.dol" curl -f -L -s -S --insecure "%FilesHostedOn%/apps/WiiModLite/boot.dol" --output apps/WiiModLite/boot.dol
if %percent%==26 set /a temperrorlev=%errorlevel%
if %percent%==26 set modul=Downloading Wii Mod Lite
if %percent%==26 if not %temperrorlev%==0 goto error_patching

if %percent%==26 if not exist "apps/WiiModLite/database.txt" curl -f -L -s -S --insecure "%FilesHostedOn%/apps/WiiModLite/database.txt" --output apps/WiiModLite/database.txt
if %percent%==26 set /a temperrorlev=%errorlevel%
if %percent%==26 set modul=Downloading Wii Mod Lite
if %percent%==26 if not %temperrorlev%==0 goto error_patching
goto wiiu_patching_fast_travel_100
:wiiu_patching_fast_travel_27
if %percent%==27 if not exist "apps/WiiModLite/icon.png" curl -f -L -s -S --insecure "%FilesHostedOn%/apps/WiiModLite/icon.png" --output apps/WiiModLite/icon.png
if %percent%==27 set /a temperrorlev=%errorlevel%
if %percent%==27 set modul=Downloading Wii Mod Lite
if %percent%==27 if not %temperrorlev%==0 goto error_patching

if %percent%==27 if not exist "apps/WiiModLite/icon.png" curl -f -L -s -S --insecure "%FilesHostedOn%/apps/WiiModLite/icon.png" --output apps/WiiModLite/icon.png
if %percent%==27 set /a temperrorlev=%errorlevel%
if %percent%==27 set modul=Downloading Wii Mod Lite
if %percent%==27 if not %temperrorlev%==0 goto error_patching
goto wiiu_patching_fast_travel_100

:wiiu_patching_fast_travel_28
if %percent%==28 if not exist apps/ww-43db-patcher md apps\ww-43db-patcher
if %percent%==28 if not exist "apps/WiiModLite/meta.xml" curl -f -L -s -S --insecure "%FilesHostedOn%/apps/WiiModLite/meta.xml" --output apps/WiiModLite/meta.xml
if %percent%==28 set /a temperrorlev=%errorlevel%
if %percent%==28 set modul=Downloading Wii Mod Lite
if %percent%==28 if not %temperrorlev%==0 goto error_patching
if %percent%==28 if not exist "apps/WiiModLite/wiimod.txt" curl -f -L -s -S --insecure "%FilesHostedOn%/apps/WiiModLite/wiimod.txt" --output apps/WiiModLite/wiimod.txt
if %percent%==28 set /a temperrorlev=%errorlevel%
if %percent%==28 set modul=Downloading Wii Mod Lite
if %percent%==28 if not %temperrorlev%==0 goto error_patching

if %percent%==28 if not exist "apps/ww-43db-patcher/meta.xml" curl -f -L -s -S --insecure "%FilesHostedOn%/apps/ww-43db-patcher/meta.xml" --output apps/ww-43db-patcher/meta.xml
if %percent%==28 set /a temperrorlev=%errorlevel%
if %percent%==28 set modul=Downloading ww-43db-patcher
if %percent%==28 if not %temperrorlev%==0 goto error_patching
if %percent%==28 if not exist "apps/ww-43db-patcher/icon.png" curl -f -L -s -S --insecure "%FilesHostedOn%/apps/ww-43db-patcher/icon.png" --output apps/ww-43db-patcher/icon.png
if %percent%==28 set /a temperrorlev=%errorlevel%
if %percent%==28 set modul=Downloading ww-43db-patcher
if %percent%==28 if not %temperrorlev%==0 goto error_patching
if %percent%==28 if not exist "apps/ww-43db-patcher/boot.dol" curl -f -L -s -S --insecure "%FilesHostedOn%/apps/ww-43db-patcher/boot.dol" --output apps/ww-43db-patcher/boot.dol
if %percent%==28 set /a temperrorlev=%errorlevel%
if %percent%==28 set modul=Downloading ww-43db-patcher
if %percent%==28 if not %temperrorlev%==0 goto error_patching







goto wiiu_patching_fast_travel_100
:wiiu_patching_fast_travel_29
if not exist "apps/ConnectMii" md "apps\ConnectMii"
	if not exist "apps/ConnectMii/meta.xml" curl -f -L -s -S --insecure "%FilesHostedOn%/apps/ConnectMii/meta.xml" --output apps/ConnectMii/meta.xml
set /a temperrorlev=%errorlevel%
set modul=Downloading ConnectMii
if not %temperrorlev%==0 goto error_patching
	if not exist "apps/ConnectMii/boot.dol" curl -f -L -s -S --insecure "%FilesHostedOn%/apps/ConnectMii/boot.dol" --output apps/ConnectMii/boot.dol
set /a temperrorlev=%errorlevel%
set modul=Downloading ConnectMii
if not %temperrorlev%==0 goto error_patching
	if not exist "apps/ConnectMii/icon.png" curl -f -L -s -S --insecure "%FilesHostedOn%/apps/ConnectMii/icon.png" --output apps/ConnectMii/icon.png
set /a temperrorlev=%errorlevel%
set modul=Downloading ConnectMii
if not %temperrorlev%==0 goto error_patching


goto wiiu_patching_fast_travel_100
:wiiu_patching_fast_travel_30
if not exist "EVCPatcher/patch/Europe.delta" curl -f -L -s -S --insecure "%FilesHostedOn%/EVCPatcher/patch/Europe.delta" --output EVCPatcher/patch/Europe.delta
set /a temperrorlev=%errorlevel%
set modul=Downloading Europe Delta
if not %temperrorlev%==0 goto error_patching
goto wiiu_patching_fast_travel_100
:wiiu_patching_fast_travel_31
if not exist "EVCPatcher/patch/USA.delta" curl -f -L -s -S --insecure "%FilesHostedOn%/EVCPatcher/patch/USA.delta" --output EVCPatcher/patch/USA.delta
set /a temperrorlev=%errorlevel%
set modul=Downloading Wii Mod Lite
if not %temperrorlev%==0 goto error_patching
goto wiiu_patching_fast_travel_100

:wiiu_patching_fast_travel_32
if not exist "WAD/IOS31 Wii U (IOS) (RiiConnect24).wad" curl -f -L -s -S --insecure "http://164.132.44.106/RiiConnect24_Patcher/IOS31_vwii.wad" --output "WAD/IOS31 Wii U (IOS) (RiiConnect24).wad"
set /a temperrorlev=%errorlevel%
set modul=Downloading IOS31
if not %temperrorlev%==0 goto error_patching
goto wiiu_patching_fast_travel_100

:wiiu_patching_fast_travel_33
if not exist NewsChannelPatcher md NewsChannelPatcher

if not exist "NewsChannelPatcher\00000001.delta" curl -f -L -s -S --insecure "%FilesHostedOn%/NewsChannelPatcher/00000001.delta" --output "NewsChannelPatcher/00000001.delta"
set /a temperrorlev=%errorlevel%
set modul=Downloading News Channel files
if not %temperrorlev%==0 goto error_patching
goto wiiu_patching_fast_travel_100

:wiiu_patching_fast_travel_34
if not exist "NewsChannelPatcher\libWiiSharp.dll" curl -f -L -s -S --insecure "%FilesHostedOn%/NewsChannelPatcher/libWiiSharp.dll" --output "NewsChannelPatcher/libWiiSharp.dll"
set /a temperrorlev=%errorlevel%
set modul=Downloading News Channel files
if not %temperrorlev%==0 goto error_patching
goto wiiu_patching_fast_travel_100

:wiiu_patching_fast_travel_35
if not exist "NewsChannelPatcher\Sharpii.exe" curl -f -L -s -S --insecure "%FilesHostedOn%/NewsChannelPatcher/Sharpii.exe" --output "NewsChannelPatcher/Sharpii.exe"
set /a temperrorlev=%errorlevel%
set modul=Downloading News Channel files
if not %temperrorlev%==0 goto error_patching
goto wiiu_patching_fast_travel_100

:wiiu_patching_fast_travel_36
if not exist "NewsChannelPatcher\WadInstaller.dll" curl -f -L -s -S --insecure "%FilesHostedOn%/NewsChannelPatcher/WadInstaller.dll" --output "NewsChannelPatcher/WadInstaller.dll"
set /a temperrorlev=%errorlevel%
set modul=Downloading News Channel files
if not %temperrorlev%==0 goto error_patching

if not exist "NewsChannelPatcher\xdelta3.exe" curl -f -L -s -S --insecure "%FilesHostedOn%/NewsChannelPatcher/xdelta3.exe" --output "NewsChannelPatcher/xdelta3.exe"
set /a temperrorlev=%errorlevel%
set modul=Downloading News Channel files
if not %temperrorlev%==0 goto error_patching

	set /a progress_downloading=1
goto wiiu_patching_fast_travel_100





::News Channel
:wiiu_patching_fast_travel_37
if %evcregion%==1 call NewsChannelPatcher\sharpii.exe nusd -id 0001000248414750 -v 7 -wad>NUL
	if %evcregion%==1 set /a temperrorlev=%errorlevel%
	if %evcregion%==1 set modul=Downloading News Channel
	if %evcregion%==1 if not %temperrorlev%==0 goto error_patching
if %evcregion%==2 call NewsChannelPatcher\sharpii.exe nusd -id 0001000248414745 -v 7 -wad>NUL
	if %evcregion%==2 set /a temperrorlev=%errorlevel%
	if %evcregion%==2 set modul=Downloading News Channel
	if %evcregion%==2 if not %temperrorlev%==0 goto error_patching
goto wiiu_patching_fast_travel_100
:wiiu_patching_fast_travel_38

if %evcregion%==1 call NewsChannelPatcher\sharpii.exe wad -u 0001000248414750v7.wad unpacked-temp/
	if %evcregion%==1 set /a temperrorlev=%errorlevel%
	if %evcregion%==1 set modul=Unpacking News Channel
	if %evcregion%==1 if not %temperrorlev%==0 goto error_patching
if %evcregion%==2 call NewsChannelPatcher\sharpii.exe wad -u 0001000248414745v7.wad unpacked-temp/
	if %evcregion%==2 set /a temperrorlev=%errorlevel%
	if %evcregion%==2 set modul=Unpacking News Channel
	if %evcregion%==2 if not %temperrorlev%==0 goto error_patching
goto wiiu_patching_fast_travel_100
:wiiu_patching_fast_travel_39
ren unpacked-temp\00000001.app source.app
	set /a temperrorlev=%errorlevel%
	set modul=Moving News Channel 0000001.app
	if not %temperrorlev%==0 goto error_patching
call NewsChannelPatcher\xdelta3 -d -f -s unpacked-temp\source.app NewsChannelPatcher\00000001.delta unpacked-temp\00000001.app
	set /a temperrorlev=%errorlevel%
	set modul=Patching News Channel delta
	if not %temperrorlev%==0 goto error_patching
goto wiiu_patching_fast_travel_100
:wiiu_patching_fast_travel_40
if %evcregion%==1 NewsChannelPatcher\sharpii.exe wad -p unpacked-temp/ "WAD\News Channel Wii U (Europe) (Channel) (RiiConnect24).wad"
	if %evcregion%==1 set /a temperrorlev=%errorlevel%
	if %evcregion%==1 set modul=Packing News Channel
	if %evcregion%==1 if not %temperrorlev%==0 goto error_patching
if %evcregion%==2 NewsChannelPatcher\sharpii.exe wad -p unpacked-temp/ "WAD\News Channel Wii U (USA) (Channel) (RiiConnect24).wad"
	if %evcregion%==2 set /a temperrorlev=%errorlevel%
	if %evcregion%==2 set modul=Packing News Channel
	if %evcregion%==2 if not %temperrorlev%==0 goto error_patching
set progress_news=1
goto wiiu_patching_fast_travel_100

::EVC Patcher
:wiiu_patching_fast_travel_42
if %custominstall_evc%==1 if %percent%==42 if not exist 0001000148414A50v512 md 0001000148414A50v512
if %custominstall_evc%==1 if %percent%==42 if not exist 0001000148414A45v512 md 0001000148414A45v512
if %custominstall_evc%==1 if %percent%==42 if not exist 0001000148414A50v512\cetk copy /y "EVCPatcher\dwn\0001000148414A50v512\cetk" "0001000148414A50v512\cetk"

if %custominstall_evc%==1 if %percent%==42 if not exist 0001000148414A45v512\cetk copy /y "EVCPatcher\dwn\0001000148414A45v512\cetk" "0001000148414A45v512\cetk"

goto wiiu_patching_fast_travel_100
::USA
:wiiu_patching_fast_travel_43
if %custominstall_evc%==1 if %percent%==43 if %evcregion%==2 call EVCPatcher\dwn\sharpii.exe NUSD -ID 0001000148414A45 -v 512 -encrypt >NUL
::PAL
if %custominstall_evc%==1 if %percent%==43 if %evcregion%==1 call EVCPatcher\dwn\sharpii.exe NUSD -ID 0001000148414A50 -v 512 -encrypt >NUL
if %custominstall_evc%==1 if %percent%==43 set /a temperrorlev=%errorlevel%
if %custominstall_evc%==1 if %percent%==43 set modul=Downloading EVC
if %custominstall_evc%==1 if %percent%==43 if not %temperrorlev%==0 goto error_patching
goto wiiu_patching_fast_travel_100
:wiiu_patching_fast_travel_45
if %custominstall_evc%==1 if %percent%==45 if %evcregion%==1 copy /y "EVCPatcher\NUS_Downloader_Decrypt.exe" "0001000148414A50v512"
if %custominstall_evc%==1 if %percent%==45 if %evcregion%==2 copy /y "EVCPatcher\NUS_Downloader_Decrypt.exe" "0001000148414A45v512"
if %custominstall_evc%==1 if %percent%==45 set /a temperrorlev=%errorlevel%
if %custominstall_evc%==1 if %percent%==45 set modul=Copying NDC.exe
if %custominstall_evc%==1 if %percent%==45 if not %temperrorlev%==0 goto error_patching
goto wiiu_patching_fast_travel_100
:wiiu_patching_fast_travel_47
if %custominstall_evc%==1 if %percent%==47 if %evcregion%==1 ren "0001000148414A50v512\tmd.512" "tmd"
if %custominstall_evc%==1 if %percent%==47 if %evcregion%==2 ren "0001000148414A45v512\tmd.512" "tmd"
if %custominstall_evc%==1 if %percent%==47 set /a temperrorlev=%errorlevel%
if %custominstall_evc%==1 if %percent%==47 set modul=Renaming files [Delete everything except RiiConnect24Patcher.bat]
if %custominstall_evc%==1 if %percent%==47 if not %temperrorlev%==0 goto error_patching
goto wiiu_patching_fast_travel_100
:wiiu_patching_fast_travel_50
if %custominstall_evc%==1 if %percent%==50 if %evcregion%==1 cd 0001000148414A50v512
if %custominstall_evc%==1 if %percent%==50 if %evcregion%==1 call NUS_Downloader_Decrypt.exe >NUL
if %custominstall_evc%==1 if %percent%==50 if %evcregion%==2 cd 0001000148414A45v512
if %custominstall_evc%==1 if %percent%==50 if %evcregion%==2 call NUS_Downloader_Decrypt.exe >NUL
if %custominstall_evc%==1 if %percent%==50 set /a temperrorlev=%errorlevel%
if %custominstall_evc%==1 if %percent%==50 set modul=Decrypter error
if %custominstall_evc%==1 if %percent%==50 if not %temperrorlev%==0 cd..& goto error_patching
if %custominstall_evc%==1 if %percent%==50 cd..
goto wiiu_patching_fast_travel_100
:wiiu_patching_fast_travel_60
if %custominstall_evc%==1 if %percent%==60 if %evcregion%==1 move /y "0001000148414A50v512\HAJP.wad" "EVCPatcher\pack"
if %custominstall_evc%==1 if %percent%==60 if %evcregion%==2 move /y "0001000148414A45v512\HAJE.wad" "EVCPatcher\pack"
if %custominstall_evc%==1 if %percent%==60 set /a temperrorlev=%errorlevel%
if %custominstall_evc%==1 if %percent%==60 set modul=move.exe
if %custominstall_evc%==1 if %percent%==60 if not %temperrorlev%==0 goto error_patching
goto wiiu_patching_fast_travel_100
:wiiu_patching_fast_travel_62
if %custominstall_evc%==1 if %percent%==62 if %evcregion%==1 call EVCPatcher\pack\Sharpii.exe WAD -u EVCPatcher\pack\HAJP.wad EVCPatcher\pack\unencrypted >NUL
if %custominstall_evc%==1 if %percent%==62 if %evcregion%==2 call EVCPatcher\pack\Sharpii.exe WAD -u EVCPatcher\pack\HAJE.wad EVCPatcher\pack\unencrypted >NUL
goto wiiu_patching_fast_travel_100
:wiiu_patching_fast_travel_63
if %custominstall_evc%==1 if %percent%==63 move /y "EVCPatcher\pack\unencrypted\00000001.app" "00000001.app"
if %custominstall_evc%==1 if %percent%==63 set /a temperrorlev=%errorlevel%
if %custominstall_evc%==1 if %percent%==63 set modul=move.exe
if %custominstall_evc%==1 if %percent%==63 if not %temperrorlev%==0 goto error_patching
goto wiiu_patching_fast_travel_100
:wiiu_patching_fast_travel_65
if %custominstall_evc%==1 if %percent%==65 if %evcregion%==1 call EVCPatcher\patch\xdelta3.exe -f -d -s 00000001.app EVCPatcher\patch\Europe.delta EVCPatcher\pack\unencrypted\00000001.app
if %custominstall_evc%==1 if %percent%==65 if %evcregion%==2 call EVCPatcher\patch\xdelta3.exe -f -d -s 00000001.app EVCPatcher\patch\USA.delta EVCPatcher\pack\unencrypted\00000001.app
if %custominstall_evc%==1 if %percent%==65 set /a temperrorlev=%errorlevel%
if %custominstall_evc%==1 if %percent%==65 set modul=xdelta.exe EVC
if %custominstall_evc%==1 if %percent%==65 if not %temperrorlev%==0 goto error_patching
goto wiiu_patching_fast_travel_100
:wiiu_patching_fast_travel_67
if %custominstall_evc%==1 if %percent%==67 if %evcregion%==1 call EVCPatcher\pack\Sharpii.exe WAD -p "EVCPatcher\pack\unencrypted" "WAD\Everybody Votes Channel (Europe) (Channel) (RiiConnect24)" -f 
if %custominstall_evc%==1 if %percent%==67 if %evcregion%==2 call EVCPatcher\pack\Sharpii.exe WAD -p "EVCPatcher\pack\unencrypted" "WAD\Everybody Votes Channel (USA) (Channel) (RiiConnect24)" -f
if %custominstall_evc%==1 if %percent%==67 set /a temperrorlev=%errorlevel%
if %custominstall_evc%==1 if %percent%==67 set modul=Packing EVC WAD
if %custominstall_evc%==1 if %percent%==67 set /a progress_evc=1
if %custominstall_evc%==1 if %percent%==67 if not %temperrorlev%==0 goto error_patching
goto wiiu_patching_fast_travel_100

::CMOC
:wiiu_patching_fast_travel_68
if %custominstall_cmoc%==1 if %percent%==68 if not exist 0001000148415050v512 md 0001000148415050v512
if %custominstall_cmoc%==1 if %percent%==68 if not exist 0001000148415045v512 md 0001000148415045v512
if %custominstall_cmoc%==1 if %percent%==68 if not exist 0001000148415050v512\cetk copy /y "CMOCPatcher\dwn\0001000148415050v512\cetk" "0001000148415050v512\cetk"

if %custominstall_cmoc%==1 if %percent%==68 if not exist 0001000148415045v512\cetk copy /y "CMOCPatcher\dwn\0001000148415045v512\cetk" "0001000148415045v512\cetk"

goto wiiu_patching_fast_travel_100
::USA
:wiiu_patching_fast_travel_70
if %custominstall_cmoc%==1 if %percent%==70 if %evcregion%==2 call CMOCPatcher\dwn\sharpii.exe NUSD -ID 0001000148415045 -v 512 -encrypt >NUL
::PAL
if %custominstall_cmoc%==1 if %percent%==70 if %evcregion%==1 call CMOCPatcher\dwn\sharpii.exe NUSD -ID 0001000148415050 -v 512 -encrypt >NUL
if %custominstall_cmoc%==1 if %percent%==70 set /a temperrorlev=%errorlevel%
if %custominstall_cmoc%==1 if %percent%==70 set modul=Downloading CMOC
if %custominstall_cmoc%==1 if %percent%==70 if not %temperrorlev%==0 goto error_patching
goto wiiu_patching_fast_travel_100
:wiiu_patching_fast_travel_71
if %custominstall_cmoc%==1 if %percent%==71 if %evcregion%==1 copy /y "CMOCPatcher\NUS_Downloader_Decrypt.exe" "0001000148415050v512"
if %custominstall_cmoc%==1 if %percent%==71 if %evcregion%==2 copy /y "CMOCPatcher\NUS_Downloader_Decrypt.exe" "0001000148415045v512"
if %custominstall_cmoc%==1 if %percent%==71 set /a temperrorlev=%errorlevel%
if %custominstall_cmoc%==1 if %percent%==71 set modul=Copying NDC.exe
if %custominstall_cmoc%==1 if %percent%==71 if not %temperrorlev%==0 goto error_patching
goto wiiu_patching_fast_travel_100
:wiiu_patching_fast_travel_72
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
goto wiiu_patching_fast_travel_100
:wiiu_patching_fast_travel_74
if %custominstall_cmoc%==1 if %percent%==74 if %evcregion%==1 move /y "0001000148415050v512\HAPP.wad" "CMOCPatcher\pack"
if %custominstall_cmoc%==1 if %percent%==74 if %evcregion%==2 move /y "0001000148415045v512\HAPE.wad" "CMOCPatcher\pack"
if %custominstall_cmoc%==1 if %percent%==74 set /a temperrorlev=%errorlevel%
if %custominstall_cmoc%==1 if %percent%==74 set modul=move.exe
if %custominstall_cmoc%==1 if %percent%==74 if not %temperrorlev%==0 goto error_patching
goto wiiu_patching_fast_travel_100
:wiiu_patching_fast_travel_75
if %custominstall_cmoc%==1 if %percent%==75 if %evcregion%==1 call CMOCPatcher\pack\Sharpii.exe WAD -u CMOCPatcher\pack\HAPP.wad CMOCPatcher\pack\unencrypted >NUL
if %custominstall_cmoc%==1 if %percent%==75 if %evcregion%==2 call CMOCPatcher\pack\Sharpii.exe WAD -u CMOCPatcher\pack\HAPE.wad CMOCPatcher\pack\unencrypted >NUL
goto wiiu_patching_fast_travel_100
:wiiu_patching_fast_travel_76
if %custominstall_cmoc%==1 if %percent%==76 move /y "CMOCPatcher\pack\unencrypted\00000001.app" "00000001.app"
if %custominstall_cmoc%==1 if %percent%==76 move /y "CMOCPatcher\pack\unencrypted\00000004.app" "00000004.app"
if %custominstall_cmoc%==1 if %percent%==76 set /a temperrorlev=%errorlevel%
if %custominstall_cmoc%==1 if %percent%==76 set modul=move.exe
if %custominstall_cmoc%==1 if %percent%==76 if not %temperrorlev%==0 goto error_patching
goto wiiu_patching_fast_travel_100
:wiiu_patching_fast_travel_77
if %custominstall_cmoc%==1 if %percent%==77 if %evcregion%==1 call CMOCPatcher\patch\xdelta3.exe -f -d -s 00000001.app CMOCPatcher\patch\00000001_Europe.delta CMOCPatcher\pack\unencrypted\00000001.app
if %custominstall_cmoc%==1 if %percent%==77 if %evcregion%==1 call CMOCPatcher\patch\xdelta3.exe -f -d -s 00000004.app CMOCPatcher\patch\00000004_Europe.delta CMOCPatcher\pack\unencrypted\00000004.app
if %custominstall_cmoc%==1 if %percent%==77 if %evcregion%==2 call CMOCPatcher\patch\xdelta3.exe -f -d -s 00000001.app CMOCPatcher\patch\00000001_USA.delta CMOCPatcher\pack\unencrypted\00000001.app
if %custominstall_cmoc%==1 if %percent%==77 if %evcregion%==2 call CMOCPatcher\patch\xdelta3.exe -f -d -s 00000004.app CMOCPatcher\patch\00000004_USA.delta CMOCPatcher\pack\unencrypted\00000004.app
if %custominstall_cmoc%==1 if %percent%==77 set /a temperrorlev=%errorlevel%
if %custominstall_cmoc%==1 if %percent%==77 set modul=xdelta.exe CMOC
if %custominstall_cmoc%==1 if %percent%==77 if not %temperrorlev%==0 goto error_patching
goto wiiu_patching_fast_travel_100
:wiiu_patching_fast_travel_79
if %custominstall_cmoc%==1 if %percent%==79 if %evcregion%==1 call CMOCPatcher\pack\Sharpii.exe WAD -p "CMOCPatcher\pack\unencrypted" "WAD\Mii Contest Channel (Europe) (Channel) (RiiConnect24)" -f 
if %custominstall_cmoc%==1 if %percent%==79 if %evcregion%==2 call CMOCPatcher\pack\Sharpii.exe WAD -p "CMOCPatcher\pack\unencrypted" "WAD\Check Mii Out Channel (USA) (Channel) (RiiConnect24)" -f
if %custominstall_cmoc%==1 if %percent%==79 set /a temperrorlev=%errorlevel%
if %custominstall_cmoc%==1 if %percent%==79 set modul=Packing CMOC WAD
if %custominstall_cmoc%==1 if %percent%==79 set /a progress_cmoc=1
if %custominstall_cmoc%==1 if %percent%==79 if not %temperrorlev%==0 goto error_patching
goto wiiu_patching_fast_travel_100










::NC

:wiiu_patching_fast_travel_81
if %custominstall_nc%==1 if %percent%==81 if not exist 0001000148415450v1792 md 0001000148415450v1792
if %custominstall_nc%==1 if %percent%==81 if not exist 0001000148415445v1792 md 0001000148415445v1792
if %custominstall_nc%==1 if %percent%==81 if not exist 0001000148415450v1792\cetk copy /y "NCPatcher\dwn\0001000148415450v1792\cetk" "0001000148415450v1792\cetk"

if %custominstall_nc%==1 if %percent%==81 if not exist 0001000148415445v1792\cetk copy /y "NCPatcher\dwn\0001000148415445v1792\cetk" "0001000148415445v1792\cetk"

:wiiu_patching_fast_travel_85
::USA
if %custominstall_nc%==1 if %percent%==85 if %evcregion%==2 call NCPatcher\dwn\sharpii.exe NUSD -ID 0001000148415445 -v 1792 -encrypt >NUL
if %custominstall_nc%==1 if %percent%==85 if %evcregion%==2 set /a temperrorlev=%errorlevel%
if %custominstall_nc%==1 if %percent%==85 if %evcregion%==2 set modul=Downloading NC
if %custominstall_nc%==1 if %percent%==85 if %evcregion%==2	 if not %temperrorlev%==0 goto error_patching
::PAL
if %custominstall_nc%==1 if %percent%==85 if %evcregion%==1 call NCPatcher\dwn\sharpii.exe NUSD -ID 0001000148415450 -v 1792 -encrypt >NUL
if %custominstall_nc%==1 if %percent%==85 if %evcregion%==1 set /a temperrorlev=%errorlevel%
if %custominstall_nc%==1 if %percent%==85 if %evcregion%==1 set modul=Downloading NC
if %custominstall_nc%==1 if %percent%==85 if %evcregion%==1 if not %temperrorlev%==0 goto error_patching
goto wiiu_patching_fast_travel_100
:wiiu_patching_fast_travel_86
if %custominstall_nc%==1 if %percent%==86 if %evcregion%==1 copy /y "NCPatcher\NUS_Downloader_Decrypt.exe" "0001000148415450v1792"
if %custominstall_nc%==1 if %percent%==86 if %evcregion%==2 copy /y "NCPatcher\NUS_Downloader_Decrypt.exe" "0001000148415445v1792"
if %custominstall_nc%==1 if %percent%==86 set /a temperrorlev=%errorlevel%
if %custominstall_nc%==1 if %percent%==86 set modul=Copying NDC.exe
if %custominstall_nc%==1 if %percent%==86 if not %temperrorlev%==0 goto error_patching
goto wiiu_patching_fast_travel_100
:wiiu_patching_fast_travel_87
if %custominstall_nc%==1 if %percent%==87 if %evcregion%==1 ren "0001000148415450v1792\tmd.1792" "tmd"
if %custominstall_nc%==1 if %percent%==87 if %evcregion%==2 ren "0001000148415445v1792\tmd.1792" "tmd"
if %custominstall_nc%==1 if %percent%==87 set /a temperrorlev=%errorlevel%
if %custominstall_nc%==1 if %percent%==87 set modul=Renaming files
if %custominstall_nc%==1 if %percent%==87 if not %temperrorlev%==0 goto error_patching
goto wiiu_patching_fast_travel_100
:wiiu_patching_fast_travel_88
if %custominstall_nc%==1 if %percent%==88 if %evcregion%==1 cd 0001000148415450v1792
if %custominstall_nc%==1 if %percent%==88 if %evcregion%==1 call NUS_Downloader_Decrypt.exe >NUL
if %custominstall_nc%==1 if %percent%==88 if %evcregion%==2 cd 0001000148415445v1792
if %custominstall_nc%==1 if %percent%==88 if %evcregion%==2 call NUS_Downloader_Decrypt.exe >NUL
if %custominstall_nc%==1 if %percent%==88 set /a temperrorlev=%errorlevel%
if %custominstall_nc%==1 if %percent%==88 set modul=Decrypter error
if %custominstall_nc%==1 if %percent%==88 if not %temperrorlev%==0 cd..& goto error_patching
if %custominstall_nc%==1 if %percent%==88 cd..
goto wiiu_patching_fast_travel_100
:wiiu_patching_fast_travel_89
if %custominstall_nc%==1 if %percent%==89 if %evcregion%==1 move /y "0001000148415450v1792\HATP.wad" "NCPatcher\pack"
if %custominstall_nc%==1 if %percent%==89 if %evcregion%==2 move /y "0001000148415445v1792\HATE.wad" "NCPatcher\pack"
if %custominstall_nc%==1 if %percent%==89 set /a temperrorlev=%errorlevel%
if %custominstall_nc%==1 if %percent%==89 set modul=move.exe
if %custominstall_nc%==1 if %percent%==89 if not %temperrorlev%==0 goto error_patching
goto wiiu_patching_fast_travel_100
:wiiu_patching_fast_travel_90
if %custominstall_nc%==1 if %percent%==90 if %evcregion%==1 call NCPatcher\pack\Sharpii.exe WAD -u NCPatcher\pack\HATP.wad NCPatcher\pack\unencrypted >NUL
if %custominstall_nc%==1 if %percent%==90 if %evcregion%==2 call NCPatcher\pack\Sharpii.exe WAD -u NCPatcher\pack\HATE.wad NCPatcher\pack\unencrypted >NUL
goto wiiu_patching_fast_travel_100
:wiiu_patching_fast_travel_93
if %custominstall_nc%==1 if %percent%==93 move /y "NCPatcher\pack\unencrypted\00000001.app" "00000001_NC.app"
if %custominstall_nc%==1 if %percent%==93 set /a temperrorlev=%errorlevel%
if %custominstall_nc%==1 if %percent%==93 set modul=move.exe
if %custominstall_nc%==1 if %percent%==93 if not %temperrorlev%==0 goto error_patching
goto wiiu_patching_fast_travel_100
:wiiu_patching_fast_travel_94
if %custominstall_nc%==1 if %percent%==94 if %evcregion%==1 call NCPatcher\patch\xdelta3.exe -f -d -s 00000001_NC.app NCPatcher\patch\Europe.delta NCPatcher\pack\unencrypted\00000001.app
if %custominstall_nc%==1 if %percent%==94 if %evcregion%==2 call NCPatcher\patch\xdelta3.exe -f -d -s 00000001_NC.app NCPatcher\patch\USA.delta NCPatcher\pack\unencrypted\00000001.app
if %custominstall_nc%==1 if %percent%==94 set /a temperrorlev=%errorlevel%
if %custominstall_nc%==1 if %percent%==94 set modul=xdelta.exe NC
if %custominstall_nc%==1 if %percent%==94 if not %temperrorlev%==0 goto error_patching
goto wiiu_patching_fast_travel_100
:wiiu_patching_fast_travel_95
if %custominstall_nc%==1 if %percent%==95 if %evcregion%==1 call NCPatcher\pack\Sharpii.exe WAD -p "NCPatcher\pack\unencrypted" "WAD\Nintendo Channel (Europe) (Channel) (RiiConnect24)" -f 
if %custominstall_nc%==1 if %percent%==95 if %evcregion%==2 call NCPatcher\pack\Sharpii.exe WAD -p "NCPatcher\pack\unencrypted" "WAD\Nintendo Channel (USA) (Channel) (RiiConnect24)" -f
if %custominstall_nc%==1 if %percent%==95 set /a temperrorlev=%errorlevel%
if %custominstall_nc%==1 if %percent%==95 set modul=Packing NC WAD
if %custominstall_nc%==1 if %percent%==95 if not %temperrorlev%==0 goto error_patching
if %custominstall_nc%==1 if %percent%==95 set /a progress_nc=1
goto wiiu_patching_fast_travel_100


:wiiu_patching_fast_travel_99
if %percent%==99 if not %sdcard%==NUL echo.&echo Don't worry^^! It might take some time... Now copying files to your SD Card...
if %percent%==99 if not %sdcard%==NUL xcopy /y "WAD" "%sdcard%:\WAD" /e|| set /a errorcopying=1
if %percent%==99 if not %sdcard%==NUL xcopy /y "apps" "%sdcard%:\apps" /e|| set /a errorcopying=1
if %percent%==99 if not %sdcard%==NUL xcopy /y "wiiu" "%sdcard%:\wiiu" /e|| set /a errorcopying=1

if %percent%==99 if exist 0001000148415045v512 rmdir /s /q 0001000148415045v512
if %percent%==99 if exist 0001000148415050v512 rmdir /s /q 0001000148415050v512
if %percent%==99 if exist 0001000248414745v7 rmdir /s /q 0001000248414745v7
if %percent%==99 if exist 0001000248414750v7 rmdir /s /q 0001000248414750v7

if %percent%==99 if exist 0001000148414A45v512 rmdir /s /q 0001000148414A45v512
if %percent%==99 if exist 0001000148414A50v512 rmdir /s /q 0001000148414A50v512
if %percent%==99 if exist 0001000148415450v1792 rmdir /s /q 0001000148415450v1792
if %percent%==99 if exist 0001000148415445v1792 rmdir /s /q 0001000148415445v1792 
if %percent%==99 if exist 48414745 rmdir /s /q 48414745 
if %percent%==99 if exist 48414750 rmdir /s /q 48414750
if %percent%==99 if exist unpacked-temp rmdir /s /q unpacked-temp
if %percent%==99 if exist IOSPatcher rmdir /s /q IOSPatcher
if %percent%==99 if exist NewsChannelPatcher rmdir /s /q NewsChannelPatcher
if %percent%==99 if exist EVCPatcher rmdir /s /q EVCPatcher
if %percent%==99 if exist NCPatcher rmdir /s /q NCPatcher
if %percent%==99 if exist CMOCPatcher rmdir /s /q CMOCPatcher
if %percent%==99 del /q 00000001.app
if %percent%==99 del /q 0001000248414745v7.wad
if %percent%==99 del /q 0001000248414750v7.wad
if %percent%==99 del /q 00000004.app
if %percent%==99 del /q 00000001_NC.app
if %percent%==99 set /a progress_finishing=1
goto wiiu_patching_fast_travel_100


:wiiu_patching_fast_travel_100

if %percent%==100 goto 2_4_wiiu
::ping localhost -n 1 >NUL

if /i %ss% GEQ 20 goto random_funfact
set /a percent=%percent%+1
goto 2_3_wiiu

:2_4_wiiu
cls
echo %header%
echo -----------------------------------------------------------------------------------------------------------------------------
echo.
echo Alright^^! We're done with that^^!
if %sdcardstatus%==1 if not %sdcard%==NUL if %errorcopying%==0 echo Copying successful^^! Every file is on your SD Card.
if %sdcardstatus%==1 if not %sdcard%==NUL if %errorcopying%==1 echo Wha- Something failed^^! Please copy "WAD", "apps" and "wiiu" folders to your SD Card. They're next to RiiConnect24Patcher.bat

if %sdcardstatus%==0 echo Please connect your Wii U's SD Card to the computer and copy "WAD", "apps" and "wiiu" folder to it.
echo.
echo We're nearly done^^!
echo.
echo We're now about to patch a file that's responsible for the 4:3 black bars bug that appears on Wii mode.
echo.
echo Now, please connect the SD Card to your Wii U, enter vWii, open Homebrew Launcher.
echo On the list, please find ww-43db-patcher (WiiWare 4:3 DB Patcher) and run it.
echo.
echo Press any button to continue.
pause>NUL
goto 2_7_wiiu
:2_7_wiiu
cls
echo %header%
echo -----------------------------------------------------------------------------------------------------------------------------
echo.
echo Patching done^^!
echo.
echo You can now continue with the guide.
echo.
echo What to do next?
echo.
echo 1. Return to main menu
echo 2. Close the patcher
set /p s=Choose: 
if %s%==1 goto script_start
if %s%==2 goto end
goto 2_7_wiiu

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
echo --- Other tools ---
echo.
echo 3. Install WAD files directly to the SD Card.
echo   - This will allow you to directly install a channel to your SD Card instead of you having to move it from NAND.
echo.
echo 4. Patch Wii WAD Games to work with Wiimmfi.
echo   - This will patch WAD Games (WiiWare) for use with Wiimmfi which will allow you to play online with other people.
echo.
echo 5. Patch Mario Kart Wii to work with Wiimmfi.
echo   - This will patch your copy of Mario Kart Wii to work with Wiimmfi which will enable online multiplayer to work again.
echo.
echo 6. Patch other Wii Games to work with Wiimmfi.
echo   - This will patch any other game than Mario Kart Wii to work with Wiimmfi. 
echo.
echo 7. Visit Homebrew Shop
echo   - Download and install homebrew on your SD Card using Open Shop Channel.
set /p s=Choose: 
if %s%==1 goto 2_prepare
if %s%==2 goto 2_prepare_uninstall
if %s%==3 goto direct_install_download_binary
if %s%==4 goto wadgames_patch_info
if %s%==5 goto mariokartwii_patch
if %s%==6 goto wiigames_patch
if %s%==7 goto open_shop_sdcarddetect
goto 1

:direct_install_sdcard
if not exist "%MainFolder%\WiiKeys\device.cert" goto direct_install_sdcard_configuration
if not exist "%MainFolder%\WiiKeys\keys.txt" goto direct_install_sdcard_configuration

goto direct_install_sdcard_main_menu

:direct_install_sdcard_configuration
cls
echo %header%
echo -----------------------------------------------------------------------------------------------------------------------------
echo.
echo [*] Install WAD files directly to the SD Card - wad2bin.
echo   ^> Created by DarkMatterCore.
echo.
echo Welcome %username%^^!
echo This is a configuration screen for wad2bin. You will be required to do this step only once.
echo.
echo Since every Wii is different, you will be required to dump keys from your Wii. It sounds scary but no worries because we've
echo prepared everything for you.
echo.
echo Please connect your Wii's SD Card to your computer.
echo.
echo 1. Connected.
echo 2. I can't connect the SD Card.
set /p s=Choose: 
if %s%==1 set tempgotonext=direct_install_sdcard_configuration_summary& goto detect_sd_card
if %s%==2 goto direct_install_sdcard_nosdcard_access
goto direct_install_sdcard_configuration
:direct_install_sdcard_nosdcard_access
cls
echo %header%
echo -----------------------------------------------------------------------------------------------------------------------------
echo.
echo [*] Install WAD files directly to the SD Card - wad2bin.
echo   ^> Created by DarkMatterCore.
echo.
echo Unfortunately, without direct access to the SD Card, not much can be done.
echo Please find a way to connect the SD Card to your computer and please come back here later.
echo.
echo Press any key to go back to main menu.
pause>NUL
goto begin_main
:direct_install_sdcard_configuration_summary
cls
echo %header%
echo -----------------------------------------------------------------------------------------------------------------------------
echo.
echo [*] Install WAD files directly to the SD Card - wad2bin.
echo   ^> Created by DarkMatterCore.
echo.
if %sdcard%==NUL echo Hmm... looks like an SD Card wasn't found in your system. Please choose the `Change drive letter` option
if %sdcard%==NUL echo to set your SD Card drive letter manually.
if %sdcard%==NUL echo.
if %sdcard%==NUL echo Cannot continue until you set the path.
if not %sdcard%==NUL echo Congrats^^! I've successfully detected your SD Card^^! Drive letter: %sdcard%
if not %sdcard%==NUL echo We can now continue.
echo.
echo What's next?
if %sdcard%==NUL echo 1. Connected, scan again  2. Change drive letter  2. Exit
if not %sdcard%==NUL echo 1. Continue 2. Exit 3. Change drive letter
echo.
set /p s=Choose: 

	if %sdcard%==NUL if %s%==1 set tempgotonext=direct_install_sdcard_configuration_summary& goto detect_sd_card
	if %sdcard%==NUL if %s%==2 goto direct_install_sdcard_configuration_drive_letter
	if %sdcard%==NUL if %s%==2 goto begin_main

	if not %sdcard%==NUL if %s%==1 goto direct_install_sdcard_configuration_xazzy
	if not %sdcard%==NUL if %s%==1 goto begin_main
	if not %sdcard%==NUL if %s%==1 goto direct_install_sdcard_configuration_drive_letter
goto direct_install_sdcard_configuration_summary
:direct_install_sdcard_configuration_drive_letter
cls
echo %header%
echo -----------------------------------------------------------------------------------------------------------------------------
echo.
echo [*] Install WAD files directly to the SD Card - wad2bin.
echo   ^> Created by DarkMatterCore.
echo.
echo Current SD Card Letter: %sdcard%
echo.
echo Type in the new drive letter (e.g H)
set /p sdcard=
goto direct_install_sdcard_configuration_summary

:direct_install_sdcard_configuration_xazzy
cls
echo %header%
echo -----------------------------------------------------------------------------------------------------------------------------
echo.
echo [*] Install WAD files directly to the SD Card - wad2bin.
echo   ^> Created by DarkMatterCore.
echo.
echo Please wait... I'm currently installing xyzzy-mod on your SD Card.
md "%sdcard%:\apps\xyzzy-mod"

curl -f -L -s -S --insecure "%FilesHostedOn%/apps/xyzzy-mod/boot.dol" --output "%sdcard%:\apps\xyzzy-mod\boot.dol"
	if not %errorlevel%==0 goto direct_install_sdcard_configuration_xazzy_download_error

curl -f -L -s -S --insecure "%FilesHostedOn%/apps/xyzzy-mod/icon.png" --output "%sdcard%:\apps\xyzzy-mod\icon.png"
	if not %errorlevel%==0 goto direct_install_sdcard_configuration_xazzy_download_error
	
curl -f -L -s -S --insecure "%FilesHostedOn%/apps/xyzzy-mod/meta.xml" --output "%sdcard%:\apps\xyzzy-mod\meta.xml"
		if not %errorlevel%==0 goto direct_install_sdcard_configuration_xazzy_download_error

goto direct_install_sdcard_configuration_xazzy_wait

:direct_install_sdcard_configuration_xazzy_download_error
cls
echo %header%
echo -----------------------------------------------------------------------------------------------------------------------------
echo.
echo [*] Install WAD files directly to the SD Card - wad2bin.
echo   ^> Created by DarkMatterCore.
echo.
echo There was an error while downloading xazzy-mod to your Wii'S SD Card.
echo.
echo Please try again.
echo Press any key to go back.
pause>NUL
goto begin_main
:direct_install_sdcard_configuration_xazzy_wait
cls
echo %header%
echo -----------------------------------------------------------------------------------------------------------------------------
echo.
echo [*] Install WAD files directly to the SD Card - wad2bin.
echo   ^> Created by DarkMatterCore.
echo.
echo Alright^^! I've successfully installed xyzzy-mod on your SD Card. I will remove it once this step is done.
echo.
echo Now, please connect the SD Card to your Wii and launch xyzzy-mod from your Homebrew Channel.
echo (You should find it on the last page)
echo.
echo Please select the device as SD Card and please wait for the results.
echo Once it's done, please plug the SD Card here.
echo.
echo Is it done?
echo.
echo 1. Yes, the SD Card is connected.
echo 2. Exit.
echo.
set /p s=Choose: 
if %s%==1 goto direct_install_sdcard_configuration_xazzy_find
if %s%==2 goto begin_main

goto direct_install_sdcard_configuration_xazzy_wait

:direct_install_sdcard_configuration_xazzy_find
cls
echo %header%
echo -----------------------------------------------------------------------------------------------------------------------------
echo.
echo [*] Install WAD files directly to the SD Card - wad2bin.
echo   ^> Created by DarkMatterCore.
echo.
echo Please wait...
md "%MainFolder%\WiiKeys"
copy /y "%sdcard%:\device.cert" "%MainFolder%\WiiKeys\device.cert"
if not exist "%sdcard%:\device.cert" goto direct_install_sdcard_configuration_xazzy_error
copy /y "%sdcard%:\keys.txt" "%MainFolder%\WiiKeys\keys.txt"
if not exist "%sdcard%:\keys.txt" goto direct_install_sdcard_configuration_xazzy_error

rmdir /s /q "%sdcard%:\apps\xyzzy-mod"

goto direct_install_sdcard_configuration_xazzy_done

:direct_install_sdcard_configuration_xazzy_error
cls
echo %header%
echo -----------------------------------------------------------------------------------------------------------------------------
echo.
echo [*] Install WAD files directly to the SD Card - wad2bin.
echo   ^> Created by DarkMatterCore.
echo.
echo There was an error while detecting the files.
echo Are you sure you followed the instructions correctly?
echo.
echo 1. Try copying the files again.
echo 2. Go back.
echo.
set /p s=Choose: 
if %s%==1 goto direct_install_sdcard_configuration_xazzy_find
if %s%==2 goto direct_install_sdcard_configuration_xazzy_wait

goto direct_install_sdcard_configuration_xazzy_error
:direct_install_sdcard_configuration_xazzy_done
cls
echo %header%
echo -----------------------------------------------------------------------------------------------------------------------------
echo.
echo [*] Install WAD files directly to the SD Card - wad2bin.
echo   ^> Created by DarkMatterCore.
echo.
echo Alright^^! We're done with the configuration.
echo That wasn't so hard, was it?
echo.
echo Press any key to continue.
pause>NUL
goto direct_install_sdcard_main_menu
:direct_install_sdcard_auto_not_found
cls
echo %header%
echo -----------------------------------------------------------------------------------------------------------------------------
echo.
echo [*] Install WAD files directly to the SD Card - wad2bin.
echo   ^> Created by DarkMatterCore.
echo.
echo Could not find your Wii's SD Card.
echo Please plug it in now.
echo.
echo 1. Connected.
echo 2. Set the drive letter manually.
echo 3. Go back.
set /p s=Choose: 
if %s%==1 goto direct_install_sdcard_main_menu
if %s%==2 goto direct_install_sdcard_set
if %s%==3 goto begin_main
goto direct_install_sdcard_auto_not_found

:direct_install_sdcard_set
cls
echo %header%
echo -----------------------------------------------------------------------------------------------------------------------------
echo.
echo [*] Install WAD files directly to the SD Card - wad2bin.
echo   ^> Created by DarkMatterCore.
echo.
echo Current SD Card Letter: %sdcard%
echo.
echo Type in the new drive letter (e.g H)
set /p sdcard=
goto direct_install_sdcard_main_menu
:direct_install_download_binary
cls
echo %header%
echo -----------------------------------------------------------------------------------------------------------------------------
echo.
echo Please wait...
echo I'm downloading wad2bin...

curl -f -L -s -S --insecure "%FilesHostedOn%/wad2bin.exe" --output "wad2bin.exe"
set /a temperrorlev=%errorlevel%

if not %temperrorlev%==0 goto direct_install_download_binary_error

goto direct_install_sdcard_main_menu

:direct_install_download_binary_error
cls
echo %header%
echo -----------------------------------------------------------------------------------------------------------------------------
echo.
echo There was an error while downloading wad2bin...
echo CURL Error code: %temperrorlev%
echo.
echo Press any key to go back to main menu.
pause>NUL
goto begin_main


:direct_install_sdcard_main_menu

if not exist "%MainFolder%\WiiKeys\device.cert" goto direct_install_sdcard_configuration
if not exist "%MainFolder%\WiiKeys\keys.txt" goto direct_install_sdcard_configuration

if %sdcard%==NUL set tempgotonext=direct_install_sdcard_main_menu2&call :detect_sd_card
:direct_install_sdcard_main_menu2
if %sdcard%==NUL goto direct_install_sdcard_auto_not_found

if not exist "wad2bin.exe" goto direct_install_download_binary

set /a file_not_exist=0

cls
echo %header%
echo -----------------------------------------------------------------------------------------------------------------------------
echo.
echo [*] Install WAD files directly to the SD Card - wad2bin.
echo   ^> Created by DarkMatterCore.
echo.
echo Welcome %username%^^! What can I get you?
if %direct_install_del_done%==1 echo.
if %direct_install_del_done%==1 echo :------------------------------------------:
if %direct_install_del_done%==1 echo : Deleting bogus WAD files is done^^!        :
if %direct_install_del_done%==1 echo :------------------------------------------:
set /a direct_install_del_done=0

echo.
echo 1. Install WAD files on your SD Card.
echo 2. Install DLC's for Just Dance, Rock Band or Guitar Hero. (Coming soon!)
echo 3. Reconfigure keys (use this when changing a Wii etc.)
echo.
echo 4. Delete all bogus WAD files from your SD Card.
echo 5. Main Menu.
echo.
set /p s=Choose: 
if %s%==1 goto direct_install_bulk
::if %s%==2 goto direct_install_dlc
:: If you're reading this, you know what you're doing.
:: There's an issue with wad2bin that needs to be sorted out. Coming soon.

if %s%==3 goto direct_install_sdcard_configuration
if %s%==4 goto direct_install_delete_bogus
if %s%==5 goto begin_main
goto direct_install_sdcard_main_menu

:direct_install_dlc
cls
echo %header%
echo -----------------------------------------------------------------------------------------------------------------------------
echo.
echo [*] Install DLC files directly to the SD Card - wad2bin.
echo   ^> Created by DarkMatterCore.
echo.
if not exist "wad2bin" md wad2bin
if %direct_install_bulk_files_error%==1 echo :-------------------------------------------------------:
if %direct_install_bulk_files_error%==1 echo : Could not find any .WAD files inside wad2bin folder.  :
if %direct_install_bulk_files_error%==1 echo :-------------------------------------------------------:
if %direct_install_bulk_files_error%==1 echo.
set /a direct_install_bulk_files_error=0

echo We're now going to install WAD DLC files to your SD Card.
echo I created a folder called wad2bin next to the RiiConnect24 Patcher.bat. Please put all of the files that you want to
echo install in that folder.
echo.
echo :----------------------------------------------------------------------:
echo : NOTE: You will be asked about every game during the installation.    :
echo :----------------------------------------------------------------------:
echo.
echo Are the files all in place?
echo.
echo 1. Yes, start installing.
echo 2. No, go back.
set /p s=Choose: 
if %s%==1 goto direct_install_bulk_scan_dlc
if %s%==2 goto direct_install_sdcard_main_menu

goto direct_install_dlc

:direct_install_bulk_scan_dlc
if exist "wad2bin\*.wad" goto direct_install_bulk_install_dlc
set /a direct_install_bulk_files_error=1
goto direct_install_dlc

:direct_install_bulk_install_dlc
set /a file_counter=0
for %%f in ("wad2bin\*.wad") do set /a file_counter+=1
set /a patching_file=1

	
setlocal disableDelayedExpansion
cd wad2bin
powershell -c "get-childitem *.WAD | foreach { rename-item $_ $_.Name.Replace('!', '') }"
powershell -c "get-childitem *.WAD | foreach { rename-item $_ $_.Name.Replace('&', '') }"
cd..
setlocal enableDelayedExpansion
setlocal enableextensions

for %%a in ("wad2bin\*.wad") do (
set file_path=%%a

cls
echo %header_for_loops%
echo -----------------------------------------------------------------------------------------------------------------------------
echo.
echo [.] Install DLC files directly to the SD Card - wad2bin.
echo   ^> Created by DarkMatterCore.
echo.
echo Instaling file [!patching_file!] out of [%file_counter%]
echo File name: %%~na
echo.
echo What's the game's name for the file that you're installing?
echo.
echo 1. Just Dance 2
echo 2. Just Dance 3
echo 3. Just Dance 4
echo 4. Just Dance 2014
echo 5. Just Dance 2015
echo 6. Rock Band 2
echo 7. Rock Band 3
echo 8. The Beatles - Rock Band
echo 9. Green Day - Rock Band
echo 10. Guitar Hero: World Tour
echo 11. Guitar Hero 5
echo 12. Guitar Hero: Warriors of Rock
echo.
echo 13. The game is not listed. Skip installation for this file.
set dlc_id=NUL
echo.
set /p game_dlc=Choose: 
if !game_dlc!==1 set dlc_id=00010000534432
if !game_dlc!==2 set dlc_id=00010000534A44
if !game_dlc!==3 set dlc_id=00010000534A58
if !game_dlc!==4 set dlc_id=00010000534A4F
if !game_dlc!==5 set dlc_id=00010000534533
if !game_dlc!==6 set dlc_id=00010000535A41
if !game_dlc!==7 set dlc_id=00010000535A42
if !game_dlc!==8 set dlc_id=0001000052394A
if !game_dlc!==9 set dlc_id=00010000535A41
if !game_dlc!==10 set dlc_id=00010000535841
if !game_dlc!==11 set dlc_id=00010000535845
if !game_dlc!==12 set dlc_id=00010000535849
echo.
if not !dlc_id!==NUL echo Region?
if not !dlc_id!==NUL echo 1. Europe 
if not !dlc_id!==NUL echo 2. USA
if not !dlc_id!==NUL set /p region_dlc=Choose: 
if not !dlc_id!==NUL if !region_dlc!==1 set dlc_id=!dlc_id!50
if not !dlc_id!==NUL if !region_dlc!==2 set dlc_id=!dlc_id!45
echo.
echo Alright, installing...

if not "!dlc_id!"=="NUL" wad2bin "%MainFolder%\WiiKeys\keys.txt" "%MainFolder%\WiiKeys\device.cert" "%%a" "%sdcard%:\" !dlc_id!
echo off
pause
	set /a temperrorlev=!errorlevel!
	if not !temperrorlev!==0 goto direct_install_single_fail

move /Y "%sdcard%:\*_bogus.wad" "%sdcard%:\WAD\">NUL

set /a patching_file=!patching_file!+1
)
del /q wad2bin_output.txt
echo.
echo Installation complete^^! 
echo  Now, please start your WAD Manager (Wii Mod Lite, if you installed RiiConnect24) and please install the WAD file called
echo  (numbers)_bogus.wad on your Wii.
echo.
echo  NOTE: You will get a -1022 error - don't worry! The WAD is empty but all we need is the TMD and ticket.
echo  After you're done installing the WAD, you can later plug in the SD Card in and choose the option to delete bogus WAD's
echo  in the main menu.
echo.
echo Press any key to go back.

pause>NUL
goto direct_install_sdcard_main_menu


























:direct_install_bulk
cls
echo %header%
echo -----------------------------------------------------------------------------------------------------------------------------
echo.
echo [*] Install WAD files directly to the SD Card - wad2bin.
echo   ^> Created by DarkMatterCore.
echo.
if not exist "wad2bin" md wad2bin
if %direct_install_bulk_files_error%==1 echo :-------------------------------------------------------:
if %direct_install_bulk_files_error%==1 echo : Could not find any .WAD files inside wad2bin folder.  :
if %direct_install_bulk_files_error%==1 echo :-------------------------------------------------------:
if %direct_install_bulk_files_error%==1 echo.
set /a direct_install_bulk_files_error=0

echo We're now going to install WAD files to your SD Card.
echo I created a folder called wad2bin next to the RiiConnect24 Patcher.bat. Please put all of the files that you want to
echo install in that folder.
echo.
echo :-----------------------------------------------------:
echo : NOTE: Some DLC files might result in an error.      :
echo :-----------------------------------------------------:
echo.
echo Are the files all in place?
echo.
echo 1. Yes, start installing.
echo 2. No, go back.
set /p s=Choose: 
if %s%==1 goto direct_install_bulk_scan
if %s%==2 goto direct_install_sdcard_main_menu

goto direct_install_bulk

:direct_install_bulk_scan
if exist "wad2bin\*.wad" goto direct_install_bulk_install
set /a direct_install_bulk_files_error=1
goto direct_install_bulk

:direct_install_bulk_install
set /a file_counter=0
for %%f in ("wad2bin\*.wad") do set /a file_counter+=1
set /a patching_file=1


setlocal disableDelayedExpansion
cd wad2bin
powershell -c "get-childitem *.WAD | foreach { rename-item $_ $_.Name.Replace('!', '') }"
powershell -c "get-childitem *.WAD | foreach { rename-item $_ $_.Name.Replace('&', '') }"
cd..
setlocal enableDelayedExpansion

for %%f in ("wad2bin\*.wad") do (

cls
echo %header_for_loops%
echo -----------------------------------------------------------------------------------------------------------------------------
echo.
echo [.] Install WAD files directly to the SD Card - wad2bin.
echo   ^> Created by DarkMatterCore.
echo.
echo Instaling file [!patching_file!] out of [%file_counter%]
echo File name: %%~nf
call wad2bin.exe "%MainFolder%\WiiKeys\keys.txt" "%MainFolder%\WiiKeys\device.cert" "%%f" %sdcard%:\>wad2bin_output.txt
	set /a temperrorlev=!errorlevel!
	if not !temperrorlev!==0 goto direct_install_single_fail

move /Y "%sdcard%:\*_bogus.wad" "%sdcard%:\WAD\">NUL

set /a patching_file=!patching_file!+1
)
del /q wad2bin_output.txt
echo.
echo Installation complete^^! 
echo  Now, please start your WAD Manager (Wii Mod Lite, if you installed RiiConnect24) and please install the WAD file called
echo  (numbers)_bogus.wad on your Wii.
echo.
echo  NOTE: You will get a -1022 error - don't worry! The WAD is empty but all we need is the TMD and ticket.
echo  After you're done installing the WAD, you can later plug in the SD Card in and choose the option to delete bogus WAD's
echo  in the main menu.
echo.
echo Press any key to go back.

pause>NUL
goto direct_install_sdcard_main_menu
:direct_install_delete_bogus
cls
echo %header%
echo -----------------------------------------------------------------------------------------------------------------------------
echo.
echo [*] Install WAD files directly to the SD Card - wad2bin.
echo   ^> Created by DarkMatterCore.
echo.
echo Are you sure you want to delete all bogus files?
echo If you still didn't install them, you won't be able to open any installed channels by you.
echo.
echo Are you sure you want to delete them?
echo.
echo 1. Yes
echo 2. No, go back.
set /p s=Choose: 
if %s%==1 del /q "%sdcard%:\WAD\*_bogus.wad"&set /a direct_install_del_done=1&goto direct_install_sdcard_main_menu
if %s%==2 goto direct_install_sdcard_main_menu
goto direct_install_delete_bogus

:direct_install_single_fail
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
echo   /     \  Installing WAD file(s) has failed.
echo  /   ^^!   \ 
echo  --------- wad2bin returned error code: %temperrorlev%
if %temperrorlev%==-1 echo            ERROR: Invalid arguments
if %temperrorlev%==-2 echo            ERROR: Memory allocation for internal path buffers failed
if %temperrorlev%==-3 echo            ERROR: (Windows only) UTF-8 to UTF-16 conversion failed
if %temperrorlev%==-4 echo            ERROR: Failed to load console-specific keydata
if %temperrorlev%==-5 echo            ERROR: Failed to unpack input WAD
if %temperrorlev%==-6 echo            ERROR: Failed to realign loaded certificate chain buffer
if %temperrorlev%==-7 echo            ERROR: Failed to realign loaded ticket buffer
if %temperrorlev%==-8 echo            ERROR: Failed to realign loaded TMD buffer
if %temperrorlev%==-9 echo            ERROR: Input WAD is a DLC WAD from a game that doesn't support loading data from a SD card
if %temperrorlev%==-10 echo            ERROR: Failed to generate indexed bin files from unpacked DLC WAD
if %temperrorlev%==-11 echo            ERROR: Failed to generate content.bin file from unpacked non-DLC WAD
if %temperrorlev%==-12 echo            ERROR: Failed to generate bogus WAD
echo.
echo            Please contact KcrPL#4625 on Discord or mail us at support@riiconnect24.net
echo.
echo       1. Go back to wad2bin menu.
echo       2. Show error info.
echo ---------------------------------------------------------------------------------------------------------------------------
echo.
set /p s=Choose: 
if %s%==1 goto direct_install_sdcard_main_menu
if %s%==2 call "wad2bin_output.txt"
goto direct_install_single_fail
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
curl -f -L -s -S --insecure "https://download.wiimm.de/wiimmfi/patcher/wiimmfi-patcher-v4.7z" --output "Wiimmfi-Patcher\wiimmfi-patcher-v4.7z"
echo 50%%
curl -f -L -s -S --insecure "%FilesHostedOn%/7z.exe" --output "Wiimmfi-Patcher\7z.exe"
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

if exist "*.WBFS" copy "*.WBFS" "Wiimmfi-Patcher\wiimmfi-patcher-v4\Windows"
if exist "*.ISO" copy "*.ISO" "Wiimmfi-Patcher\wiimmfi-patcher-v4\Windows"

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
echo The patched game image file(s) has been moved to the wiimmfi-images folder next to RiiConnect24 Patcher.
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
curl -f -L -s -S --insecure "https://download.wiimm.de/wiimmfi/patcher/mkw-wiimmfi-patcher-v6.zip" --output "MKWii-Patcher\mkw-wiimmfi-patcher-v6.zip"
echo 50%%
curl -f -L -s -S --insecure "%FilesHostedOn%/7z.exe" --output "MKWii-Patcher\7z.exe"
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
if exist "*.WBFS" copy "*.WBFS" "MKWii-Patcher\mkw-wiimmfi-patcher-v6\"
if exist "*.ISO" copy "*.ISO" "MKWii-Patcher\mkw-wiimmfi-patcher-v6\"

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
echo The patched Mario Kart Wii image file has been copied to the wiimmfi-images folder next to RiiConnect24 Patcher.
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
curl -f -L -s -S --insecure "%FilesHostedOn_WiiWarePatcher%/libWiiSharp.dll" --output WiiWare-Patcher/libWiiSharp.dll
echo 28%%
curl -f -L -s -S --insecure "%FilesHostedOn_WiiWarePatcher%/lzx.exe" --output WiiWare-Patcher/lzx.exe
echo 42%%
curl -f -L -s -S --insecure "%FilesHostedOn_WiiWarePatcher%/patcher.bat" --output WiiWare-Patcher/patcher.bat
echo 57%%
curl -f -L -s -S --insecure "%FilesHostedOn_WiiWarePatcher%/Sharpii.exe" --output WiiWare-Patcher/Sharpii.exe
echo 71%%
curl -f -L -s -S --insecure "%FilesHostedOn_WiiWarePatcher%/WadInstaller.dll" --output WiiWare-Patcher/WadInstaller.dll
echo 85%%
curl -f -L -s -S --insecure "%FilesHostedOn_WiiWarePatcher%/WiiwarePatcher.exe" --output WiiWare-Patcher/WiiwarePatcher.exe
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
if %percent%==1 if not exist "IOSPatcher/00000006-31.delta" curl -f -L -s -S --insecure "%FilesHostedOn%/IOSPatcher/00000006-31.delta" --output IOSPatcher/00000006-31.delta
if %percent%==1 set /a temperrorlev=%errorlevel%
if %percent%==1 set modul=Downloading 06-31.delta
if %percent%==1 if not %temperrorlev%==0 goto error_patching

if %percent%==3 if not exist "IOSPatcher/00000006-80.delta" curl -f -L -s -S --insecure "%FilesHostedOn%/IOSPatcher/00000006-80.delta" --output IOSPatcher/00000006-80.delta
if %percent%==3 set /a temperrorlev=%errorlevel%
if %percent%==3 set modul=Downloading 06-80.delta
if %percent%==3 if not %temperrorlev%==0 goto error_patching

if %percent%==6 if not exist "IOSPatcher/00000006-80.delta" curl -f -L -s -S --insecure "%FilesHostedOn%/IOSPatcher/00000006-80.delta" --output IOSPatcher/00000006-80.delta
if %percent%==6 set /a temperrorlev=%errorlevel%
if %percent%==6 set modul=Downloading 06-80.delta
if %percent%==6 if not %temperrorlev%==0 goto error_patching

if %percent%==9 if not exist "IOSPatcher/libWiiSharp.dll" curl -f -L -s -S --insecure "%FilesHostedOn%/IOSPatcher/libWiiSharp.dll" --output IOSPatcher/libWiiSharp.dll
if %percent%==9 set /a temperrorlev=%errorlevel%
if %percent%==9 set modul=Downloading libWiiSharp.dll
if %percent%==9 if not %temperrorlev%==0 goto error_patching

if %percent%==12 if not exist "IOSPatcher/Sharpii.exe" curl -f -L -s -S --insecure "%FilesHostedOn%/IOSPatcher/Sharpii.exe" --output IOSPatcher/Sharpii.exe
if %percent%==12 set /a temperrorlev=%errorlevel%
if %percent%==12 set modul=Downloading Sharpii.exe
if %percent%==12 if not %temperrorlev%==0 goto error_patching

if %percent%==15 if not exist "IOSPatcher/WadInstaller.dll" curl -f -L -s -S --insecure "%FilesHostedOn%/IOSPatcher/WadInstaller.dll" --output IOSPatcher/WadInstaller.dll
if %percent%==15 set /a temperrorlev=%errorlevel%
if %percent%==15 set modul=Downloading WadInstaller.dll
if %percent%==15 if not %temperrorlev%==0 goto error_patching

if %percent%==17 if not exist "IOSPatcher/xdelta3.exe" curl -f -L -s -S --insecure "%FilesHostedOn%/IOSPatcher/xdelta3.exe" --output IOSPatcher/xdelta3.exe
if %percent%==17 set /a temperrorlev=%errorlevel%
if %percent%==17 set modul=Downloading xdelta3.exe
if %percent%==17 if not %temperrorlev%==0 goto error_patching


if %percent%==20 if not exist apps md apps

if %percent%==23 if not exist apps/WiiModLite md apps\WiiModLite
if %percent%==23 if not exist apps/WiiXplorer md apps\WiiXplorer
if %percent%==23 if not exist "apps/WiiModLite/boot.dol" curl -f -L -s -S --insecure "%FilesHostedOn%/apps/WiiModLite/boot.dol" --output apps/WiiModLite/boot.dol
if %percent%==23 set /a temperrorlev=%errorlevel%
if %percent%==23 set modul=Downloading Wii Mod Lite
if %percent%==23 if not %temperrorlev%==0 goto error_patching

if %percent%==25 if not exist "apps/WiiModLite/database.txt" curl -f -L -s -S --insecure "%FilesHostedOn%/apps/WiiModLite/database.txt" --output apps/WiiModLite/database.txt
if %percent%==25 set /a temperrorlev=%errorlevel%
if %percent%==25 set modul=Downloading Wii Mod Lite
if %percent%==25 if not %temperrorlev%==0 goto error_patching

if %percent%==27 if not exist "apps/WiiModLite/icon.png" curl -f -L -s -S --insecure "%FilesHostedOn%/apps/WiiModLite/icon.png" --output apps/WiiModLite/icon.png
if %percent%==27 set /a temperrorlev=%errorlevel%
if %percent%==27 set modul=Downloading Wii Mod Lite
if %percent%==27 if not %temperrorlev%==0 goto error_patching

if %percent%==30 if not exist "apps/WiiModLite/icon.png" curl -f -L -s -S --insecure "%FilesHostedOn%/apps/WiiModLite/icon.png" --output apps/WiiModLite/icon.png
if %percent%==30 set /a temperrorlev=%errorlevel%
if %percent%==30 set modul=Downloading Wii Mod Lite
if %percent%==30 if not %temperrorlev%==0 goto error_patching

if %percent%==32 if not exist "apps/WiiModLite/meta.xml" curl -f -L -s -S --insecure "%FilesHostedOn%/apps/WiiModLite/meta.xml" --output apps/WiiModLite/meta.xml"
if %percent%==32 set /a temperrorlev=%errorlevel%
if %percent%==32 set modul=Downloading Wii Mod Lite
if %percent%==32 if not %temperrorlev%==0 goto error_patching

if %percent%==34 if not exist "apps/WiiModLite/wiimod.txt" curl -f -L -s -S --insecure "%FilesHostedOn%/apps/WiiModLite/wiimod.txt" --output apps/WiiModLite/wiimod.txt
if %percent%==34 set /a temperrorlev=%errorlevel%
if %percent%==34 set modul=Downloading Wii Mod Lite
if %percent%==34 if not %temperrorlev%==0 goto error_patching

if %percent%==36 if not exist "apps/WiiXplorer/boot.dol" curl -f -L -s -S --insecure "%FilesHostedOn%/apps/WiiXplorer/boot.dol" --output apps/WiiXplorer/boot.dol
if %percent%==36 set /a temperrorlev=%errorlevel%
if %percent%==36 set modul=Downloading WiiXplorer
if %percent%==36 if not %temperrorlev%==0 goto error_patching

if %percent%==38 if not exist "apps/WiiXplorer/icon.png" curl -f -L -s -S --insecure "%FilesHostedOn%/apps/WiiXplorer/icon.png" --output apps/WiiXplorer/icon.png
if %percent%==38 set /a temperrorlev=%errorlevel%
if %percent%==38 set modul=Downloading WiiXplorer
if %percent%==38 if not %temperrorlev%==0 goto error_patching

if %percent%==39 if not exist "apps/WiiXplorer/meta.xml" curl -f -L -s -S --insecure "%FilesHostedOn%/apps/WiiXplorer/meta.xml" --output apps/WiiXplorer/meta.xml
if %percent%==39 set /a temperrorlev=%errorlevel%
if %percent%==39 set modul=Downloading WiiXplorer
if %percent%==39 if not %temperrorlev%==0 goto error_patching

if %percent%==40 if %uninstall_2_1%==1 if not exist "apps/WiiXplorer/meta.xml" curl -f -L -s -S --insecure "%FilesHostedOn%/apps/WiiModLite/meta.xml" --output apps/WiiModLite/meta.xml
if %percent%==40 if %uninstall_2_1%==1 set /a temperrorlev=%errorlevel%
if %percent%==40 if %uninstall_2_1%==1 set modul=Downloading WiiXplorer
if %percent%==40 if %uninstall_2_1%==1 if not %temperrorlev%==0 goto error_patching

if %percent%==45 if %uninstall_2_1%==1 if not exist "apps/WiiXplorer/icon.png" curl -f -L -s -S --insecure "%FilesHostedOn%/apps/WiiModLite/meta.xml" --output apps/WiiModLite/meta.xml
if %percent%==45 if %uninstall_2_1%==1 set /a temperrorlev=%errorlevel%
if %percent%==45 if %uninstall_2_1%==1 set modul=Downloading WiiXplorer
if %percent%==45 if %uninstall_2_1%==1 if not %temperrorlev%==0 goto error_patching

if %percent%==48 if %uninstall_2_1%==1 if not exist "apps/WiiXplorer/boot.dol" curl -f -L -s -S --insecure "%FilesHostedOn%/apps/WiiModLite/meta.xml" --output apps/WiiModLite/meta.xml
if %percent%==48 if %uninstall_2_1%==1 set /a temperrorlev=%errorlevel%
if %percent%==48 if %uninstall_2_1%==1 set modul=Downloading WiiXplorer
if %percent%==48 if %uninstall_2_1%==1 if not %temperrorlev%==0 goto error_patching

if %percent%==50 if not exist "WAD" md "WAD"
if %percent%==50 call IOSPatcher\Sharpii.exe NUSD -IOS 31 -v latest -o "wad\IOS31 Wii Only (IOS) (Original).wad" -wad >NUL
if %percent%==50 set /a temperrorlev=%errorlevel%
if %percent%==50 set modul=Sharpii.exe
if %percent%==50 if not %temperrorlev%==0 goto error_patching

if %percent%==80 call IOSPatcher\Sharpii.exe NUSD -IOS 80 -v latest -o "wad\IOS80 Wii Only (IOS) (Original).wad" -wad >NUL
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
set /a custominstall_news_fore=1
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
if %custominstall_ios%==1 echo 2. [X] IOS Patches [required for other channels to work]
if %custominstall_ios%==0 echo 2. [ ] IOS Patches [required for other channels to work]
if %custominstall_news_fore%==1 echo 3. [X] Forecast/News Channel
if %custominstall_news_fore%==0 echo 3. [ ] Forecast/News Channel
if %custominstall_evc%==1 echo 4. [X] Everybody Votes Channel
if %custominstall_evc%==0 echo 4. [ ] Everybody Votes Channel
if %custominstall_nc%==1 echo 5. [X] Nintendo Channel
if %custominstall_nc%==0 echo 5. [ ] Nintendo Channel
if %custominstall_cmoc%==1 echo 6. [X] Check Mii Out Channel / Mii Contest Channel
if %custominstall_cmoc%==0 echo 6. [ ] Check Mii Out Channel / Mii Contest Channel
echo.
echo 7. Begin patching^^!
echo R. Go back.
set /p s=
if %s%==1 goto 2_switch_region
if %s%==2 goto 2_switch_fore-news-wiimail
if %s%==3 goto 2_switch_fore_news
if %s%==4 goto 2_switch_evc
if %s%==5 goto 2_switch_nc
if %s%==6 goto 2_switch_cmoc
if %s%==7 goto 2_2
if %s%==r goto begin_main
if %s%==R goto begin_main
goto 2_choose_custom_install_type2
:2_switch_fore_news
if %custominstall_news_fore%==1 set /a custominstall_news_fore=0&goto 2_choose_custom_install_type2
if %custominstall_news_fore%==0 set /a custominstall_news_fore=1&goto 2_choose_custom_install_type2
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
set /a custominstall_news_fore=1	
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
echo The following process will download about 170MB of data.
echo.

echo What's next?
if %sdcardstatus%==0 echo 1. Start Patching  2. Exit
if %sdcardstatus%==1 if %sdcard%==NUL echo 1. Start Patching 2. Exit 3. Change drive letter
if %sdcardstatus%==1 if not %sdcard%==NUL echo 1. Start Patching 2. Exit 3. Change drive letter

set /p s=Choose: 
if %s%==1 goto check_for_wad_folder_wii
if %s%==2 goto begin_main
if %s%==3 goto 2_change_drive_letter
goto 2_1_summary
:check_for_wad_folder_wii
if not exist "WAD" goto 2_2
cls
echo %header%
echo -----------------------------------------------------------------------------------------------------------------------------
echo.
echo One more thing^^! I've detected WAD folder.
echo I need to delete it.
echo.
echo Can I?
echo 1. Yes
echo 2. No
set /p s=Choose: 
if %s%==1 rmdir /s /q "WAD"
if %s%==1 goto 2_2
if %s%==2 goto 2_1_summary
goto check_for_wad_folder_wii

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
:2_change_drive_letter_wiiu
cls
echo %header%
echo -----------------------------------------------------------------------------------------------------------------------------
echo [*] SD Card
echo.
echo Current SD Card Letter: %sdcard%
echo.
echo Type in the new drive letter (e.g H)
set /p sdcard=
goto 2_1_summary_wiiu
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
set /a progress_news_fore=0
set /a progress_evc=0
set /a progress_nc=0
set /a progress_cmoc=0
set /a progress_finishing=0
set /a wiiu_return=0

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
if %funfact_number%==21 set funfact=The News Channel has an alternate slide show song that plays as night.
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
if %wiiu_return%==1 goto 2_3_wiiu
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
if %custominstall_news_fore%==1 if %progress_news_fore%==0 echo [ ] Patching News/Forecast Channel
if %custominstall_news_fore%==1 if %progress_news_fore%==1 echo [X] Patching News/Forecast Channel
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
if exist 0001000148415045v512 rmdir /s /q 0001000148415045v512
if exist 0001000148415050v512 rmdir /s /q 0001000148415050v512

if exist 0001000148414A45v512 rmdir /s /q 0001000148414A45v512
if exist 0001000148414A50v512 rmdir /s /q 0001000148414A50v512
if exist 0001000148415450v1792 rmdir /s /q 0001000148415450v1792
if exist 0001000148415445v1792 rmdir /s /q 0001000148415445v1792 
if exist unpacked-temp rmdir /s /q unpacked-temp
if exist IOSPatcher rmdir /s /q IOSPatcher
if exist EVCPatcher rmdir /s /q EVCPatcher
if exist NCPatcher rmdir /s /q NCPatcher
if exist CMOCPatcher rmdir /s /q CMOCPatcher
if exist NewsChannelPatcher rmdir /s /q NewsChannelPatcher
if exist 00000001.app del /q 00000001.app
if exist 0001000248414650v7.wad del /q 0001000248414650v7.wad
if exist 0001000248414645v7.wad del /q 0001000248414645v7.wad
if exist 0001000248414750v7.wad del /q 0001000248414750v7.wad
if exist 0001000248414745v7.wad del /q 0001000248414745v7.wad
if exist 00000004.app del /q 00000004.app
if exist 00000001_NC.app del /q 00000001_NC.app


if not exist WAD md WAD
if exist NewsChannelPatcher rmdir /s /q NewsChannelPatcher
if not exist NewsChannelPatcher md NewsChannelPatcher
if not exist IOSPatcher md IOSPatcher
if not exist "IOSPatcher/00000006-31.delta" curl -f -L -s -S --insecure "%FilesHostedOn%/IOSPatcher/00000006-31.delta" --output IOSPatcher/00000006-31.delta
set /a temperrorlev=%errorlevel%
set modul=Downloading 06-31.delta
if not %temperrorlev%==0 goto error_patching

if not exist "IOSPatcher/00000006-80.delta" curl -f -L -s -S --insecure "%FilesHostedOn%/IOSPatcher/00000006-80.delta" --output IOSPatcher/00000006-80.delta
set /a temperrorlev=%errorlevel%
set modul=Downloading 06-80.delta
if not %temperrorlev%==0 goto error_patching
goto patching_fast_travel_100
:patching_fast_travel_2
if not exist "IOSPatcher/00000006-80.delta" curl -f -L -s -S --insecure "%FilesHostedOn%/IOSPatcher/00000006-80.delta" --output IOSPatcher/00000006-80.delta
set /a temperrorlev=%errorlevel%
set modul=Downloading 06-80.delta
if not %temperrorlev%==0 goto error_patching
goto patching_fast_travel_100
:patching_fast_travel_3
if not exist "IOSPatcher/libWiiSharp.dll" curl -f -L -s -S --insecure "%FilesHostedOn%/IOSPatcher/libWiiSharp.dll" --output IOSPatcher/libWiiSharp.dll
set /a temperrorlev=%errorlevel%
set modul=Downloading libWiiSharp.dll
if not %temperrorlev%==0 goto error_patching

if not exist "IOSPatcher/Sharpii.exe" curl -f -L -s -S --insecure "%FilesHostedOn%/IOSPatcher/Sharpii.exe" --output IOSPatcher/Sharpii.exe
set /a temperrorlev=%errorlevel%
set modul=Downloading Sharpii.exe
if not %temperrorlev%==0 goto error_patching
goto patching_fast_travel_100
:patching_fast_travel_4
if not exist "IOSPatcher/WadInstaller.dll" curl -f -L -s -S --insecure "%FilesHostedOn%/IOSPatcher/WadInstaller.dll" --output IOSPatcher/WadInstaller.dll
set /a temperrorlev=%errorlevel%
set modul=Downloading WadInstaller.dll
if not %temperrorlev%==0 goto error_patching
goto patching_fast_travel_100
:patching_fast_travel_5
if not exist "IOSPatcher/xdelta3.exe" curl -f -L -s -S --insecure "%FilesHostedOn%/IOSPatcher/xdelta3.exe" --output IOSPatcher/xdelta3.exe
set /a temperrorlev=%errorlevel%
set modul=Downloading xdelta3.exe
if not %temperrorlev%==0 goto error_patching
goto patching_fast_travel_100
::EVC
:patching_fast_travel_6
if not exist EVCPatcher/patch md EVCPatcher\patch
if not exist EVCPatcher/dwn md EVCPatcher\dwn
if not exist EVCPatcher/dwn/0001000148414A45v512 md EVCPatcher\dwn\0001000148414A45v512
if not exist EVCPatcher/dwn/0001000148414A50v512 md EVCPatcher\dwn\0001000148414A50v512
if not exist EVCPatcher/pack md EVCPatcher\pack
if not exist "EVCPatcher/patch/Europe.delta" curl -f -L -s -S --insecure "%FilesHostedOn%/EVCPatcher/patch/Europe.delta" --output EVCPatcher/patch/Europe.delta
set /a temperrorlev=%errorlevel%
set modul=Downloading Europe Delta
if not %temperrorlev%==0 goto error_patching
if not exist "EVCPatcher/patch/USA.delta" curl -f -L -s -S --insecure "%FilesHostedOn%/EVCPatcher/patch/USA.delta" --output EVCPatcher/patch/USA.delta
set /a temperrorlev=%errorlevel%
set modul=Downloading USA Delta
if not %temperrorlev%==0 goto error_patching
goto patching_fast_travel_100
:patching_fast_travel_7
if not exist "EVCPatcher/NUS_Downloader_Decrypt.exe" curl -f -L -s -S --insecure "%FilesHostedOn%/EVCPatcher/NUS_Downloader_Decrypt.exe" --output EVCPatcher/NUS_Downloader_Decrypt.exe
set /a temperrorlev=%errorlevel%
set modul=Downloading decrypter
if not %temperrorlev%==0 goto error_patching
goto patching_fast_travel_100

:patching_fast_travel_8
if not exist "EVCPatcher/patch/xdelta3.exe" curl -f -L -s -S --insecure "%FilesHostedOn%/EVCPatcher/patch/xdelta3.exe" --output EVCPatcher/patch/xdelta3.exe
set /a temperrorlev=%errorlevel%
set modul=Downloading xdelta3.exe
if not %temperrorlev%==0 goto error_patching

if not exist "EVCPatcher/pack/libWiiSharp.dll" curl -f -L -s -S --insecure "%FilesHostedOn%/EVCPatcher/pack/libWiiSharp.dll" --output "EVCPatcher/pack/libWiiSharp.dll"
set /a temperrorlev=%errorlevel%
set modul=Downloading libWiiSharp.dll
if not %temperrorlev%==0 goto error_patching

if not exist "EVCPatcher/pack/Sharpii.exe" curl -f -L -s -S --insecure "%FilesHostedOn%/EVCPatcher/pack/Sharpii.exe" --output EVCPatcher/pack/Sharpii.exe
set /a temperrorlev=%errorlevel%
set modul=Downloading Sharpii.exe
if not %temperrorlev%==0 goto error_patching
if not exist "EVCPatcher/dwn/Sharpii.exe" curl -f -L -s -S --insecure "%FilesHostedOn%/EVCPatcher/dwn/Sharpii.exe" --output EVCPatcher/dwn/Sharpii.exe
set /a temperrorlev=%errorlevel%
set modul=Downloading Sharpii.exe
if not %temperrorlev%==0 goto error_patching
goto patching_fast_travel_100
:patching_fast_travel_9
if not exist "EVCPatcher/dwn/libWiiSharp.dll" curl -f -L -s -S --insecure "%FilesHostedOn%/EVCPatcher/dwn/libWiiSharp.dll" --output EVCPatcher/dwn/libWiiSharp.dll
set /a temperrorlev=%errorlevel%
set modul=Downloading libWiiSharp.dll
if not %temperrorlev%==0 goto error_patching
goto patching_fast_travel_100
:patching_fast_travel_10
if not exist "EVCPatcher/dwn/0001000148414A45v512/cetk" curl -f -L -s -S --insecure "%FilesHostedOn%/EVCPatcher/dwn/0001000148414A45v512/cetk" --output EVCPatcher/dwn/0001000148414A45v512/cetk
set /a temperrorlev=%errorlevel%
set modul=Downloading USA CETK
if not %temperrorlev%==0 goto error_patching

if not exist "EVCPatcher/dwn/0001000148414A50v512/cetk" curl -f -L -s -S --insecure "%FilesHostedOn%/EVCPatcher/dwn/0001000148414A50v512/cetk" --output EVCPatcher/dwn/0001000148414A50v512/cetk
set /a temperrorlev=%errorlevel%
set modul=Downloading EUR CETK
if not %temperrorlev%==0 goto error_patching
goto patching_fast_travel_100

::CMOC
:patching_fast_travel_11
if not exist CMOCPatcher/patch md CMOCPatcher\patch
if not exist CMOCPatcher/dwn md CMOCPatcher\dwn
if not exist CMOCPatcher/dwn/0001000148415045v512 md CMOCPatcher\dwn\0001000148415045v512
if not exist CMOCPatcher/dwn/0001000148415050v512 md CMOCPatcher\dwn\0001000148415050v512
if not exist CMOCPatcher/pack md CMOCPatcher\pack
if not exist "CMOCPatcher/patch/00000001_Europe.delta" curl -f -L -s -S --insecure "%FilesHostedOn%/CMOCPatcher/patch/00000001_Europe.delta" --output CMOCPatcher/patch/00000001_Europe.delta
if not exist "CMOCPatcher/patch/00000004_Europe.delta" curl -f -L -s -S --insecure "%FilesHostedOn%/CMOCPatcher/patch/00000004_Europe.delta" --output CMOCPatcher/patch/00000004_Europe.delta
set /a temperrorlev=%errorlevel%
set modul=Downloading Europe Delta
if not %temperrorlev%==0 goto error_patching
goto patching_fast_travel_100
:patching_fast_travel_12
if not exist "CMOCPatcher/patch/00000001_USA.delta" curl -f -L -s -S --insecure "%FilesHostedOn%/CMOCPatcher/patch/00000001_USA.delta" --output CMOCPatcher/patch/00000001_USA.delta
if not exist "CMOCPatcher/patch/00000004_USA.delta" curl -f -L -s -S --insecure "%FilesHostedOn%/CMOCPatcher/patch/00000004_USA.delta" --output CMOCPatcher/patch/00000004_USA.delta
set /a temperrorlev=%errorlevel%
set modul=Downloading USA Delta
if not %temperrorlev%==0 goto error_patching
if not exist "CMOCPatcher/NUS_Downloader_Decrypt.exe" curl -f -L -s -S --insecure "%FilesHostedOn%/CMOCPatcher/NUS_Downloader_Decrypt.exe" --output CMOCPatcher/NUS_Downloader_Decrypt.exe
set /a temperrorlev=%errorlevel%
set modul=Downloading decrypter
if not %temperrorlev%==0 goto error_patching
goto patching_fast_travel_100
:patching_fast_travel_13
if not exist "CMOCPatcher/patch/xdelta3.exe" curl -f -L -s -S --insecure "%FilesHostedOn%/CMOCPatcher/patch/xdelta3.exe" --output CMOCPatcher/patch/xdelta3.exe
set /a temperrorlev=%errorlevel%
set modul=Downloading xdelta3.exe
if not %temperrorlev%==0 goto error_patching
if not exist "CMOCPatcher/pack/libWiiSharp.dll" curl -f -L -s -S --insecure "%FilesHostedOn%/CMOCPatcher/pack/libWiiSharp.dll" --output "CMOCPatcher/pack/libWiiSharp.dll"
set /a temperrorlev=%errorlevel%
set modul=Downloading libWiiSharp.dll
if not %temperrorlev%==0 goto error_patching
if not exist "CMOCPatcher/pack/Sharpii.exe" curl -f -L -s -S --insecure "%FilesHostedOn%/CMOCPatcher/pack/Sharpii.exe" --output CMOCPatcher/pack/Sharpii.exe
set /a temperrorlev=%errorlevel%
set modul=Downloading Sharpii.exe
if not %temperrorlev%==0 goto error_patching
if not exist "CMOCPatcher/dwn/Sharpii.exe" curl -f -L -s -S --insecure "%FilesHostedOn%/CMOCPatcher/dwn/Sharpii.exe" --output CMOCPatcher/dwn/Sharpii.exe
set /a temperrorlev=%errorlevel%
set modul=Downloading Sharpii.exe
if not %temperrorlev%==0 goto error_patching
if not exist "CMOCPatcher/dwn/libWiiSharp.dll" curl -f -L -s -S --insecure "%FilesHostedOn%/CMOCPatcher/dwn/libWiiSharp.dll" --output CMOCPatcher/dwn/libWiiSharp.dll
set /a temperrorlev=%errorlevel%
set modul=Downloading libWiiSharp.dll
if not %temperrorlev%==0 goto error_patching
goto patching_fast_travel_100

:patching_fast_travel_14
if not exist NewsChannelPatcher md NewsChannelPatcher

if not exist "NewsChannelPatcher/00000001_Forecast_Europe.delta" curl -f -L -s -S --insecure "%FilesHostedOn%/NewsChannelPatcher/URL_Patches/Europe/00000001_Forecast.delta" --output "NewsChannelPatcher/00000001_Forecast_Europe.delta"
set /a temperrorlev=%errorlevel%
set modul=Downloading Forecast Channel files

if not exist "NewsChannelPatcher/00000001_Forecast_USA.delta" curl -f -L -s -S --insecure "%FilesHostedOn%/NewsChannelPatcher/URL_Patches/USA/00000001_Forecast.delta" --output "NewsChannelPatcher/00000001_Forecast_USA.delta"
set /a temperrorlev=%errorlevel%
set modul=Downloading Forecast Channel files

if not exist "NewsChannelPatcher/00000001_News_Europe.delta" curl -f -L -s -S --insecure "%FilesHostedOn%/NewsChannelPatcher/URL_Patches/Europe/00000001_News.delta" --output "NewsChannelPatcher/00000001_News_Europe.delta"
set /a temperrorlev=%errorlevel%
set modul=Downloading News Channel files

if not exist "NewsChannelPatcher/00000001_News_USA.delta" curl -f -L -s -S --insecure "%FilesHostedOn%/NewsChannelPatcher/URL_Patches/USA/00000001_News.delta" --output "NewsChannelPatcher/00000001_News_USA.delta"
set /a temperrorlev=%errorlevel%
set modul=Downloading News Channel files

if not %temperrorlev%==0 goto error_patching
goto patching_fast_travel_100

:patching_fast_travel_15
if not exist "NewsChannelPatcher\libWiiSharp.dll" curl -f -L -s -S --insecure "%FilesHostedOn%/NewsChannelPatcher/libWiiSharp.dll" --output "NewsChannelPatcher/libWiiSharp.dll"
set /a temperrorlev=%errorlevel%
set modul=Downloading News Channel files
if not %temperrorlev%==0 goto error_patching
goto patching_fast_travel_100

:patching_fast_travel_16
if not exist "NewsChannelPatcher\Sharpii.exe" curl -f -L -s -S --insecure "%FilesHostedOn%/NewsChannelPatcher/Sharpii.exe" --output "NewsChannelPatcher/Sharpii.exe"
set /a temperrorlev=%errorlevel%
set modul=Downloading News Channel files
if not %temperrorlev%==0 goto error_patching
goto patching_fast_travel_100

:patching_fast_travel_17
if not exist "NewsChannelPatcher\WadInstaller.dll" curl -f -L -s -S --insecure "%FilesHostedOn%/NewsChannelPatcher/WadInstaller.dll" --output "NewsChannelPatcher/WadInstaller.dll"
set /a temperrorlev=%errorlevel%
set modul=Downloading News Channel files
if not %temperrorlev%==0 goto error_patching

if not exist "NewsChannelPatcher\xdelta3.exe" curl -f -L -s -S --insecure "%FilesHostedOn%/NewsChannelPatcher/xdelta3.exe" --output "NewsChannelPatcher/xdelta3.exe"
set /a temperrorlev=%errorlevel%
set modul=Downloading News Channel files
if not %temperrorlev%==0 goto error_patching
goto patching_fast_travel_100

:patching_fast_travel_18
if not exist "CMOCPatcher/dwn/0001000148415045v512/cetk" curl -f -L -s -S --insecure "%FilesHostedOn%/CMOCPatcher/dwn/0001000148415045v512/cetk" --output CMOCPatcher/dwn/0001000148415045v512/cetk
if not exist "CMOCPatcher/dwn/0001000148415045v512/cert" curl -f -L -s -S --insecure "%FilesHostedOn%/CMOCPatcher/dwn/0001000148415045v512/cert" --output CMOCPatcher/dwn/0001000148415045v512/cert
set /a temperrorlev=%errorlevel%
set modul=Downloading USA CETK
if not %temperrorlev%==0 goto error_patching
goto patching_fast_travel_100
:patching_fast_travel_19
if not exist "CMOCPatcher/dwn/0001000148415050v512/cetk" curl -f -L -s -S --insecure "%FilesHostedOn%/CMOCPatcher/dwn/0001000148415050v512/cetk" --output CMOCPatcher/dwn/0001000148415050v512/cetk
if not exist "CMOCPatcher/dwn/0001000148415050v512/cert" curl -f -L -s -S --insecure "%FilesHostedOn%/CMOCPatcher/dwn/0001000148415050v512/cert" --output CMOCPatcher/dwn/0001000148415050v512/cert
set /a temperrorlev=%errorlevel%
set modul=Downloading EUR CETK
if not %temperrorlev%==0 goto error_patching
goto patching_fast_travel_100


::NC
:patching_fast_travel_20
if not exist NCPatcher/patch md NCPatcher\patch
if not exist NCPatcher/dwn md NCPatcher\dwn
if not exist NCPatcher/dwn/0001000148415450v1792 md NCPatcher\dwn\0001000148415450v1792
if not exist NCPatcher/dwn/0001000148415445v1792 md NCPatcher\dwn\0001000148415445v1792
if not exist NCPatcher/pack md NCPatcher\pack
if not exist "NCPatcher/patch/Europe.delta" curl -f -L -s -S --insecure "%FilesHostedOn%/NCPatcher/patch/Europe.delta" --output NCPatcher/patch/Europe.delta
set /a temperrorlev=%errorlevel%
set modul=Downloading Europe Delta [NC]
if not %temperrorlev%==0 goto error_patching

if not exist "NCPatcher/patch/USA.delta" curl -f -L -s -S --insecure "%FilesHostedOn%/NCPatcher/patch/USA.delta" --output NCPatcher/patch/USA.delta
set /a temperrorlev=%errorlevel%
set modul=Downloading USA Delta [NC]
if not %temperrorlev%==0 goto error_patching

if not exist "NCPatcher/NUS_Downloader_Decrypt.exe" curl -f -L -s -S --insecure "%FilesHostedOn%/NCPatcher/NUS_Downloader_Decrypt.exe" --output NCPatcher/NUS_Downloader_Decrypt.exe
set /a temperrorlev=%errorlevel%
set modul=Downloading Decrypter
if not %temperrorlev%==0 goto error_patching
goto patching_fast_travel_100
:patching_fast_travel_21
if not exist "NCPatcher/patch/xdelta3.exe" curl -f -L -s -S --insecure "%FilesHostedOn%/NCPatcher/patch/xdelta3.exe" --output NCPatcher/patch/xdelta3.exe
set /a temperrorlev=%errorlevel%
set modul=Downloading xdelta3.exe
if not %temperrorlev%==0 goto error_patching

if not exist "NCPatcher/pack/libWiiSharp.dll" curl -f -L -s -S --insecure "%FilesHostedOn%/NCPatcher/pack/libWiiSharp.dll" --output NCPatcher/pack/libWiiSharp.dll
set /a temperrorlev=%errorlevel%
set modul=Downloading libWiiSharp.dll
if not %temperrorlev%==0 goto error_patching

if not exist "NCPatcher/pack/Sharpii.exe" curl -f -L -s -S --insecure "%FilesHostedOn%/NCPatcher/pack/Sharpii.exe" --output NCPatcher/pack/Sharpii.exe
set /a temperrorlev=%errorlevel%
set modul=Downloading Sharpii.exe
if not %temperrorlev%==0 goto error_patching
goto patching_fast_travel_100
:patching_fast_travel_22
if not exist "NCPatcher/dwn/Sharpii.exe" curl -f -L -s -S --insecure "%FilesHostedOn%/NCPatcher/dwn/Sharpii.exe" --output NCPatcher/dwn/Sharpii.exe
set /a temperrorlev=%errorlevel%
set modul=Downloading Sharpii.exe
if not %temperrorlev%==0 goto error_patching
goto patching_fast_travel_100
:patching_fast_travel_23
if not exist "NCPatcher/dwn/libWiiSharp.dll" curl -f -L -s -S --insecure "%FilesHostedOn%/NCPatcher/dwn/libWiiSharp.dll" --output NCPatcher/dwn/libWiiSharp.dll
set /a temperrorlev=%errorlevel%
set modul=Downloading libWiiSharp.dll
if not %temperrorlev%==0 goto error_patching
goto patching_fast_travel_100
:patching_fast_travel_24
if not exist "NCPatcher/dwn/0001000148415445v1792/cetk" curl -f -L -s -S --insecure "%FilesHostedOn%/NCPatcher/dwn/0001000148415445v1792/cetk" --output NCPatcher/dwn/0001000148415445v1792/cetk
set /a temperrorlev=%errorlevel%
set modul=Downloading USA CETK
if not %temperrorlev%==0 goto error_patching

if not exist "NCPatcher/dwn/0001000148415450v1792/cetk" curl -f -L -s -S --insecure "%FilesHostedOn%/NCPatcher/dwn/0001000148415450v1792/cetk" --output NCPatcher/dwn/0001000148415450v1792/cetk
set /a temperrorlev=%errorlevel%
set modul=Downloading EUR CETK
if not %temperrorlev%==0 goto error_patching
goto patching_fast_travel_100

::Everything else
:patching_fast_travel_25
if not exist apps md apps
if not exist apps/Mail-Patcher md apps\Mail-Patcher
if not exist "apps/Mail-Patcher/boot.dol" curl -f -L -s -S --insecure "%FilesHostedOn%/apps/Mail-Patcher/boot.dol" --output apps/Mail-Patcher/boot.dol
set /a temperrorlev=%errorlevel%
set modul=Downloading Mail Patcher
if not %temperrorlev%==0 goto error_patching


if not exist "apps/Mail-Patcher/icon.png" curl -f -L -s -S --insecure "%FilesHostedOn%/apps/Mail-Patcher/icon.png" --output apps/Mail-Patcher/icon.png
set /a temperrorlev=%errorlevel%
set modul=Downloading Mail Patcher
if not %temperrorlev%==0 goto error_patching


if not exist "apps/Mail-Patcher/meta.xml" curl -f -L -s -S --insecure "%FilesHostedOn%/apps/Mail-Patcher/meta.xml" --output apps/Mail-Patcher/meta.xml
set /a temperrorlev=%errorlevel%
set modul=Downloading Mail Patcher
if not %temperrorlev%==0 goto error_patching
goto patching_fast_travel_100

:patching_fast_travel_26
if not exist apps/WiiModLite md apps\WiiModLite
if not exist apps/Mail-Patcher md apps\Mail-Patcher
if not exist "apps/WiiModLite/boot.dol" curl -f -L -s -S --insecure "%FilesHostedOn%/apps/WiiModLite/boot.dol" --output apps/WiiModLite/boot.dol
set /a temperrorlev=%errorlevel%
set modul=Downloading Wii Mod Lite
if not %temperrorlev%==0 goto error_patching

if not exist "apps/WiiModLite/database.txt" curl -f -L -s -S --insecure "%FilesHostedOn%/apps/WiiModLite/database.txt" --output apps/WiiModLite/database.txt
set /a temperrorlev=%errorlevel%
set modul=Downloading Wii Mod Lite
if not %temperrorlev%==0 goto error_patching
goto patching_fast_travel_100
:patching_fast_travel_27
if not exist "apps/WiiModLite/icon.png" curl -f -L -s -S --insecure "%FilesHostedOn%/apps/WiiModLite/icon.png" --output apps/WiiModLite/icon.png
set /a temperrorlev=%errorlevel%
set modul=Downloading Wii Mod Lite
if not %temperrorlev%==0 goto error_patching

if not exist "apps/WiiModLite/icon.png" curl -f -L -s -S --insecure "%FilesHostedOn%/apps/WiiModLite/icon.png" --output apps/WiiModLite/icon.png
set /a temperrorlev=%errorlevel%
set modul=Downloading Wii Mod Lite
if not %temperrorlev%==0 goto error_patching
goto patching_fast_travel_100

:patching_fast_travel_28
if not exist "apps/WiiModLite/meta.xml" curl -f -L -s -S --insecure "%FilesHostedOn%/apps/WiiModLite/meta.xml" --output apps/WiiModLite/meta.xml
set /a temperrorlev=%errorlevel%
set modul=Downloading Wii Mod Lite
if not %temperrorlev%==0 goto error_patching
if not exist "apps/WiiModLite/wiimod.txt" curl -f -L -s -S --insecure "%FilesHostedOn%/apps/WiiModLite/wiimod.txt" --output apps/WiiModLite/wiimod.txt
set /a temperrorlev=%errorlevel%
set modul=Downloading Wii Mod Lite
if not %temperrorlev%==0 goto error_patching
goto patching_fast_travel_100
:patching_fast_travel_29
if not exist "EVCPatcher/patch/Europe.delta" curl -f -L -s -S --insecure "%FilesHostedOn%EVCPatcher/patch/Europe.delta" --output EVCPatcher/patch/Europe.delta
set /a temperrorlev=%errorlevel%
set modul=Downloading Europe Delta
if not %temperrorlev%==0 goto error_patching
goto patching_fast_travel_100
:patching_fast_travel_30
if not exist "EVCPatcher/patch/USA.delta" curl -f -L -s -S --insecure "%FilesHostedOn%/EVCPatcher/patch/USA.delta" --output EVCPatcher/patch/USA.delta
set /a temperrorlev=%errorlevel%
set /a progress_downloading=1
set modul=Downloading Wii Mod Lite
if not %temperrorlev%==0 goto error_patching
goto patching_fast_travel_100

::IOS Patcher
:patching_fast_travel_31
if %custominstall_ios%==1 call IOSPatcher\Sharpii.exe NUSD -IOS 31 -v latest -o IOSPatcher\IOS31-old.wad -wad >NUL
if %custominstall_ios%==1 set /a temperrorlev=%errorlevel%
if %custominstall_ios%==1 set modul=Sharpii.exe
if %custominstall_ios%==1 if not %temperrorlev%==0 goto error_patching
if %custominstall_ios%==1 call IOSPatcher\Sharpii.exe NUSD -IOS 80 -v latest -o IOSPatcher\IOS80-old.wad -wad >NUL
if %custominstall_ios%==1 set /a temperrorlev=%errorlevel%
if %custominstall_ios%==1 set modul=Sharpii.exe
if %custominstall_ios%==1 if not %temperrorlev%==0 goto error_patching
if %custominstall_ios%==1 call IOSPatcher\Sharpii.exe WAD -u IOSPatcher\IOS31-old.wad IOSPatcher/IOS31/ >NUL
if %custominstall_ios%==1 set /a temperrorlev=%errorlevel%
if %custominstall_ios%==1 set modul=Sharpii.exe
if %custominstall_ios%==1 if not %temperrorlev%==0 goto error_patching
if %custominstall_ios%==1 call IOSPatcher\Sharpii.exe WAD -u IOSPatcher\IOS80-old.wad IOSPatcher\IOS80/ >NUL
if %custominstall_ios%==1 set /a temperrorlev=%errorlevel%
if %custominstall_ios%==1 set modul=Sharpii.exe
if %custominstall_ios%==1 if not %temperrorlev%==0 goto error_patching
if %custominstall_ios%==1 move /y IOSPatcher\IOS31\00000006.app IOSPatcher\00000006.app >NUL
if %custominstall_ios%==1 set /a temperrorlev=%errorlevel%
if %custominstall_ios%==1 set modul=move.exe
if %custominstall_ios%==1 if not %temperrorlev%==0 goto error_patching
goto patching_fast_travel_100
:patching_fast_travel_32
if %custominstall_ios%==1 call IOSPatcher\xdelta3.exe -f -d -s IOSPatcher\00000006.app IOSPatcher\00000006-31.delta IOSPatcher\IOS31\00000006.app >NUL
if %custominstall_ios%==1 set /a temperrorlev=%errorlevel%
if %custominstall_ios%==1 set modul=xdelta.exe
if %custominstall_ios%==1 if not %temperrorlev%==0 goto error_patching
goto patching_fast_travel_100
:patching_fast_travel_33
if %custominstall_ios%==1 move /y IOSPatcher\IOS80\00000006.app IOSPatcher\00000006.app >NUL
if %custominstall_ios%==1 set /a temperrorlev=%errorlevel%
if %custominstall_ios%==1 set modul=move.exe
if %custominstall_ios%==1 if not %temperrorlev%==0 goto error_patching
if %custominstall_ios%==1 call IOSPatcher\xdelta3.exe -f -d -s IOSPatcher\00000006.app IOSPatcher\00000006-80.delta IOSPatcher\IOS80\00000006.app >NUL
if %custominstall_ios%==1 set /a temperrorlev=%errorlevel%
if %custominstall_ios%==1 set modul=xdelta3.exe
if %custominstall_ios%==1 if not %temperrorlev%==0 goto error_patching
if %custominstall_ios%==1 if not exist IOSPatcher\WAD mkdir IOSPatcher\WAD
if %custominstall_ios%==1 set /a temperrorlev=%errorlevel%
if %custominstall_ios%==1 set modul=mkdir.exe
if %custominstall_ios%==1 if not %temperrorlev%==0 goto error_patching
goto patching_fast_travel_100
:patching_fast_travel_34
if %custominstall_ios%==1 call IOSPatcher\Sharpii.exe WAD -p IOSPatcher\IOS31\ "IOSPatcher\WAD\IOS31 Wii Only (IOS) (RiiConnect24).wad" -fs >NUL
if %custominstall_ios%==1 set /a temperrorlev=%errorlevel%
if %custominstall_ios%==1 set modul=Sharpii.exe
if %custominstall_ios%==1 if not %temperrorlev%==0 goto error_patching
if %custominstall_ios%==1 call IOSPatcher\Sharpii.exe WAD -p IOSPatcher\IOS80\ "IOSPatcher\WAD\IOS80 Wii Only (IOS) (RiiConnect24).wad" -fs >NUL
if %custominstall_ios%==1 set /a temperrorlev=%errorlevel%
if %custominstall_ios%==1 set modul=Sharpii.exe
if %custominstall_ios%==1 if not %temperrorlev%==0 goto error_patching
:patching_fast_travel_35
if %custominstall_ios%==1 del IOSPatcher\00000006.app /q >NUL
if %custominstall_ios%==1 set /a temperrorlev=%errorlevel%
if %custominstall_ios%==1 set modul=del.exe
if %custominstall_ios%==1 if not %temperrorlev%==0 goto error_patching
if %custominstall_ios%==1 del IOSPatcher\IOS31-old.wad /q >NUL
if %custominstall_ios%==1 set /a temperrorlev=%errorlevel%
if %custominstall_ios%==1 set modul=del.exe
if %custominstall_ios%==1 if not %temperrorlev%==0 goto error_patching
if %custominstall_ios%==1 del IOSPatcher\IOS80-old.wad /q >NUL
if %custominstall_ios%==1 set /a temperrorlev=%errorlevel%
if %custominstall_ios%==1 set modul=del.exe
if %custominstall_ios%==1 if not %temperrorlev%==0 goto error_patching
if %custominstall_ios%==1 if exist IOSPatcher\IOS31 rmdir /s /q IOSPatcher\IOS31 >NUL
if %custominstall_ios%==1 set /a temperrorlev=%errorlevel%
if %custominstall_ios%==1 set modul=rmdir.exe
if %custominstall_ios%==1 if not %temperrorlev%==0 goto error_patching
if %custominstall_ios%==1 if exist IOSPatcher\IOS80 rmdir /s /q IOSPatcher\IOS80 >NUL
if %custominstall_ios%==1 set /a temperrorlev=%errorlevel%
if %custominstall_ios%==1 set modul=rmdir.exe
if %custominstall_ios%==1 if not %temperrorlev%==0 goto error_patching
goto patching_fast_travel_100
:patching_fast_travel_36
if %custominstall_ios%==1 call IOSPatcher\Sharpii.exe IOS "IOSPatcher\WAD\IOS31 Wii Only (IOS) (RiiConnect24).wad" -fs -es -np -vp>NUL
if %custominstall_ios%==1 set /a temperrorlev=%errorlevel%
if %custominstall_ios%==1 set modul=Sharpii.exe
if %custominstall_ios%==1 if not %temperrorlev%==0 goto error_patching
goto patching_fast_travel_100
:patching_fast_travel_37
if %custominstall_ios%==1 call IOSPatcher\Sharpii.exe IOS IOSPatcher\WAD\IOS80 Wii Only (IOS) (RiiConnect24).wad" -fs -es -np -vp>NUL
if %custominstall_ios%==1 set /a temperrorlev=%errorlevel%
if %custominstall_ios%==1 set modul=Sharpii.exe
if %custominstall_ios%==1 if not %temperrorlev%==0 goto error_patching
goto patching_fast_travel_100
:patching_fast_travel_38
if %custominstall_ios%==1 if not exist WAD md WAD
if %custominstall_ios%==1 move "IOSPatcher\WAD\IOS31 Wii Only (IOS) (RiiConnect24).wad" "WAD"
if %custominstall_ios%==1 move "IOSPatcher\WAD\IOS80 Wii Only (IOS) (RiiConnect24).wad" "WAD"
goto patching_fast_travel_100
:patching_fast_travel_39
if %custominstall_ios%==1 if exist IOSPatcher rmdir /s /q IOSPatcher
if %custominstall_ios%==1 set /a progress_ios=1
goto patching_fast_travel_100

::News/Forecast Channel
::News
:patching_fast_travel_40
if %custominstall_news_fore%==1 if not exist NewsChannelPatcher md NewsChannelPatcher
if %custominstall_news_fore%==1 if %evcregion%==1 call NewsChannelPatcher\sharpii.exe nusd -id 0001000248414750 -v 7 -wad>NUL
if %custominstall_news_fore%==1 	if %evcregion%==1 set /a temperrorlev=%errorlevel%
if %custominstall_news_fore%==1 	if %evcregion%==1 set modul=Downloading News Channel
if %custominstall_news_fore%==1 	if %evcregion%==1 if not %temperrorlev%==0 goto error_patching
if %custominstall_news_fore%==1 if %evcregion%==2 call NewsChannelPatcher\sharpii.exe nusd -id 0001000248414745 -v 7 -wad>NUL
if %custominstall_news_fore%==1 	if %evcregion%==2 set /a temperrorlev=%errorlevel%
if %custominstall_news_fore%==1 	if %evcregion%==2 set modul=Downloading News Channel
if %custominstall_news_fore%==1 	if %evcregion%==2 if not %temperrorlev%==0 goto error_patching
goto patching_fast_travel_100
:patching_fast_travel_42

if %custominstall_news_fore%==1 if %evcregion%==1 call NewsChannelPatcher\sharpii.exe wad -u 0001000248414750v7.wad unpacked-temp/
if %custominstall_news_fore%==1 	if %evcregion%==1 set /a temperrorlev=%errorlevel%
if %custominstall_news_fore%==1 	if %evcregion%==1 set modul=Unpacking News Channel
if %custominstall_news_fore%==1 	if %evcregion%==1 if not %temperrorlev%==0 goto error_patching
if %custominstall_news_fore%==1 if %evcregion%==2 call NewsChannelPatcher\sharpii.exe wad -u 0001000248414745v7.wad unpacked-temp/
if %custominstall_news_fore%==1 	if %evcregion%==2 set /a temperrorlev=%errorlevel%
if %custominstall_news_fore%==1 	if %evcregion%==2 set modul=Unpacking News Channel
if %custominstall_news_fore%==1 	if %evcregion%==2 if not %temperrorlev%==0 goto error_patching
goto patching_fast_travel_100
:patching_fast_travel_43
if %custominstall_news_fore%==1 ren unpacked-temp\00000001.app source.app
if %custominstall_news_fore%==1 	set /a temperrorlev=%errorlevel%
if %custominstall_news_fore%==1 	set modul=Moving News Channel 0000001.app
if %custominstall_news_fore%==1 	if not %temperrorlev%==0 goto error_patching
if %custominstall_news_fore%==1 if %evcregion%==1 call NewsChannelPatcher\xdelta3 -d -f -s unpacked-temp\source.app NewsChannelPatcher\00000001_News_Europe.delta unpacked-temp\00000001.app
if %custominstall_news_fore%==1 if %evcregion%==2 call NewsChannelPatcher\xdelta3 -d -f -s unpacked-temp\source.app NewsChannelPatcher\00000001_News_USA.delta unpacked-temp\00000001.app

if %custominstall_news_fore%==1 	set /a temperrorlev=%errorlevel%
if %custominstall_news_fore%==1 	set modul=Patching News Channel delta
if %custominstall_news_fore%==1 	if not %temperrorlev%==0 goto error_patching
goto patching_fast_travel_100
:patching_fast_travel_44
if %custominstall_news_fore%==1 if %evcregion%==1 NewsChannelPatcher\sharpii.exe wad -p unpacked-temp/ "WAD\News Channel (Europe) (Channel) (RiiConnect24).wad"
if %custominstall_news_fore%==1 	if %evcregion%==1 set /a temperrorlev=%errorlevel%
if %custominstall_news_fore%==1 	if %evcregion%==1 set modul=Packing News Channel
if %custominstall_news_fore%==1 	if %evcregion%==1 if not %temperrorlev%==0 goto error_patching
if %custominstall_news_fore%==1 if %evcregion%==2 NewsChannelPatcher\sharpii.exe wad -p unpacked-temp/ "WAD\News Channel (USA) (Channel) (RiiConnect24).wad"
if %custominstall_news_fore%==1 	if %evcregion%==2 set /a temperrorlev=%errorlevel%
if %custominstall_news_fore%==1 	if %evcregion%==2 set modul=Packing News Channel
if %custominstall_news_fore%==1 	if %evcregion%==2 if not %temperrorlev%==0 goto error_patching
if %custominstall_news_fore%==1 	rmdir /s /q unpacked-temp
goto patching_fast_travel_100

::Forecast
:patching_fast_travel_45
if %custominstall_news_fore%==1 if %evcregion%==1 call NewsChannelPatcher\sharpii.exe nusd -id 0001000248414650 -v 7 -wad>NUL
if %custominstall_news_fore%==1 	if %evcregion%==1 set /a temperrorlev=%errorlevel%
if %custominstall_news_fore%==1 	if %evcregion%==1 set modul=Downloading Forecast Channel
if %custominstall_news_fore%==1 	if %evcregion%==1 if not %temperrorlev%==0 goto error_patching
if %custominstall_news_fore%==1 if %evcregion%==2 call NewsChannelPatcher\sharpii.exe nusd -id 0001000248414645 -v 7 -wad>NUL
if %custominstall_news_fore%==1 	if %evcregion%==2 set /a temperrorlev=%errorlevel%
if %custominstall_news_fore%==1 	if %evcregion%==2 set modul=Downloading Forecast Channel
if %custominstall_news_fore%==1 	if %evcregion%==2 if not %temperrorlev%==0 goto error_patching
goto patching_fast_travel_100
:patching_fast_travel_46

if %custominstall_news_fore%==1 if %evcregion%==1 call NewsChannelPatcher\sharpii.exe wad -u 0001000248414650v7.wad unpacked-temp/
if %custominstall_news_fore%==1 	if %evcregion%==1 set /a temperrorlev=%errorlevel%
if %custominstall_news_fore%==1 	if %evcregion%==1 set modul=Unpacking Forecast Channel
if %custominstall_news_fore%==1 	if %evcregion%==1 if not %temperrorlev%==0 goto error_patching
if %custominstall_news_fore%==1 if %evcregion%==2 call NewsChannelPatcher\sharpii.exe wad -u 0001000248414645v7.wad unpacked-temp/
if %custominstall_news_fore%==1 	if %evcregion%==2 set /a temperrorlev=%errorlevel%
if %custominstall_news_fore%==1 	if %evcregion%==2 set modul=Unpacking Forecast Channel
if %custominstall_news_fore%==1 	if %evcregion%==2 if not %temperrorlev%==0 goto error_patching
goto patching_fast_travel_100
:patching_fast_travel_47
if %custominstall_news_fore%==1 ren unpacked-temp\00000001.app source.app
if %custominstall_news_fore%==1 	set /a temperrorlev=%errorlevel%
if %custominstall_news_fore%==1 	set modul=Moving Forecast Channel 0000001.app
if %custominstall_news_fore%==1 	if not %temperrorlev%==0 goto error_patching
if %custominstall_news_fore%==1 if %evcregion%==1 call NewsChannelPatcher\xdelta3 -d -f -s unpacked-temp\source.app NewsChannelPatcher\00000001_Forecast_Europe.delta unpacked-temp\00000001.app
if %custominstall_news_fore%==1 if %evcregion%==2 call NewsChannelPatcher\xdelta3 -d -f -s unpacked-temp\source.app NewsChannelPatcher\00000001_Forecast_USA.delta unpacked-temp\00000001.app
if %custominstall_news_fore%==1 	set /a temperrorlev=%errorlevel%
if %custominstall_news_fore%==1 	set modul=Patching Forecast Channel delta
if %custominstall_news_fore%==1 	if not %temperrorlev%==0 goto error_patching
goto patching_fast_travel_100
:patching_fast_travel_49
if %custominstall_news_fore%==1 if %evcregion%==1 NewsChannelPatcher\sharpii.exe wad -p unpacked-temp/ "WAD\Forecast Channel (Europe) (Channel) (RiiConnect24).wad"
if %custominstall_news_fore%==1 	if %evcregion%==1 set /a temperrorlev=%errorlevel%
if %custominstall_news_fore%==1 	if %evcregion%==1 set modul=Packing Forecast Channel
if %custominstall_news_fore%==1 	if %evcregion%==1 if not %temperrorlev%==0 goto error_patching
if %custominstall_news_fore%==1 if %evcregion%==2 NewsChannelPatcher\sharpii.exe wad -p unpacked-temp/ "WAD\Forecast Channel (USA) (Channel) (RiiConnect24).wad"
if %custominstall_news_fore%==1 	if %evcregion%==2 set /a temperrorlev=%errorlevel%
if %custominstall_news_fore%==1 	if %evcregion%==2 set modul=Packing Forecast Channel
if %custominstall_news_fore%==1 	if %evcregion%==2 if not %temperrorlev%==0 goto error_patching
set /a progress_news_fore=1
goto patching_fast_travel_100

::EVC Patcher
:patching_fast_travel_50
if %custominstall_evc%==1 if not exist 0001000148414A50v512 md 0001000148414A50v512
if %custominstall_evc%==1 if not exist 0001000148414A45v512 md 0001000148414A45v512
if %custominstall_evc%==1 if not exist 0001000148414A50v512\cetk copy /y "EVCPatcher\dwn\0001000148414A50v512\cetk" "0001000148414A50v512\cetk"

if %custominstall_evc%==1 if not exist 0001000148414A45v512\cetk copy /y "EVCPatcher\dwn\0001000148414A45v512\cetk" "0001000148414A45v512\cetk"

goto patching_fast_travel_100
::USA
:patching_fast_travel_52
if %custominstall_evc%==1 if %evcregion%==2 call EVCPatcher\dwn\sharpii.exe NUSD -ID 0001000148414A45 -v 512 -encrypt >NUL
::PAL
if %custominstall_evc%==1 if %evcregion%==1 call EVCPatcher\dwn\sharpii.exe NUSD -ID 0001000148414A50 -v 512 -encrypt >NUL
if %custominstall_evc%==1 set /a temperrorlev=%errorlevel%
if %custominstall_evc%==1 set modul=Downloading EVC
if %custominstall_evc%==1 if not %temperrorlev%==0 goto error_patching
goto patching_fast_travel_100
:patching_fast_travel_54
if %custominstall_evc%==1 if %evcregion%==1 copy /y "EVCPatcher\NUS_Downloader_Decrypt.exe" "0001000148414A50v512"
if %custominstall_evc%==1 if %evcregion%==2 copy /y "EVCPatcher\NUS_Downloader_Decrypt.exe" "0001000148414A45v512"
if %custominstall_evc%==1 set /a temperrorlev=%errorlevel%
if %custominstall_evc%==1 set modul=Copying NDC.exe
if %custominstall_evc%==1 if not %temperrorlev%==0 goto error_patching
goto patching_fast_travel_100
:patching_fast_travel_56
if %custominstall_evc%==1 if %evcregion%==1 ren "0001000148414A50v512\tmd.512" "tmd"
if %custominstall_evc%==1 if %evcregion%==2 ren "0001000148414A45v512\tmd.512" "tmd"
if %custominstall_evc%==1 set /a temperrorlev=%errorlevel%
if %custominstall_evc%==1 set modul=Renaming files [Delete everything except RiiConnect24Patcher.bat]
if %custominstall_evc%==1 if not %temperrorlev%==0 goto error_patching
goto patching_fast_travel_100
:patching_fast_travel_57
if %custominstall_evc%==1 if %evcregion%==1 cd 0001000148414A50v512
if %custominstall_evc%==1 if %evcregion%==1 call NUS_Downloader_Decrypt.exe >NUL
if %custominstall_evc%==1 if %evcregion%==2 cd 0001000148414A45v512
if %custominstall_evc%==1 if %evcregion%==2 call NUS_Downloader_Decrypt.exe >NUL
if %custominstall_evc%==1 set /a temperrorlev=%errorlevel%
if %custominstall_evc%==1 set modul=Decrypter error
if %custominstall_evc%==1 if not %temperrorlev%==0 cd..& goto error_patching
if %custominstall_evc%==1 cd..
goto patching_fast_travel_100
:patching_fast_travel_60
if %custominstall_evc%==1 if %evcregion%==1 move /y "0001000148414A50v512\HAJP.wad" "EVCPatcher\pack"
if %custominstall_evc%==1 if %evcregion%==2 move /y "0001000148414A45v512\HAJE.wad" "EVCPatcher\pack"
if %custominstall_evc%==1 set /a temperrorlev=%errorlevel%
if %custominstall_evc%==1 set modul=move.exe
if %custominstall_evc%==1 if not %temperrorlev%==0 goto error_patching
goto patching_fast_travel_100
:patching_fast_travel_62
if %custominstall_evc%==1 if %evcregion%==1 call EVCPatcher\pack\Sharpii.exe WAD -u EVCPatcher\pack\HAJP.wad EVCPatcher\pack\unencrypted >NUL
if %custominstall_evc%==1 if %evcregion%==2 call EVCPatcher\pack\Sharpii.exe WAD -u EVCPatcher\pack\HAJE.wad EVCPatcher\pack\unencrypted >NUL
goto patching_fast_travel_100
:patching_fast_travel_63
if %custominstall_evc%==1 move /y "EVCPatcher\pack\unencrypted\00000001.app" "00000001.app"
if %custominstall_evc%==1 set /a temperrorlev=%errorlevel%
if %custominstall_evc%==1 set modul=move.exe
if %custominstall_evc%==1 if not %temperrorlev%==0 goto error_patching
goto patching_fast_travel_100
:patching_fast_travel_65
if %custominstall_evc%==1 if %evcregion%==1 call EVCPatcher\patch\xdelta3.exe -f -d -s 00000001.app EVCPatcher\patch\Europe.delta EVCPatcher\pack\unencrypted\00000001.app
if %custominstall_evc%==1 if %evcregion%==2 call EVCPatcher\patch\xdelta3.exe -f -d -s 00000001.app EVCPatcher\patch\USA.delta EVCPatcher\pack\unencrypted\00000001.app
if %custominstall_evc%==1 set /a temperrorlev=%errorlevel%
if %custominstall_evc%==1 set modul=xdelta.exe EVC
if %custominstall_evc%==1 if not %temperrorlev%==0 goto error_patching
goto patching_fast_travel_100
:patching_fast_travel_67
if %custominstall_evc%==1 if %evcregion%==1 call EVCPatcher\pack\Sharpii.exe WAD -p "EVCPatcher\pack\unencrypted" "WAD\Everybody Votes Channel (Europe) (Channel) (RiiConnect24)" -f 
if %custominstall_evc%==1 if %evcregion%==2 call EVCPatcher\pack\Sharpii.exe WAD -p "EVCPatcher\pack\unencrypted" "WAD\Everybody Votes Channel (USA) (Channel) (RiiConnect24)" -f
if %custominstall_evc%==1 set /a temperrorlev=%errorlevel%
if %custominstall_evc%==1 set modul=Packing EVC WAD
if %custominstall_evc%==1 set /a progress_evc=1
if %custominstall_evc%==1 if not %temperrorlev%==0 goto error_patching
goto patching_fast_travel_100

::CMOC
:patching_fast_travel_68
if %custominstall_cmoc%==1 if not exist 0001000148415050v512 md 0001000148415050v512
if %custominstall_cmoc%==1 if not exist 0001000148415045v512 md 0001000148415045v512
if %custominstall_cmoc%==1 if not exist 0001000148415050v512\cetk copy /y "CMOCPatcher\dwn\0001000148415050v512\cetk" "0001000148415050v512\cetk"

if %custominstall_cmoc%==1 if not exist 0001000148415045v512\cetk copy /y "CMOCPatcher\dwn\0001000148415045v512\cetk" "0001000148415045v512\cetk"

goto patching_fast_travel_100
::USA
:patching_fast_travel_70
if %custominstall_cmoc%==1 if %evcregion%==2 call CMOCPatcher\dwn\sharpii.exe NUSD -ID 0001000148415045 -v 512 -encrypt >NUL
::PAL
if %custominstall_cmoc%==1 if %evcregion%==1 call CMOCPatcher\dwn\sharpii.exe NUSD -ID 0001000148415050 -v 512 -encrypt >NUL
if %custominstall_cmoc%==1 set /a temperrorlev=%errorlevel%
if %custominstall_cmoc%==1 set modul=Downloading CMOC
if %custominstall_cmoc%==1 if not %temperrorlev%==0 goto error_patching
goto patching_fast_travel_100
:patching_fast_travel_71
if %custominstall_cmoc%==1 if %evcregion%==1 copy /y "CMOCPatcher\NUS_Downloader_Decrypt.exe" "0001000148415050v512"
if %custominstall_cmoc%==1 if %evcregion%==2 copy /y "CMOCPatcher\NUS_Downloader_Decrypt.exe" "0001000148415045v512"
if %custominstall_cmoc%==1 set /a temperrorlev=%errorlevel%
if %custominstall_cmoc%==1 set modul=Copying NDC.exe
if %custominstall_cmoc%==1 if not %temperrorlev%==0 goto error_patching
goto patching_fast_travel_100
:patching_fast_travel_72
if %custominstall_cmoc%==1 if %evcregion%==1 ren "0001000148415050v512\tmd.512" "tmd"
if %custominstall_cmoc%==1 if %evcregion%==2 ren "0001000148415045v512\tmd.512" "tmd"
if %custominstall_cmoc%==1 set /a temperrorlev=%errorlevel%
if %custominstall_cmoc%==1 set modul=Renaming files [Delete everything except RiiConnect24Patcher.bat]
if %custominstall_cmoc%==1 if not %temperrorlev%==0 goto error_patching

if %custominstall_cmoc%==1 if %evcregion%==1 cd 0001000148415050v512
if %custominstall_cmoc%==1 if %evcregion%==1 call NUS_Downloader_Decrypt.exe >NUL
if %custominstall_cmoc%==1 if %evcregion%==2 cd 0001000148415045v512
if %custominstall_cmoc%==1 if %evcregion%==2 call NUS_Downloader_Decrypt.exe >NUL
if %custominstall_cmoc%==1 set /a temperrorlev=%errorlevel%
if %custominstall_cmoc%==1 set modul=Decrypter error
if %custominstall_cmoc%==1 if not %temperrorlev%==0 cd..& goto error_patching
if %custominstall_cmoc%==1 cd..
goto patching_fast_travel_100
:patching_fast_travel_74
if %custominstall_cmoc%==1 if %evcregion%==1 move /y "0001000148415050v512\HAPP.wad" "CMOCPatcher\pack"
if %custominstall_cmoc%==1 if %evcregion%==2 move /y "0001000148415045v512\HAPE.wad" "CMOCPatcher\pack"
if %custominstall_cmoc%==1 set /a temperrorlev=%errorlevel%
if %custominstall_cmoc%==1 set modul=move.exe
if %custominstall_cmoc%==1 if not %temperrorlev%==0 goto error_patching
goto patching_fast_travel_100
:patching_fast_travel_75
if %custominstall_cmoc%==1 if %evcregion%==1 call CMOCPatcher\pack\Sharpii.exe WAD -u CMOCPatcher\pack\HAPP.wad CMOCPatcher\pack\unencrypted >NUL
if %custominstall_cmoc%==1 if %evcregion%==2 call CMOCPatcher\pack\Sharpii.exe WAD -u CMOCPatcher\pack\HAPE.wad CMOCPatcher\pack\unencrypted >NUL
goto patching_fast_travel_100
:patching_fast_travel_76
if %custominstall_cmoc%==1 move /y "CMOCPatcher\pack\unencrypted\00000001.app" "00000001.app"
if %custominstall_cmoc%==1 move /y "CMOCPatcher\pack\unencrypted\00000004.app" "00000004.app"
if %custominstall_cmoc%==1 set /a temperrorlev=%errorlevel%
if %custominstall_cmoc%==1 set modul=move.exe
if %custominstall_cmoc%==1 if not %temperrorlev%==0 goto error_patching
goto patching_fast_travel_100
:patching_fast_travel_77
if %custominstall_cmoc%==1 if %evcregion%==1 call CMOCPatcher\patch\xdelta3.exe -f -d -s 00000001.app CMOCPatcher\patch\00000001_Europe.delta CMOCPatcher\pack\unencrypted\00000001.app
if %custominstall_cmoc%==1 if %evcregion%==1 call CMOCPatcher\patch\xdelta3.exe -f -d -s 00000004.app CMOCPatcher\patch\00000004_Europe.delta CMOCPatcher\pack\unencrypted\00000004.app
if %custominstall_cmoc%==1 if %evcregion%==2 call CMOCPatcher\patch\xdelta3.exe -f -d -s 00000001.app CMOCPatcher\patch\00000001_USA.delta CMOCPatcher\pack\unencrypted\00000001.app
if %custominstall_cmoc%==1 if %evcregion%==2 call CMOCPatcher\patch\xdelta3.exe -f -d -s 00000004.app CMOCPatcher\patch\00000004_USA.delta CMOCPatcher\pack\unencrypted\00000004.app
if %custominstall_cmoc%==1 set /a temperrorlev=%errorlevel%
if %custominstall_cmoc%==1 set modul=xdelta.exe CMOC
if %custominstall_cmoc%==1 if not %temperrorlev%==0 goto error_patching
goto patching_fast_travel_100
:patching_fast_travel_79
if %custominstall_cmoc%==1 if %evcregion%==1 call CMOCPatcher\pack\Sharpii.exe WAD -p "CMOCPatcher\pack\unencrypted" "WAD\Mii Contest Channel (Europe) (Channel) (RiiConnect24)" -f 
if %custominstall_cmoc%==1 if %evcregion%==2 call CMOCPatcher\pack\Sharpii.exe WAD -p "CMOCPatcher\pack\unencrypted" "WAD\Check Mii Out Channel (USA) (Channel) (RiiConnect24)" -f
if %custominstall_cmoc%==1 set /a temperrorlev=%errorlevel%
if %custominstall_cmoc%==1 set modul=Packing CMOC WAD
if %custominstall_cmoc%==1 set /a progress_cmoc=1
if %custominstall_cmoc%==1 if not %temperrorlev%==0 goto error_patching
goto patching_fast_travel_100

::NC

:patching_fast_travel_81
if %custominstall_nc%==1 if not exist 0001000148415450v1792 md 0001000148415450v1792
if %custominstall_nc%==1 if not exist 0001000148415445v1792 md 0001000148415445v1792
if %custominstall_nc%==1 if not exist 0001000148415450v1792\cetk copy /y "NCPatcher\dwn\0001000148415450v1792\cetk" "0001000148415450v1792\cetk"

if %custominstall_nc%==1 if not exist 0001000148415445v1792\cetk copy /y "NCPatcher\dwn\0001000148415445v1792\cetk" "0001000148415445v1792\cetk"

:patching_fast_travel_85
::USA
if %custominstall_nc%==1 if %evcregion%==2 call NCPatcher\dwn\sharpii.exe NUSD -ID 0001000148415445 -v 1792 -encrypt >NUL
::PAL
if %custominstall_nc%==1 if %evcregion%==1 call NCPatcher\dwn\sharpii.exe NUSD -ID 0001000148415450 -v 1792 -encrypt >NUL
if %custominstall_nc%==1 set /a temperrorlev=%errorlevel%
if %custominstall_nc%==1 set modul=Downloading NC
if %custominstall_nc%==1 if not %temperrorlev%==0 goto error_patching
goto patching_fast_travel_100
:patching_fast_travel_86
if %custominstall_nc%==1 if %evcregion%==1 copy /y "NCPatcher\NUS_Downloader_Decrypt.exe" "0001000148415450v1792"
if %custominstall_nc%==1 if %evcregion%==2 copy /y "NCPatcher\NUS_Downloader_Decrypt.exe" "0001000148415445v1792"
if %custominstall_nc%==1 set /a temperrorlev=%errorlevel%
if %custominstall_nc%==1 set modul=Copying NDC.exe
if %custominstall_nc%==1 if not %temperrorlev%==0 goto error_patching
goto patching_fast_travel_100
:patching_fast_travel_87
if %custominstall_nc%==1 if %evcregion%==1 ren "0001000148415450v1792\tmd.1792" "tmd"
if %custominstall_nc%==1 if %evcregion%==2 ren "0001000148415445v1792\tmd.1792" "tmd"
if %custominstall_nc%==1 set /a temperrorlev=%errorlevel%
if %custominstall_nc%==1 set modul=Renaming files
if %custominstall_nc%==1 if not %temperrorlev%==0 goto error_patching
goto patching_fast_travel_100
:patching_fast_travel_88
if %custominstall_nc%==1 if %evcregion%==1 cd 0001000148415450v1792
if %custominstall_nc%==1 if %evcregion%==1 call NUS_Downloader_Decrypt.exe >NUL
if %custominstall_nc%==1 if %evcregion%==2 cd 0001000148415445v1792
if %custominstall_nc%==1 if %evcregion%==2 call NUS_Downloader_Decrypt.exe >NUL
if %custominstall_nc%==1 set /a temperrorlev=%errorlevel%
if %custominstall_nc%==1 set modul=Decrypter error
if %custominstall_nc%==1 if not %temperrorlev%==0 cd..& goto error_patching
if %custominstall_nc%==1 cd..
goto patching_fast_travel_100
:patching_fast_travel_89
if %custominstall_nc%==1 if %evcregion%==1 move /y "0001000148415450v1792\HATP.wad" "NCPatcher\pack"
if %custominstall_nc%==1 if %evcregion%==2 move /y "0001000148415445v1792\HATE.wad" "NCPatcher\pack"
if %custominstall_nc%==1 set /a temperrorlev=%errorlevel%
if %custominstall_nc%==1 set modul=move.exe
if %custominstall_nc%==1 if not %temperrorlev%==0 goto error_patching
goto patching_fast_travel_100
:patching_fast_travel_90
if %custominstall_nc%==1 if %evcregion%==1 call NCPatcher\pack\Sharpii.exe WAD -u NCPatcher\pack\HATP.wad NCPatcher\pack\unencrypted >NUL
if %custominstall_nc%==1 if %evcregion%==2 call NCPatcher\pack\Sharpii.exe WAD -u NCPatcher\pack\HATE.wad NCPatcher\pack\unencrypted >NUL
goto patching_fast_travel_100
:patching_fast_travel_93
if %custominstall_nc%==1 move /y "NCPatcher\pack\unencrypted\00000001.app" "00000001_NC.app"
if %custominstall_nc%==1 set /a temperrorlev=%errorlevel%
if %custominstall_nc%==1 set modul=move.exe
if %custominstall_nc%==1 if not %temperrorlev%==0 goto error_patching
goto patching_fast_travel_100
:patching_fast_travel_94
if %custominstall_nc%==1 if %evcregion%==1 call NCPatcher\patch\xdelta3.exe -f -d -s 00000001_NC.app NCPatcher\patch\Europe.delta NCPatcher\pack\unencrypted\00000001.app
if %custominstall_nc%==1 if %evcregion%==2 call NCPatcher\patch\xdelta3.exe -f -d -s 00000001_NC.app NCPatcher\patch\USA.delta NCPatcher\pack\unencrypted\00000001.app
if %custominstall_nc%==1 set /a temperrorlev=%errorlevel%
if %custominstall_nc%==1 set modul=xdelta.exe NC
if %custominstall_nc%==1 if not %temperrorlev%==0 goto error_patching
goto patching_fast_travel_100
:patching_fast_travel_95
if %custominstall_nc%==1 if %evcregion%==1 call NCPatcher\pack\Sharpii.exe WAD -p "NCPatcher\pack\unencrypted" "WAD\Nintendo Channel (Europe) (Channel) (RiiConnect24)" -f 
if %custominstall_nc%==1 if %evcregion%==2 call NCPatcher\pack\Sharpii.exe WAD -p "NCPatcher\pack\unencrypted" "WAD\Nintendo Channel (USA) (Channel) (RiiConnect24)" -f
if %custominstall_nc%==1 set /a temperrorlev=%errorlevel%
if %custominstall_nc%==1 set modul=Packing NC WAD
if %custominstall_nc%==1 if not %temperrorlev%==0 goto error_patching
if %custominstall_nc%==1 set /a progress_nc=1
goto patching_fast_travel_100

::Final commands
:patching_fast_travel_98
if not %sdcard%==NUL set /a errorcopying=0
if not %sdcard%==NUL if not exist "%sdcard%:\WAD" md "%sdcard%:\WAD"
if not %sdcard%==NUL if not exist "%sdcard%:\apps" md "%sdcard%:\apps"
goto patching_fast_travel_100

:patching_fast_travel_99
echo.&echo Don't worry^^! It might take some time... Now copying files to your SD Card...
if not %sdcard%==NUL xcopy /y "WAD" "%sdcard%:\WAD" /e|| set /a errorcopying=1
if not %sdcard%==NUL xcopy /y "apps" "%sdcard%:\apps" /e|| set /a errorcopying=1

if exist 0001000148415045v512 rmdir /s /q 0001000148415045v512
if exist 0001000148415050v512 rmdir /s /q 0001000148415050v512

if exist 0001000148414A45v512 rmdir /s /q 0001000148414A45v512
if exist 0001000148414A50v512 rmdir /s /q 0001000148414A50v512
if exist 0001000148415450v1792 rmdir /s /q 0001000148415450v1792
if exist 0001000148415445v1792 rmdir /s /q 0001000148415445v1792 
if exist unpacked-temp rmdir /s /q unpacked-temp
if exist IOSPatcher rmdir /s /q IOSPatcher
if exist EVCPatcher rmdir /s /q EVCPatcher
if exist NCPatcher rmdir /s /q NCPatcher
if exist CMOCPatcher rmdir /s /q CMOCPatcher
if exist NewsChannelPatcher rmdir /s /q NewsChannelPatcher
del /q 00000001.app
del /q 0001000248414650v7.wad
del /q 0001000248414645v7.wad
del /q 0001000248414750v7.wad
del /q 0001000248414745v7.wad
del /q 00000004.app
del /q 00000001_NC.app
set /a progress_finishing=1
goto patching_fast_travel_100


:patching_fast_travel_100

if %percent%==100 if %dolphin%==1 goto 2_install_dolphin_3
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
set /p s=Choose: 
if %s%==1 goto script_start
if %s%==2 goto end
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
