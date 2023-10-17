@echo off
setlocal enableextensions
setlocal DisableDelayedExpansion
cd /d "%~dp0"

set /a conhost_enable=0
ver | C:\Windows\system32\findstr.exe "10.0">NUL && set /a conhost_enable=1

if %conhost_enable%==1 if not "%1"=="-conhost" (
	start conhost.exe "%~dpnx0" -conhost
	exit /b 0
	)


set currentPath=%cd%

echo 	Starting up...
echo	The program is starting...

:: ===========================================================================
:: RiiConnect24 Patcher for Windows
set version=1.5.2
:: AUTHORS: KcrPL
:: ***************************************************************************
:: Copyright (c) 2018-2023 KcrPL, RiiConnect24 and it's (Lead) Developers
:: ===========================================================================

if exist temp.bat del /q temp.bat
::if exist update_assistant.bat del /q update_assistant.bat
set /a preboot_environment=0
:script_start
:: Issue workarounds
set user_name=%userprofile:~9%
set mode_path=C:\Windows\system32\mode.com
set findstr_path=C:\Windows\system32\findstr.exe
set wmic_path=wmic
set timeout_path=C:\Windows\system32\timeout.exe
echo 	.. Setting up the variables


:: Window size (Lines, columns)
set mode=128,37
%mode_path% %mode%
set s=NUL

::Beta
set /a beta=0
::This variable controls if the current version of the patcher is in the stable or beta branch. It will change updating path.
:: 0 = stable  1 = beta



::
set /a internet_channel_enable=0
set /a photo_channel_enable=0
set /a wii_speak_channel_enable=0
set /a today_and_tomorrow_enable=0

set /a info_nothing_selected=0
set /a translation_download_error=0
set /a dolphin=0
set /a first_start_lang_load=1
set /a exitmessage=1
set /a errorcopying=0
set /a tempncpatcher=0
set /a tempiospatcher=0
set /a tempevcpatcher=0
set /a tempsdcardapps=0
set /a wiimmfi_patcher_backup=0
set /a wiiu_return=0
set /a sdcardstatus=0
set /a troubleshoot_auto_tool_notification=0
set /a wiiware_patching=0
set sdcard=NUL
set tempgotonext=begin_main
set direct_install_del_done=0
set direct_install_bulk_files_error=0
set error_changing_language=0
set /a sdcard_refresh_pending=0
set sound_enable=1

set free_drive_space_bytes=9999999999
set free_sd_card_space_bytes=9999999999

:: Free space requirements
	set cd_temp=%cd%
	set running_on_drive=%cd_temp:~0,1%
	
	:: RiiConnect24 Patching for Wii (in MB)
	set wii_patching_requires=700
		set /a size1=%wii_patching_requires%*1024
		set /a patching_size_required_wii_bytes=%size1%*1024

	:: RiiConnect24 Patching for Wii U (in MB)
	set wiiu_patching_requires=630
		set /a size1=%wiiu_patching_requires%*1024
		set /a patching_size_required_wiiu_bytes=%size1%*1024

	:: RiiConnect24 Patching for Wii - SD Card Size Requirement (in MB)
	set wii_sd_card_copy_requires=230	
		set /a size1=%wii_sd_card_copy_requires%*1024
		set /a patching_size_required_wii_sd_card=%size1%*1024


For /F "Delims=" %%A In ('ver') do set "windows_version=%%A"

set post_url=https://patcher.rc24.xyz/v1/reporting.php

set mm=0
set ss=0
set cc=0
set hh=0

:: Window Title
if %beta%==0 set title=RiiConnect24 Patcher v%version% Created by @KcrPL
if %beta%==1 set title=RiiConnect24 Patcher v%version% [BETA] Created by @KcrPL

title %title%

set last_build=2023/01/08
set at=11:44 CET
:: ### Auto Update ###
:: 1=Enable 0=Disable
:: Update_Activate - If disabled, patcher will not even check for updates, default=1
:: offlinestorage - Only used while testing of Update function, default=0
:: FilesHostedOn - The website and path to where the files are hosted. WARNING! DON'T END WITH "/"
:: MainFolder/TempStorage - folder that is used to keep version.txt and whatsnew.txt. These two files are deleted every startup but if offlinestorage will be set 1, they won't be deleted.
set /a Update_Activate=1
set /a offlinestorage=0
if %beta%==0 set FilesHostedOn=https://patcher.rc24.xyz/update/RiiConnect24-Patcher/v1
if %beta%==1 set FilesHostedOn=https://patcher.rc24.xyz/update/RiiConnect24-Patcher_BETA/v1


if "%1"=="-preboot" set /a preboot_environment=1

:: Other patchers repositories


set FilesHostedOn_Beta=https://patcher.rc24.xyz/update/RiiConnect24-Patcher_BETA/v1
set FilesHostedOn_Stable=https://patcher.rc24.xyz/update/RiiConnect24-Patcher/v1
set CheckNUS.Domain=http://ccs.cdn.sho.rc24.xyz
set useragent=--user-agent "RiiConnect24 Patcher Windows v%version%"


set MainFolder=%appdata%\RiiConnect24Patcher
set TempStorage=%appdata%\RiiConnect24Patcher\internet\temp

if exist "%TempStorage%" del /s /q "%TempStorage%">NUL
if exist "%TempStorage%\announcement" rmdir /s /q "%TempStorage%\announcement">NUL

if %beta%==0 set header=RiiConnect24 Patcher - (C) KcrPL v%version% (Updated on %last_build% at %at%)
if %beta%==1 set header=RiiConnect24 Patcher - (C) KcrPL v%version% [BETA] (Updated on %last_build% at %at%)

set header_for_loops=RiiConnect24 Patcher - KcrPL v%version% - Updated on %last_build% at %at%

if not exist "%MainFolder%" md "%MainFolder%"
if not exist "%TempStorage%" md "%TempStorage%"

:: Trying to prevent running from OS that is not Windows.
if not "%os%"=="Windows_NT" goto not_windows_nt


:: Generate random identifier
if not exist "%MainFolder%\random_ident.txt" (
	call :generate_identifier
	Setlocal DisableDelayedExpansion
	)


:: Read random identifier
if exist "%MainFolder%\random_ident.txt" for /f "usebackq" %%a in ("%MainFolder%\random_ident.txt") do set random_identifier=%%a

:: Load background color from file if it exists
if exist "%MainFolder%\background_color.txt" for /f "usebackq" %%a in ("%MainFolder%\background_color.txt") do color %%a


:: Load sound setting
if not exist "%MainFolder%\sound_enable.txt" >"%MainFolder%\sound_enable.txt" echo 1
if exist "%MainFolder%\sound_enable.txt" for /f "usebackq" %%a in ("%MainFolder%\sound_enable.txt") do set sound_enable=%%a


:: Check if can use chcp 65001
set /a chcp_enable=0
if %preboot_environment%==1 set /a chcp_enable=1

::if %preboot_environment%==0 ver | findstr "6.3">NUL && set /a chcp_enable=1
if %preboot_environment%==0 ver | %findstr_path% "10.0">NUL && set /a chcp_enable=1

::if %chcp_enable%==1 chcp 65001>NUL

goto script_start_languages

:generate_identifier
	set lengthnumberuser=6
    Setlocal EnableDelayedExpansion
    Set _RNDLength=%lengthnumberuser%
    Set _Alphanumeric=ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789
    Set _Str=%_Alphanumeric%987654321
:_LenLoop
    IF NOT "%_Str:~18%"=="" SET _Str=%_Str:~9%& SET /A _Len+=9& GOTO :_LenLoop
    SET _tmp=%_Str:~9,1%
    SET /A _Len=_Len+_tmp
    Set _count=0
    SET _RndAlphaNum=
:_loop
    Set /a _count+=1
    SET _RND=%Random%
    Set /A _RND=_RND%%%_Len%
    SET _RndAlphaNum=!_RndAlphaNum!!_Alphanumeric:~%_RND%,1!
    If !_count! lss %_RNDLength% goto _loop
	echo !_RndAlphaNum!>"%MainFolder%\random_ident.txt"
	Setlocal DisableDelayedExpansion
	exit /b

:check_rc24_server_connection
call curl -f -L -s %useragent% --insecure "https://patcher.rc24.xyz/connection_test.txt">NUL
	set /a temperrorlev=%errorlevel%

	if not "%temperrorlev%"=="0" exit /b 1

exit /b 0
:server_connection_lost
cls
echo %header%
set sound_play=warning3&call :sound_play
echo -----------------------------------------------------------------------------------------------------------------------------
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
echo.
echo ---------------------------------------------------------------------------------------------------------------------------
echo    /---\   %string73%
echo   /     \  %string586%
echo  /   ^!   \ %string587%
echo  --------- 
echo.
echo            %string90%
echo ---------------------------------------------------------------------------------------------------------------------------
pause>NUL
goto begin_main

:script_start_languages
setlocal disableDelayedExpansion
:: Detect Language
FOR /F "tokens=2 delims==" %%a IN ('%wmic_path% os get OSLanguage /Value') DO set OSLanguage=%%a
:: Load English
set language=English
call :set_language_english

:: Detect Language
if "%OSLanguage%"=="1046" set language=pt-BR
if "%OSLanguage%"=="1045" set language=pl-PL
if "%OSLanguage%"=="1040" set language=it-IT
if "%OSLanguage%"=="3082" set language=es-ES
if "%OSLanguage%"=="1053" set language=sv-SE
if "%OSLanguage%"=="1031" set language=de-DE
if "%OSLanguage%"=="1038" set language=hu-HU
if "%OSLanguage%"=="1036" set language=fr-FR
if "%OSLanguage%"=="1043" set language=nl-NL
if "%OSLanguage%"=="2052" set language=zh-CN
if "%OSLanguage%"=="1041" set language=ja-JP
if "%OSLanguage%"=="1055" set language=tr-TR
if "%OSLanguage%"=="1048" set language=ro-RO

:: Contact server, download up to date translation and load it.
	set /a online_download_ok=0

if %chcp_enable%==1 (
	echo .. Downloading the latest translation file...
	curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/UPDATE/Translation_Files/Language_%language%.bat" --output "%TempStorage%\Language_%language%.bat"
	if %errorlevel%==0 set /a online_download_ok=1
)
if %chcp_enable%==0 (
	echo .. Downloading the latest translation file...
	curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/UPDATE/Translation_Files_CHCP_OFF/Language_%language%.bat" --output "%TempStorage%\Language_%language%.bat"
	if %errorlevel%==0 set /a online_download_ok=1
)

	if %online_download_ok%==1 (
		if exist "%TempStorage%\Language_%language%.bat" echo .. Applying latest online translation...
		if %chcp_enable%==1 if exist "%TempStorage%\Language_%language%.bat" call "%TempStorage%\Language_%language%.bat" -chcp
		if %chcp_enable%==0 if exist "%TempStorage%\Language_%language%.bat" call "%TempStorage%\Language_%language%.bat"
		if %online_download_ok%==1 set /a local_load=0
		)
		
goto script_start_languages_2
:reload_language
	set /a online_download_ok=0
	echo.

if %chcp_enable%==1 (
	echo .. Downloading the latest translation file...
	curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/UPDATE/Translation_Files/Language_%language%.bat" --output "%TempStorage%\Language_%language%.bat"
	if %errorlevel%==0 set /a online_download_ok=1
)
if %chcp_enable%==0 (
	echo .. Downloading the latest translation file...
	curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/UPDATE/Translation_Files_CHCP_OFF/Language_%language%.bat" --output "%TempStorage%\Language_%language%.bat"
	if %errorlevel%==0 set /a online_download_ok=1
)

	if %online_download_ok%==0 (
	set /a error_changing_language=1
	goto online_download_ok
	)

	if %online_download_ok%==1 (
	
		call :set_language_english
		
		if exist "%TempStorage%\Language_%language%.bat" echo .. Applying latest online translation...
		if %chcp_enable%==1 if exist "%TempStorage%\Language_%language%.bat" call "%TempStorage%\Language_%language%.bat" -chcp
		if %chcp_enable%==0 if exist "%TempStorage%\Language_%language%.bat" call "%TempStorage%\Language_%language%.bat"
		)
		
goto begin_main
:script_start_languages_2
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

:set_language_english
echo .. Loading language: English...

:: Should be available locally
set string1=RiiConnect your Wii.
set string2=Start
set string3=Credits
set string4=Settings
set string588=Troubleshooting
set string5=manage VFF Downloader for Dolphin here
set string6=Run the VFF Downloader once.
set string7=Do you have problems or want to contact us?
set string8=Mail us at support@riiconnect24.net
set string9=Detected Wii SD Card:
set string10=Could not detect your Wii SD Card.
set string11=Refresh
set string12=If incorrect, you can change later.

set string13=Warning
set string14=You are using an experimental version of this program.
set string15=That means that this version might contain experimental features
set string16=and bugs that might break your Wii/Wii U console or your computer.
set string17=If you don't know what you're doing, please go to settings and go back to
set string18=stable branch of the patcher.

set string19=Type a number that you can see above next to the command and hit ENTER

set string20=Troubleshooting tools
set string21=These tools should help you diagnose some problems with the patcher and try to repair them automatically.
set string22=Could not detect SD Card.
set string23=Could not copy files to the SD Card.
set string24=Renaming files error
set string25=Return to main menu
set string26=Choose

set string27=RiiConnect24 Patcher Settings
set string28=Go back
set string29=Set background/text color
set string30=Turn off/on updating
set string31=Currently
set string32=Change updating branch to
set string33=Beta
set string34=Stable
set string35=Repair patcher file
set string36=Redownload
set string37=VFF Downloader for Dolphin Settings
set string38=Completely delete VFF Downloader for Dolphin from your computer
set string39=Delete VFF Downloader from startup
set string40=If VFF Downloader is running, shut it down.
set string41=Please wait... fetching data.
set string42=Do you want to go back to stable version of the patcher?
set string43=Current version
set string44=Stable version
set string45=Sorry, there was an error while fetching data.
set string46=Do you want to switch branches?
set string47=Updating process will start.
set string48=Yes, switch to Stable branch.
set string49=[UNABLE TO SWITCH TO STABLE VERSION]
set string50=No, go back to main menu.
set string51=Do you want to switch to BETA version of the patcher?
set string52=Beta version
set string53=Sorry, there's currently no public beta version available.
set string54=Yes, switch to Beta branch.
set string55=[UNABLE TO SWITCH TO BETA VERSION]
set string589=Enable sounds


set string56=WAIT
set string57=Are you trying to disable updating?
set string58=Please do remember that updates will keep you safe and updated about the patcher.
set string59=Only use this option for debugging and troubleshooting.
set string60=Are you sure that you want to disable autoupdating?

set string61=Yes
set string62=No, go back.

set string63=Change color:
set string64=Dark theme
set string65=Light theme *please don't hurt my eyes edition*
set string66=Light theme *please hurt my eyes edition*
set string67=Yellow
set string68=Green
set string69=Red
set string70=Blue

set string71=Downloading curl... Please wait.
set string72=This can take some time...

set string73=ERROR.
set string74=There was an error while downloading curl.
set string75=We will now open a website that will download curl.exe.
set string76=Please move curl.exe to the folder where RiiConnect24 Patcher is and restart the patcher.
set string77=Press any key to open download page in browser and to return to menu.

set string78=Checking for updates...
set string79=An Update is available.
set string80=An Update for this program is available. We suggest updating the RiiConnect24 Patcher to the latest version.
set string81=Current version
set string82=New version
set string83=Update
set string84=Dismiss
set string85=What's new in this update?
set string86=Updating.
set string87=Please wait...
set string88=RiiConnect24 Patcher will restart shortly...
set string89=There was an error while downloading the update assistant.
set string90=Press any key to return to main menu.
set string91=What's new in update
set string92=Error. What's new file is not available.
set string93=Press any button to go back.
:: Local end

:: Must be available online
set string100=Welcome to the Homebrew Shop.
set string101=Before downloading any homebrew, do you want to enable automatic installation on your SD Card?
set string102=Yes, detect the SD Card.
set string103=No, I'll install them manually.
set string104=Hmm... looks like an SD Card wasn't found in your system. Please choose the `Change drive letter` option
set string105=to set your SD Card drive letter manually.
set string106=Otherwise, you will have to copy the homebrew manually to the SD Card.
set string107=Congrats^^! I've successfully detected your SD Card^^! Drive letter:
set string108=I will be able to automatically download and install everything on your SD Card^^!
set string109=What's next?
set string110=Continue
set string111=Exit
set string112=Change drive letter
set string113=Current SD Card Letter
set string114=Type in the new drive letter (e.g H)
set string115=Preparing for use with Open Shop Channel downloader...
set string116=Please wait...
set string117=There was an error while downloading the Open Shop Channel downloader.
set string118=CURL Exit Code
set string119=Press any key to go back.
set string120=Open Shop Channel Downloader is ready^^! What next?
set string121=Show list of homebrew available.
set string122=Download homebrew.
set string123=Return to main menu
set string124=One second please...
set string125=TIP: Remember the name of the homebrew that you're interrested in, return to the program, select "Download homebrew" and type it in.
set string126=It will show you a description and some other useful info about homebrew that you've chosen.
set string127=List of homebrew available
set string128=Type the name of your homebrew.
set string129=is not available on the server.
set string130=For the list of homebrew that's on the server, please go back and choose "Show list of homebrew available".
set string131=Fetching data...
set string132=You requested...
set string133=Long description:
set string134=Would you like to download this app?
set string135=If enabled, it will be automatically installed to the SD Card.
set string136=No, return.
set string137=Downloading
set string138=Downloading .ZIP
set string139=Done^^!
set string140=The .ZIP file is in the directory where RiiConnect24 Patcher is.
set string141=Press any key to go back.
set string142=Downloading 7zip CLI
set string143=Extracting the homebrew app to your SD Card...
set string144=There was an error while downloading your homebrew.
set string145=There was an error while downloading the homebrew from Open Shop Channel servers.
set string146=There was an error while downloading 7zip.
set string147=There was an error while copying the files to your SD Card.

::
set string148=Announcement
set string149=Welcome to the RiiConnect24 Patcher^^!
set string150=With this program, you can patch your Wii or Wii U for use with RiiConnect24.
set string151=You can also use such tools as Wiimmfi Patcher for all Wii games to play them online again.
set string152=So, what device are we patching today?
set string153=Dolphin Emulator
set string154=Choose wisely

set string155=Which mode should I run
set string156=Install RiiConnect24 on your Dolphin Emulator
set string191=Install RiiConnect24 on your Wii U
set string273=Install RiiConnect24 on your Wii.
set string274=Uninstall RiiConnect24 from your Wii.
set string275=This will help you uninstall RiiConnect24 from your Wii.
set string157=The patcher will guide you through process of installing RiiConnect24
set string158=Other tools
set string159=Patch Wii WAD Games to work with Wiimmfi.
set string160=This will patch WAD Games (WiiWare) for use with Wiimmfi which will allow you to play online with other people.
set string163=Patch other Wii Games to work with Wiimmfi.
set string164=This will patch any other game than Mario Kart Wii to work with Wiimmfi.
set string165=Visit Homebrew Shop
set string166=Download and install homebrew on your SD Card using Open Shop Channel.
set string192=Install WAD files directly to the SD Card.
set string193=This will allow you to directly install a channel to your SD Card instead of you having to move it from NAND.

set string182=What region should I download?
set string183=Europe
set string184=USA
set string185=We're done^^! Now please open Dolphin, press on Tools and install the WAD file that has been downloaded to the WAD folder 
set string186=next to the RiiConnect24 Patcher.
set string187=That's it^^!
set string188=What to do next?
set string189=Return to main menu
set string190=Close the patcher

set string200=Install RiiConnect24 on your Wii U.
set string201=Choose installation type:
set string202=Express (Recommended)
set string203=This will patch every channel for later use on your Wii U. This includes:
set string204=News Channel
set string376=Forecast Channel
set string377=Wii Mail
set string205=Everybody Votes Channel
set string206=Nintendo Channel
set string207=Check Mii Out Channel / Mii Contest Channel
set string256=Mii Contest Channel
set string257=Check Mii Out Channel
set string208=Custom
set string209=You will be asked what you want to patch.
set string210=Install RiiConnect24
set string211=Switch region. Current region:
set string212=Begin patching^^!
set string213=Go back.

set string214=Hello
set string215=welcome to the express instalation of RiiConnect24.
set string216=The patcher will download any files that are required to run the patcher.
set string217=The entire process should take about 1 to 3 minutes depending on your computer CPU and internet speed.
set string218=But before starting, you need to tell me one thing:
set string219=For
set string220=and
set string221=which region should I download and patch?
set string222=(Where do you live?/Region of your console)
set string223=Choose one
set string224=Great^^!
set string225=After passing this screen, any user interraction won't be needed so you can relax and let me do the work^^!
set string226=Did I forget about something? Yes^^! To make patching even easier, I can download everything that you need and put it on
set string227=your SD Card^^!
set string228=Please connect your Wii U SD Card to the computer.
set string229=Connected^^!
set string230=I can't connect an SD Card to the computer.
set string231=Aww, no worries. You will be able to copy files later after patching.
set string232=Hmm... looks like an SD Card wasn't found in your system. Please choose the `Change drive letter` option
set string233=to set your SD Card drive letter manually.
set string234=Otherwise, starting patching will set copying to manual so you will have to copy them later.
set string235=Congrats^^! I've successfully detected your SD Card^^! Drive letter:
set string236=I will be able to automatically download and install everything on your SD Card^^!
set string237=Everything is ready^^!
set string238=What's next?
set string239=Start Patching
set string240=Exit
set string241=Change drive letter
set string242=One more thing^^! I've detected WAD folder.
set string243=I need to delete it.
set string244=Can I?
set string245=Yes
set string246=No
set string247=Patching... this can take some time depending on the processing speed (CPU) of your computer.
set string248=Warning: There was an error while patching, but the patcher ran the troubleshooting tool that should automatically fix
set string249=the problem. The patching process has been restarted.
set string250=Fun Fact
set string251=Next fun fact in
set string252=sec
set string253=Progress
set string254=Downloading files
set string258=Finishing...

set string259=Alright^^! We're done with that^^!
set string260=Copying successful^^! Every file is on your SD Card.
set string261=Wha- Something failed^^! Please copy "WAD", "apps" and "wiiu" folders to your SD Card. They're next to RiiConnect24Patcher.bat
set string262=Please connect your Wii U's SD Card to the computer and copy "WAD", "apps" and "wiiu" folder to it.
set string263=We're nearly done^^!
set string264=We're now about to patch a file that's responsible for the 4:3 black bars bug that appears on Wii mode.
set string265=Now, please connect the SD Card to your Wii U, enter vWii, open Homebrew Launcher.
set string266=On the list, please find ww-43db-patcher (WiiWare 4:3 DB Patcher) and run it.
set string267=Press any button to continue.
set string268=Patching done^^!
set string269=You can now continue with the guide.
set string270=What to do next?
set string271=Return to main menu
set string272=Close the patcher

set string276=Install WAD files directly to the SD Card - wad2bin.
set string277=Created by DarkMatterCore.
set string278=Welcome
set string279=This is a configuration screen for wad2bin. You will be required to do this step only once.
set string280=Since every Wii is different, you will be required to dump keys from your Wii. It sounds scary but no worries because we've
set string281=prepared everything for you.
set string282=Please connect your Wii's SD Card to your computer.
set string283=Connected.
set string284=I can't connect the SD Card.
set string285=Unfortunately, without direct access to the SD Card, not much can be done.
set string286=Please find a way to connect the SD Card to your computer and please come back here later.
set string287=Press any key to go back to main menu.
set string288=Cannot continue until you set the path.
set string289=We can now continue.
set string290=Connected, scan again
set string291=Please wait... I'm currently installing xyzzy-mod on your SD Card.
set string292=There was an error while downloading xazzy-mod to your  SD Card.
set string293=Please try again.
set string294=Press any key to go back.
set string295=Alright^^! I've successfully installed xyzzy-mod on your SD Card. I will remove it once this step is done.
set string296=Now, please connect the SD Card to your Wii and launch xyzzy-mod from your Homebrew Channel.
set string297=(You should find it on the last page)
set string298=Please select the device as SD Card and please wait for the results.
set string299=Once it's done, please plug the SD Card here.
set string300=Is it done?
set string301=Yes, the SD Card is connected.
set string302=Exit.
set string303=There was an error while detecting the files.
set string304=Are you sure you followed the instructions correctly?
set string305=Try copying the files again.
set string306=Go back.
set string307=Alright^^! We're done with the configuration.
set string308=That wasn't so hard, was it?
set string309=Press any key to continue.
set string310=Could not find your Wii's SD Card.
set string311=Please plug it in now.
set string312=Set the drive letter manually.
set string313=I'm downloading wad2bin...
set string314=There was an error while downloading wad2bin...
set string315=What can I get you?
set string316=Deleting "bogus" WAD files is done^^!
set string317=Install WAD files on your SD Card.
set string318=Install DLC's for Just Dance, Rock Band or Guitar Hero. (Not yet done...)
set string319=Reconfigure keys (use this when changing a Wii etc.)
set string320=Delete all "bogus" WAD files from your SD Card.
set string321=Main Menu.
set string322=Could not find any .WAD files inside wad2bin folder.
set string323=We're now going to install WAD files to your SD Card.
set string324=I created a folder called wad2bin next to the RiiConnect24 Patcher.bat. Please put all of the files that you want to
set string325=install in that folder.
set string326=NOTE: Some DLC files might result in an error.
set string327=Are the files all in place?
set string328=Yes, start installing.
set string329=No, go back.
set string330=Instaling file
set string331=out of
set string332=File name
set string333=Installation complete^^! 
set string334=Now, please start your WAD Manager (Wii Mod Lite, if you installed RiiConnect24) and please install the WAD file called
set string335=(numbers)_bogus.wad on your Wii.
set string336=NOTE: You will get a -1022 error - don't worry! The WAD is empty but all we need is the TMD and ticket.
set string337=After you're done installing the WAD, you can later plug in the SD Card in and choose the option to delete bogus WAD's
set string338=in the main menu.
set string339=Are you sure you want to delete all bogus files?
set string340=If you still didn't install them, you won't be able to open any installed channels by you.
set string341=Are you sure you want to delete them?
set string342=Installing WAD file(s) has failed.
set string343=wad2bin returned error code
set string344=Please contact KcrPL#4625 on Discord or mail us at support@riiconnect24.net
set string345=Go back to wad2bin menu.
set string346=Show error info.

set string347=Preparing for use with Wiimmfi Patcher...
set string348=Please wait...
set string349=Wiimmfi Patcher is ready^^!
set string350=Please the game image (can be ISO or WBFS) in a folder where RiiConnect24 Patcher is and choose "Ready".
set string351=ISO Files
set string352=WBFS Files
set string353=Found
set string354=Not Found
set string355=Ready. Start Wiimmfi Patcher.
set string356=Go back to Main Menu.
set string357=The Wiimmfi Patcher is done^^!
set string358=The patched game image file(s) has been moved to the wiimmfi-images folder next to RiiConnect24 Patcher.
set string359=Press any button to go back to main menu.
set string360=Preparing for use with Mario Kart Wii Wiimmfi Patcher...
set string361=Mario Kart Wii Wiimmfi Patcher is ready^^!
set string362=Please put the Mario Kart Wii image file (can be ISO or WBFS) in a folder where RiiConnect24 Patcher is and choose "Ready".
set string363=Ready. Start Mario Kart Wii Patcher.
set string364=The patched Mario Kart Wii image file has been copied to the wiimmfi-images folder next to RiiConnect24 Patcher.
set string365=Preparing for use with WiiWare Patcher...
set string368=Moving files... please wait.
set string369=WiiWare Patcher has exited...
set string370=If the files were patched, you can find the patched .WAD files in the wiimmfi-wads folder next to the RiiConnect24 Patcher.
set string371=Press any button to return to main menu.

set string372=If you are doing troubleshooting, please keep that in mind that reinstalling RiiConnect24 probably won't help you
set string373=Please contact RiiConnect24 Developers at support@riiconnect24.net for more info.
set string374=This part of this patcher will help you uninstalling RiiConnect24 from your Wii.
set string375=By completing these steps you will lose access to:
set string378=If you have other channels installed on your Wii, you will have to uninstall them manually.
set string379=Do you want to proceed with the guide?
set string380=Would you like to include tutorial with how to delete your nwc24msg.cfg file?
set string381=(This is a mail configuration file)
set string382=Would you like to ask us to delete your mail from our database?
set string383=(After deleting it from our database, you will be able to patch your Wii again in the future for RiiConnect24,
set string384= it is recommended to do that)
set string385=Yes, show me the instructions how to do that.
set string386=Please send a mail to support@riiconnect24.net with a request to delete you from our database.
set string387=With that email, please include a picture showing your Friend Code in the Address Book.
set string388=To do that, please open Wii Message Board -^> New Message -^> Address Book -^> Make a picture of your Friend Code and
set string389=please send it to us to make sure that you are the owner of the Friend Code.
set string390=By doing so, you will lose access to the RiiConnect24 Mailing system. You will be able to restore full functionality using
set string391=the RiiConnect24 Mail Patcher homebrew app on your Wii.
set string392=Press any key to continue...
set string393=After downloading all the files, do you want to copy them to your SD Card?
set string394=Please connect your Wii SD Card to the computer.
set string395=The entire patching process will download about 5MB of data.
set string396=Restoring default IOS's and downloading utilities...
set string397=Patching done^^! Now please follow these instructions:
set string398=Plaese copy the wad and apps folder next to the patcher to your SD Card.
set string399=Part I - Reinstalling stock IOS 31 and IOS 80
set string400=Please open Homebrew Channel and start Wii Mod Lite
set string401=Using the +Control Pad on your Wii Remote, navigate to WAD Manager, and then navigate to the WAD folder.
set string402=When IOS31.wad is highlighted, press +, then do the same for IOS80.wad and hit the A button.
set string403=When you're done, press the HOME Button to go back to Homebrew Channel.
set string404=What to do now?
set string405=Next page
set string406=Part II - Restoring the nwc24msg.cfg to it's factory default.
set string407=Please launch WiiXplorer from the Homebrew Channel.
set string408=In WiiXplorer, press Start -^> Settings -^> Boot Settings -^> NAND Write Access (turn on)
set string409=Remember to turn it on because it's important^^!
set string410=Change your device to NAND (on the bar on top)
set string411=Go to shared2 -^> wc24
set string412=Hover your cursor over nwc24msg.cfg, press + on your Wii Remote and delete it.
set string413=Go to Wii Menu (the nwc24msg.cfg file should regenerate with the same Friend Code)
set string414=Previous page
set string415=Part III - Disconnecting from RiiConnect24
set string416=Go to Wii Options.
set string417=Go to Wii Settings.
set string418=Go to Page 2, then click on Internet.
set string419=Go to Connection Settings.
set string420=Select your current connection.
set string421=Go to Change Settings.
set string422=Go to Auto-Obtain DNS (Not IP Address), then select Yes.
set string423=Select Save and do the connection test.
set string424=When asking for update, press No to skip it.
set string425=That's it^^! RiiConnect24 should be now gone from your Wii^^!
set string426=Please come back to us soon :)
set string427=Press any key to exit the patcher.

set string428=The Nintendo Update Server (NUS) is currently down. Patcher needs that server in order to work.
set string429=This probably means that there is a maintenance currently going on the server.
set string430=Please come back later^^!
set string431=Preparing...

set string432=Install RiiConnect24.
set string433=This will patch every channel for later use on your Wii. This includes:
set string434=IOS Patches [required for other channels to work]
set string435=Forecast/News Channel
set string436=Please connect your Wii SD Card to the computer.
set string437=The following process will download about 170MB of data.

set string438=Did you know the wii was the best selling game-console of 2006?
set string439=Did you know KcrPL makes these amazing patchers?
set string440=RiiConnect24 originally started out as "CustomConnect24"!
set string441=Did you know that the RiiConnect24 logo was made by NeoRame, the same person who made the Wiimmfi logo?
set string442=The Wii was nicknamed "Revolution" during its development stage.
set string443=Did you know the letters in the Wii model number RVL stand for the Wii's codename, Revolution?
set string444=The music used in many of the Wii's channels (including the Wii Shop, Mii, Check Mii Out, and Forecast Channel) was composed by Kazumi Totaka.
set string445=The Internet Channel once costed 500 Wii Points.
set string446=It's possible to use candles as a Wii Sensor Bar.
set string447=The blinking blue light that indicates a system message has been received is actually synced to the bird call of the Japanese bush warbler. More info about it on RiiConnect24 YouTube Channel^^!
set string448=Wii Sports is the most sold game on the Wii. It sold 82.85 million. Overall it is the 3rd most sold game in the world.
set string449=Did you know that most of the scripts used to make RiiConnect24 work are written in Python?
set string450=Thank you Spotlight for making our mail system secure.
set string451=Did you know that we have an awesome Discord server where you can always stay updated about the project status?
set string452=The Everybody Votes Channel was originally an idea about sending quizzes and questions daily to Wiis.
set string453=The News Channel developers had an idea at some point about making a dad's Mii being the news caster in the Channel, but it probably didn't make it because some stories on there probably aren't appropriate for kids.
set string454=The Everybody Votes Channel was originally called the Questionnaire Channel, then Citizens Vote Channel.
set string455=The Forecast Channel had a "laundry index" (to show how appropriate it is to dry your clothes outside) and a "pollen count" in the Japanese version.
set string456=During the Forecast Channel development, Nintendo's America department got hit by a thunderstorm, and the developers of the Channel in Japan lost contact with them.
set string457=During the News Channel development, Nintendo's Europe department got hit by a big rainstorm, and the developers of the Channel in Japan lost contact with them.
set string458=The News Channel has an alternate slide show song that plays as night.
set string459=During E3 2006, Satoru Iwata said WiiConnect24 uses as much power as a miniature lightbulb while the console is in standby.
set string460=The effect used when rapidly zooming in and out of photos on the Photo Channel was implemented into the News Channel to zoom in and out of text.
set string461=The help cats in the News Channel and the Photo Channel are brothers and sisters (the one in the News Channel being male, and the Photo Channel being a younger female).
set string462=The Japanese version of the Forecast Channel does not show the current forecast.
set string463=The Forecast Channel, News Channel and the Photo Channel were made by nearly the same team.
set string464=The first worldwide Everybody Votes Channel question about if you like dogs or cats more got more than 500,000 votes.
set string465=The night song that plays when viewing the local forecast in the Forecast Channel was made before the day song, that was requested to make people not feel sleepy when it was played during the day.
set string466=The globe in the Forecast and News Channel is based on imagery from NASA, and the same globe was used in Mario Kart Wii.
set string467=You can press the Reset button while the Wii's in standby to turn off the blue light that glows when you receive a message.

set string468=Patching IOS's
set string469=Patching News/Forecast Channel
set string470=Don't worry^^! It might take some time... Now copying files to your SD Card...
set string471=Please connect your Wii SD Card and copy apps and WAD folder to the root (main folder) of your SD Card. You can find these folders next to RiiConnect24Patcher.bat
set string472=Every file is in its place on your SD Card^^!
set string473=You can find these folders next to RiiConnect24Patcher.bat.
set string474=Please proceed with the tutorial that you can find on https://wii.guide/riiconnect24

set string475=Thank you very much for using this patcher^^! :)
set string476=Have fun using RiiConnect24^^!
set string477=Closing the patcher in:

set string478=There is no internet connection.
set string479=Could not connect to remote server.
set string480=Check your internet connection or check if your firewall isn't blocking curl.
set string481=There was an error while patching.
set string482=Error Code
set string483=Failing module
set string484=TIP: Consider turning off your antivirus temporarily.
set string485=SOLUTION: Please check your internet connection.
set string486=ERROR DETAILS: Curl write error. Try moving the patcher to desktop and try again.
set string487=SOLUTION: Please install latest .NET Framework, then try again.

set string488=SD Card
set string489=Start File Explorer.
set string490=Installation failed for WAD:
set string491=Installation failed for:
set string492=WAD(s)
set string493=Pressing any key will open the error log and return to main menu.


set string494=It looks like you're missing Visual C++ Redistributable on your computer.
set string495=It is required to run one of our tools.
set string496=We can automatically install it for you.
set string497=What do you say?
set string498=Yes, please.
set string499=This will install Visual C++ Redistributable
set string500=No, I'll install it manually.
set string501=Installing

set string502=Preparing to report the error...
set string503=Error reported successfully!
set string504=Randomize your error reporting identifier.
set string505=Current:


set string506=Take a second to send back feedback to developers. [PLEASE :)]
set string507=Welcome! We will now ask you a few questions.
set string508=Which one best fits the app that you just used?
set string509=The app is bad.
set string510=I encountered a lot of issues when patching.
set string511=Not intuitive.
set string512=It's alright.
set string513=The app is really easy to use!
set string514=How did you find out about RiiConnect24?
set string515=I've heard about it from my friend.
set string516=I've heard about it on Discord.
set string517=YouTube.
set string518=wii.guide.
set string519=I found out about it on Google.
set string520=Other.
set string521=Have you ever used other features in the patcher such as wad2bin or installing homebrew directly to your SD Card?
set string522=No and I don't plan to.
set string523=No, but I'm planning to.
set string524=Would you like to write a message to developer of this app? (anonymously) [In English]
set string525=No, skip.
set string526=Your message must be in English.
set string527=Write your message here [ENTER confirms your message].
set string528=This is your message:
set string529=Would you like to attach it?
set string530=Preparing to send feedback...

set string531=Japan
set string537=Korea
set string532=There is currently maintenance in progress on our servers.
set string533=Developer requested that access to the program will be prohibited until the maintenance is done.
set string534=Please try again later.
set string535=There is currently background maintenance in progress on our servers.
set string536=Some functionality may be limited or not functioning until the maintenance is done.

set string538=Unfortunately, for Korean region we only support Wii Mail.
set string539=Other channels were originally not supported by WiiConnect24.

set string540=Additional Channels
set string541=There was an error while downloading WiiWare Patcher.
set string542=Please check your Internet connection and try again.

set string543=WiiWare Patcher has completed it's job!
set string544=I've copied the original WAD files to the "backup-wads" folder.
set string545=Newly patched WAD's are in the "wiimmfi-wads" folder.
set string546=Patching file
set string547=File name

set string548=Welcome to the WiiWare Patcher!
set string549=This patcher will patch your WAD games to use with Wiimmfi.
set string550=Please put the WAD files in the folder where this patcher is and please select "Continue".
set string551=Patching process will begin.

set string552=Could not find any .WAD files next to the patcher.
set string553=Cannot continue until the conditions are met.

set string554=We can also bundle few other channels that are not RiiConnect24 oriented.
set string555=Please select if you want me to bundle them with other WAD's
set string556=Please select and then choose `Continue`. This is optional. You can just skip.

set string557=Photo Channel
set string558=Wii Speak Channel
set string559=Today and Tomorrow Channel
set string560=Internet Channel

set string561=You selected USA region and opted in to get Today and Tomorrow Channel.
set string562=This channel never appeared in America. I gave you the European version of the channel.
set string563=Please make sure you enable Region Free Everything in Priiloader before using it.

set string564=RiiConnect24 Servers are currently offline.
set string565=It appears that you have an active Internet connection but RiiConnect24 Server is currently offline.

set string566=What region should I restore the News Channel and Forecast Channel to?

set string567=There is not enough space on the disk to perform the operation.
set string568=Please free up some space and try again.
set string569=Amount of free space required:

set string570=Don't worry^^! It might take some time... Now copying files to your SD Card...

set string571=Make a backup of your game before patching. (Takes more disk space)

set string572=All done^^! Your game(s) have been patched.
set string573=There was an error while patching. Please see log above to see what caused the error.

set string574=Could not find any games.
set string575=Please make sure they're in the right folder and try again.

set string576=Copying... This may take a while.

set string577=There was an error while downloading Wiimmfi Patcher.
set string578=This will patch Wii Games (Mario Kart Wii and other disc games) to work with Wiimmfi.
set string579=Patch Wii disc based games to work with Wiimmfi.

set string580=There is not enough space on your SD Card to perform the copy operation.

set string581=Donate
set string582=Donate to:

set string583=Thanks for supporting me. I really appreciate any amount, it took me a long time to make this program. I hope you enjoy it as much as I enjoyed making it.
set string584=All donations made to RiiConnect24 go towards server hosting and renewing our websites.

set string585=Your feedback has been sent^^! Continuing in 5 seconds...
set string586=Your connection to RiiConnect24 Server has been lost.

set string587=Make sure your internet connection is good and try again. It it keeps up, visit https://status.rc24.xyz
::string588 used
::string589 used

set string590=You need to select something in order to start patching.
set string591=Please proceed with the tutorial that you can find on https://wii.guide/riiconnect24-dolphin

set string592=Region Select
set string593=This will patch every channel for later use on your Dolphin Emulator. This includes:

set string594=Hello again! We're glad you're back!
set string595=Dolphin Emulator now officially supports RiiConnect24.
set string596=Do you remember you still have VFF Downloader for Dolphin running in the background? 
set string597=I forgot about mine but it's time to uninstall it.
set string598=With Dolphin Emulator now supporting WC24, all you need to do is install the WAD's.
set string599=Can we remove the VFF Downloader for Dolphin for you? (Make sure to update Dolphin to the latest developer version!)
set string600=Sure
set string601=Dismiss (we'll remind you next time you use RiiConnect24 Patcher).

set string602=Alright! We're ready to begin patching.
set string603=I will now download and patch the WAD's so you can use them in Dolphin emulator.
set string604=Make sure to install them later!


set string605=Good morning^!
set string606=Good afternoon^!
set string607=Good evening^!

set string608=You can only select one channel at a time.


exit /b

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
:refresh_sdcard
set /a sdcard_refresh_pending=0
goto script_start_languages_2

:begin_main
cls
if "%sdcard_refresh_pending%"=="1" goto refresh_sdcard
%mode_path% %mode%
echo %header%
echo              `..````
echo              yNNNNNNNNMNNmmmmdddhhhyyyysssooo+++/:--.`
echo              ddmNNd:dNMMMMNMMMMMMMMMMMMMMMMMMMMMMMMMMs
echo              hNNNNNNNNMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMd
echo             `mdmNNy dNMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM+    %string1%
echo             .mmmmNs mNMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM:
echo             :mdmmN+`mNMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM.  1. %string2%
echo             /mmmmN:-mNMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMN   2. %string3%
if not exist "%userprofile%\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\VFF-Downloader-for-Dolphin.exe" echo             ommmmN.:mMMMMMMMMMMMMmNMMMMMMMMMMMMMMMMMd   3. %string4%
if exist "%userprofile%\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\VFF-Downloader-for-Dolphin.exe" echo             smmmmm`+mMMMMMMMMMNhMNNMNNMMMMMMMMMMMMMMy   3. %string4% (%string5%)
echo             smmmmm`+mMMMMMMMMMNhMNNMNNMMMMMMMMMMMMMMy   4. %string588%
if exist "%appdata%\VFF-Downloader-for-Dolphin\VFF-Downloader-for-Dolphin.exe" echo             hmmmmh omMMMMMMMMMmhNMMMmNNNNMMMMMMMMMMM+   5. %string6%
if not exist "%appdata%\VFF-Downloader-for-Dolphin\VFF-Downloader-for-Dolphin.exe" echo             hmmmmh omMMMMMMMMMmhNMMMmNNNNMMMMMMMMMMM+   	
echo             hmmmmh omMMMMMMMMMmhNMMMmNNNNMMMMMMMMMMM+   C. Change language
echo             mmmmms smMMMMMMMMMmddMMmmNmNMMMMMMMMMMMM;
echo            `mmmmmo hNMMMMMMMMMmddNMMMNNMMMMMMMMMMMMM.  %string7%  
echo            -mmmmm/ dNMMMMMMMMMNmddMMMNdhdMMMMMMMMMMN   %string8%
echo            :mmmmm-`mNMMMMMMMMNNmmmNMMNmmmMMMMMMMMMMd   
if not %sdcard%==NUL echo            :mmmmm-`mNMMMMMMMMNNmmmNMMNmmmMMMMMMMMMMd   %string9% %sdcard%:\
if %sdcard%==NUL echo            +mmmmN.-mNMMMMMMMMMNmmmmMMMMMMMMMMMMMMMMy     %string10%
echo            smmmmm`/mMMMMMMMMMNNmmmmNMMMMNMMNMMMMMNmy.    R. %string11% ^| %string12%
echo            hmmmmd`omMMMMMMMMMNNmmmNmMNNMmNNNNMNdhyhh.
echo            mmmmmh ymMMMMMMMMMNNmmmNmNNNMNNMMMMNyyhhh`    6. %string581%
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
if %beta%==1 echo         .oy: :ys.          %string13%^!
if %beta%==1 echo       -sy-     -ss-      
if %beta%==1 echo    `:ss-   ...   -ss-`   
if %beta%==1 echo  `:ss-`   .ysy     -ss:`   %string14%
if %beta%==1 echo /yo.      .ysy       .oy:  %string15%
if %beta%==1 echo :yo.      .hhh       .oy:  %string16%
if %beta%==1 echo  `:ss-             -sy:` 
if %beta%==1 echo     -ss-  `\./   -ss-`     
if %beta%==1 echo       -ss-     -ss-        %string17%
if %beta%==1 echo         -sy: :ys-          %string18%
if %beta%==1 echo           .oho.            
if %beta%==1 echo.
set /p s=%string19%: 
if %s%==1 goto begin_main1
if %s%==2 goto credits
if %s%==3 goto settings_menu
if %s%==4 goto troubleshooting_menu
if %s%==5 if exist "%appdata%\VFF-Downloader-for-Dolphin\VFF-Downloader-for-Dolphin.exe" start "" "%appdata%\VFF-Downloader-for-Dolphin\VFF-Downloader-for-Dolphin.exe" -run_once
if %s%==r goto begin_main_refresh_sdcard
if %s%==R goto begin_main_refresh_sdcard
if %s%==c goto change_language
if %s%==C goto change_language
if %s%==6 goto donate_main
if %s%==cmd echo.&cmd
if %s%==restart goto script_start
if %s%==exit exit
goto begin_main
:donate_main
cls
echo %header%
echo -----------------------------------------------------------------------------------------------------------------------------
echo.
echo R. %string356%
echo.
echo %string582%
echo.
echo 1. KcrPL [PayPal]
echo  - %string583%
echo.
echo 2. RiiConnect24 [PayPal]
echo 3. RiiConnect24 [Patreon]
echo  - %string584%
echo.
set /p s=%string26%: 
if %s%==1 start https://paypal.me/kcrplo
if %s%==2 start https://www.paypal.me/RiiConnect
if %s%==3 start https://www.patreon.com/bePatron?u=7497603
if %s%==r goto begin_main
if %s%==R goto begin_main
goto donate_main
:change_language
cls
echo %header%
echo -----------------------------------------------------------------------------------------------------------------------------
echo.
if "%error_changing_language%"=="1" (
echo :-------------------------------------------------------:
echo : There was an error while applying the translation.    :
echo : Please try again later.                            :
echo :-------------------------------------------------------:
echo.
set /a error_changing_language=0
)

echo Please select your language.
echo.
echo Please note that the translations are made by you - the community. Translations may be inaccurate or wrong.
echo You can contribute to translations! You can help us here: https://crowdin.com/project/riiconnect24-patcher
echo.
echo R. Return to main menu.
echo.
echo 1. English
echo 2. Chinese (Simplified)
echo 3. Dutch
echo 4. French
echo 5. German
echo 6. Hungarian
echo 7. Italian
echo 8. Japanese
echo 9. Polish
echo 10. Portuguese (Brazilian)
echo 11. Romanian
echo 12. Russian
echo 13. Spanish
echo 14. Swedish
echo 15. Turkish

echo.
set /p s=Choose: 
if "%s%"=="r" goto begin_main
if "%s%"=="R" goto begin_main
if "%s%"=="1" set language=English&& goto reload_language
if "%s%"=="2" set language=zh-CN&& goto reload_language
if "%s%"=="3" set language=nl-NL& goto reload_language
if "%s%"=="4" set language=fr-FR& goto reload_language
if "%s%"=="5" set language=de-DE& goto reload_language
if "%s%"=="6" set language=hu-HU& goto reload_language
if "%s%"=="7" set language=it-IT& goto reload_language
if "%s%"=="8" set language=ja-JP& goto reload_language
if "%s%"=="9" set language=pl-PL& goto reload_language
if "%s%"=="10" set language=pt-BR& goto reload_language
if "%s%"=="11" set language=ro-RO& goto reload_language
if "%s%"=="12" (
			if %chcp_enable%==0 goto language_unavailable
			set language=ru-RU
			goto reload_language
			)
if "%s%"=="13" set language=es-ES& goto reload_language
if "%s%"=="14" set language=sv-SE& goto reload_language
if "%s%"=="15" set language=tr-TR& goto reload_language
goto change_language

:language_unavailable
cls
echo %header%
echo -----------------------------------------------------------------------------------------------------------------------------
echo.
echo Outdated operating system. ^| Feature unavailable.
echo.
echo The language that you want to load only works on Windows 10 or newer.
echo Please select English or any other language.
echo.
echo Press any key to go back.
pause>NUL
goto change_language

:begin_main_refresh_sdcard
set sdcard=NUL
set tempgotonext=begin_main
goto detect_sd_card

:troubleshooting_menu
cls
echo %header%
echo -----------------------------------------------------------------------------------------------------------------------------
echo.
echo --- %string20% ---
echo %string21%
echo.
echo 1. %string22%
echo 2. %string23%
echo 3. %string24%
echo.
echo R. %string25%
echo.
echo.
set /p s=%string26%: 
if %s%==r goto begin_main
if %s%==R goto begin_main

if %s%==1 goto troubleshooting_2
if %s%==2 goto troubleshooting_3
if %s%==3 goto troubleshooting_4
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

call :clean_temp_files

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
call curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/version.txt" --output "%TempStorage%\version.txt"
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
echo %string27%.
echo.
echo 1. %string28%
echo 2. %string29%
if %Update_Activate%==1 echo 3. %string30%. [%string31%:  ON]
if %Update_Activate%==0 echo 3. %string30%. [%string31%: OFF]
if %sound_enable%==1 echo 4. %string589%. [%string31%: ON]
if %sound_enable%==0 echo 4. %string589%. [%string31%: OFF]
if %preboot_environment%==0 if %beta%==0 echo 5. %string32% %string33% [%string31%: %string34%]
if %preboot_environment%==0 if %beta%==1 echo 5. %string32% %string34%. [%string31%: %string33%]
if %preboot_environment%==0 echo 6. %string35% (%string36%)
echo 7. %string504% %string505% %random_identifier%
if "%vff_settings%"=="1" echo -----------------------------------------------------------------------------------------------------------------------------
echo.
if "%vff_settings%"=="1" echo %string37%. 
if "%vff_settings%"=="1" echo.
if "%vff_settings%"=="1" echo 8. %string38%.
if "%vff_settings%"=="1" echo 9. %string39%.
if "%vff_settings%"=="1" echo 10. %string40%
if %vff_settings%==1 echo.
set /p s=%string26%:
if %s%==1 goto begin_main
if %s%==2 goto change_color
if %s%==3 goto change_updating
if %s%==4 goto change_sounds
if %preboot_environment%==0 if %s%==5 goto change_updating_branch
if %preboot_environment%==0 if %s%==6 goto update_files
if %s%==7 (
	call :generate_identifier 
	for /f "usebackq" %%a in ("%MainFolder%\random_ident.txt") do set random_identifier=%%a
	)
if %s%==8 if %vff_settings%==1 goto settings_del_config_VFF
if %s%==9 if %vff_settings%==1 goto settings_del_vff_downloader
if %s%==10 if %vff_settings%==1 goto settings_taskkill_vff


goto settings_menu
:change_sounds
if %sound_enable%==1 (
	>"%MainFolder%\sound_enable.txt" echo 0
	set /a sound_enable=0
	goto settings_menu
	)
if %sound_enable%==0 (
	>"%MainFolder%\sound_enable.txt" echo 1
	set /a sound_enable=1
	goto settings_menu
	)

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
echo %string41%
echo.
if %beta%==1 goto change_updating_branch_stable
if %beta%==0 goto change_updating_branch_beta
goto settings_menu
:change_updating_branch_stable
set /a stable_available_check=1

	if exist "%TempStorage%\version.txt" del "%TempStorage%\version.txt" /q
	call curl -f -L -s -S %useragent% --insecure "%FilesHostedOn_Stable%/UPDATE/version.txt" --output "%TempStorage%\version.txt"
	echo 1
	set /a temperrorlev=%errorlevel%
		if not %temperrorlev%==0 set /a stable_available_check=0&goto switch_to_stable
	if exist "%TempStorage%\version.txt" set /p updateversion_stable=<"%TempStorage%\version.txt"
	goto switch_to_stable	

:change_updating_branch_beta
set /a beta_available_check=0
	
	if exist "%TempStorage%\beta_available.txt" del "%TempStorage%\beta_available.txt" /q
	call curl -f -L -s -S %useragent% --insecure "%FilesHostedOn_Beta%/UPDATE/beta_available.txt" --output "%TempStorage%\beta_available.txt"
		set /a temperrorlev=%errorlevel%
		if not %temperrorlev%==0 set /a beta_available_check=2&goto switch_to_beta
	if exist "%TempStorage%\beta_available.txt" set /p beta_available=<"%TempStorage%\beta_available.txt"
	
	if %beta_available%==0 set /a beta_available_check=0
	if %beta_available%==1 set /a beta_available_check=1
	
	if %beta_available_check%==0 goto switch_to_beta
	
	if exist "%TempStorage%\version.txt" del "%TempStorage%\version.txt" /q
	call curl -f -L -s -S %useragent% --insecure "%FilesHostedOn_Beta%/UPDATE/version.txt" --output "%TempStorage%\version.txt"
		set /a temperrorlev=%errorlevel%
		if not %temperrorlev%==0 set /a beta_available_check=2&goto switch_to_beta
	if exist "%TempStorage%\version.txt" set /p updateversion_beta=<"%TempStorage%\version.txt"

	goto switch_to_beta
:switch_to_stable
cls
echo %header%
echo -----------------------------------------------------------------------------------------------------------------------------
echo.
echo %string42%
echo.
echo %string43%: %version% [%string33%]
if %stable_available_check%==1 echo %string44%: %updateversion_stable%
if %stable_available_check%==0 echo %string44%: %string45%
echo.
echo %string46% (%string47%)
echo.
if %stable_available_check%==1 echo 1. %string48%
if not %stable_available_check%==1 echo 1. %string49%
echo 2. %string50%
set /p s=%string26%: 
if %s%==1 (
	if %stable_available_check%==0 goto switch_to_stable
	curl -f -L -s -S %useragent% --insecure "%FilesHostedOn_Stable%/UPDATE/update_assistant.bat" --output "update_assistant.bat"
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
echo %string51%
echo.
echo %string43%: %version%
if %beta_available_check%==0 echo %string52%: %string53%
if %beta_available_check%==1 echo %string52%: %updateversion_beta% [BETA]
if %beta_available_check%==2 echo %string52%: %string45%
echo.
echo %string46% (%string47%)
echo.
if %beta_available_check%==1 echo 1. %string54%
if not %beta_available_check%==1 echo 1. %string55%
echo 2. %string50%
set /p s=%string26%: 
if %s%==1 (
	if not %beta_available_check%==1 goto switch_to_beta

	curl -f -L -s -S %useragent% --insecure "%FilesHostedOn_Stable%/UPDATE/update_assistant.bat" --output "update_assistant.bat"
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
echo %string56%^! %string57% 
echo %string58%
echo.
echo %string59%
echo.
echo %string60%
echo 1. %string61%
echo 2. %string62%
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
echo %string63%
echo.
echo 1. %string64%
echo 2. %string65%
echo 3. %string66%
echo 4. %string67%
echo 5. %string68%
echo 6. %string69%
echo 7. %string70%
echo.
echo E. %string28%
set /p s=%string26%: 
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
if exist "%MainFolder%\background_color.txt" del /q "%MainFolder%\background_color.txt"
color %tempcolor%
echo>>"%MainFolder%\background_color.txt" %tempcolor%
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
echo              yNNNNNNNNMNNmmmmdddhhhyyyysssooo+++/:--.`    %string71%
echo              hNNNNNNNNMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMd    %string72%
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
echo    /---\   %string73%              
echo   /     \  %string74%
echo  /   ^!   \ 
echo  --------- %string75%
echo            %string76%
echo.
echo       %string77%
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
setlocal DisableDelayedExpansion
:: For whatever reason, it returns 2
curl
if not %errorlevel%==2 goto begin_main_download_curl

cls
echo %header%
echo.
echo              `..````                                     :-------------------------:
echo              yNNNNNNNNMNNmmmmdddhhhyyyysssooo+++/:--.`    %string78%
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
		title %string78% :          :
:: Update script.
set updateversion=0.0.0
:: Delete version.txt and whatsnew.txt
if %offlinestorage%==0 if exist "%TempStorage%\version.txt" del "%TempStorage%\version.txt" /q
if %offlinestorage%==0 if exist "%TempStorage%\whatsnew.txt" del "%TempStorage%\whatsnew.txt" /q

if not exist "%TempStorage%" md "%TempStorage%"
:: Commands to download files from server.

		title %string78% :-          :

call curl -f -L -s %useragent% --insecure "http://www.msftncsi.com/ncsi.txt">NUL
	if "%errorlevel%"=="6" title %title%& goto no_internet_connection

		title %string78% :--         :

For /F "Delims=" %%A In ('call curl -f -L -s %useragent% --insecure "https://patcher.rc24.xyz/connection_test.txt"') do set "connection_test=%%A"
	set /a temperrorlev=%errorlevel%
	
	if not "%connection_test%"=="OK" title %title%& goto server_dead
	
		title %string78% :---        :

if %Update_Activate%==1 if %preboot_environment%==0 if %offlinestorage%==0 call curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/UPDATE/whatsnew.txt" --output "%TempStorage%\whatsnew.txt"
if %Update_Activate%==1 if %preboot_environment%==0 if %offlinestorage%==0 call curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/UPDATE/version.txt" --output "%TempStorage%\version.txt"
	set /a temperrorlev=%errorlevel%

		title %string78% :----       :

if %Update_Activate%==1 if %offlinestorage%==0 if %chcp_enable%==1 call curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/UPDATE/Translation_Files/Language_%language%.bat" --output "%TempStorage%\Language_%language%.bat"
if %Update_Activate%==1 if %offlinestorage%==0 if %chcp_enable%==0 call curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/UPDATE/Translation_Files_CHCP_OFF/Language_%language%.bat" --output "%TempStorage%\Language_%language%.bat"
if not %errorlevel%==0 set /a translation_download_error=1

if %chcp_enable%==1 if exist "%TempStorage%\Language_%language%.bat" call "%TempStorage%\Language_%language%.bat" -chcp
if %chcp_enable%==0 if exist "%TempStorage%\Language_%language%.bat" call "%TempStorage%\Language_%language%.bat"

		title %string78% :-----      :
		
set /a updateserver=1
	::Bind exit codes to errors here

	if not %temperrorlev%==0 set /a updateserver=0

if exist "%TempStorage%\version.txt`" ren "%TempStorage%\version.txt`" "version.txt"
if exist "%TempStorage%\whatsnew.txt`" ren "%TempStorage%\whatsnew.txt`" "whatsnew.txt"
:: Copy the content of version.txt to variable.

		title %string78% :------     :
		
		set /a local_sounds_version=0
		if exist "%MainFolder%\sounds\sounds_version.txt" set /p local_sounds_version=<"%MainFolder%\sounds\sounds_version.txt"
For /F "Delims=" %%A In ('call curl -f -L -s %useragent% --insecure "%FilesHostedOn%/sounds/sounds_version.txt"') do set "remote_sounds_version=%%A"
		set /a sounds_need_update=0
		if not "%local_sounds_version%"=="%remote_sounds_version%" set /a sounds_need_update=1
		
		if not exist "%MainFolder%\sounds\confirm1.wav" set /a sounds_need_update=1
		if not exist "%MainFolder%\sounds\select1.wav" set /a sounds_need_update=1
		if not exist "%MainFolder%\sounds\select3.wav" set /a sounds_need_update=1
		if not exist "%MainFolder%\sounds\warning1.wav" set /a sounds_need_update=1
		if not exist "%MainFolder%\sounds\warning3.wav" set /a sounds_need_update=1
		if not exist "%MainFolder%\sounds\exit1.wav" set /a sounds_need_update=1
		if not exist "%MainFolder%\sounds\info2.wav" set /a sounds_need_update=1
		
		if "%sound_enable%"=="1" if "%sounds_need_update%"=="1" (
			if not exist "%MainFolder%\sounds" mkdir "%MainFolder%\sounds"
			curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/sounds/confirm1.wav" --output "%MainFolder%\sounds\confirm1.wav"
			curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/sounds/select1.wav" --output "%MainFolder%\sounds\select1.wav"
			curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/sounds/select3.wav" --output "%MainFolder%\sounds\select3.wav"
			curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/sounds/warning1.wav" --output "%MainFolder%\sounds\warning1.wav"
			curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/sounds/warning3.wav" --output "%MainFolder%\sounds\warning3.wav"
			curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/sounds/exit1.wav" --output "%MainFolder%\sounds\exit1.wav"
			curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/sounds/info2.wav" --output "%MainFolder%\sounds\info2.wav"
			>"%MainFolder%\sounds\sounds_version.txt" echo %remote_sounds_version%
			)
		
		title %string78% :-------    :
if exist "%TempStorage%\version.txt" set /p updateversion=<"%TempStorage%\version.txt"
if not exist "%TempStorage%\version.txt" set /a updateavailable=0
if %Update_Activate%==1 if exist "%TempStorage%\version.txt" set /a updateavailable=1
:: If version.txt doesn't match the version variable stored in this batch file, it means that update is available.
if %updateversion%==%version% set /a updateavailable=0

if exist "%TempStorage%\annoucement.txt" del /q "%TempStorage%\annoucement.txt"
curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/UPDATE/annoucement.txt" --output %TempStorage%\annoucement.txt"

		title %string78% :--------   :

if %Update_Activate%==1 if %updateavailable%==1 set /a updateserver=2
if %Update_Activate%==1 if %updateavailable%==1 title %title%& goto update_notice

set /a maintenance_info=0
set /a maintenance_block=0

		title %string78% :---------- :


For /F "Delims=" %%A In ('call curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/UPDATE/maintenance_info.txt"') do set "maintenance_info=%%A"
For /F "Delims=" %%A In ('call curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/UPDATE/maintenance_block.txt"') do set "maintenance_block=%%A"

	title %title%

if "%maintenance_block%"=="1" goto maintenance_block
if "%maintenance_info%"=="1" goto maintenance_info


if exist "%appdata%\Microsoft\Windows\Start Menu\Programs\Startup\VFF-Downloader-for-Dolphin.exe" goto dolphin_support_update

set sound_play=select1&call :sound_play
goto select_device

:dolphin_support_update
cls
set sound_play=warning1&call :sound_play
echo %header%
echo -----------------------------------------------------------------------------------------------------------------------------
echo.
echo %string594%
echo.
echo %string595%
echo %string596%
echo %string597%
echo.
echo %string598%
echo.
echo %string599%
echo.
echo 1. %string600%
echo 2. %string601%
echo.
set /p s=%string26%:
if %s%==1 goto dolphin_support_update_remove
if %s%==2 goto select_device
goto dolphin_support_update
:dolphin_support_update_remove
taskkill /im VFF-Downloader-for-Dolphin.exe /f
del /q "%appdata%\Microsoft\Windows\Start Menu\Programs\Startup\VFF-Downloader-for-Dolphin.exe"
goto begin_main1

:sound_play
if "%sound_enable%"=="0" exit /b 0
if exist "%MainFolder%\sounds\%sound_play%.wav" (
	chcp 437>NUL
	start /B "cmd /C" PowerShell -C (New-Object System.Media.SoundPlayer '%MainFolder%\sounds\%sound_play%.wav'").PlaySync()
	)
exit /b 0

:server_dead
cls
set sound_play=warning3&call :sound_play
echo %header%
echo -----------------------------------------------------------------------------------------------------------------------------
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
echo    /---\   %string13%.
echo   /     \  %string564%
echo  /   ^!   \ 
echo  --------- %string565%
echo            %string587%
echo.
echo            %string430%
echo.
echo            %string90%
echo ---------------------------------------------------------------------------------------------------------------------------
pause>NUL
goto begin_main
:maintenance_block
cls
set sound_play=warning1&call :sound_play
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
echo    /---\   %string13%.
echo   /     \  %string532%
echo  /   ^!   \ 
echo  --------- %string533%
echo            %string534%
echo.
echo            %string90%
echo ---------------------------------------------------------------------------------------------------------------------------
pause>NUL
goto begin_main

:maintenance_info
cls
set sound_play=warning1&call :sound_play
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
echo    /---\   %string13%.
echo   /     \  %string535%
echo  /   ^!   \ 
echo  --------- %string536%
echo.
echo            %string309%
echo ---------------------------------------------------------------------------------------------------------------------------
pause>NUL
goto select_device





:update_notice
if exist "%MainFolder%\failsafe.txt" del /q "%MainFolder%\failsafe.txt"
if %updateversion%==0.0.0 goto error_update_not_available
set /a update=1
cls
set sound_play=select1&call :sound_play
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
echo    /---\   %string79%              
echo   /     \  %string80%
echo  /   ^!   \ 
echo  ---------  %string81%: %version%
echo             %string82%: %updateversion%
echo                       1. %string83%                      2. %string84%               3. %string85%
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
if %s%==1 set sound_play=confirm1&call :sound_play&goto update_files
if %s%==2 set sound_play=exit1&call :sound_play&goto select_device
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
echo    /---\   %string86%
echo   /     \  %string87%
echo  /   ^!   \ 
echo  --------- %string88% 
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
:update_1
call :check_rc24_server_connection
if "%errorlevel%"=="1" goto server_connection_lost
curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/UPDATE/update_assistant.bat" --output "update_assistant.bat"
	set temperrorlev=%errorlevel%
	if not %temperrorlev%==0 goto error_updating
if %beta%==0 start update_assistant.bat -RC24_Patcher
if %beta%==1 start update_assistant.bat -RC24_Patcher -beta
exit
:error_updating
cls
set sound_play=warning3&call :sound_play
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
echo    /---\   %string73%
echo   /     \  %string89%
echo  /   ^!   \ 
echo  --------- %sting90%
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
echo %string91% %updateversion%?
echo.
type "%TempStorage%\whatsnew.txt"
pause>NUL
goto update_notice
:whatsnew_notexist
cls
echo %header%
echo -----------------------------------------------------------------------------------------------------------------------------
echo.
echo %string92%
echo.
echo %string93%
pause>NUL
goto update_notice

:open_shop_sdcarddetect
cls
echo %header%
echo -----------------------------------------------------------------------------------------------------------------------------
echo.
echo %string100%
echo %string101%
echo.
echo 1. %string102%
echo 2. %string103%
echo.
set /p s=%string26%: 
if %s%==1 set sound_play=confirm1&call :sound_play&set /a sdcardstatus=1& set tempgotonext=open_shop_summarysdcard& goto detect_sd_card
if %s%==2 set sound_play=exit1&call :sound_play&set /a sdcardstatus=0& goto open_shop_getexecutable
goto open_shop_sdcarddetect
:open_shop_summarysdcard
setlocal disableDelayedExpansion
cls
echo %header%
echo -----------------------------------------------------------------------------------------------------------------------------
echo.
if %sdcardstatus%==1 if %sdcard%==NUL echo %string104%
if %sdcardstatus%==1 if %sdcard%==NUL echo %string105%
if %sdcardstatus%==1 if %sdcard%==NUL echo.
if %sdcardstatus%==1 if %sdcard%==NUL echo %string106%
if %sdcardstatus%==1 if not %sdcard%==NUL echo %string107% %sdcard%
if %sdcardstatus%==1 if not %sdcard%==NUL echo %string108%	
echo.
echo %string109%
if %sdcardstatus%==1 if %sdcard%==NUL echo 1. %string110% 2. %string111% 3. %string112%
if %sdcardstatus%==1 if not %sdcard%==NUL echo 1. %string110% 2. %string111% 3. %string112%
echo.
set /p s=%string26%: 
if %s%==1 set sound_play=confirm1&call :sound_play&goto open_shop_getexecutable
if %s%==2 set sound_play=exit1&call :sound_play&goto begin_main
if %s%==3 set sound_play=confirm1&call :sound_play&goto open_shop_change_drive_letter
goto open_shop_summarysdcard
:open_shop_change_drive_letter
cls
echo %header%
echo -----------------------------------------------------------------------------------------------------------------------------
echo [*] %string488%
echo.
echo %string113%: %sdcard%
echo.
echo %string114%
set /p sdcard=
set sound_play=confirm1&call :sound_play
goto open_shop_summarysdcard
:open_shop_getexecutable
cls
if exist osc-dl.exe del /q osc-dl.exe
echo %header%
echo -----------------------------------------------------------------------------------------------------------------------------
echo.
echo %string115%
echo %string116%
echo.	
curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/osc-dl.exe" --output "osc-dl.exe"
set /a temperrorlev=%errorlevel%
if not %temperrorlev%==0 goto open_shop_getexecutable_fail
goto open_shop_mainmenu
:open_shop_getexecutable_fail
cls
set sound_play=warning3&call :sound_play
echo %header%
echo -----------------------------------------------------------------------------------------------------------------------------
echo.
echo %string117%
echo %string118%: %temperrorlev%
echo.
echo %string119%
echo.
echo %string502%

>"%MainFolder%\error_report.txt" echo RiiConnect24 Patcher v%version%
>>"%MainFolder%\error_report.txt" echo.
>>"%MainFolder%\error_report.txt" echo Open Shop Channel
>>"%MainFolder%\error_report.txt" echo.
>>"%MainFolder%\error_report.txt" echo Date: %date%
>>"%MainFolder%\error_report.txt" echo Time: %time:~0,5%
>>"%MainFolder%\error_report.txt" echo.
>>"%MainFolder%\error_report.txt" echo Windows version: %windows_version%
>>"%MainFolder%\error_report.txt" echo Language: %language%
>>"%MainFolder%\error_report.txt" echo Device: %device%
>>"%MainFolder%\error_report.txt" echo.
>>"%MainFolder%\error_report.txt" echo Action: Downloading the executable
>>"%MainFolder%\error_report.txt" echo Module: cURL
>>"%MainFolder%\error_report.txt" echo Exit code: %temperrorlev%

curl -s %useragent% --insecure -F "report=@%MainFolder%\error_report.txt" %post_url%?user=%random_identifier%>NUL

echo %string503%



pause>NUL
set sound_play=exit1&call :sound_play
goto begin_main
:open_shop_mainmenu
setlocal disableDelayedExpansion
cls
set /a homebrew_online_var=0
echo %header%
echo -----------------------------------------------------------------------------------------------------------------------------
echo.
echo %string100%
echo %string120%
echo.
echo 1. %string121%
echo 2. %string122%
echo.
echo R. %string123%
if %preboot_environment%==1 echo 3. %string489%
echo.
set /p s=%string26%: 
if %s%==1 set sound_play=confirm1&call :sound_play&goto open_shop_list
if %s%==2 set sound_play=confirm1&call :sound_play&goto open_shop_homebrew
if %preboot_environment%==1 if %s%==3 "X:\TOTALCMD.exe"
if %s%==r set sound_play=exit1&call :sound_play&goto begin_main
if %s%==R set sound_play=exit1&call :sound_play&goto begin_main
goto open_shop_mainmenu
:open_shop_list
cls
echo %header%
echo -----------------------------------------------------------------------------------------------------------------------------
echo.
echo %string124%
echo %header%>"Open Shop Channel Homebrew List.txt"
echo.>>"Open Shop Channel Homebrew List.txt"
echo %string125%>>"Open Shop Channel Homebrew List.txt"
echo      %string126%>>"Open Shop Channel Homebrew List.txt"
echo.>>"Open Shop Channel Homebrew List.txt"
echo %string127%:>>"Open Shop Channel Homebrew List.txt"
echo.>>"Open Shop Channel Homebrew List.txt"
osc-dl.exe list>>"Open Shop Channel Homebrew List.txt"

start "" "Open Shop Channel Homebrew List.txt"
goto open_shop_mainmenu

:open_shop_homebrew
cls
echo %header%
echo -----------------------------------------------------------------------------------------------------------------------------
echo.
echo %string128%
echo.
if %homebrew_online_var%==1 echo :-----------------------------------------------------------------------------------------------------------------------:
if %homebrew_online_var%==1 echo  "%homebrew_name%" %string129%
if %homebrew_online_var%==1 echo  %string130%
if %homebrew_online_var%==1 echo :-----------------------------------------------------------------------------------------------------------------------:
if %homebrew_online_var%==1 echo.
set /a homebrew_online_var=0
echo R. %string213%
echo.
set /p homebrew_name=Type here: 
if %homebrew_name%==r set sound_play=exit1&call :sound_play&goto open_shop_mainmenu
if %homebrew_name%==R set sound_play=exit1&call :sound_play&goto open_shop_mainmenu
set sound_play=confirm1&call :sound_play
goto open_shop_homebrew_download

:open_shop_homebrew_download
cls
echo %header%
echo -----------------------------------------------------------------------------------------------------------------------------
echo.
echo %string131%

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
echo %string132%
osc-dl.exe meta -n "%homebrew_name%" -t name
echo.
echo %string133%
echo.
osc-dl.exe meta -n "%homebrew_name%" -t long_description
echo -----------------------------------------------------------------------------------------------------------------------------
echo.
echo %string134%
echo (%string135%)
echo.
echo 1. %string61%.
echo 2. %string136%
set /p s=%string26%: 
if %s%==1 set sound_play=confirm1&call :sound_play&goto open_shop_homebrew_download
if %s%==2 set sound_play=exit1&call :sound_play&goto open_shop_mainmenu
goto open_shop_homebrew_show_info
:open_shop_homebrew_finishnosdcard
setlocal disableDelayedExpansion
cls
echo %header%
echo -----------------------------------------------------------------------------------------------------------------------------
echo %string137% %homebrew_app_name%...
echo.
echo [OK] %string138%
echo.
echo %string139%
echo %string140%
echo %string141%
pause>NUL
goto open_shop_mainmenu

:open_shop_homebrew_download
cls
echo %header%
echo -----------------------------------------------------------------------------------------------------------------------------
echo %string137% %homebrew_app_name%...
echo.
echo [..] %string138%
osc-dl.exe get -n "%homebrew_name%" --noconfirm --output "%homebrew_name%.zip"
set /a temperrorlev=%errorlevel%
if not %temperrorlev%==0 set /a reason=1&goto open_shop_homebrew_download_error
if %sdcardstatus%==0 goto open_shop_homebrew_finishnosdcard
cls
echo %header%
echo -----------------------------------------------------------------------------------------------------------------------------
echo Downloading %homebrew_app_name%...
echo.
echo [OK] %string138%
echo [..] %string142%
curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/7z.exe" --output "7z.exe"
set /a temperrorlev=%errorlevel%
if not %temperrorlev%==0 set /a reason=2&goto open_shop_homebrew_download_error
cls
echo %header%
echo -----------------------------------------------------------------------------------------------------------------------------
echo Downloading %homebrew_app_name%...
echo.
echo [OK] %string138%
echo [OK] %string142%
echo [..] %string143%
7z x "%homebrew_name%.zip" -aoa -o%sdcard%:
set /a temperrorlev=%errorlevel%
if not %temperrorlev%==0 set /a reason=3&goto open_shop_homebrew_download_error
cls
echo %header%
echo -----------------------------------------------------------------------------------------------------------------------------
echo Downloading %homebrew_app_name%...
echo.
echo [OK] %string138%
echo [OK] %string142%
echo [OK] %string143%
echo.
echo %string139%
echo %string141%
del /q "%homebrew_name%.zip"
set sound_play=info2&call :sound_play
pause>NUL
goto open_shop_mainmenu
:open_shop_homebrew_download_error
cls
set sound_play=warning3&call :sound_play
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
echo    /---\   %string73%
echo   /     \  %string144%
echo  /   ^!   \ 
echo  --------- 
echo.
if %reason%==1 echo %string145%
if %reason%==2 echo %string146%
if %reason%==3 echo %string147%
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

echo %string502%
>"%MainFolder%\error_report.txt" echo RiiConnect24 Patcher v%version%
>>"%MainFolder%\error_report.txt" echo.
>>"%MainFolder%\error_report.txt" echo Open Shop Channel
>>"%MainFolder%\error_report.txt" echo.
>>"%MainFolder%\error_report.txt" echo Date: %date%
>>"%MainFolder%\error_report.txt" echo Time: %time:~0,5%
>>"%MainFolder%\error_report.txt" echo.
>>"%MainFolder%\error_report.txt" echo Windows version: %windows_version%
>>"%MainFolder%\error_report.txt" echo Language: %language%
>>"%MainFolder%\error_report.txt" echo Device: %device%
>>"%MainFolder%\error_report.txt" echo.
>>"%MainFolder%\error_report.txt" echo Action: Downloading homebrew
>>"%MainFolder%\error_report.txt" echo Reason: %reason%
>>"%MainFolder%\error_report.txt" echo Exit code: %temperrorlev%

curl -s %useragent% --insecure -F "report=@%MainFolder%\error_report.txt" %post_url%?user=%random_identifier%>NUL

echo %string503%


pause>NUL
goto open_shop_mainmenu
:select_device
setlocal disableDelayedExpansion
cls
echo %header%
echo -----------------------------------------------------------------------------------------------------------------------------
if exist "%TempStorage%\annoucement.txt" echo --- %string148% --- 
if exist "%TempStorage%\annoucement.txt" type "%TempStorage%\annoucement.txt"
if exist "%TempStorage%\annoucement.txt" echo -------------------
if "%translation_download_error%"=="1" if not "%language%"=="English" (
set sound_play=warning1&call :sound_play
echo :-----------------------------------------------------------------------:
echo : There was an error while downloading the up-to-date translation.      :
echo : Your language was reverted to English.                                :
echo :-----------------------------------------------------------------------:
echo.
set /a translation_download_error=0
)
echo.
	set current_time=%time:~0,5%
	if /i "%current_time%" GEQ " 5:00" if /i "%current_time%" LSS "13:00" echo %string605% %string149%
	if /i "%current_time%" GEQ "13:00" if /i "%current_time%" LSS "18:00" echo %string606% %string149%
	if /i "%current_time%" GEQ "18:00" if /i "%current_time%" LEQ "23:59" echo %string607% %string149%
	if /i "%current_time%" GEQ " 0:00" if /i "%current_time%" LSS " 5:00" echo %string607% %string149%
echo.
echo %string150%
echo %string151%
echo.
echo %string152%
echo.
echo 1. Wii
echo 2. Wii U (vWii, Wii Mode)
echo 3. %string153%
echo.
set /p s=%string154%: 
if %s%==1 set sound_play=confirm1&call :sound_play&set device=1&goto 1
if %s%==2 set sound_play=confirm1&call :sound_play&set device=1_wiiu&goto 1_wiiu
if %s%==3 set sound_play=confirm1&call :sound_play&set device=1_dolphin&goto 1_dolphin
goto select_device

:1_dolphin
cls
echo %header%
echo -----------------------------------------------------------------------------------------------------------------------------
if exist "%TempStorage%\annoucement.txt" echo --- %string148% --- 
if exist "%TempStorage%\annoucement.txt" type "%TempStorage%\annoucement.txt"
if exist "%TempStorage%\annoucement.txt" echo --------------------
echo.
echo %string155%?
echo.
echo 1. %string156%
echo   - %string157%
echo.
echo --- %string158% ---
echo.
echo 2. %string159%
echo   - %string160%
echo.
echo 3. %string579%
echo   - %string578%
echo.	
echo 4. %string165%
echo   - %string166%
set /p s=%string26%: 

if %s%==1 set sound_play=confirm1&call :sound_play&goto 2_prepare
if %s%==2 set sound_play=confirm1&call :sound_play&goto wadgames_patch_info
if %s%==3 set sound_play=confirm1&call :sound_play&goto wiimmfi_patcher_prepare
if %s%==4 set sound_play=confirm1&call :sound_play&goto open_shop_sdcarddetect
goto 1_dolphin


:2_prepare_dolphin
cls
echo %header%
echo -----------------------------------------------------------------------------------------------------------------------------
echo.
echo %string116%
echo %string431%

	curl --silent --show-error --fail %CheckNUS.Domain%/ccs/download/0001000248414741/tmd>NUL
	if not "%errorlevel%"=="23" if not "%errorlevel%"=="0" goto error_NUS_DOWN

	curl --silent --show-error --fail %CheckNUS.Domain%/ccs/download/0001000248414745/tmd>NUL
	if not "%errorlevel%"=="23" if not "%errorlevel%"=="0" goto error_NUS_DOWN


	curl --silent --show-error --fail %CheckNUS.Domain%/ccs/download/000100024841474A/tmd>NUL
	if not "%errorlevel%"=="23" if not "%errorlevel%"=="0" goto error_NUS_DOWN


	curl --silent --show-error --fail %CheckNUS.Domain%/ccs/download/0001000248414750/tmd>NUL
	if not "%errorlevel%"=="23" if not "%errorlevel%"=="0" goto error_NUS_DOWN

:: Checking disk space
set /a patching_size_required_bytes=%patching_size_required_wii_bytes%
set /a patching_size_required_megabytes=%wii_patching_requires%

for /f "usebackq delims== tokens=2" %%x in (`%wmic_path% logicaldisk where "DeviceID='%running_on_drive%:'" get FreeSpace /format:value`) do set free_drive_space_bytes=%%x

if %errorlevel%==0 (
	if /i %free_drive_space_bytes% LSS %patching_size_required_bytes% goto disk_space_insufficient
	)
	
goto 2_auto


:2_after_vff
cls
echo %header%
echo -----------------------------------------------------------------------------------------------------------------------------
echo.
echo %string171%
echo.
echo %string172% 
echo - %string173% 
echo   %string174%
echo.
echo - %string175%
echo   %string176%
echo.
echo %string177%
echo 1. %string178%
echo 2. %string179%
echo 3. %string180%
set /p s=%string26%: 
if %s%==1 goto 2_install_dolphin_1
if %s%==2 goto 2_prepare_dolphin
if %s%==3 goto begin_main
goto 2_after_vff
:2_install_dolphin_1
cls
echo %header%
echo -----------------------------------------------------------------------------------------------------------------------------
echo.
echo %string181%
echo.
echo %string182%
echo.
echo 1. %string183%
echo 2. %string184%
set /p evcregion=%string26%: 
if "%evcregion%"=="1" set sound_play=confirm1&call :sound_play&goto 2_install_dolphin_2
if "%evcregion%"=="2" set sound_play=confirm1&call :sound_play&goto 2_install_dolphin_2

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
setlocal disableDelayedExpansion
echo %string185%
echo %string186%
echo.
echo %string187%
echo %string188%
echo.
echo 1. %string189%
echo 2. %string190%
set /p s=%string26%: 
if %s%==1 goto script_start
if %s%==2 goto end
goto 2_install_dolphin_3
:1_wiiu
cls
echo %header%
echo -----------------------------------------------------------------------------------------------------------------------------
if exist "%TempStorage%\annoucement.txt" echo --- %string148% --- 
if exist "%TempStorage%\annoucement.txt" type "%TempStorage%\annoucement.txt"
if exist "%TempStorage%\annoucement.txt" echo -------------------
echo.
echo %string155%?
echo.
echo 1. %string191%
echo   - %string157%
echo.
echo --- %string158% ---
echo.
echo 2. %string192%
echo   - %string193%
echo.
echo 3. %string159%
echo   - %string160%
echo.
echo 4. %string579%
echo   - %string578%
echo.	
echo 5. %string165%
echo   - %string166%
set /p s=%string26%: 
if %s%==1 set sound_play=confirm1&call :sound_play&goto 2_prepare_wiiu
if %s%==2 set sound_play=confirm1&call :sound_play&goto direct_install_download_binary
if %s%==3 set sound_play=confirm1&call :sound_play&goto wadgames_patch_info
if %s%==4 set sound_play=confirm1&call :sound_play&goto wiimmfi_patcher_prepare
if %s%==5 set sound_play=confirm1&call :sound_play&goto open_shop_sdcarddetect
goto 1_wiiu
:2_prepare_wiiu
:: Checking disk space
set /a patching_size_required_bytes=%patching_size_required_wiiu_bytes%
set /a patching_size_required_megabytes=%wiiu_patching_requires%

for /f "usebackq delims== tokens=2" %%x in (`call %wmic_path% logicaldisk where "DeviceID='%running_on_drive%:'" get FreeSpace /format:value`) do set free_drive_space_bytes=%%x
if %errorlevel%==0 (
	if /i %free_drive_space_bytes% LSS %patching_size_required_bytes% goto disk_space_insufficient
	)
cls
echo %header%
echo -----------------------------------------------------------------------------------------------------------------------------
echo.
echo %string200%
echo.
echo %string201%
echo 1. %string202%
echo   - %string203%
echo     - %string204%
echo     - %string205%
echo     - %string206%
echo     - %string207%
echo.
echo 2. %string208%
echo   - %string209%
set /p s=
if %s%==1 set sound_play=confirm1&call :sound_play&goto 2_auto_wiiu
if %s%==2 set sound_play=confirm1&call :sound_play&goto 2_choose_custom_instal_type_wiiu
goto 2_prepare_wiiu
:2_choose_custom_instal_type_wiiu

set /a evcregion=1
set /a custominstall_news_fore=1
set /a custominstall_evc=1
set /a custominstall_nc=1
set /a custominstall_cmoc=1



set /a sdcardstatus=0
set /a errorcopying=0
set sdcard=NUL
goto 2_choose_custom_install_type2_wiiu
:2_choose_custom_install_type2_wiiu
setlocal disableDelayedExpansion
if "%evcregion%"=="3" set /a custominstall_nc=0

cls
echo %header%
echo -----------------------------------------------------------------------------------------------------------------------------
echo.
echo %string210%
echo.
echo %string201%
echo - %string208%
echo.
if "%info_nothing_selected%"=="1" (
	echo :---------------------------------------------------------------------------------------------------------------------------:
	echo  %string590%
	echo :---------------------------------------------------------------------------------------------------------------------------:
	echo.
	set /a info_nothing_selected=0
)
if %evcregion%==1 echo 1. %string211% %string183%
if %evcregion%==2 echo 1. %string211% %string184%
if %evcregion%==3 echo 1. %string211% %string531%
echo.
if %custominstall_news_fore%==1 echo 2. [X] %string435%
if %custominstall_news_fore%==0 echo 2. [ ] %string435%
if %custominstall_evc%==1 echo 3. [X] %string205%
if %custominstall_evc%==0 echo 3. [ ] %string205%
if not "%evcregion%"=="3" if %custominstall_nc%==1 echo 4. [X] %string206%
if not "%evcregion%"=="3" if %custominstall_nc%==0 echo 4. [ ] %string206%
if %custominstall_cmoc%==1 echo 5. [X] %string207%
if %custominstall_cmoc%==0 echo 5. [ ] %string207%
echo.
echo - %string540%
echo.
if %internet_channel_enable%==0 echo 6. [ ] %string560%
if %internet_channel_enable%==1 echo 6. [X] %string560%
if %photo_channel_enable%==0 echo 7. [ ] %string557%
if %photo_channel_enable%==1 echo 7. [X] %string557%
if %wii_speak_channel_enable%==0 echo 8. [ ] %string558%
if %wii_speak_channel_enable%==1 echo 8. [X] %string558%
if %today_and_tomorrow_enable%==0 echo 9. [ ] %string559%
if %today_and_tomorrow_enable%==1 echo 9. [X] %string559%
echo.
echo 10. %string212%
echo R. %string213%
set /p s=

	set /a check=0
	if "%custominstall_news_fore%"=="1" set /a check=%check%+1
	if "%custominstall_evc%"=="1" set /a check=%check%+1
	if "%custominstall_nc%"=="1" set /a check=%check%+1
	if "%custominstall_cmoc%"=="1" set /a check=%check%+1
	if "%internet_channel_enable%"=="1" set /a check=%check%+1
	if "%photo_channel_enable%"=="1" set /a check=%check%+1
	if "%wii_speak_channel_enable%"=="1" set /a check=%check%+1
	if "%today_and_tomorrow_enable%"=="1" set /a check=%check%+1



if "%s%"=="10" (

	if "%check%"=="0" set /a info_nothing_selected=1
	if "%check%"=="0" set sound_play=warning1&call :sound_play
	if "%check%"=="0" goto 2_choose_custom_install_type2_wiiu
	
	set sound_play=confirm1&call :sound_play&goto 2_2_wiiu
	)
set sound_play=select3&call :sound_play
if "%s%"=="1" goto 2_switch_region_wiiu
if "%s%"=="2" goto 2_switch_news_wiiu
if "%s%"=="3" goto 2_switch_evc_wiiu
if not "%evcregion%"=="3" if "%s%"=="4" goto 2_switch_nc_wiiu
if "%s%"=="5" goto 2_switch_cmoc_wiiu
if "%s%"=="6" goto 2_switch_internet_channel_wiiu
if "%s%"=="7" goto 2_switch_photo_channel_wiiu
if "%s%"=="8" goto 2_switch_wii_speak_channel_wiiu
if "%s%"=="9" goto 2_switch_today_and_tomorrow_channel_wiiu

if "%s%"=="r" goto begin_main
if "%s%"=="R" goto begin_main
goto 2_choose_custom_install_type2_wiiu
:2_switch_internet_channel_wiiu
if %internet_channel_enable%==1 set /a internet_channel_enable=0&goto 2_choose_custom_install_type2_wiiu
if %internet_channel_enable%==0 set /a internet_channel_enable=1&goto 2_choose_custom_install_type2_wiiu

:2_switch_photo_channel_wiiu
if %photo_channel_enable%==1 set /a photo_channel_enable=0&goto 2_choose_custom_install_type2_wiiu
if %photo_channel_enable%==0 set /a photo_channel_enable=1&goto 2_choose_custom_install_type2_wiiu

:2_switch_wii_speak_channel_wiiu
if %wii_speak_channel_enable%==1 set /a wii_speak_channel_enable=0&goto 2_choose_custom_install_type2_wiiu
if %wii_speak_channel_enable%==0 set /a wii_speak_channel_enable=1&goto 2_choose_custom_install_type2_wiiu

:2_switch_news_wiiu
if %custominstall_news_fore%==1 set /a custominstall_news_fore=0&goto 2_choose_custom_install_type2_wiiu
if %custominstall_news_fore%==0 set /a custominstall_news_fore=1&goto 2_choose_custom_install_type2_wiiu
:2_switch_region_wiiu
if %evcregion%==1 set /a evcregion=2&goto 2_choose_custom_install_type2_wiiu
if %evcregion%==2 set /a evcregion=3&goto 2_choose_custom_install_type2_wiiu
if %evcregion%==3 set /a evcregion=1&goto 2_choose_custom_install_type2_wiiu
:2_switch_evc_wiiu
if %custominstall_evc%==1 set /a custominstall_evc=0&goto 2_choose_custom_install_type2_wiiu
if %custominstall_evc%==0 set /a custominstall_evc=1&goto 2_choose_custom_install_type2_wiiu
:2_switch_nc_wiiu
if %custominstall_nc%==1 set /a custominstall_nc=0&goto 2_choose_custom_install_type2_wiiu
if %custominstall_nc%==0 set /a custominstall_nc=1&goto 2_choose_custom_install_type2_wiiu
:2_switch_cmoc_wiiu
if %custominstall_cmoc%==1 set /a custominstall_cmoc=0&goto 2_choose_custom_install_type2_wiiu
if %custominstall_cmoc%==0 set /a custominstall_cmoc=1&goto 2_choose_custom_install_type2_wiiu

:2_switch_today_and_tomorrow_channel_wiiu
if %today_and_tomorrow_enable%==1 set /a today_and_tomorrow_enable=0&goto 2_choose_custom_install_type2_wiiu
if %today_and_tomorrow_enable%==0 set /a today_and_tomorrow_enable=1&goto 2_choose_custom_install_type2_wiiu


:2_auto_wiiu
set /a internet_channel_enable=0
set /a photo_channel_enable=0
set /a wii_speak_channel_enable=0
set /a today_and_tomorrow_enable=0
cls
echo %header%
echo -----------------------------------------------------------------------------------------------------------------------------
echo.
echo %string214% %username%, %string215%
echo.
echo %string216%
echo %string217%
echo.
echo %string218%
echo.
echo %string219% %string204%, %string205%, %string207% %string220% %string206%, %string221% 
echo %string222%
echo.
echo 1. %string183% (E)
echo 2. %string184% (U)
echo 3. %string531% (J)
echo 4. %string537% (K)
echo.
set /p s=%string223%: 
set sound_play=confirm1&call :sound_play
if "%s%"=="e" set /a evcregion=1& goto 2_1_1_wiiu
if "%s%"=="u" set /a evcregion=2& goto 2_1_1_wiiu
if "%s%"=="j" set /a evcregion=3& goto 2_1_1_wiiu
if "%s%"=="k" set /a evcregion=4& goto 2_1_1_wiiu

if "%s%"=="E" set /a evcregion=1& goto 2_1_1_wiiu
if "%s%"=="U" set /a evcregion=2& goto 2_1_1_wiiu
if "%s%"=="J" set /a evcregion=3& goto 2_1_1_wiiu
if "%s%"=="K" set /a evcregion=4& goto 2_1_1_wiiu


if "%s%"=="1" set /a evcregion=1& goto 2_1_1_wiiu
if "%s%"=="2" set /a evcregion=2& goto 2_1_1_wiiu
if "%s%"=="3" set /a evcregion=3& goto 2_1_1_wiiu
if "%s%"=="4" set /a evcregion=4& goto 2_1_1_wiiu
goto 2_auto

:2_1_1_wiiu
cls
echo %header%
echo -----------------------------------------------------------------------------------------------------------------------------
echo.
echo %string554%
echo.
echo %string555%.
echo %string556%
echo.
if %photo_channel_enable%==0 echo 1. [ ] %string557%
if %photo_channel_enable%==1 echo 1. [X] %string557%
if %wii_speak_channel_enable%==0 echo 2. [ ] %string558%
if %wii_speak_channel_enable%==1 echo 2. [X] %string558%
if %today_and_tomorrow_enable%==0 echo 3. [ ] %string559%
if %today_and_tomorrow_enable%==1 echo 3. [X] %string559%
if not %evcregion%==4 if %internet_channel_enable%==0 echo 4. [ ] %string560%
if not %evcregion%==4 if %internet_channel_enable%==1 echo 4. [X] %string560%

echo.
echo 5. %string110%
set /p s=%string26%: 
if %s%==5 set sound_play=confirm1&call :sound_play&goto 2_1_2_wiiu
set sound_play=select3&call :sound_play
if %s%==1 goto 2_1_1_switch_2_wiiu
if %s%==2 goto 2_1_1_switch_3_wiiu
if %s%==3 goto 2_1_1_switch_4_wiiu
if not %evcregion%==4 if %s%==4 goto 2_1_1_switch_1_wiiu
goto 2_1_1_wiiu
:2_1_1_switch_1_wiiu
if %internet_channel_enable%==1 set /a internet_channel_enable=0&goto 2_1_1_wiiu
if %internet_channel_enable%==0 set /a internet_channel_enable=1&goto 2_1_1_wiiu

:2_1_1_switch_2_wiiu
if %photo_channel_enable%==1 set /a photo_channel_enable=0&goto 2_1_1_wiiu
if %photo_channel_enable%==0 set /a photo_channel_enable=1&goto 2_1_1_wiiu

:2_1_1_switch_3_wiiu
if %wii_speak_channel_enable%==1 set /a wii_speak_channel_enable=0&goto 2_1_1_wiiu
if %wii_speak_channel_enable%==0 set /a wii_speak_channel_enable=1&goto 2_1_1_wiiu

:2_1_1_switch_4_wiiu
if %today_and_tomorrow_enable%==1 set /a today_and_tomorrow_enable=0&goto 2_1_1_wiiu
if %today_and_tomorrow_enable%==0 set /a today_and_tomorrow_enable=1&goto 2_1_1_wiiu

:2_1_2_wiiu

if not %evcregion%==3 if not %evcregion%==4 (
	set /a custominstall_ios=1
	set /a custominstall_evc=1
	set /a custominstall_nc=1
	set /a custominstall_cmoc=1
	set /a custominstall_news_fore=1
	)
	
if %evcregion%==3 (
	set /a custominstall_ios=1
	set /a custominstall_evc=1
	set /a custominstall_nc=0
	set /a custominstall_cmoc=1
	set /a custominstall_news_fore=1
	)
	
if %evcregion%==4 (
	set /a custominstall_ios=1
	set /a custominstall_evc=0
	set /a custominstall_nc=0
	set /a custominstall_cmoc=0
	set /a custominstall_news_fore=0
	)

setlocal disableDelayedExpansion
cls
echo %header%
echo -----------------------------------------------------------------------------------------------------------------------------
echo.
echo %string224%
echo %string225% :)
echo.
echo %string226% 
echo %string227%
echo.
echo %string228%
echo.
echo 1. %string229%
echo 2. %string230%
set /p s=
set sdcard=NUL
if %s%==1 set sound_play=confirm1&call :sound_play&set /a sdcardstatus=1& set tempgotonext=2_1_summary_wiiu& goto detect_sd_card
if %s%==2 set sound_play=exit1&call :sound_play&set /a sdcardstatus=0&set sdcard=NUL&set /a sdcard_refresh_pending=1& goto 2_1_summary_wiiu
goto 2_1_wiiu
:2_1_summary_wiiu
cls
echo %header%
echo -----------------------------------------------------------------------------------------------------------------------------
echo.
if %sdcardstatus%==0 echo %string231%
if %sdcardstatus%==1 if %sdcard%==NUL echo %string232%
if %sdcardstatus%==1 if %sdcard%==NUL echo %string233%
if %sdcardstatus%==1 if %sdcard%==NUL echo.
if %sdcardstatus%==1 if %sdcard%==NUL echo %string234%
if %sdcardstatus%==1 if not %sdcard%==NUL echo %string235% %sdcard%
if %sdcardstatus%==1 if not %sdcard%==NUL echo %string236%	
echo.
echo %string237%
echo.
echo %string238%
if %sdcardstatus%==0 echo 1. %string239%  2. %string240%
if %sdcardstatus%==1 if %sdcard%==NUL echo 1. %string239% 2. %string240% 3. %string241%
if %sdcardstatus%==1 if not %sdcard%==NUL echo 1. %string239% 2. %string240% 3. %string241%

set /p s=%string26%: 
if %s%==1 set sound_play=confirm1&call :sound_play&goto check_for_wad_folder
if %s%==2 set sound_play=exit1&call :sound_play&goto begin_main
if %s%==3 set sound_play=confirm1&call :sound_play&goto 2_change_drive_letter_wiiu
goto 2_1_summary_wiiu
:check_for_wad_folder
if not exist "WAD" goto 2_2_wiiu
cls
set sound_play=warning1&call :sound_play
echo %header%
echo -----------------------------------------------------------------------------------------------------------------------------
echo.
echo %string242%
echo %string243%
echo.
echo %string244%
echo 1. %string245%
echo 2. %string246%
set /p s=%string26%: 
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
set /a progress_news_fore=0
set /a progress_ios=0
set /a progress_evc=0
set /a progress_nc=0
set /a progress_cmoc=0
set /a progress_finishing=0
set /a progress_additional=0
set /a wiiu_return=1

set /a total_additional=0
set /a total_additional=%internet_channel_enable%+%photo_channel_enable%+%wii_speak_channel_enable%+%today_and_tomorrow_enable%

>"%MainFolder%\patching_output.txt" echo Begin saving output.
>>"%MainFolder%\patching_output.txt" echo.


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
echo %header%
echo ---------------------------------------------------------------------------------------------------------------------------
echo  [*] %string247%

if %troubleshoot_auto_tool_notification%==1 echo :------------------------------------------------------------------------------------------------------------------------:
if %troubleshoot_auto_tool_notification%==1 echo   %string248%
if %troubleshoot_auto_tool_notification%==1 echo   %string249%
if %troubleshoot_auto_tool_notification%==1 echo :------------------------------------------------------------------------------------------------------------------------:
echo.

set /a refreshing_in=20-"%ss%">>NUL
echo ---------------------------------------------------------------------------------------------------------------------------
echo %string250%: %funfact%
echo ---------------------------------------------------------------------------------------------------------------------------
if /i %refreshing_in% GTR 0 echo %string251%... %refreshing_in% %string252%
if /i %refreshing_in% LEQ 0 echo %string251%... 0 %string252%
echo.

echo    %string253%:
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
if "%progress_downloading%"=="0" echo [ ] %string254%
if "%progress_downloading%"=="1" echo [X] %string254%
if "%custominstall_news_fore%"=="1" if "%progress_news_fore%"=="0" echo [ ] %string469%
if "%custominstall_news_fore%"=="1" if "%progress_news_fore%"=="1" echo [X] %string469%
if "%custominstall_evc%"=="1" if "%progress_evc%"=="0" echo [ ] %string205%
if "%custominstall_evc%"=="1" if "%progress_evc%"=="1" echo [X] %string205%
if "%custominstall_cmoc%"=="1" if "%evcregion%"=="1" if %progress_cmoc%==0 echo [ ] %string256%
if "%custominstall_cmoc%"=="1" if "%evcregion%"=="1" if %progress_cmoc%==1 echo [X] %string256%
if "%custominstall_cmoc%"=="1" if "%evcregion%"=="2" if %progress_cmoc%==0 echo [ ] %string257%
if "%custominstall_cmoc%"=="1" if "%evcregion%"=="2" if %progress_cmoc%==1 echo [X] %string257%
if "%custominstall_nc%"=="1" if "%progress_nc%"=="0" echo [ ] %string206%
if "%custominstall_nc%"=="1" if "%progress_nc%"=="1" echo [X] %string206%
if not "%total_additional%"=="0" if "%progress_additional%"=="0" echo [ ] %string540%
if not "%total_additional%"=="0" if "%progress_additional%"=="1" echo [X] %string540%
if "%progress_finishing%"=="0" echo [ ] %string258%
if "%progress_finishing%"=="1" echo [X] %string258%

>>"%MainFolder%\patching_output.txt" echo [%time:~0,8% / %date%] - %percent%%%
call :wiiu_patching_fast_travel_%percent%

if %percent%==100 goto 2_4_wiiu
::ping localhost -n 1 >NUL

if /i %ss% GEQ 20 goto random_funfact
set /a percent=%percent%+1

goto 2_3_wiiu

::Download files
:wiiu_patching_fast_travel_1
call :clean_temp_files
	call :check_rc24_server_connection
	if "%errorlevel%"=="1" goto server_connection_lost


if %percent%==1 if not exist "WAD" md WAD
exit /b 0
::EVC
:wiiu_patching_fast_travel_4
if not exist EVCPatcher/patch md EVCPatcher\patch
if not exist EVCPatcher/dwn md EVCPatcher\dwn
if not exist EVCPatcher/dwn/0001000148414A45v512 md EVCPatcher\dwn\0001000148414A45v512
if not exist EVCPatcher/dwn/0001000148414A50v512 md EVCPatcher\dwn\0001000148414A50v512
if not exist EVCPatcher/dwn/0001000148414A4Av512 md EVCPatcher\dwn\0001000148414A4Av512
if not exist EVCPatcher/pack md EVCPatcher\pack
if not exist "EVCPatcher/patch/Europe.delta" curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/EVCPatcher/patch/Europe.delta" --output EVCPatcher/patch/Europe.delta

set /a temperrorlev=%errorlevel%	
set modul=Downloading Europe Delta
if not %temperrorlev%==0 goto error_patching
if not exist "EVCPatcher/patch/USA.delta" curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/EVCPatcher/patch/USA.delta" --output EVCPatcher/patch/USA.delta
set /a temperrorlev=%errorlevel%
set modul=Downloading USA Delta
if not %temperrorlev%==0 goto error_patching
exit /b 0
:wiiu_patching_fast_travel_7
if not exist "EVCPatcher/NUS_Downloader_Decrypt.exe" curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/EVCPatcher/NUS_Downloader_Decrypt.exe" --output EVCPatcher/NUS_Downloader_Decrypt.exe
set /a temperrorlev=%errorlevel%
set modul=Downloading decrypter
if not %temperrorlev%==0 goto error_patching
exit /b 0

:wiiu_patching_fast_travel_8
if not exist "EVCPatcher/patch/xdelta3.exe" curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/EVCPatcher/patch/xdelta3.exe" --output EVCPatcher/patch/xdelta3.exe
set /a temperrorlev=%errorlevel%
set modul=Downloading xdelta3.exe
if not %temperrorlev%==0 goto error_patching

if not exist "EVCPatcher/pack/libWiiSharp.dll" curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/EVCPatcher/pack/libWiiSharp.dll" --output "EVCPatcher/pack/libWiiSharp.dll"
set /a temperrorlev=%errorlevel%
set modul=Downloading libWiiSharp.dll
if not %temperrorlev%==0 goto error_patching

if not exist "EVCPatcher/pack/Sharpii.exe" curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/EVCPatcher/pack/Sharpii.exe" --output EVCPatcher/pack/Sharpii.exe
set /a temperrorlev=%errorlevel%
set modul=Downloading Sharpii.exe
if not %temperrorlev%==0 goto error_patching
if not exist "EVCPatcher/dwn/Sharpii.exe" curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/EVCPatcher/dwn/Sharpii.exe" --output EVCPatcher/dwn/Sharpii.exe
set /a temperrorlev=%errorlevel%
set modul=Downloading Sharpii.exe
if not %temperrorlev%==0 goto error_patching
exit /b 0
:wiiu_patching_fast_travel_9
if not exist "EVCPatcher/dwn/libWiiSharp.dll" curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/EVCPatcher/dwn/libWiiSharp.dll" --output EVCPatcher/dwn/libWiiSharp.dll
set /a temperrorlev=%errorlevel%
set modul=Downloading libWiiSharp.dll
if not %temperrorlev%==0 goto error_patching
exit /b 0
:wiiu_patching_fast_travel_10
if not exist "EVCPatcher/dwn/0001000148414A45v512/cetk" curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/EVCPatcher/dwn/0001000148414A45v512/cetk" --output EVCPatcher/dwn/0001000148414A45v512/cetk
set /a temperrorlev=%errorlevel%
set modul=Downloading USA CETK
if not %temperrorlev%==0 goto error_patching

if not exist "EVCPatcher/dwn/0001000148414A50v512/cetk" curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/EVCPatcher/dwn/0001000148414A50v512/cetk" --output EVCPatcher/dwn/0001000148414A50v512/cetk
set /a temperrorlev=%errorlevel%
set modul=Downloading EUR CETK
if not %temperrorlev%==0 goto error_patching

if not exist "EVCPatcher/dwn/0001000148414A4Av512/cetk" curl -f -L -s -S  %useragent% --insecure "%FilesHostedOn%/EVCPatcher/dwn/0001000148414A4Av512/cetk" --output EVCPatcher/dwn/0001000148414A4Av512/cetk>>"%MainFolder%\patching_output.txt"
set /a temperrorlev=%errorlevel%
set modul=Downloading JPN CETK
if not %temperrorlev%==0 goto error_patching
echo cURL OK>>"%MainFolder%\patching_output.txt"

if not exist "cert.sys" curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/cert.sys" --output cert.sys>>"%MainFolder%\patching_output.txt"
set /a temperrorlev=%errorlevel%
set /a progress_downloading=1
set modul=Downloading cert.sys
if not %temperrorlev%==0 goto error_patching

exit /b 0

::CMOC
:wiiu_patching_fast_travel_11
if not exist CMOCPatcher/patch md CMOCPatcher\patch
if not exist CMOCPatcher/dwn md CMOCPatcher\dwn
if not exist CMOCPatcher/dwn/0001000148415045v512 md CMOCPatcher\dwn\0001000148415045v512
if not exist CMOCPatcher/dwn/0001000148415050v512 md CMOCPatcher\dwn\0001000148415050v512
if not exist CMOCPatcher/dwn/000100014841504Av512 md CMOCPatcher\dwn\000100014841504Av512
if not exist CMOCPatcher/pack md CMOCPatcher\pack
if not exist "CMOCPatcher/patch/00000001_Europe.delta" curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/CMOCPatcher/patch/00000001_Europe.delta" --output CMOCPatcher/patch/00000001_Europe.delta
if not exist "CMOCPatcher/patch/00000004_Europe.delta" curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/CMOCPatcher/patch/00000004_Europe.delta" --output CMOCPatcher/patch/00000004_Europe.delta
set /a temperrorlev=%errorlevel%
set modul=Downloading Europe Delta
if not %temperrorlev%==0 goto error_patching
exit /b 0
:wiiu_patching_fast_travel_12
if not exist "CMOCPatcher/patch/00000001_USA.delta" curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/CMOCPatcher/patch/00000001_USA.delta" --output CMOCPatcher/patch/00000001_USA.delta
if not exist "CMOCPatcher/patch/00000004_USA.delta" curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/CMOCPatcher/patch/00000004_USA.delta" --output CMOCPatcher/patch/00000004_USA.delta
set /a temperrorlev=%errorlevel%
set modul=Downloading USA Delta
if not %temperrorlev%==0 goto error_patching

if not exist "CMOCPatcher/patch/00000001_Japan.delta" curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/CMOCPatcher/patch/00000001_Japan.delta" --output CMOCPatcher/patch/00000001_Japan.delta>>"%MainFolder%\patching_output.txt"
if not exist "CMOCPatcher/patch/00000004_Japan.delta" curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/CMOCPatcher/patch/00000004_Japan.delta" --output CMOCPatcher/patch/00000004_Japan.delta>>"%MainFolder%\patching_output.txt"
set /a temperrorlev=%errorlevel%
set modul=Downloading Japan Delta
if not %temperrorlev%==0 goto error_patching
echo cURL OK>>"%MainFolder%\patching_output.txt"

if not exist "CMOCPatcher/NUS_Downloader_Decrypt.exe" curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/CMOCPatcher/NUS_Downloader_Decrypt.exe" --output CMOCPatcher/NUS_Downloader_Decrypt.exe
set /a temperrorlev=%errorlevel%
set modul=Downloading decrypter
if not %temperrorlev%==0 goto error_patching
exit /b 0
:wiiu_patching_fast_travel_13
if not exist "CMOCPatcher/patch/xdelta3.exe" curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/CMOCPatcher/patch/xdelta3.exe" --output CMOCPatcher/patch/xdelta3.exe
set /a temperrorlev=%errorlevel%
set modul=Downloading xdelta3.exe
if not %temperrorlev%==0 goto error_patching
exit /b 0
:wiiu_patching_fast_travel_14
if not exist "CMOCPatcher/pack/libWiiSharp.dll" curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/CMOCPatcher/pack/libWiiSharp.dll" --output "CMOCPatcher/pack/libWiiSharp.dll"
set /a temperrorlev=%errorlevel%
set modul=Downloading libWiiSharp.dll
if not %temperrorlev%==0 goto error_patching
exit /b 0
:wiiu_patching_fast_travel_15
if not exist "CMOCPatcher/pack/Sharpii.exe" curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/CMOCPatcher/pack/Sharpii.exe" --output CMOCPatcher/pack/Sharpii.exe
set /a temperrorlev=%errorlevel%
set modul=Downloading Sharpii.exe
if not %temperrorlev%==0 goto error_patching
exit /b 0
:wiiu_patching_fast_travel_16
if not exist "CMOCPatcher/dwn/Sharpii.exe" curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/CMOCPatcher/dwn/Sharpii.exe" --output CMOCPatcher/dwn/Sharpii.exe
set /a temperrorlev=%errorlevel%
set modul=Downloading Sharpii.exe
if not %temperrorlev%==0 goto error_patching
exit /b 0
:wiiu_patching_fast_travel_17
if not exist "CMOCPatcher/dwn/libWiiSharp.dll" curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/CMOCPatcher/dwn/libWiiSharp.dll" --output CMOCPatcher/dwn/libWiiSharp.dll
set /a temperrorlev=%errorlevel%
set modul=Downloading libWiiSharp.dll
if not %temperrorlev%==0 goto error_patching
exit /b 0
:wiiu_patching_fast_travel_18
if not exist "CMOCPatcher/dwn/0001000148415045v512/cetk" curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/CMOCPatcher/dwn/0001000148415045v512/cetk" --output CMOCPatcher/dwn/0001000148415045v512/cetk
if not exist "CMOCPatcher/dwn/0001000148415045v512/cert" curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/CMOCPatcher/dwn/0001000148415045v512/cert" --output CMOCPatcher/dwn/0001000148415045v512/cert
set /a temperrorlev=%errorlevel%
set modul=Downloading USA CETK
if not %temperrorlev%==0 goto error_patching
exit /b 0
:wiiu_patching_fast_travel_19
if not exist "CMOCPatcher/dwn/0001000148415050v512/cetk" curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/CMOCPatcher/dwn/0001000148415050v512/cetk" --output CMOCPatcher/dwn/0001000148415050v512/cetk
if not exist "CMOCPatcher/dwn/0001000148415050v512/cert" curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/CMOCPatcher/dwn/0001000148415050v512/cert" --output CMOCPatcher/dwn/0001000148415050v512/cert
set /a temperrorlev=%errorlevel%
set modul=Downloading EUR CETK
if not %temperrorlev%==0 goto error_patching

if not exist "CMOCPatcher/dwn/000100014841504Av512/cetk" curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/CMOCPatcher/dwn/000100014841504Av512/cetk" --output CMOCPatcher/dwn/000100014841504Av512/cetk>>"%MainFolder%\patching_output.txt"
if not exist "CMOCPatcher/dwn/000100014841504Av512/cert" curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/CMOCPatcher/dwn/000100014841504Av512/cert" --output CMOCPatcher/dwn/000100014841504Av512/cert>>"%MainFolder%\patching_output.txt"
set /a temperrorlev=%errorlevel%
set modul=Downloading JPN CETK
if not %temperrorlev%==0 goto error_patching

exit /b 0


::NC
:wiiu_patching_fast_travel_20
if not exist NCPatcher/patch md NCPatcher\patch
if not exist NCPatcher/dwn md NCPatcher\dwn
if not exist NCPatcher/dwn/0001000148415450v1792 md NCPatcher\dwn\0001000148415450v1792
if not exist NCPatcher/dwn/0001000148415445v1792 md NCPatcher\dwn\0001000148415445v1792
if not exist NCPatcher/dwn/000100014841544Av1792 md NCPatcher\dwn\000100014841544Av1792
if not exist NCPatcher/pack md NCPatcher\pack

	call :check_rc24_server_connection
	if "%errorlevel%"=="1" goto server_connection_lost



if not exist "NCPatcher/patch/Europe.delta" curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/NCPatcher/patch/Europe.delta" --output NCPatcher/patch/Europe.delta
set /a temperrorlev=%errorlevel%
set modul=Downloading Europe Delta [NC]
if not %temperrorlev%==0 goto error_patching

if not exist "NCPatcher/patch/USA.delta" curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/NCPatcher/patch/USA.delta" --output NCPatcher/patch/USA.delta
set /a temperrorlev=%errorlevel%
set modul=Downloading USA Delta [NC]
if not %temperrorlev%==0 goto error_patching

if not exist "NCPatcher/patch/JPN.delta" curl -f -L -s -S  %useragent% --insecure "%FilesHostedOn%/NCPatcher/patch/JPN.delta" --output NCPatcher/patch/JPN.delta>>"%MainFolder%\patching_output.txt"
set /a temperrorlev=%errorlevel%
set modul=Downloading JPN Delta [NC]
if not %temperrorlev%==0 goto error_patching
echo cURL OK>>"%MainFolder%\patching_output.txt"


if not exist "NCPatcher/NUS_Downloader_Decrypt.exe" curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/NCPatcher/NUS_Downloader_Decrypt.exe" --output NCPatcher/NUS_Downloader_Decrypt.exe
set /a temperrorlev=%errorlevel%
set modul=Downloading Decrypter
if not %temperrorlev%==0 goto error_patching
exit /b 0
:wiiu_patching_fast_travel_21
if not exist "NCPatcher/patch/xdelta3.exe" curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/NCPatcher/patch/xdelta3.exe" --output NCPatcher/patch/xdelta3.exe
set /a temperrorlev=%errorlevel%
set modul=Downloading xdelta3.exe
if not %temperrorlev%==0 goto error_patching

if not exist "NCPatcher/pack/libWiiSharp.dll" curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/NCPatcher/pack/libWiiSharp.dll" --output NCPatcher/pack/libWiiSharp.dll
set /a temperrorlev=%errorlevel%
set modul=Downloading libWiiSharp.dll
if not %temperrorlev%==0 goto error_patching

if not exist "NCPatcher/pack/Sharpii.exe" curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/NCPatcher/pack/Sharpii.exe" --output NCPatcher/pack/Sharpii.exe
set /a temperrorlev=%errorlevel%
set modul=Downloading Sharpii.exe
if not %temperrorlev%==0 goto error_patching
exit /b 0
:wiiu_patching_fast_travel_22
if not exist "NCPatcher/dwn/Sharpii.exe" curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/NCPatcher/dwn/Sharpii.exe" --output NCPatcher/dwn/Sharpii.exe
set /a temperrorlev=%errorlevel%
set modul=Downloading Sharpii.exe
if not %temperrorlev%==0 goto error_patching
exit /b 0
:wiiu_patching_fast_travel_23
if not exist "NCPatcher/dwn/libWiiSharp.dll" curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/NCPatcher/dwn/libWiiSharp.dll" --output NCPatcher/dwn/libWiiSharp.dll
set /a temperrorlev=%errorlevel%
set modul=Downloading libWiiSharp.dll
if not %temperrorlev%==0 goto error_patching
exit /b 0
:wiiu_patching_fast_travel_24
if not exist "NCPatcher/dwn/0001000148415445v1792/cetk" curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/NCPatcher/dwn/0001000148415445v1792/cetk" --output NCPatcher/dwn/0001000148415445v1792/cetk
set /a temperrorlev=%errorlevel%
set modul=Downloading USA CETK
if not %temperrorlev%==0 goto error_patching

if not exist "NCPatcher/dwn/0001000148415450v1792/cetk" curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/NCPatcher/dwn/0001000148415450v1792/cetk" --output NCPatcher/dwn/0001000148415450v1792/cetk
set /a temperrorlev=%errorlevel%
set modul=Downloading EUR CETK
if not %temperrorlev%==0 goto error_patching

if not exist "NCPatcher/dwn/000100014841544Av1792/cetk" curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/NCPatcher/dwn/000100014841544Av1792/cetk" --output NCPatcher/dwn/000100014841544Av1792/cetk>>"%MainFolder%\patching_output.txt"
set /a temperrorlev=%errorlevel%
set modul=Downloading JPN CETK
if not %temperrorlev%==0 goto error_patching
exit /b 0

::Everything else
:wiiu_patching_fast_travel_25
if not exist apps md apps
exit /b 0

:wiiu_patching_fast_travel_26
if not exist apps/WiiModLite md apps\WiiModLite
if not exist "apps/WiiModLite/boot.dol" curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/apps/WiiModLite/boot.dol" --output apps/WiiModLite/boot.dol
set /a temperrorlev=%errorlevel%
set modul=Downloading Wii Mod Lite
if not %temperrorlev%==0 goto error_patching

if not exist "apps/WiiModLite/database.txt" curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/apps/WiiModLite/database.txt" --output apps/WiiModLite/database.txt
set /a temperrorlev=%errorlevel%
set modul=Downloading Wii Mod Lite
if not %temperrorlev%==0 goto error_patching
exit /b 0
:wiiu_patching_fast_travel_27
if not exist "apps/WiiModLite/icon.png" curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/apps/WiiModLite/icon.png" --output apps/WiiModLite/icon.png
set /a temperrorlev=%errorlevel%
set modul=Downloading Wii Mod Lite
if not %temperrorlev%==0 goto error_patching

if not exist "apps/WiiModLite/icon.png" curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/apps/WiiModLite/icon.png" --output apps/WiiModLite/icon.png
set /a temperrorlev=%errorlevel%
set modul=Downloading Wii Mod Lite
if not %temperrorlev%==0 goto error_patching
exit /b 0

:wiiu_patching_fast_travel_28
if not exist apps/ww-43db-patcher md apps\ww-43db-patcher
if not exist "apps/WiiModLite/meta.xml" curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/apps/WiiModLite/meta.xml" --output apps/WiiModLite/meta.xml
set /a temperrorlev=%errorlevel%
set modul=Downloading Wii Mod Lite
if not %temperrorlev%==0 goto error_patching
if not exist "apps/WiiModLite/wiimod.txt" curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/apps/WiiModLite/wiimod.txt" --output apps/WiiModLite/wiimod.txt
set /a temperrorlev=%errorlevel%
set modul=Downloading Wii Mod Lite
if not %temperrorlev%==0 goto error_patching

if not exist "apps/ww-43db-patcher/meta.xml" curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/apps/ww-43db-patcher/meta.xml" --output apps/ww-43db-patcher/meta.xml
set /a temperrorlev=%errorlevel%
set modul=Downloading ww-43db-patcher
if not %temperrorlev%==0 goto error_patching
if not exist "apps/ww-43db-patcher/icon.png" curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/apps/ww-43db-patcher/icon.png" --output apps/ww-43db-patcher/icon.png
set /a temperrorlev=%errorlevel%
set modul=Downloading ww-43db-patcher
if not %temperrorlev%==0 goto error_patching
if not exist "apps/ww-43db-patcher/boot.dol" curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/apps/ww-43db-patcher/boot.dol" --output apps/ww-43db-patcher/boot.dol
set /a temperrorlev=%errorlevel%
set modul=Downloading ww-43db-patcher
if not %temperrorlev%==0 goto error_patching







exit /b 0
:wiiu_patching_fast_travel_29
	call :check_rc24_server_connection
	if "%errorlevel%"=="1" goto server_connection_lost

	if not exist "WAD/ConnectMii (RiiConnect24).wad" curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/apps/ConnectMii_WAD/ConnectMii.wad" --output "WAD/ConnectMii (RiiConnect24).wad"
set /a temperrorlev=%errorlevel%
set modul=Downloading ConnectMii
if not %temperrorlev%==0 goto error_patching


exit /b 0
:wiiu_patching_fast_travel_30
if not exist "EVCPatcher/patch/Europe.delta" curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/EVCPatcher/patch/Europe.delta" --output EVCPatcher/patch/Europe.delta
set /a temperrorlev=%errorlevel%
set modul=Downloading Europe Delta
if not %temperrorlev%==0 goto error_patching
exit /b 0
:wiiu_patching_fast_travel_31
if not exist "EVCPatcher/patch/USA.delta" curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/EVCPatcher/patch/USA.delta" --output EVCPatcher/patch/USA.delta
set /a temperrorlev=%errorlevel%
set modul=Downloading USA Delta
if not %temperrorlev%==0 goto error_patching

if not exist "EVCPatcher/patch/JPN.delta" curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/EVCPatcher/patch/JPN.delta" --output EVCPatcher/patch/JPN.delta
set /a temperrorlev=%errorlevel%
set modul=Downloading Japan Delta
if not %temperrorlev%==0 goto error_patching
exit /b 0

:wiiu_patching_fast_travel_32
if not exist "WAD/IOS31 Wii U (IOS) (RiiConnect24).wad" curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/IOSPatcher/IOS31_vwii.wad" --output "WAD/IOS31 Wii U (IOS) (RiiConnect24).wad"
set /a temperrorlev=%errorlevel%
set modul=Downloading IOS31
if not %temperrorlev%==0 goto error_patching
exit /b 0

:wiiu_patching_fast_travel_33
if not exist NewsChannelPatcher md NewsChannelPatcher

if not exist "NewsChannelPatcher\00000001.delta" curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/NewsChannelPatcher/00000001.delta" --output "NewsChannelPatcher/00000001.delta"
set /a temperrorlev=%errorlevel%
set modul=Downloading News Channel files
if not %temperrorlev%==0 goto error_patching

if not exist "NewsChannelPatcher\00000001_Forecast.delta" curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/NewsChannelPatcher/URL_Patches_WiiU/00000001_Forecast_All.delta" --output "NewsChannelPatcher/00000001_Forecast.delta"
set /a temperrorlev=%errorlevel%
set modul=Downloading Forecast Channel files
if not %temperrorlev%==0 goto error_patching

exit /b 0

:wiiu_patching_fast_travel_34
if not exist "NewsChannelPatcher\libWiiSharp.dll" curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/NewsChannelPatcher/libWiiSharp.dll" --output "NewsChannelPatcher/libWiiSharp.dll"
set /a temperrorlev=%errorlevel%
set modul=Downloading News Channel files
if not %temperrorlev%==0 goto error_patching
exit /b 0

:wiiu_patching_fast_travel_35
if not exist "NewsChannelPatcher\Sharpii.exe" curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/NewsChannelPatcher/Sharpii.exe" --output "NewsChannelPatcher/Sharpii.exe"
set /a temperrorlev=%errorlevel%
set modul=Downloading News Channel files
if not %temperrorlev%==0 goto error_patching
exit /b 0

:wiiu_patching_fast_travel_36
if not exist "NewsChannelPatcher\WadInstaller.dll" curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/NewsChannelPatcher/WadInstaller.dll" --output "NewsChannelPatcher/WadInstaller.dll"
set /a temperrorlev=%errorlevel%
set modul=Downloading News Channel files
if not %temperrorlev%==0 goto error_patching

if not exist "NewsChannelPatcher\xdelta3.exe" curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/NewsChannelPatcher/xdelta3.exe" --output "NewsChannelPatcher/xdelta3.exe"
set /a temperrorlev=%errorlevel%
set modul=Downloading News Channel files
if not %temperrorlev%==0 goto error_patching

	set /a progress_downloading=1
exit /b 0





::News Channel
:wiiu_patching_fast_travel_37
if "%custominstall_news_fore%"=="1" if %evcregion%==1 call NewsChannelPatcher\sharpii.exe nusd -id 0001000248414750 -v 7 -wad >>"%MainFolder%\patching_output.txt"
	if "%custominstall_news_fore%"=="1" if %evcregion%==1 set /a temperrorlev=%errorlevel%
	if "%custominstall_news_fore%"=="1" if %evcregion%==1 set modul=Downloading News Channel
	if "%custominstall_news_fore%"=="1" if %evcregion%==1 if not %temperrorlev%==0 goto error_patching
if "%custominstall_news_fore%"=="1" if %evcregion%==2 call NewsChannelPatcher\sharpii.exe nusd -id 0001000248414745 -v 7 -wad >>"%MainFolder%\patching_output.txt"
	if "%custominstall_news_fore%"=="1" if %evcregion%==2 set /a temperrorlev=%errorlevel%
	if "%custominstall_news_fore%"=="1" if %evcregion%==2 set modul=Downloading News Channel
	if "%custominstall_news_fore%"=="1" if %evcregion%==2 if not %temperrorlev%==0 goto error_patching
if "%custominstall_news_fore%"=="1" if %evcregion%==3 call NewsChannelPatcher\sharpii.exe nusd -id 000100024841474A -v 7 -wad >>"%MainFolder%\patching_output.txt"
	if "%custominstall_news_fore%"=="1" if %evcregion%==3 set /a temperrorlev=%errorlevel%
	if "%custominstall_news_fore%"=="1" if %evcregion%==3 set modul=Downloading News Channel
	if "%custominstall_news_fore%"=="1" if %evcregion%==3 if not %temperrorlev%==0 goto error_patching
exit /b 0
:wiiu_patching_fast_travel_38

if "%custominstall_news_fore%"=="1" if %evcregion%==1 call NewsChannelPatcher\sharpii.exe wad -u 0001000248414750v7.wad unpacked-temp/ >>"%MainFolder%\patching_output.txt"
	if "%custominstall_news_fore%"=="1" if %evcregion%==1 set /a temperrorlev=%errorlevel%
	if "%custominstall_news_fore%"=="1" if %evcregion%==1 set modul=Unpacking News Channel
	if "%custominstall_news_fore%"=="1" if %evcregion%==1 if not %temperrorlev%==0 goto error_patching
if "%custominstall_news_fore%"=="1" if %evcregion%==2 call NewsChannelPatcher\sharpii.exe wad -u 0001000248414745v7.wad unpacked-temp/ >>"%MainFolder%\patching_output.txt"
	if "%custominstall_news_fore%"=="1" if %evcregion%==2 set /a temperrorlev=%errorlevel%
	if "%custominstall_news_fore%"=="1" if %evcregion%==2 set modul=Unpacking News Channel
	if "%custominstall_news_fore%"=="1" if %evcregion%==2 if not %temperrorlev%==0 goto error_patching
if "%custominstall_news_fore%"=="1" if %evcregion%==3 call NewsChannelPatcher\sharpii.exe wad -u 000100024841474Av7.wad unpacked-temp/ >>"%MainFolder%\patching_output.txt"
	if "%custominstall_news_fore%"=="1" if %evcregion%==3 set /a temperrorlev=%errorlevel%
	if "%custominstall_news_fore%"=="1" if %evcregion%==3 set modul=Unpacking News Channel
	if "%custominstall_news_fore%"=="1" if %evcregion%==3 if not %temperrorlev%==0 goto error_patching
if "%custominstall_news_fore%"=="1" ren unpacked-temp\00000001.app source.app >>"%MainFolder%\patching_output.txt"
	if "%custominstall_news_fore%"=="1" set /a temperrorlev=%errorlevel%
	if "%custominstall_news_fore%"=="1" set modul=Moving News Channel 0000001.app
	if "%custominstall_news_fore%"=="1" if not %temperrorlev%==0 goto error_patching
if "%custominstall_news_fore%"=="1" call NewsChannelPatcher\xdelta3 -d -f -s unpacked-temp\source.app NewsChannelPatcher\00000001.delta unpacked-temp\00000001.app >>"%MainFolder%\patching_output.txt"
	if "%custominstall_news_fore%"=="1" set /a temperrorlev=%errorlevel%
	if "%custominstall_news_fore%"=="1" set modul=Patching News Channel delta
	if "%custominstall_news_fore%"=="1" if not %temperrorlev%==0 goto error_patching
exit /b 0
:wiiu_patching_fast_travel_39
if "%custominstall_news_fore%"=="1" if %evcregion%==1 NewsChannelPatcher\sharpii.exe wad -p unpacked-temp/ "WAD\News Channel Wii U (Europe) (Channel) (RiiConnect24).wad" >>"%MainFolder%\patching_output.txt"
	if "%custominstall_news_fore%"=="1" if %evcregion%==1 set /a temperrorlev=%errorlevel%
	if "%custominstall_news_fore%"=="1" if %evcregion%==1 set modul=Packing News Channel
	if "%custominstall_news_fore%"=="1" if %evcregion%==1 if not %temperrorlev%==0 goto error_patching
if "%custominstall_news_fore%"=="1" if %evcregion%==2 NewsChannelPatcher\sharpii.exe wad -p unpacked-temp/ "WAD\News Channel Wii U (USA) (Channel) (RiiConnect24).wad" >>"%MainFolder%\patching_output.txt"
	if "%custominstall_news_fore%"=="1" if %evcregion%==2 set /a temperrorlev=%errorlevel%
	if "%custominstall_news_fore%"=="1" if %evcregion%==2 set modul=Packing News Channel
	if "%custominstall_news_fore%"=="1" if %evcregion%==2 if not %temperrorlev%==0 goto error_patching
if "%custominstall_news_fore%"=="1" if %evcregion%==3 NewsChannelPatcher\sharpii.exe wad -p unpacked-temp/ "WAD\News Channel Wii U (Japan) (Channel) (RiiConnect24).wad" >>"%MainFolder%\patching_output.txt"
	if "%custominstall_news_fore%"=="1" if %evcregion%==3 set /a temperrorlev=%errorlevel%
	if "%custominstall_news_fore%"=="1" if %evcregion%==3 set modul=Packing News Channel
	if "%custominstall_news_fore%"=="1" if %evcregion%==3 if not %temperrorlev%==0 goto error_patching
exit /b 0
:wiiu_patching_fast_travel_40
if "%custominstall_news_fore%"=="1" if %evcregion%==1 call NewsChannelPatcher\sharpii.exe nusd -ID 0001000248414650 -v 7 -wad >>"%MainFolder%\patching_output.txt"
if "%custominstall_news_fore%"=="1" 	if %evcregion%==1 set /a temperrorlev=%errorlevel%
if "%custominstall_news_fore%"=="1" 	if %evcregion%==1 set modul=Downloading Forecast Channel
if "%custominstall_news_fore%"=="1" 	if %evcregion%==1 if not %temperrorlev%==0 goto error_patching
if "%custominstall_news_fore%"=="1" if %evcregion%==2 call NewsChannelPatcher\sharpii.exe nusd -ID 0001000248414645 -v 7 -wad >>"%MainFolder%\patching_output.txt"
if "%custominstall_news_fore%"=="1" 	if %evcregion%==2 set /a temperrorlev=%errorlevel%
if "%custominstall_news_fore%"=="1" 	if %evcregion%==2 set modul=Downloading Forecast Channel
if "%custominstall_news_fore%"=="1" 	if %evcregion%==2 if not %temperrorlev%==0 goto error_patching
if "%custominstall_news_fore%"=="1" if %evcregion%==3 call NewsChannelPatcher\sharpii.exe nusd -ID 000100024841464A -v 7 -wad >>"%MainFolder%\patching_output.txt"
if "%custominstall_news_fore%"=="1" 	if %evcregion%==3 set /a temperrorlev=%errorlevel%
if "%custominstall_news_fore%"=="1" 	if %evcregion%==3 set modul=Downloading Forecast Channel
if "%custominstall_news_fore%"=="1" 	if %evcregion%==3 if not %temperrorlev%==0 goto error_patching
rmdir /s /q unpacked-temp
:: Forecast Channel

if "%custominstall_news_fore%"=="1" if %evcregion%==1 call NewsChannelPatcher\sharpii.exe wad -u 0001000248414650v7.wad unpacked-temp >>"%MainFolder%\patching_output.txt"
if "%custominstall_news_fore%"=="1" 	if %evcregion%==1 set /a temperrorlev=%errorlevel%
if "%custominstall_news_fore%"=="1" 	if %evcregion%==1 set modul=Unpacking Forecast Channel
if "%custominstall_news_fore%"=="1" 	if %evcregion%==1 if not %temperrorlev%==0 goto error_patching
if "%custominstall_news_fore%"=="1" if %evcregion%==2 call NewsChannelPatcher\sharpii.exe wad -u 0001000248414645v7.wad unpacked-temp/ >>"%MainFolder%\patching_output.txt"
if "%custominstall_news_fore%"=="1" 	if %evcregion%==2 set /a temperrorlev=%errorlevel%
if "%custominstall_news_fore%"=="1" 	if %evcregion%==2 set modul=Unpacking Forecast Channel
if "%custominstall_news_fore%"=="1" 	if %evcregion%==2 if not %temperrorlev%==0 goto error_patching
if "%custominstall_news_fore%"=="1" if %evcregion%==3 call NewsChannelPatcher\sharpii.exe wad -u 000100024841464Av7.wad unpacked-temp/ >>"%MainFolder%\patching_output.txt"
if "%custominstall_news_fore%"=="1" 	if %evcregion%==3 set /a temperrorlev=%errorlevel%
if "%custominstall_news_fore%"=="1" 	if %evcregion%==3 set modul=Unpacking Forecast Channel
if "%custominstall_news_fore%"=="1" 	if %evcregion%==3 if not %temperrorlev%==0 goto error_patching

if "%custominstall_news_fore%"=="1" ren unpacked-temp\00000001.app source.app
if "%custominstall_news_fore%"=="1" 	set /a temperrorlev=%errorlevel%
if "%custominstall_news_fore%"=="1" 	set modul=Moving Forecast Channel 0000001.app
if "%custominstall_news_fore%"=="1" 	if not %temperrorlev%==0 goto error_patching
if "%custominstall_news_fore%"=="1" if %evcregion%==1 call NewsChannelPatcher\xdelta3 -d -f -s unpacked-temp\source.app NewsChannelPatcher\00000001_Forecast.delta unpacked-temp\00000001.app >>"%MainFolder%\patching_output.txt"
if "%custominstall_news_fore%"=="1" if %evcregion%==2 call NewsChannelPatcher\xdelta3 -d -f -s unpacked-temp\source.app NewsChannelPatcher\00000001_Forecast.delta unpacked-temp\00000001.app >>"%MainFolder%\patching_output.txt"
if "%custominstall_news_fore%"=="1" if %evcregion%==3 call NewsChannelPatcher\xdelta3 -d -f -s unpacked-temp\source.app NewsChannelPatcher\00000001_Forecast.delta unpacked-temp\00000001.app >>"%MainFolder%\patching_output.txt"
if "%custominstall_news_fore%"=="1" 	set /a temperrorlev=%errorlevel%
if "%custominstall_news_fore%"=="1" 	set modul=Patching Forecast Channel delta
if "%custominstall_news_fore%"=="1" 	if not %temperrorlev%==0 goto error_patching
exit /b 0
:wiiu_patching_fast_travel_41
if "%custominstall_news_fore%"=="1" if %evcregion%==1 NewsChannelPatcher\sharpii.exe wad -p unpacked-temp\ "WAD\Forecast Channel Wii U (Europe) (Channel) (RiiConnect24).wad" >>"%MainFolder%\patching_output.txt"
if "%custominstall_news_fore%"=="1" 	if %evcregion%==1 set /a temperrorlev=%errorlevel%
if "%custominstall_news_fore%"=="1" 	if %evcregion%==1 set modul=Packing Forecast Channel
if "%custominstall_news_fore%"=="1" 	if %evcregion%==1 if not %temperrorlev%==0 goto error_patching
if "%custominstall_news_fore%"=="1" 	if %evcregion%==1 rmdir /s /q unpacked-temp
if "%custominstall_news_fore%"=="1" if %evcregion%==2 NewsChannelPatcher\sharpii.exe wad -p unpacked-temp\ "WAD\Forecast Channel Wii U (USA) (Channel) (RiiConnect24).wad" >>"%MainFolder%\patching_output.txt"
if "%custominstall_news_fore%"=="1" 	if %evcregion%==2 set /a temperrorlev=%errorlevel%
if "%custominstall_news_fore%"=="1" 	if %evcregion%==2 set modul=Packing Forecast Channel
if "%custominstall_news_fore%"=="1" 	if %evcregion%==2 if not %temperrorlev%==0 goto error_patching
if "%custominstall_news_fore%"=="1" 	if %evcregion%==2 rmdir /s /q unpacked-temp
if "%custominstall_news_fore%"=="1" if %evcregion%==3 NewsChannelPatcher\sharpii.exe wad -p unpacked-temp\ "WAD\Forecast Channel Wii U (Japan) (Channel) (RiiConnect24).wad" >>"%MainFolder%\patching_output.txt"
if "%custominstall_news_fore%"=="1" 	if %evcregion%==3 set /a temperrorlev=%errorlevel%
if "%custominstall_news_fore%"=="1" 	if %evcregion%==3 set modul=Packing Forecast Channel
if "%custominstall_news_fore%"=="1" 	if %evcregion%==3 if not %temperrorlev%==0 goto error_patching
if "%custominstall_news_fore%"=="1" 	if %evcregion%==3 rmdir /s /q unpacked-temp

set /a progress_news_fore=1
exit /b 0
::EVC Patcher
:wiiu_patching_fast_travel_42
if %custominstall_evc%==1 if not exist 0001000148414A4Av512 md 0001000148414A4Av512
if %custominstall_evc%==1 if not exist 0001000148414A50v512 md 0001000148414A50v512
if %custominstall_evc%==1 if not exist 0001000148414A45v512 md 0001000148414A45v512
if %custominstall_evc%==1 if not exist 0001000148414A50v512\cetk copy /y "EVCPatcher\dwn\0001000148414A50v512\cetk" "0001000148414A50v512\cetk" >>"%MainFolder%\patching_output.txt"

if %custominstall_evc%==1 if not exist 0001000148414A45v512\cetk copy /y "EVCPatcher\dwn\0001000148414A45v512\cetk" "0001000148414A45v512\cetk" >>"%MainFolder%\patching_output.txt"
if %custominstall_evc%==1 if not exist 0001000148414A4Av512\cetk copy /y "EVCPatcher\dwn\0001000148414A4Av512\cetk" "0001000148414A4Av512\cetk" >>"%MainFolder%\patching_output.txt"

exit /b 0
::USA
:wiiu_patching_fast_travel_43
if %custominstall_evc%==1 if %evcregion%==3 call EVCPatcher\dwn\sharpii.exe NUSD -ID 0001000148414A4A -v 512 -encrypt >>"%MainFolder%\patching_output.txt"
if %custominstall_evc%==1 if %evcregion%==2 call EVCPatcher\dwn\sharpii.exe NUSD -ID 0001000148414A45 -v 512 -encrypt >>"%MainFolder%\patching_output.txt"
::PAL
if %custominstall_evc%==1 if %evcregion%==1 call EVCPatcher\dwn\sharpii.exe NUSD -ID 0001000148414A50 -v 512 -encrypt >>"%MainFolder%\patching_output.txt"
if %custominstall_evc%==1 set /a temperrorlev=%errorlevel%
if %custominstall_evc%==1 set modul=Downloading EVC
if %custominstall_evc%==1 if not %temperrorlev%==0 goto error_patching
exit /b 0
:wiiu_patching_fast_travel_45
if %custominstall_evc%==1 if %evcregion%==1 copy /y "EVCPatcher\NUS_Downloader_Decrypt.exe" "0001000148414A50v512" >>"%MainFolder%\patching_output.txt"
if %custominstall_evc%==1 if %evcregion%==2 copy /y "EVCPatcher\NUS_Downloader_Decrypt.exe" "0001000148414A45v512" >>"%MainFolder%\patching_output.txt"
if %custominstall_evc%==1 if %evcregion%==3 copy /y "EVCPatcher\NUS_Downloader_Decrypt.exe" "0001000148414A4Av512" >>"%MainFolder%\patching_output.txt"
if %custominstall_evc%==1 set /a temperrorlev=%errorlevel%
if %custominstall_evc%==1 set modul=Copying NDC.exe
if %custominstall_evc%==1 if not %temperrorlev%==0 goto error_patching
exit /b 0
:wiiu_patching_fast_travel_47
if %custominstall_evc%==1 if %evcregion%==1 ren "0001000148414A50v512\tmd.512" "tmd" >>"%MainFolder%\patching_output.txt"
if %custominstall_evc%==1 if %evcregion%==2 ren "0001000148414A45v512\tmd.512" "tmd" >>"%MainFolder%\patching_output.txt"
if %custominstall_evc%==1 if %evcregion%==3 ren "0001000148414A4Av512\tmd.512" "tmd" >>"%MainFolder%\patching_output.txt"
if %custominstall_evc%==1 set /a temperrorlev=%errorlevel%
if %custominstall_evc%==1 set modul=Renaming files (Delete everything except RiiConnect24Patcher.bat)
if %custominstall_evc%==1 if not %temperrorlev%==0 goto error_patching
exit /b 0
:wiiu_patching_fast_travel_50
if %custominstall_evc%==1 if %evcregion%==1 cd 0001000148414A50v512
if %custominstall_evc%==1 if %evcregion%==1 call NUS_Downloader_Decrypt.exe >>"%MainFolder%\patching_output.txt"
if %custominstall_evc%==1 if %evcregion%==2 cd 0001000148414A45v512
if %custominstall_evc%==1 if %evcregion%==2 call NUS_Downloader_Decrypt.exe >>"%MainFolder%\patching_output.txt"
if %custominstall_evc%==1 if %evcregion%==3 cd 0001000148414A4Av512
if %custominstall_evc%==1 if %evcregion%==3 call NUS_Downloader_Decrypt.exe >>"%MainFolder%\patching_output.txt"
if %custominstall_evc%==1 set /a temperrorlev=%errorlevel%
if %custominstall_evc%==1 set modul=Decrypter error
if %custominstall_evc%==1 if not %temperrorlev%==0 cd..& goto error_patching
if %custominstall_evc%==1 cd..
exit /b 0
:wiiu_patching_fast_travel_60
if %custominstall_evc%==1 if %evcregion%==1 move /y "0001000148414A50v512\HAJP.wad" "EVCPatcher\pack"
if %custominstall_evc%==1 if %evcregion%==2 move /y "0001000148414A45v512\HAJE.wad" "EVCPatcher\pack"
if %custominstall_evc%==1 if %evcregion%==3 move /y "0001000148414A4Av512\HAJJ.wad" "EVCPatcher\pack"
if %custominstall_evc%==1 set /a temperrorlev=%errorlevel%
if %custominstall_evc%==1 set modul=move.exe
if %custominstall_evc%==1 if not %temperrorlev%==0 goto error_patching
exit /b 0
:wiiu_patching_fast_travel_62
if %custominstall_evc%==1 if %evcregion%==1 call EVCPatcher\pack\Sharpii.exe WAD -u EVCPatcher\pack\HAJP.wad EVCPatcher\pack\unencrypted >>"%MainFolder%\patching_output.txt"
if %custominstall_evc%==1 if %evcregion%==2 call EVCPatcher\pack\Sharpii.exe WAD -u EVCPatcher\pack\HAJE.wad EVCPatcher\pack\unencrypted >>"%MainFolder%\patching_output.txt"
if %custominstall_evc%==1 if %evcregion%==3 call EVCPatcher\pack\Sharpii.exe WAD -u EVCPatcher\pack\HAJJ.wad EVCPatcher\pack\unencrypted >>"%MainFolder%\patching_output.txt"
exit /b 0
:wiiu_patching_fast_travel_63
if %custominstall_evc%==1 move /y "EVCPatcher\pack\unencrypted\00000001.app" "00000001.app" >>"%MainFolder%\patching_output.txt"
if %custominstall_evc%==1 set /a temperrorlev=%errorlevel%
if %custominstall_evc%==1 set modul=move.exe
if %custominstall_evc%==1 if not %temperrorlev%==0 goto error_patching
exit /b 0
:wiiu_patching_fast_travel_65
if %custominstall_evc%==1 if %evcregion%==1 call EVCPatcher\patch\xdelta3.exe -f -d -s 00000001.app EVCPatcher\patch\Europe.delta EVCPatcher\pack\unencrypted\00000001.app >>"%MainFolder%\patching_output.txt"
if %custominstall_evc%==1 if %evcregion%==2 call EVCPatcher\patch\xdelta3.exe -f -d -s 00000001.app EVCPatcher\patch\USA.delta EVCPatcher\pack\unencrypted\00000001.app >>"%MainFolder%\patching_output.txt"
if %custominstall_evc%==1 if %evcregion%==3 call EVCPatcher\patch\xdelta3.exe -f -d -s 00000001.app EVCPatcher\patch\JPN.delta EVCPatcher\pack\unencrypted\00000001.app >>"%MainFolder%\patching_output.txt"
if %custominstall_evc%==1 set /a temperrorlev=%errorlevel%
if %custominstall_evc%==1 set modul=xdelta.exe EVC
if %custominstall_evc%==1 if not %temperrorlev%==0 goto error_patching
exit /b 0
:wiiu_patching_fast_travel_67
if %custominstall_evc%==1 if %evcregion%==1 call EVCPatcher\pack\Sharpii.exe WAD -p "EVCPatcher\pack\unencrypted" "WAD\Everybody Votes Channel (Europe) (Channel) (RiiConnect24)" -f  >>"%MainFolder%\patching_output.txt"
if %custominstall_evc%==1 if %evcregion%==2 call EVCPatcher\pack\Sharpii.exe WAD -p "EVCPatcher\pack\unencrypted" "WAD\Everybody Votes Channel (USA) (Channel) (RiiConnect24)" -f >>"%MainFolder%\patching_output.txt"
if %custominstall_evc%==1 if %evcregion%==3 call EVCPatcher\pack\Sharpii.exe WAD -p "EVCPatcher\pack\unencrypted" "WAD\Everybody Votes Channel (Japan) (Channel) (RiiConnect24)" -f >>"%MainFolder%\patching_output.txt"
if %custominstall_evc%==1 set /a temperrorlev=%errorlevel%
if %custominstall_evc%==1 set modul=Packing EVC WAD
if %custominstall_evc%==1 set /a progress_evc=1
if %custominstall_evc%==1 if not %temperrorlev%==0 goto error_patching
exit /b 0

::CMOC
:wiiu_patching_fast_travel_68
if %custominstall_cmoc%==1 if not exist 0001000148415050v512 md 0001000148415050v512
if %custominstall_cmoc%==1 if not exist 0001000148415045v512 md 0001000148415045v512
if %custominstall_cmoc%==1 if not exist 000100014841504Av512 md 000100014841504Av512
if %custominstall_cmoc%==1 if not exist 0001000148415050v512\cetk copy /y "CMOCPatcher\dwn\0001000148415050v512\cetk" "0001000148415050v512\cetk" >>"%MainFolder%\patching_output.txt"

if %custominstall_cmoc%==1 if not exist 0001000148415045v512\cetk copy /y "CMOCPatcher\dwn\0001000148415045v512\cetk" "0001000148415045v512\cetk" >>"%MainFolder%\patching_output.txt"
if %custominstall_cmoc%==1 if not exist 000100014841504Av512\cetk copy /y "CMOCPatcher\dwn\000100014841504Av512\cetk" "000100014841504Av512\cetk" >>"%MainFolder%\patching_output.txt"

exit /b 0
::USA
:wiiu_patching_fast_travel_70
if %custominstall_cmoc%==1 if %evcregion%==2 call CMOCPatcher\dwn\sharpii.exe NUSD -ID 0001000148415045 -v 512 -encrypt >>"%MainFolder%\patching_output.txt"
if %custominstall_cmoc%==1 if %evcregion%==3 call CMOCPatcher\dwn\sharpii.exe NUSD -ID 000100014841504A -v 512 -encrypt >>"%MainFolder%\patching_output.txt"
::PAL
if %custominstall_cmoc%==1 if %evcregion%==1 call CMOCPatcher\dwn\sharpii.exe NUSD -ID 0001000148415050 -v 512 -encrypt >>"%MainFolder%\patching_output.txt"
if %custominstall_cmoc%==1 set /a temperrorlev=%errorlevel%
if %custominstall_cmoc%==1 set modul=Downloading CMOC
if %custominstall_cmoc%==1 if not %temperrorlev%==0 goto error_patching
exit /b 0
:wiiu_patching_fast_travel_71
if %custominstall_cmoc%==1 if %evcregion%==1 copy /y "CMOCPatcher\NUS_Downloader_Decrypt.exe" "0001000148415050v512" >>"%MainFolder%\patching_output.txt"
if %custominstall_cmoc%==1 if %evcregion%==2 copy /y "CMOCPatcher\NUS_Downloader_Decrypt.exe" "0001000148415045v512" >>"%MainFolder%\patching_output.txt"
if %custominstall_cmoc%==1 if %evcregion%==3 copy /y "CMOCPatcher\NUS_Downloader_Decrypt.exe" "000100014841504Av512" >>"%MainFolder%\patching_output.txt"
if %custominstall_cmoc%==1 set /a temperrorlev=%errorlevel%
if %custominstall_cmoc%==1 set modul=Copying NDC.exe
if %custominstall_cmoc%==1 if not %temperrorlev%==0 goto error_patching
exit /b 0
:wiiu_patching_fast_travel_72
if %custominstall_cmoc%==1 if %evcregion%==1 ren "0001000148415050v512\tmd.512" "tmd" >>"%MainFolder%\patching_output.txt"
if %custominstall_cmoc%==1 if %evcregion%==2 ren "0001000148415045v512\tmd.512" "tmd" >>"%MainFolder%\patching_output.txt"
if %custominstall_cmoc%==1 if %evcregion%==3 ren "000100014841504Av512\tmd.512" "tmd" >>"%MainFolder%\patching_output.txt"
if %custominstall_cmoc%==1 set /a temperrorlev=%errorlevel%
if %custominstall_cmoc%==1 set modul=Renaming files [Delete everything except RiiConnect24Patcher.bat]
if %custominstall_cmoc%==1 if not %temperrorlev%==0 goto error_patching

if %custominstall_cmoc%==1 if %evcregion%==1 cd 0001000148415050v512
if %custominstall_cmoc%==1 if %evcregion%==1 call NUS_Downloader_Decrypt.exe >>"%MainFolder%\patching_output.txt"
if %custominstall_cmoc%==1 if %evcregion%==2 cd 0001000148415045v512
if %custominstall_cmoc%==1 if %evcregion%==2 call NUS_Downloader_Decrypt.exe >>"%MainFolder%\patching_output.txt"
if %custominstall_cmoc%==1 if %evcregion%==3 cd 000100014841504Av512
if %custominstall_cmoc%==1 if %evcregion%==3 call NUS_Downloader_Decrypt.exe >>"%MainFolder%\patching_output.txt"
if %custominstall_cmoc%==1 set /a temperrorlev=%errorlevel%
if %custominstall_cmoc%==1 set modul=Decrypter error
if %custominstall_cmoc%==1 if not %temperrorlev%==0 cd..& goto error_patching
if %custominstall_cmoc%==1 cd..
exit /b 0
:wiiu_patching_fast_travel_74
if %custominstall_cmoc%==1 if %evcregion%==1 move /y "0001000148415050v512\HAPP.wad" "CMOCPatcher\pack" >>"%MainFolder%\patching_output.txt"
if %custominstall_cmoc%==1 if %evcregion%==2 move /y "0001000148415045v512\HAPE.wad" "CMOCPatcher\pack" >>"%MainFolder%\patching_output.txt"
if %custominstall_cmoc%==1 if %evcregion%==3 move /y "000100014841504Av512\HAPJ.wad" "CMOCPatcher\pack" >>"%MainFolder%\patching_output.txt"
if %custominstall_cmoc%==1 set /a temperrorlev=%errorlevel%
if %custominstall_cmoc%==1 set modul=move.exe
if %custominstall_cmoc%==1 if not %temperrorlev%==0 goto error_patching
exit /b 0
:wiiu_patching_fast_travel_75
if %custominstall_cmoc%==1 if %evcregion%==1 call CMOCPatcher\pack\Sharpii.exe WAD -u CMOCPatcher\pack\HAPP.wad CMOCPatcher\pack\unencrypted >>"%MainFolder%\patching_output.txt"
if %custominstall_cmoc%==1 if %evcregion%==2 call CMOCPatcher\pack\Sharpii.exe WAD -u CMOCPatcher\pack\HAPE.wad CMOCPatcher\pack\unencrypted >>"%MainFolder%\patching_output.txt"
if %custominstall_cmoc%==1 if %evcregion%==3 call CMOCPatcher\pack\Sharpii.exe WAD -u CMOCPatcher\pack\HAPJ.wad CMOCPatcher\pack\unencrypted >>"%MainFolder%\patching_output.txt"
exit /b 0
:wiiu_patching_fast_travel_76
if %custominstall_cmoc%==1 move /y "CMOCPatcher\pack\unencrypted\00000001.app" "00000001.app" >>"%MainFolder%\patching_output.txt"
if %custominstall_cmoc%==1 move /y "CMOCPatcher\pack\unencrypted\00000004.app" "00000004.app" >>"%MainFolder%\patching_output.txt"
if %custominstall_cmoc%==1 set /a temperrorlev=%errorlevel%
if %custominstall_cmoc%==1 set modul=move.exe
if %custominstall_cmoc%==1 if not %temperrorlev%==0 goto error_patching
exit /b 0
:wiiu_patching_fast_travel_77
if %custominstall_cmoc%==1 if %evcregion%==1 call CMOCPatcher\patch\xdelta3.exe -f -d -s 00000001.app CMOCPatcher\patch\00000001_Europe.delta CMOCPatcher\pack\unencrypted\00000001.app >>"%MainFolder%\patching_output.txt"
if %custominstall_cmoc%==1 if %evcregion%==1 call CMOCPatcher\patch\xdelta3.exe -f -d -s 00000004.app CMOCPatcher\patch\00000004_Europe.delta CMOCPatcher\pack\unencrypted\00000004.app >>"%MainFolder%\patching_output.txt"
if %custominstall_cmoc%==1 if %evcregion%==2 call CMOCPatcher\patch\xdelta3.exe -f -d -s 00000001.app CMOCPatcher\patch\00000001_USA.delta CMOCPatcher\pack\unencrypted\00000001.app >>"%MainFolder%\patching_output.txt"
if %custominstall_cmoc%==1 if %evcregion%==2 call CMOCPatcher\patch\xdelta3.exe -f -d -s 00000004.app CMOCPatcher\patch\00000004_USA.delta CMOCPatcher\pack\unencrypted\00000004.app >>"%MainFolder%\patching_output.txt"
if %custominstall_cmoc%==1 if %evcregion%==3 call CMOCPatcher\patch\xdelta3.exe -f -d -s 00000001.app CMOCPatcher\patch\00000001_Japan.delta CMOCPatcher\pack\unencrypted\00000001.app >>"%MainFolder%\patching_output.txt"
if %custominstall_cmoc%==1 if %evcregion%==3 call CMOCPatcher\patch\xdelta3.exe -f -d -s 00000004.app CMOCPatcher\patch\00000004_Japan.delta CMOCPatcher\pack\unencrypted\00000004.app >>"%MainFolder%\patching_output.txt"
if %custominstall_cmoc%==1 set /a temperrorlev=%errorlevel%
if %custominstall_cmoc%==1 set modul=xdelta.exe CMOC
if %custominstall_cmoc%==1 if not %temperrorlev%==0 goto error_patching
exit /b 0
:wiiu_patching_fast_travel_78
if %custominstall_cmoc%==1 if %evcregion%==1 call CMOCPatcher\pack\Sharpii.exe WAD -p "CMOCPatcher\pack\unencrypted" "WAD\Mii Contest Channel (Europe) (Channel) (RiiConnect24)" -f >>"%MainFolder%\patching_output.txt"
if %custominstall_cmoc%==1 if %evcregion%==2 call CMOCPatcher\pack\Sharpii.exe WAD -p "CMOCPatcher\pack\unencrypted" "WAD\Check Mii Out Channel (USA) (Channel) (RiiConnect24)" -f >>"%MainFolder%\patching_output.txt"
if %custominstall_cmoc%==1 if %evcregion%==3 call CMOCPatcher\pack\Sharpii.exe WAD -p "CMOCPatcher\pack\unencrypted" "WAD\Check Mii Out Channel (Japan) (Channel) (RiiConnect24)" -f >>"%MainFolder%\patching_output.txt"
if %custominstall_cmoc%==1 set /a temperrorlev=%errorlevel%
if %custominstall_cmoc%==1 set modul=Packing CMOC WAD
if %custominstall_cmoc%==1 set /a progress_cmoc=1
if %custominstall_cmoc%==1 if not %temperrorlev%==0 goto error_patching
exit /b 0










::NC

:wiiu_patching_fast_travel_79
if %custominstall_nc%==1 if not exist 0001000148415450v1792 md 0001000148415450v1792
if %custominstall_nc%==1 if not exist 0001000148415445v1792 md 0001000148415445v1792
if %custominstall_nc%==1 if not exist 000100014841544Av1792 md 000100014841544Av1792
if %custominstall_nc%==1 if not exist 0001000148415450v1792\cetk copy /y "NCPatcher\dwn\0001000148415450v1792\cetk" "0001000148415450v1792\cetk" >>"%MainFolder%\patching_output.txt"

if %custominstall_nc%==1 if not exist 0001000148415445v1792\cetk copy /y "NCPatcher\dwn\0001000148415445v1792\cetk" "0001000148415445v1792\cetk" >>"%MainFolder%\patching_output.txt"
if %custominstall_nc%==1 if not exist 000100014841544Av1792\cetk copy /y "NCPatcher\dwn\000100014841544Av1792\cetk" "000100014841544Av1792\cetk" >>"%MainFolder%\patching_output.txt"

:wiiu_patching_fast_travel_80
	call :check_rc24_server_connection
	if "%errorlevel%"=="1" goto server_connection_lost
::JPN
if %custominstall_nc%==1 if %evcregion%==3 call NCPatcher\dwn\sharpii.exe NUSD -ID 000100014841544A -v 1792 -encrypt >>"%MainFolder%\patching_output.txt"
if %custominstall_nc%==1 if %evcregion%==3 set /a temperrorlev=%errorlevel%
if %custominstall_nc%==1 if %evcregion%==3 set modul=Downloading NC
if %custominstall_nc%==1 if %evcregion%==3	 if not %temperrorlev%==0 goto error_patching
::USA
if %custominstall_nc%==1 if %evcregion%==2 call NCPatcher\dwn\sharpii.exe NUSD -ID 0001000148415445 -v 1792 -encrypt >>"%MainFolder%\patching_output.txt"
if %custominstall_nc%==1 if %evcregion%==2 set /a temperrorlev=%errorlevel%
if %custominstall_nc%==1 if %evcregion%==2 set modul=Downloading NC
if %custominstall_nc%==1 if %evcregion%==2	 if not %temperrorlev%==0 goto error_patching
::PAL
if %custominstall_nc%==1 if %evcregion%==1 call NCPatcher\dwn\sharpii.exe NUSD -ID 0001000148415450 -v 1792 -encrypt >>"%MainFolder%\patching_output.txt"
if %custominstall_nc%==1 if %evcregion%==1 set /a temperrorlev=%errorlevel%
if %custominstall_nc%==1 if %evcregion%==1 set modul=Downloading NC
if %custominstall_nc%==1 if %evcregion%==1 if not %temperrorlev%==0 goto error_patching
exit /b 0
:wiiu_patching_fast_travel_81
if %custominstall_nc%==1 if %evcregion%==1 copy /y "NCPatcher\NUS_Downloader_Decrypt.exe" "0001000148415450v1792" >>"%MainFolder%\patching_output.txt"
if %custominstall_nc%==1 if %evcregion%==2 copy /y "NCPatcher\NUS_Downloader_Decrypt.exe" "0001000148415445v1792" >>"%MainFolder%\patching_output.txt"
if %custominstall_nc%==1 if %evcregion%==3 copy /y "NCPatcher\NUS_Downloader_Decrypt.exe" "000100014841544Av1792" >>"%MainFolder%\patching_output.txt"
if %custominstall_nc%==1 set /a temperrorlev=%errorlevel%
if %custominstall_nc%==1 set modul=Copying NDC.exe
if %custominstall_nc%==1 if not %temperrorlev%==0 goto error_patching
exit /b 0
:wiiu_patching_fast_travel_82
if %custominstall_nc%==1 if %evcregion%==1 ren "0001000148415450v1792\tmd.1792" "tmd" >>"%MainFolder%\patching_output.txt"
if %custominstall_nc%==1 if %evcregion%==2 ren "0001000148415445v1792\tmd.1792" "tmd" >>"%MainFolder%\patching_output.txt"
if %custominstall_nc%==1 if %evcregion%==3 ren "000100014841544Av1792\tmd.1792" "tmd" >>"%MainFolder%\patching_output.txt"
if %custominstall_nc%==1 set /a temperrorlev=%errorlevel%
if %custominstall_nc%==1 set modul=Renaming files
if %custominstall_nc%==1 if not %temperrorlev%==0 goto error_patching
exit /b 0
:wiiu_patching_fast_travel_83
if %custominstall_nc%==1 if %evcregion%==1 cd 0001000148415450v1792
if %custominstall_nc%==1 if %evcregion%==1 call NUS_Downloader_Decrypt.exe >>"%MainFolder%\patching_output.txt"
if %custominstall_nc%==1 if %evcregion%==2 cd 0001000148415445v1792
if %custominstall_nc%==1 if %evcregion%==2 call NUS_Downloader_Decrypt.exe >>"%MainFolder%\patching_output.txt"
if %custominstall_nc%==1 if %evcregion%==3 cd 000100014841544Av1792
if %custominstall_nc%==1 if %evcregion%==3 call NUS_Downloader_Decrypt.exe >>"%MainFolder%\patching_output.txt"
if %custominstall_nc%==1 set /a temperrorlev=%errorlevel%
if %custominstall_nc%==1 set modul=Decrypter error
if %custominstall_nc%==1 if not %temperrorlev%==0 cd..& goto error_patching
if %custominstall_nc%==1 cd..
exit /b 0
:wiiu_patching_fast_travel_84
if %custominstall_nc%==1 if %evcregion%==1 move /y "0001000148415450v1792\HATP.wad" "NCPatcher\pack" >>"%MainFolder%\patching_output.txt"
if %custominstall_nc%==1 if %evcregion%==2 move /y "0001000148415445v1792\HATE.wad" "NCPatcher\pack" >>"%MainFolder%\patching_output.txt"
if %custominstall_nc%==1 if %evcregion%==3 move /y "000100014841544Av1792\HATJ.wad" "NCPatcher\pack" >>"%MainFolder%\patching_output.txt"
if %custominstall_nc%==1 set /a temperrorlev=%errorlevel%
if %custominstall_nc%==1 set modul=move.exe
if %custominstall_nc%==1 if not %temperrorlev%==0 goto error_patching
exit /b 0
:wiiu_patching_fast_travel_85
if %custominstall_nc%==1 if %evcregion%==1 call NCPatcher\pack\Sharpii.exe WAD -u NCPatcher\pack\HATP.wad NCPatcher\pack\unencrypted >>"%MainFolder%\patching_output.txt"
if %custominstall_nc%==1 if %evcregion%==2 call NCPatcher\pack\Sharpii.exe WAD -u NCPatcher\pack\HATE.wad NCPatcher\pack\unencrypted >>"%MainFolder%\patching_output.txt"
if %custominstall_nc%==1 if %evcregion%==3 call NCPatcher\pack\Sharpii.exe WAD -u NCPatcher\pack\HATJ.wad NCPatcher\pack\unencrypted >>"%MainFolder%\patching_output.txt"
exit /b 0
:wiiu_patching_fast_travel_86
if %custominstall_nc%==1 move /y "NCPatcher\pack\unencrypted\00000001.app" "00000001_NC.app" >>"%MainFolder%\patching_output.txt"
if %custominstall_nc%==1 set /a temperrorlev=%errorlevel%
if %custominstall_nc%==1 set modul=move.exe
if %custominstall_nc%==1 if not %temperrorlev%==0 goto error_patching
exit /b 0
:wiiu_patching_fast_travel_87
if %custominstall_nc%==1 if %evcregion%==1 call NCPatcher\patch\xdelta3.exe -f -d -s 00000001_NC.app NCPatcher\patch\Europe.delta NCPatcher\pack\unencrypted\00000001.app >>"%MainFolder%\patching_output.txt"
if %custominstall_nc%==1 if %evcregion%==2 call NCPatcher\patch\xdelta3.exe -f -d -s 00000001_NC.app NCPatcher\patch\USA.delta NCPatcher\pack\unencrypted\00000001.app >>"%MainFolder%\patching_output.txt"
if %custominstall_nc%==1 if %evcregion%==3 call NCPatcher\patch\xdelta3.exe -f -d -s 00000001_NC.app NCPatcher\patch\JPN.delta NCPatcher\pack\unencrypted\00000001.app >>"%MainFolder%\patching_output.txt"
if %custominstall_nc%==1 set /a temperrorlev=%errorlevel%
if %custominstall_nc%==1 set modul=xdelta.exe NC
if %custominstall_nc%==1 if not %temperrorlev%==0 goto error_patching
exit /b 0
:wiiu_patching_fast_travel_88
if %custominstall_nc%==1 if %evcregion%==1 call NCPatcher\pack\Sharpii.exe WAD -p "NCPatcher\pack\unencrypted" "WAD\Nintendo Channel (Europe) (Channel) (RiiConnect24)" -f >>"%MainFolder%\patching_output.txt"
if %custominstall_nc%==1 if %evcregion%==2 call NCPatcher\pack\Sharpii.exe WAD -p "NCPatcher\pack\unencrypted" "WAD\Nintendo Channel (USA) (Channel) (RiiConnect24)" -f >>"%MainFolder%\patching_output.txt"
if %custominstall_nc%==1 if %evcregion%==3 call NCPatcher\pack\Sharpii.exe WAD -p "NCPatcher\pack\unencrypted" "WAD\Nintendo Channel (Japan) (Channel) (RiiConnect24)" -f >>"%MainFolder%\patching_output.txt"
if %custominstall_nc%==1 set /a temperrorlev=%errorlevel%
if %custominstall_nc%==1 set modul=Packing NC WAD
if %custominstall_nc%==1 if not %temperrorlev%==0 goto error_patching
if %custominstall_nc%==1 set /a progress_nc=1
exit /b 0


:wiiu_patching_fast_travel_90
if exist cetk del /q cetk
if %internet_channel_enable%==1 if %evcregion%==1 if not exist 0001000148414450v1024 md 0001000148414450v1024
if %internet_channel_enable%==1 if %evcregion%==1 copy "cert.sys" "0001000148414450v1024" >>"%MainFolder%\patching_output.txt"
if %internet_channel_enable%==1 if %evcregion%==1 curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/AdditionalChannels_Patches/InternetChannel/Europe.cetk" --output "0001000148414450v1024\cetk"
	if %internet_channel_enable%==1 if %evcregion%==1 set /a temperrorlev=%errorlevel%
	if %internet_channel_enable%==1 if %evcregion%==1 set modul=Downloading Internet Channel CETK
	if %internet_channel_enable%==1 if %evcregion%==1 if not %temperrorlev%==0 goto error_patching
if %internet_channel_enable%==1 if %evcregion%==1 CMOCPatcher\pack\Sharpii.exe NUSD -id 0001000148414450 -v 1024 >>"%MainFolder%\patching_output.txt"
	if %internet_channel_enable%==1 if %evcregion%==1 set /a temperrorlev=%errorlevel%
	if %internet_channel_enable%==1 if %evcregion%==1 set modul=Downloading Internet Channel
	if %internet_channel_enable%==1 if %evcregion%==1 if not %temperrorlev%==0 goto error_patching
if %internet_channel_enable%==1 if %evcregion%==1 move "0001000148414450v1024\0001000148414450v1024.wad" "WAD\Internet Channel (Europe) (Channel).wad" >>"%MainFolder%\patching_output.txt"
	

if %internet_channel_enable%==1 if %evcregion%==2 if not exist 0001000148414445v1024 md 0001000148414445v1024
if %internet_channel_enable%==1 if %evcregion%==2 copy "cert.sys" "0001000148414445v1024" >>"%MainFolder%\patching_output.txt"
if %internet_channel_enable%==1 if %evcregion%==2 curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/AdditionalChannels_Patches/InternetChannel/USA.cetk" --output "0001000148414445v1024\cetk"
	if %internet_channel_enable%==1 if %evcregion%==2 set /a temperrorlev=%errorlevel%
	if %internet_channel_enable%==1 if %evcregion%==2 set modul=Downloading Internet Channel CETK
	if %internet_channel_enable%==1 if %evcregion%==2 if not %temperrorlev%==0 goto error_patching
if %internet_channel_enable%==1 if %evcregion%==2 CMOCPatcher\pack\Sharpii.exe NUSD -id 0001000148414445 -v 1024 -wad >>"%MainFolder%\patching_output.txt"
	if %internet_channel_enable%==1 if %evcregion%==2 set /a temperrorlev=%errorlevel%
	if %internet_channel_enable%==1 if %evcregion%==2 set modul=Downloading Internet Channel
	if %internet_channel_enable%==1 if %evcregion%==2 if not %temperrorlev%==0 goto error_patching
if %internet_channel_enable%==1 if %evcregion%==2 move "0001000148414445v1024.wad" "WAD\Internet Channel (USA) (Channel).wad" >>"%MainFolder%\patching_output.txt"


if %internet_channel_enable%==1 if %evcregion%==3 if not exist 000100014841444av1024 md 000100014841444av1024
if %internet_channel_enable%==1 if %evcregion%==3 copy "cert.sys" "000100014841444av1024" >>"%MainFolder%\patching_output.txt"
if %internet_channel_enable%==1 if %evcregion%==3 curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/AdditionalChannels_Patches/InternetChannel/Japan.cetk" --output "000100014841444av1024\cetk" >>"%MainFolder%\patching_output.txt"
	if %internet_channel_enable%==1 if %evcregion%==3 set /a temperrorlev=%errorlevel%
	if %internet_channel_enable%==1 if %evcregion%==3 set modul=Downloading Internet Channel CETK
	if %internet_channel_enable%==1 if %evcregion%==3 if not %temperrorlev%==0 goto error_patching
if %internet_channel_enable%==1 if %evcregion%==3 CMOCPatcher\pack\Sharpii.exe NUSD -id 000100014841444a -v 1024 -wad >>"%MainFolder%\patching_output.txt"
	if %internet_channel_enable%==1 if %evcregion%==3 set /a temperrorlev=%errorlevel%
	if %internet_channel_enable%==1 if %evcregion%==3 set modul=Downloading Internet Channel
	if %internet_channel_enable%==1 if %evcregion%==3 if not %temperrorlev%==0 goto error_patching
if %internet_channel_enable%==1 if %evcregion%==3 move "000100014841444av1024.wad" "WAD\Internet Channel (Japan) (Channel).wad" >>"%MainFolder%\patching_output.txt"
if exist cetk del /q cetk
exit /b 0

:wiiu_patching_fast_travel_93

if %today_and_tomorrow_enable%==1 if %evcregion%==1 (
	if not exist 0001000148415650v512 md 0001000148415650v512
	copy "cert.sys" "0001000148415650v512" >>"%MainFolder%\patching_output.txt" >>"%MainFolder%\patching_output.txt"
	curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/AdditionalChannels_Patches/TodayandTomorrowChannel/Europe.cetk" --output "0001000148415650v512\cetk" >>"%MainFolder%\patching_output.txt"
		set /a temperrorlev=%errorlevel%
		set modul=Downloading Today and Tomorrow Channel CETK
		if not %temperrorlev%==0 goto error_patching
	CMOCPatcher\dwn\Sharpii.exe NUSD -id 0001000148415650 -v 512 -encrypt >>"%MainFolder%\patching_output.txt"
		set /a temperrorlev=%errorlevel%
		set modul=Downloading Today and Tomorrow Channel
		if not %temperrorlev%==0 goto error_patching
	
	copy "CMOCPatcher\NUS_Downloader_Decrypt.exe" "0001000148415650v512\NUS_Downloader_Decrypt.exe"  >>"%MainFolder%\patching_output.txt"
	cd 0001000148415650v512
	ren tmd.512 tmd
	call NUS_Downloader_Decrypt.exe >>"%MainFolder%\patching_output.txt"
	cd ..
	move "0001000148415650v512\*.wad" "WAD\Today and Tomorrow Channel (Europe) (Channel).wad" >>"%MainFolder%\patching_output.txt"
	)

if %today_and_tomorrow_enable%==1 if %evcregion%==2 (
	if not exist 0001000148415650v512 md 0001000148415650v512
	copy "cert.sys" "0001000148415650v512" >>"%MainFolder%\patching_output.txt"
	curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/AdditionalChannels_Patches/TodayandTomorrowChannel/Europe.cetk" --output "0001000148415650v512\cetk" >>"%MainFolder%\patching_output.txt"
		set /a temperrorlev=%errorlevel%
		set modul=Downloading Today and Tomorrow Channel CETK
		if not %temperrorlev%==0 goto error_patching
	CMOCPatcher\dwn\Sharpii.exe NUSD -id 0001000148415650 -v 512 -encrypt >>"%MainFolder%\patching_output.txt"
		set /a temperrorlev=%errorlevel%
		set modul=Downloading Today and Tomorrow Channel
		if not %temperrorlev%==0 goto error_patching
	
	copy "CMOCPatcher\NUS_Downloader_Decrypt.exe" "0001000148415650v512\NUS_Downloader_Decrypt.exe" >>"%MainFolder%\patching_output.txt"
	cd 0001000148415650v512
	
	del /s /q tmd.* >>"%MainFolder%\patching_output.txt"
	curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/AdditionalChannels_Patches/TodayandTomorrowChannel/EuropeToUSA.tmd" --output "tmd" >>"%MainFolder%\patching_output.txt"
		set /a temperrorlev=%errorlevel%
		set modul=Downloading Today and Tomorrow Channel CETK
		if not %temperrorlev%==0 goto error_patching

	call NUS_Downloader_Decrypt.exe >>"%MainFolder%\patching_output.txt"
	cd ..
	move "0001000148415650v512\*.wad" "WAD\Today and Tomorrow Channel (USA) (Channel).wad" 
	)



if %today_and_tomorrow_enable%==1 if %evcregion%==3 (
	if not exist 000100014841564av512 md 000100014841564av512
	copy "cert.sys" "000100014841564av512" >>"%MainFolder%\patching_output.txt" >>"%MainFolder%\patching_output.txt"
	curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/AdditionalChannels_Patches/TodayandTomorrowChannel/Japan.cetk" --output "000100014841564av512\cetk" >>"%MainFolder%\patching_output.txt"
		set /a temperrorlev=%errorlevel%
		set modul=Downloading Today and Tomorrow Channel CETK
		if not %temperrorlev%==0 goto error_patching
	CMOCPatcher\dwn\Sharpii.exe NUSD -id 000100014841564a -v 512 -encrypt >>"%MainFolder%\patching_output.txt"
		set /a temperrorlev=%errorlevel%
		set modul=Downloading Today and Tomorrow Channel
		if not %temperrorlev%==0 goto error_patching
	
	copy "CMOCPatcher\NUS_Downloader_Decrypt.exe" "000100014841564av512\NUS_Downloader_Decrypt.exe" >>"%MainFolder%\patching_output.txt" 
	cd 000100014841564av512
	ren tmd.512 tmd
	call NUS_Downloader_Decrypt.exe >>"%MainFolder%\patching_output.txt"
	cd ..
	move "000100014841564av512\*.wad" "WAD\Today and Tomorrow Channel (Japan) (Channel).wad" >>"%MainFolder%\patching_output.txt"
	)

if %today_and_tomorrow_enable%==1 if %evcregion%==4 (
	if not exist 000100014841564bv512 md 000100014841564bv512
	copy "cert.sys" "000100014841564bv512" >>"%MainFolder%\patching_output.txt" >>"%MainFolder%\patching_output.txt"
	curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/AdditionalChannels_Patches/TodayandTomorrowChannel/Korea.cetk" --output "000100014841564bv512\cetk" >>"%MainFolder%\patching_output.txt"
		set /a temperrorlev=%errorlevel%
		set modul=Downloading Today and Tomorrow Channel CETK
		if not %temperrorlev%==0 goto error_patching
	CMOCPatcher\dwn\Sharpii.exe NUSD -id 000100014841564b -v 512 -encrypt >>"%MainFolder%\patching_output.txt"
		set /a temperrorlev=%errorlevel%
		set modul=Downloading Today and Tomorrow Channel
		if not %temperrorlev%==0 goto error_patching
	
	copy "CMOCPatcher\NUS_Downloader_Decrypt.exe" "000100014841564bv512\NUS_Downloader_Decrypt.exe"  >>"%MainFolder%\patching_output.txt"
	cd 000100014841564bv512
	ren tmd.512 tmd
	call NUS_Downloader_Decrypt.exe >>"%MainFolder%\patching_output.txt"
	cd ..
	move "000100014841564bv512\*.wad" "WAD\Today and Tomorrow Channel (Korea) (Channel).wad" >>"%MainFolder%\patching_output.txt"
	)

if exist cetk del /q cetk

exit /b 0

:wiiu_patching_fast_travel_95
	
if %photo_channel_enable%==1 if not exist 0001000248414141v2 md 0001000248414141v2
if %photo_channel_enable%==1 copy "cert.sys" "0001000248414141v2" >>"%MainFolder%\patching_output.txt"
if %photo_channel_enable%==1 curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/AdditionalChannels_Patches/PhotoChannel/1.0.cetk" --output "0001000248414141v2\cetk" >>"%MainFolder%\patching_output.txt"
	if %photo_channel_enable%==1 set /a temperrorlev=%errorlevel%
	if %photo_channel_enable%==1 set modul=Downloading Photo Channel 1.0 CETK
	if %photo_channel_enable%==1 if not %temperrorlev%==0 goto error_patching
if %photo_channel_enable%==1 CMOCPatcher\pack\Sharpii.exe NUSD -id 0001000248414141 -v 2 -wad >>"%MainFolder%\patching_output.txt"
	if %photo_channel_enable%==1 set /a temperrorlev=%errorlevel%
	if %photo_channel_enable%==1 set modul=Downloading Photo Channel
	if %photo_channel_enable%==1 if not %temperrorlev%==0 goto error_patching
if %photo_channel_enable%==1 move "0001000248414141v2.wad" "WAD\Photo Channel 1.0 (Channel).wad" >>"%MainFolder%\patching_output.txt"
if exist cetk del /q cetk

if %photo_channel_enable%==1 if not exist 0001000248415941v3 md 0001000248415941v3
if %photo_channel_enable%==1 copy "cert.sys" "0001000248415941v3" >>"%MainFolder%\patching_output.txt"
if %photo_channel_enable%==1 curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/AdditionalChannels_Patches/PhotoChannel/1.1.cetk" --output "0001000248415941v3\cetk" >>"%MainFolder%\patching_output.txt"
	if %photo_channel_enable%==1 set /a temperrorlev=%errorlevel%
	if %photo_channel_enable%==1 set modul=Downloading Photo Channel 1.1 CETK
	if %photo_channel_enable%==1 if not %temperrorlev%==0 goto error_patching
if %photo_channel_enable%==1 CMOCPatcher\pack\Sharpii.exe NUSD -id 0001000248415941 -v 3 -wad >>"%MainFolder%\patching_output.txt"
	if %photo_channel_enable%==1 set /a temperrorlev=%errorlevel%
	if %photo_channel_enable%==1 set modul=Downloading Photo Channel
	if %photo_channel_enable%==1 if not %temperrorlev%==0 goto error_patching

if %photo_channel_enable%==1 move "0001000248415941v3.wad" "WAD\Photo Channel 1.1 (Update).wad" >>"%MainFolder%\patching_output.txt"

exit /b 0
:wiiu_patching_fast_travel_97


if %wii_speak_channel_enable%==1 if not exist WiiWarePatcher md WiiWarePatcher
if %wii_speak_channel_enable%==1 curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/WiiWarePatcher/libWiiSharp.dll" --output "WiiWarePatcher\libWiiSharp.dll"
	if %wii_speak_channel_enable%==1 set /a temperrorlev=%errorlevel%
	if %wii_speak_channel_enable%==1 set modul=Downloading executables for WiiWarePatcher
	if %wii_speak_channel_enable%==1 if not %temperrorlev%==0 goto error_patching

if %wii_speak_channel_enable%==1 curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/WiiWarePatcher/lzx.exe" --output "WiiWarePatcher\lzx.exe"
	if %wii_speak_channel_enable%==1 set /a temperrorlev=%errorlevel%
	if %wii_speak_channel_enable%==1 set modul=Downloading executables for WiiWarePatcher
	if %wii_speak_channel_enable%==1 if not %temperrorlev%==0 goto error_patching
if %wii_speak_channel_enable%==1 curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/WiiWarePatcher/Sharpii.exe" --output "WiiWarePatcher\Sharpii.exe"
	if %wii_speak_channel_enable%==1 set /a temperrorlev=%errorlevel%
	if %wii_speak_channel_enable%==1 set modul=Downloading executables for WiiWarePatcher
	if %wii_speak_channel_enable%==1 if not %temperrorlev%==0 goto error_patching
if %wii_speak_channel_enable%==1 curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/WiiWarePatcher/WadInstaller.dll" --output "WiiWarePatcher\WadInstaller.dll"
	if %wii_speak_channel_enable%==1 set /a temperrorlev=%errorlevel%
	if %wii_speak_channel_enable%==1 set modul=Downloading executables for WiiWarePatcher
	if %wii_speak_channel_enable%==1 if not %temperrorlev%==0 goto error_patching
if %wii_speak_channel_enable%==1 curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/WiiWarePatcher/WiiWarePatcher.exe" --output "WiiWarePatcher\WiiWarePatcher.exe"
	if %wii_speak_channel_enable%==1 set /a temperrorlev=%errorlevel%
	if %wii_speak_channel_enable%==1 set modul=Downloading executables for WiiWarePatcher
	if %wii_speak_channel_enable%==1 if not %temperrorlev%==0 goto error_patching
if %wii_speak_channel_enable%==1 if %evcregion%==1 WiiWarePatcher\Sharpii.exe NUSD -ID 0001000148434650 -v 512 -all >>"%MainFolder%\patching_output.txt"
	if %wii_speak_channel_enable%==1 if %evcregion%==1 set /a temperrorlev=%errorlevel%
	if %wii_speak_channel_enable%==1 if %evcregion%==1 set modul=Downloading Wii Speak Channel
	if %wii_speak_channel_enable%==1 if %evcregion%==1 if not %temperrorlev%==0 goto error_patching
if %wii_speak_channel_enable%==1 if %evcregion%==2 WiiWarePatcher\Sharpii.exe NUSD -ID 0001000148434645 -v 512 -all >>"%MainFolder%\patching_output.txt"
	if %wii_speak_channel_enable%==1 if %evcregion%==2 set /a temperrorlev=%errorlevel%
	if %wii_speak_channel_enable%==1 if %evcregion%==2 set modul=Downloading Wii Speak Channel
	if %wii_speak_channel_enable%==1 if %evcregion%==2 if not %temperrorlev%==0 goto error_patching
if %wii_speak_channel_enable%==1 if %evcregion%==3 WiiWarePatcher\Sharpii.exe NUSD -ID 000100014843464a -v 512 -all >>"%MainFolder%\patching_output.txt"
	if %wii_speak_channel_enable%==1 if %evcregion%==3 set /a temperrorlev=%errorlevel%
	if %wii_speak_channel_enable%==1 if %evcregion%==3 set modul=Downloading Wii Speak Channel
	if %wii_speak_channel_enable%==1 if %evcregion%==3 if not %temperrorlev%==0 goto error_patching

if %wii_speak_channel_enable%==1 if %evcregion%==4 WiiWarePatcher\Sharpii.exe NUSD -ID 000100014843464b -v 512 -all >>"%MainFolder%\patching_output.txt"
	if %wii_speak_channel_enable%==1 if %evcregion%==4 set /a temperrorlev=%errorlevel%
	if %wii_speak_channel_enable%==1 if %evcregion%==4 set modul=Downloading Wii Speak Channel
	if %wii_speak_channel_enable%==1 if %evcregion%==4 if not %temperrorlev%==0 goto error_patching

if %wii_speak_channel_enable%==1 if %evcregion%==1 move "0001000148434650v512\*.wad" "Wii Speak Channel.wad" >>"%MainFolder%\patching_output.txt"
if %wii_speak_channel_enable%==1 if %evcregion%==2 move "0001000148434645v512\*.wad" "Wii Speak Channel.wad" >>"%MainFolder%\patching_output.txt"
if %wii_speak_channel_enable%==1 if %evcregion%==3 move "000100014843464av512\*.wad" "Wii Speak Channel.wad" >>"%MainFolder%\patching_output.txt"
if %wii_speak_channel_enable%==1 if %evcregion%==4 move "000100014843464bv512\*.wad" "Wii Speak Channel.wad" >>"%MainFolder%\patching_output.txt"

if %wii_speak_channel_enable%==1 WiiWarePatcher\Sharpii.exe WAD -u "Wii Speak Channel.wad" temp >>"%MainFolder%\patching_output.txt"
	if %wii_speak_channel_enable%==1 set /a temperrorlev=%errorlevel%
	if %wii_speak_channel_enable%==1 set modul=Unpacking Wii Speak Channel
	if %wii_speak_channel_enable%==1 if not %temperrorlev%==0 goto error_patching
	
if %wii_speak_channel_enable%==1 move "temp\00000001.app" "WiiWarePatcher\00000001.app" >>"%MainFolder%\patching_output.txt"
if %wii_speak_channel_enable%==1 cd WiiWarePatcher
if %wii_speak_channel_enable%==1 call WiiWarePatcher.exe >>"%MainFolder%\patching_output.txt"
if %wii_speak_channel_enable%==1 cd ..
if %wii_speak_channel_enable%==1 move "WiiWarePatcher\00000001.app" "temp\00000001.app" >>"%MainFolder%\patching_output.txt"
if %wii_speak_channel_enable%==1 del /q "Wii Speak Channel.wad"  >>"%MainFolder%\patching_output.txt"
if %wii_speak_channel_enable%==1 if %evcregion%==1 WiiWarePatcher\Sharpii.exe WAD -p temp "WAD\Wii Speak Channel (Europe) (Channel).wad"  >>"%MainFolder%\patching_output.txt"
if %wii_speak_channel_enable%==1 if %evcregion%==1 if %wii_speak_channel_enable%==1 set /a temperrorlev=%errorlevel%
if %wii_speak_channel_enable%==1 if %evcregion%==1 set modul=Packing Wii Speak Channel
if %wii_speak_channel_enable%==1 if %evcregion%==1 if not %temperrorlev%==0 goto error_patching


if %wii_speak_channel_enable%==1 if %evcregion%==2 WiiWarePatcher\Sharpii.exe WAD -p temp "WAD\Wii Speak Channel (USA) (Channel).wad"  >>"%MainFolder%\patching_output.txt"
if %wii_speak_channel_enable%==1 if %evcregion%==2 if %wii_speak_channel_enable%==1 set /a temperrorlev=%errorlevel%
if %wii_speak_channel_enable%==1 if %evcregion%==2 set modul=Packing Wii Speak Channel
if %wii_speak_channel_enable%==1 if %evcregion%==2 if not %temperrorlev%==0 goto error_patching
	
if %wii_speak_channel_enable%==1 if %evcregion%==3 WiiWarePatcher\Sharpii.exe WAD -p temp "WAD\Wii Speak Channel (Japan) (Channel).wad"  >>"%MainFolder%\patching_output.txt"
if %wii_speak_channel_enable%==1 if %evcregion%==3 if %wii_speak_channel_enable%==1 set /a temperrorlev=%errorlevel%
if %wii_speak_channel_enable%==1 if %evcregion%==3 set modul=Packing Wii Speak Channel
if %wii_speak_channel_enable%==1 if %evcregion%==3 if not %temperrorlev%==0 goto error_patching
	
if %wii_speak_channel_enable%==1 if %evcregion%==4 WiiWarePatcher\Sharpii.exe WAD -p temp "WAD\Wii Speak Channel (Korea) (Channel).wad" >>"%MainFolder%\patching_output.txt"
if %wii_speak_channel_enable%==1 if %evcregion%==4 if %wii_speak_channel_enable%==1 set /a temperrorlev=%errorlevel%
if %wii_speak_channel_enable%==1 if %evcregion%==4 set modul=Packing Wii Speak Channel
if %wii_speak_channel_enable%==1 if %evcregion%==4 if not %temperrorlev%==0 goto error_patching

if %wii_speak_channel_enable%==1 rmdir temp /s /q >>"%MainFolder%\patching_output.txt"

exit /b 0


:wiiu_patching_fast_travel_99
if not %sdcard%==NUL echo.&echo %string570%
if not %sdcard%==NUL xcopy /y /I "WAD" "%sdcard%:\WAD" /e|| set /a errorcopying=1
if not %sdcard%==NUL xcopy /y /I "apps" "%sdcard%:\apps" /e|| set /a errorcopying=1
if not %sdcard%==NUL xcopy /y /I "wiiu" "%sdcard%:\wiiu" /e|| set /a errorcopying=1
call :clean_temp_files

exit /b 0


:2_4_wiiu
setlocal disableDelayedExpansion
cls
set sound_play=info2&call :sound_play
echo %header%
echo -----------------------------------------------------------------------------------------------------------------------------
echo.
echo %string259%
if %sdcardstatus%==1 if not %sdcard%==NUL if %errorcopying%==0 echo %string260%
if %sdcardstatus%==1 if not %sdcard%==NUL if %errorcopying%==1 echo %string261%

if %sdcardstatus%==0 echo %string262%
echo.
echo %string263%
echo.
echo %string264%
echo.
echo %string265%
echo %string266%
echo.
echo %string267%
pause>NUL
goto 2_7_wiiu
:2_7_wiiu
cls
echo %header%
echo -----------------------------------------------------------------------------------------------------------------------------
echo.
echo %string268%
echo.
echo %string269%
echo.
echo %string270%
echo.
echo 1. %string271%
echo 2. %string272%
if %preboot_environment%==1 echo 3. %string489%
set /p s=%string26%: 
if %s%==1 set sound_play=confirm1&call :sound_play&goto script_start
if %s%==2 set sound_play=exit1&call :sound_play&goto end
if %preboot_environment%==1 if %s%==3 "X:\TOTALCMD.exe"
goto 2_7_wiiu

:1
cls
echo %header%
echo -----------------------------------------------------------------------------------------------------------------------------
if exist "%TempStorage%\annoucement.txt" echo --- %string148% --- 
if exist "%TempStorage%\annoucement.txt" type "%TempStorage%\annoucement.txt"
if exist "%TempStorage%\annoucement.txt" echo -------------------
echo.
echo %string155%?
echo.
echo 1. %string273%
echo   - %string157%
echo.
echo 2. %string274%
echo   - %string275%
echo.
echo --- %string158% ---
echo.
echo 3. %string192%
echo   - %string193%
echo.
echo 4. %string159%
echo   - %string160%
echo.
echo 5. %string579%
echo   - %string578%
echo.
echo 6. %string165%
echo   - %string166%
echo.
set /p s=%string26%: 
if %s%==1 set sound_play=confirm1&call :sound_play&goto 2_prepare
if %s%==2 set sound_play=confirm1&call :sound_play&goto 2_prepare_uninstall
if %s%==3 set sound_play=confirm1&call :sound_play&goto direct_install_download_binary
if %s%==4 set sound_play=confirm1&call :sound_play&goto wadgames_patch_info
if %s%==5 set sound_play=confirm1&call :sound_play&goto wiimmfi_patcher_prepare
if %s%==6 set sound_play=confirm1&call :sound_play&goto open_shop_sdcarddetect
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
echo [*] %string276%
echo   ^> %string277%
echo.
echo %string278% %username%^^!
echo %string279%
echo.
echo %string280%
echo %string281%
echo.
echo %string282%
echo.
echo 1. %string283%
echo 2. %string284%
set /p s=%string26%: 
if %s%==1 set sound_play=confirm1&call :sound_play&set tempgotonext=direct_install_sdcard_configuration_summary& goto detect_sd_card
if %s%==2 set sound_play=exit1&call :sound_play&goto direct_install_sdcard_nosdcard_access
goto direct_install_sdcard_configuration
:direct_install_sdcard_nosdcard_access
cls
echo %header%
echo -----------------------------------------------------------------------------------------------------------------------------
echo.
echo [*] %string276%
echo   ^> %string277%
echo.
echo %string285%
echo %string286%
echo.
echo %string287%
pause>NUL
set sound_play=exit1&call :sound_play
goto begin_main
:direct_install_sdcard_configuration_summary
setlocal disableDelayedExpansion
cls
echo %header%
echo -----------------------------------------------------------------------------------------------------------------------------
echo.
echo [*] %string276%
echo   ^> %string277%
echo.
if %sdcard%==NUL echo %string104%
if %sdcard%==NUL echo %string105%
if %sdcard%==NUL echo.
if %sdcard%==NUL echo %string288%
if not %sdcard%==NUL echo %string107% %sdcard%
if not %sdcard%==NUL echo %string289%
echo.
echo %string238%
if %sdcard%==NUL echo 1. %string290%  2. %string112%  3. %string111%
if not %sdcard%==NUL echo 1. %string110% 2. %string111% 3. %string112%
echo.
set /p s=%string26%: 

	if %sdcard%==NUL if %s%==1 set sound_play=confirm1&call :sound_play&set tempgotonext=direct_install_sdcard_configuration_summary& goto detect_sd_card
	if %sdcard%==NUL if %s%==2 set sound_play=confirm1&call :sound_play&goto direct_install_sdcard_configuration_drive_letter
	if %sdcard%==NUL if %s%==3 set sound_play=exit1&call :sound_play&goto begin_main

	if not %sdcard%==NUL if %s%==1 set sound_play=confirm1&call :sound_play&goto direct_install_sdcard_configuration_xazzy
	if not %sdcard%==NUL if %s%==1 set sound_play=exit1&call :sound_play&goto begin_main
	if not %sdcard%==NUL if %s%==1 set sound_play=confirm1&call :sound_play&goto direct_install_sdcard_configuration_drive_letter
goto direct_install_sdcard_configuration_summary
:direct_install_sdcard_configuration_drive_letter
cls
echo %header%
echo -----------------------------------------------------------------------------------------------------------------------------
echo.
echo [*] %string276%
echo   ^> %string277%
echo.
echo %string113%: %sdcard%
echo.
echo %string114%
set /p sdcard=
set sound_play=confirm1&call :sound_play
goto direct_install_sdcard_configuration_summary

:direct_install_sdcard_configuration_xazzy
cls
echo %header%
echo -----------------------------------------------------------------------------------------------------------------------------
echo.
echo [*] %string276%
echo   ^> %string277%
echo.
echo %string291%
md "%sdcard%:\apps\xyzzy-mod"

curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/apps/xyzzy-mod/boot.dol" --output "%sdcard%:\apps\xyzzy-mod\boot.dol"
	if not %errorlevel%==0 goto direct_install_sdcard_configuration_xazzy_download_error

curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/apps/xyzzy-mod/icon.png" --output "%sdcard%:\apps\xyzzy-mod\icon.png"
	if not %errorlevel%==0 goto direct_install_sdcard_configuration_xazzy_download_error
	
curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/apps/xyzzy-mod/meta.xml" --output "%sdcard%:\apps\xyzzy-mod\meta.xml"
		if not %errorlevel%==0 goto direct_install_sdcard_configuration_xazzy_download_error

goto direct_install_sdcard_configuration_xazzy_wait

:direct_install_sdcard_configuration_xazzy_download_error
cls
set sound_play=warning1&call :sound_play
echo %header%
echo -----------------------------------------------------------------------------------------------------------------------------
echo.
echo [*] %string276%
echo   ^> %string277%
echo.
echo %string292%
echo.
echo %string293%
echo %string294%
pause>NUL
set sound_play=exit1&call :sound_play
goto begin_main
:direct_install_sdcard_configuration_xazzy_wait
cls
echo %header%
echo -----------------------------------------------------------------------------------------------------------------------------
echo.
echo [*] %string276%
echo   ^> %string277%
echo.
echo %string295%
echo.
echo %string296%
echo %string297%
echo.
echo %string298%
echo %string299%
echo.
echo %string300%
echo.
echo 1. %string301%
echo 2. %string302%
echo.
set /p s=%string26%: 
if %s%==1 set sound_play=confirm1&call :sound_play&goto direct_install_sdcard_configuration_xazzy_find
if %s%==2 set sound_play=exit1&call :sound_play&goto begin_main

goto direct_install_sdcard_configuration_xazzy_wait

:direct_install_sdcard_configuration_xazzy_find
cls
echo %header%
echo -----------------------------------------------------------------------------------------------------------------------------
echo.
echo [*] %string276%
echo   ^> %string277%
echo.
echo %string87%
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
echo [*] %string276%
echo   ^> %string277%
echo.
echo %string303%
echo %string304%
echo.
echo 1. %string305%
echo 2. %string306%
echo.
set /p s=%string26%: 
if %s%==1 set sound_play=confirm1&call :sound_play&goto direct_install_sdcard_configuration_xazzy_find
if %s%==2 set sound_play=confirm1&call :sound_play&goto direct_install_sdcard_configuration_xazzy_wait

goto direct_install_sdcard_configuration_xazzy_error
:direct_install_sdcard_configuration_xazzy_done
cls
echo %header%
echo -----------------------------------------------------------------------------------------------------------------------------
echo.
echo [*] %string276%
echo   ^> %string277%
echo.
echo %string307%
echo %string308%
echo.
echo %string309%
pause>NUL
set sound_play=confirm1&call :sound_play
goto direct_install_sdcard_main_menu
:direct_install_sdcard_auto_not_found
cls
echo %header%
echo -----------------------------------------------------------------------------------------------------------------------------
echo.
echo [*] %string276%
echo   ^> %string277%
echo.
echo %string310%
echo %string311%
echo.
echo 1. %string283%
echo 2. %string312%
echo 3. %string306%
set /p s=%string26%: 
if %s%==1 set sound_play=confirm1&call :sound_play&goto direct_install_sdcard_main_menu
if %s%==2 set sound_play=confirm1&call :sound_play&goto direct_install_sdcard_set
if %s%==3 set sound_play=exit1&call :sound_play&goto begin_main
goto direct_install_sdcard_auto_not_found

:direct_install_sdcard_set
cls
echo %header%
echo -----------------------------------------------------------------------------------------------------------------------------
echo.
echo [*] %string276%
echo   ^> %string277%
echo.
echo %string113%: %sdcard%
echo.
echo %string114%
set /p sdcard=
set sound_play=confirm1&call :sound_play
goto direct_install_sdcard_main_menu
:direct_install_download_binary
cls
echo %header%
echo -----------------------------------------------------------------------------------------------------------------------------
echo.
echo %string116%
echo %string313%

curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/wad2bin.exe" --output "wad2bin.exe"
set /a temperrorlev=%errorlevel%

if not %temperrorlev%==0 goto direct_install_download_binary_error

goto direct_install_sdcard_main_menu

:direct_install_download_binary_error
cls
echo %header%
echo -----------------------------------------------------------------------------------------------------------------------------
echo.
echo %string314%
echo %string118%: %temperrorlev%
echo.
echo %string287%
pause>NUL
set sound_play=exit1&call :sound_play
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
echo [*] %string276%
echo   ^> %string277%
echo.
echo %string278% %username%^! %string315%
if %direct_install_del_done%==1 echo.
if %direct_install_del_done%==1 echo :------------------------------------------:
if %direct_install_del_done%==1 echo  %string316%
if %direct_install_del_done%==1 echo :------------------------------------------:
set /a direct_install_del_done=0

echo.
echo 1. %string317%
echo 2. %string318%
echo 3. %string319%
echo.
echo 4. %string320%
echo 5. %string321%
if %preboot_environment%==1 echo 6. %string489%
echo.
set /p s=%string26%: 
if %s%==1 set sound_play=confirm1&call :sound_play&goto direct_install_bulk
:: if %s%==2 goto direct_install_dlc
:: If you're reading this, you know what you're doing.
:: There's an issue with wad2bin that needs to be sorted out. Coming soon.

if %s%==3 set sound_play=exit1&call :sound_play&goto direct_install_sdcard_configuration
if %s%==4 set sound_play=confirm1&call :sound_play&goto direct_install_delete_bogus
if %s%==5 set sound_play=exit1&call :sound_play&goto begin_main
if %preboot_environment%==1 if %s%==6 "X:\TOTALCMD.exe"
goto direct_install_sdcard_main_menu

:direct_install_dlc
cls
echo %header%
echo -----------------------------------------------------------------------------------------------------------------------------
echo.
echo [*] %string276%
echo   ^> %string277%
echo.
if not exist "wad2bin" md wad2bin
if %direct_install_bulk_files_error%==1 echo :-------------------------------------------------------:
if %direct_install_bulk_files_error%==1 echo  %string322%
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
echo   ^> %string277%
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
echo %%a
if not "!dlc_id!"=="NUL" wad2bin "%MainFolder%\WiiKeys\keys.txt" "%MainFolder%\WiiKeys\device.cert" "%%a" "%sdcard%:" !dlc_id!
echo off
pause
	set /a temperrorlev=!errorlevel!
	if not !temperrorlev!==0 goto direct_install_single_fail

move /Y "%sdcard%:\*_bogus.wad" "%sdcard%:\WAD\">NUL

set /a patching_file=!patching_file!+1
)
del /q wad2bin_output.txt
echo.
set sound_play=info2&call :sound_play
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
echo [*] %string276%
echo   ^> %string277%
echo.
if not exist "wad2bin" md wad2bin
if %direct_install_bulk_files_error%==1 echo :-------------------------------------------------------:
if %direct_install_bulk_files_error%==1 echo  %string322%
if %direct_install_bulk_files_error%==1 echo :-------------------------------------------------------:
if %direct_install_bulk_files_error%==1 echo.
set /a direct_install_bulk_files_error=0

echo %string323%
echo %string324%
echo %string325%
echo.
echo :-----------------------------------------------------:
echo   %string326%
echo :-----------------------------------------------------:
echo.
echo %string327%
echo.
echo 1. %string328%
echo 2. %string329%
set /p s=%string26%: 
if %s%==1 set sound_play=confirm1&call :sound_play&goto direct_install_bulk_scan
if %s%==2 set sound_play=exit1&call :sound_play&goto direct_install_sdcard_main_menu

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

if exist installation_error_log.txt del /q installation_error_log.txt
set /a error_count=0

if not exist "%sdcard%:\WAD" md "%sdcard%:\WAD">NUL


for %%f in ("wad2bin\*.wad") do (

cls
echo %header_for_loops%
echo -----------------------------------------------------------------------------------------------------------------------------
echo.
echo [.] %string276%
echo   ^> %string277%
echo.
echo %string330% [!patching_file!] %string331% [%file_counter%]
echo %string332%: %%~nf
call wad2bin.exe "%MainFolder%\WiiKeys\keys.txt" "%MainFolder%\WiiKeys\device.cert" "%%f" %sdcard%:\>wad2bin_output.txt
	set /a temperrorlev=!errorlevel!
	if not !temperrorlev!==0 set /a error_count+=1& echo [%time:~0,8%] [%date%] [%string482%: !errorlevel!] %string490% %%~nf>>installation_error_log.txt

move /Y "%sdcard%:\*_bogus.wad" "%sdcard%:\WAD\">NUL

set /a patching_file=!patching_file!+1
)
del /q wad2bin_output.txt
echo.
echo %string333%
echo  %string334%
echo  %string335%
echo.
echo  %string336%
echo  %string337%
echo  %string338%
echo.
setlocal disableDelayedExpansion
if not "%error_count%"=="0" echo %string491% %error_count% %string492%
if not "%error_count%"=="0" echo %string493%
if not "%error_count%"=="0" set sound_play=warning1&call :sound_play
if not "%error_count%"=="0" pause>NUL
if not "%error_count%"=="0" start "" "installation_error_log.txt"
if not "%error_count%"=="0" goto direct_install_sdcard_main_menu

echo %string294%




pause>NUL
goto direct_install_sdcard_main_menu
:direct_install_delete_bogus
cls
echo %header%
echo -----------------------------------------------------------------------------------------------------------------------------
echo.
echo [*] %string276%
echo   ^> %string277%
echo.
echo %string339%
echo %string340%
echo.
echo %string341%
echo.
echo 1. %string245%
echo 2. %string329%
set /p s=%string26%: 
if %s%==1 set sound_play=exit1&call :sound_play&del /q "%sdcard%:\WAD\*_bogus.wad"&set /a direct_install_del_done=1&goto direct_install_sdcard_main_menu
if %s%==2 set sound_play=exit1&call :sound_play&goto direct_install_sdcard_main_menu
goto direct_install_delete_bogus

:direct_install_single_fail
cls
set sound_play=warning3&call :sound_play
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
echo    /---\   %string73%
echo   /     \  %string342%
echo  /   ^!   \ 
echo  --------- %string343%: %temperrorlev%
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
echo            %string344%
echo.
echo       1. %string345%
echo       2. %string346%
echo ---------------------------------------------------------------------------------------------------------------------------
echo.
set /p s=%string26%: 
if %s%==1 goto direct_install_sdcard_main_menu
if %s%==2 call "wad2bin_output.txt"
goto direct_install_single_fail
:wiimmfi_patcher_prepare
cls
echo %header%
echo -----------------------------------------------------------------------------------------------------------------------------
echo.
echo %string347%
echo %string348%
echo.
echo %string253%:
set tempCD=%cd%

	set wiimmfi_patcher_down_url=NUL
	set wiimmfi_patcher_zip_name=NUL
	set wiimmfi_patcher_zip_extracted_folder_name=NUL

echo 7%%
For /F "Delims=" %%A In ('curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/UPDATE/wiimmfi_patcher_config/wiimmfi_patcher_zip_extracted_folder_name.txt"') do set "wiimmfi_patcher_zip_extracted_folder_name=%%A"
echo 14%%
For /F "Delims=" %%B In ('curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/UPDATE/wiimmfi_patcher_config/wiimmfi_patcher_zip_name.txt"') do set "wiimmfi_patcher_zip_name=%%B"
echo 21%%
For /F "Delims=" %%C In ('curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/UPDATE/wiimmfi_patcher_config/wiimmfi_patcher_down_url.txt"') do set "wiimmfi_patcher_down_url=%%C"

	if "%wiimmfi_patcher_zip_extracted_folder_name%"=="NUL" goto wiimmfi_patcher_download_error
	if "%wiimmfi_patcher_zip_name%"=="NUL" goto wiimmfi_patcher_download_error
	if "%wiimmfi_patcher_zip_extracted_folder_name%"=="NUL" goto wiimmfi_patcher_download_error

if exist Wiimmfi-Patcher rmdir /s /q Wiimmfi-Patcher
md Wiimmfi-Patcher
echo 25%%
echo.
curl -f -L %useragent% --insecure "%wiimmfi_patcher_down_url%" --output "Wiimmfi-Patcher\%wiimmfi_patcher_zip_name%"
	set /a temperrorlev=%errorlevel%
	if not %temperrorlev%==0 goto wiimmfi_patcher_download_error
echo 50%%
curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/7z.exe" --output "Wiimmfi-Patcher\7z.exe"
	set /a temperrorlev=%errorlevel%
	if not %temperrorlev%==0 goto wiimmfi_patcher_download_error
echo 75%%
cd Wiimmfi-Patcher
7z.exe x %wiimmfi_patcher_zip_name%>NUL

cd ..

echo 100%%
goto wiimmfi_patcher_patch_ask
:wiimmfi_patcher_download_error
cls
echo %header%
echo -----------------------------------------------------------------------------------------------------------------------------
echo.
echo %string577%
echo %string542%
echo.
echo %string309%
pause>NUL
goto begin_main


:wiimmfi_patcher_patch_ask
setlocal disableDelayedExpansion
cls
echo %header%
echo -----------------------------------------------------------------------------------------------------------------------------
echo.
echo %string349%
echo %string350%
echo.

if "%wiimmfi_file_check_error%"=="1" echo :-----------------------------------------------------------------:
if "%wiimmfi_file_check_error%"=="1" echo  %string574%
if "%wiimmfi_file_check_error%"=="1" echo  %string575%
if "%wiimmfi_file_check_error%"=="1" echo :-----------------------------------------------------------------:
if "%wiimmfi_file_check_error%"=="1" echo.
set /a wiimmfi_file_check_error=0

	set /a temp_file_check=0
if exist "*.ISO" set /a temp_file_check+=1&echo %string351%: %string353%
if not exist "*.ISO" echo %string351%: %string354%
if exist "*.WBFS" set /a temp_file_check+=1&echo %string352%: %string353%
if not exist "*.WBFS" echo %string352%: %string354%
echo.
if %wiimmfi_patcher_backup%==1 echo C. [X] %string571%
if %wiimmfi_patcher_backup%==0 echo C. [ ] %string571%
echo.
echo 1. %string355%
echo 2. %string356%
set /p s=%string26%: 
if %s%==1 (
	if "%temp_file_check%"=="0" set sound_play=warning1&call :sound_play&set /a wiimmfi_file_check_error=1&goto wiimmfi_patcher_patch_ask
	set sound_play=confirm1&call :sound_play
	goto start_wiimmfi-patcher
	)
if %s%==2 set sound_play=exit1&call :sound_play&rmdir /s /q Wiimmfi-Patcher&goto begin_main
if %s%==c set sound_play=select3&call :sound_play&call :switch_wiimmfi_patcher_backup
if %s%==C set sound_play=select3&call :sound_play&call :switch_wiimmfi_patcher_backup

goto wiimmfi_patcher_patch_ask
:start_wiimmfi-patcher
cls
echo %header%
echo -----------------------------------------------------------------------------------------------------------------------------
echo.

if %wiimmfi_patcher_backup%==1 (
	echo %string576%
	if exist "*.WBFS" copy "*.WBFS" "Wiimmfi-Patcher\%wiimmfi_patcher_zip_extracted_folder_name%"
	if exist "*.ISO" copy "*.ISO" "Wiimmfi-Patcher\%wiimmfi_patcher_zip_extracted_folder_name%"
	)

if %wiimmfi_patcher_backup%==0 (
	if exist "*.WBFS" move "*.WBFS" "Wiimmfi-Patcher\%wiimmfi_patcher_zip_extracted_folder_name%"
	if exist "*.ISO" move "*.ISO" "Wiimmfi-Patcher\%wiimmfi_patcher_zip_extracted_folder_name%"
	)
cd "Wiimmfi-Patcher\%wiimmfi_patcher_zip_extracted_folder_name%"


@echo off

set ORIGPATH=%PATH%
if exist "%PROGRAMFILES(X86)%" (set cw=cygwin64) else (set cw=cygwin32)
set PATH=bin\%cw%;%PATH%
bash ./patch-images.sh
set PATH=%ORIGPATH%

echo.

echo.
	set /a temperrorlev=%errorlevel%
	if %temperrorlev%==0 echo %string572%
	if not %temperrorlev%==0 echo %string573%
echo.
cd /D %currentPath%

if not exist wiimmfi-images md wiimmfi-images
if exist "Wiimmfi-Patcher\%wiimmfi_patcher_zip_extracted_folder_name%\wiimmfi-images\*.iso" move "Wiimmfi-Patcher\%wiimmfi_patcher_zip_extracted_folder_name%\wiimmfi-images\*.iso" "wiimmfi-images\">NUL
if exist "Wiimmfi-Patcher\%wiimmfi_patcher_zip_extracted_folder_name%\wiimmfi-images\*.wbfs" move "Wiimmfi-Patcher\%wiimmfi_patcher_zip_extracted_folder_name%\wiimmfi-images\*.wbfs" "wiimmfi-images\">NUL

rmdir /S /Q Wiimmfi-Patcher
pause
mode %mode%

ping localhost -n 2>NUL

cls
echo %header%
echo -----------------------------------------------------------------------------------------------------------------------------
echo.
echo %string357% 
echo %string358%
echo.
echo %string359%
pause>NUL

goto script_start

:mariokartwii_patch
cls
echo %header%
echo -----------------------------------------------------------------------------------------------------------------------------
echo.
echo %string360%
echo %string348%
echo.
echo %string253%:
set tempCD=%cd%
if exist MKWii-Patcher rmdir /s /q MKWii-Patcher
md MKWii-Patcher
echo 25%%
curl -f -L -s -S %useragent% --insecure "https://download.wiimm.de/wiimmfi/patcher/mkw-wiimmfi-patcher-v6.zip" --output "MKWii-Patcher\mkw-wiimmfi-patcher-v6.zip"
if not "%errorcode%"=="0" goto wiimmfi_patcher_download_error
echo 50%%
curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/7z.exe" --output "MKWii-Patcher\7z.exe"
if not "%errorcode%"=="0" goto wiimmfi_patcher_download_error
echo 75%%
cd MKWii-Patcher
7z.exe x mkw-wiimmfi-patcher-v6.zip>NUL
cd..
echo 100%%
goto mariokartwii_patch_ask

:mariokartwii_patch_ask
setlocal disableDelayedExpansion
cls
echo %header%
echo -----------------------------------------------------------------------------------------------------------------------------
echo.
echo %string361%
echo %string362%
echo.

if "%wiimmfi_file_check_error%"=="1" echo :-----------------------------------------------------------------:
if "%wiimmfi_file_check_error%"=="1" echo  %string574%
if "%wiimmfi_file_check_error%"=="1" echo  %string575%
if "%wiimmfi_file_check_error%"=="1" echo :-----------------------------------------------------------------:
if "%wiimmfi_file_check_error%"=="1" echo.
set /a wiimmfi_file_check_error=0

	set /a temp_file_check=0
if exist "*.ISO" set /a temp_file_check+=1&echo %string351%: %string353%
if not exist "*.ISO" echo %string351%: %string354%
if exist "*.WBFS" set /a temp_file_check+=1&echo %string352%: %string353%
if not exist "*.WBFS" echo %string352%: %string354%
echo.
if %wiimmfi_patcher_backup%==1 echo C. [X] %string571%
if %wiimmfi_patcher_backup%==0 echo C. [ ] %string571%
echo.
echo 1. %string363%
echo 2. %string356%
echo.
set /p s=%string26%: 
if %s%==1 (
	if "%temp_file_check%"=="0" set /a wiimmfi_file_check_error=1&goto mariokartwii_patch_ask
	set sound_play=confirm1&call :sound_play
	goto start_mkwii-patcher
	)
if %s%==2 set sound_play=exit1&call :sound_play&rmdir /s /q MKWii-Patcher&goto begin_main
if %s%==c set sound_play=select3&call :sound_play&call :switch_wiimmfi_patcher_backup
if %s%==C set sound_play=select3&call :sound_play&call :switch_wiimmfi_patcher_backup
goto mariokartwii_patch_ask

:switch_wiimmfi_patcher_backup
if %wiimmfi_patcher_backup%==1 set /a wiimmfi_patcher_backup=0&exit /b 0
if %wiimmfi_patcher_backup%==0 set /a wiimmfi_patcher_backup=1&exit /b 0

:start_mkwii-patcher
cls
echo %header%
echo -----------------------------------------------------------------------------------------------------------------------------
echo.
set tempCD=%cd%
if %wiimmfi_patcher_backup%==1 (
	if exist "*.WBFS" copy "*.WBFS" "MKWii-Patcher\mkw-wiimmfi-patcher-v6\"
	if exist "*.ISO" copy "*.ISO" "MKWii-Patcher\mkw-wiimmfi-patcher-v6\"
	)

if %wiimmfi_patcher_backup%==0 (
	if exist "*.WBFS" move "*.WBFS" "MKWii-Patcher\mkw-wiimmfi-patcher-v6\"
	if exist "*.ISO" move "*.ISO" "MKWii-Patcher\mkw-wiimmfi-patcher-v6\"
	)

cd MKWii-Patcher\mkw-wiimmfi-patcher-v6

@echo off

mode 130,250

::Actual patching
set PATH=bin\cygwin;%PATH%
bash ./patch-wiimmfi.sh
echo.
	set /a temperrorlev=%errorlevel%
	if %temperrorlev%==0 echo %string572%
	if not %temperrorlev%==0 echo %string573%

cd /D %currentPath%
if not exist wiimmfi-images md wiimmfi-images
if exist "MKWii-Patcher\mkw-wiimmfi-patcher-v6\wiimmfi-images\*.iso" move "MKWii-Patcher\mkw-wiimmfi-patcher-v6\wiimmfi-images\*.iso" "wiimmfi-images\">NUL
if exist "MKWii-Patcher\mkw-wiimmfi-patcher-v6\wiimmfi-images\*.wbfs" move "MKWii-Patcher\mkw-wiimmfi-patcher-v6\wiimmfi-images\*.wbfs" "wiimmfi-images\">NUL

pause
mode %mode% 

rmdir MKWii-Patcher

cls
set sound_play=info2&call :sound_play
echo %header%
echo -----------------------------------------------------------------------------------------------------------------------------
echo.
echo %string357%
echo %string364%
echo.
echo %string359%
pause>NUL
set sound_play=exit1&call :sound_play&
goto script_start

:wadgames_download_error
cls
set sound_play=warning1&call :sound_play
echo %header%
echo -----------------------------------------------------------------------------------------------------------------------------
echo.
echo %string541%
echo %string542%
echo.
echo %string309%
pause>NUL
goto begin_main

:wadgames_patch_info
cls
echo %header%
echo -----------------------------------------------------------------------------------------------------------------------------
echo.
echo %string365%
echo %string348%
echo.
echo %string253%:
call :check_rc24_server_connection
if "%errorlevel%"=="1" goto server_connection_lost
if exist WiiWarePatcher rmdir /s /q WiiWarePatcher
md WiiWarePatcher
curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/WiiWarePatcher/libWiiSharp.dll" --output "WiiWarePatcher/libWiiSharp.dll"
set /a temperrorlev=%errorlevel%
if not %temperrorlev%==0 goto wadgames_download_error
echo 20%%
curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/WiiWarePatcher/lzx.exe" --output "WiiWarePatcher/lzx.exe"
set /a temperrorlev=%errorlevel%
if not %temperrorlev%==0 goto wadgames_download_error
echo 40%%
curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/WiiWarePatcher/Sharpii.exe" --output "WiiWarePatcher/Sharpii.exe"
set /a temperrorlev=%errorlevel%
if not %temperrorlev%==0 goto wadgames_download_error
echo 60%%
curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/WiiWarePatcher/WadInstaller.dll" --output "WiiWarePatcher/WadInstaller.dll"
set /a temperrorlev=%errorlevel%
if not %temperrorlev%==0 goto wadgames_download_error
echo 80%%
curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/WiiWarePatcher/WiiWarePatcher.exe" --output "WiiWarePatcher/WiiWarePatcher.exe"
set /a temperrorlev=%errorlevel%
if not %temperrorlev%==0 goto wadgames_download_error
echo 100%%
goto wadgames_patch_ask
:wadgames_patch_ask
cls
echo %header%
echo -----------------------------------------------------------------------------------------------------------------------------
echo.
echo %string548%
echo %string549%
echo.
echo %string550%
echo %string551%
if "%no_wads_warning%"=="1" echo.
if "%no_wads_warning%"=="1" echo :------------------------------------------------------------------:
if "%no_wads_warning%"=="1" echo  %string552%
if "%no_wads_warning%"=="1" echo  %string553%
if "%no_wads_warning%"=="1" echo :------------------------------------------------------------------:
echo.
echo 1. %string110%.
echo 2. %string356%
echo.
set /p s=%string26%: 
if %s%==1 (
	if not exist "*.wad" set /a no_wads_warning=1&set sound_play=warning1&call :sound_play&& goto wadgames_patch_ask
	set sound_play=confirm1&call :sound_play
	goto wadgames_patch_begin
	)
if %s%==2 set sound_play=exit1&call :sound_play&goto script_start
goto wadgames_patch_ask

:wadgames_patch_begin
if not exist temp md temp
if not exist wiimmfi-wads md wiimmfi-wads
if not exist backup-wads md backup-wads

set /a patching_file=1
set /a wiiware_patching=1
set /a file_counter=0

for %%f in ("*.wad") do set /a file_counter+=1
setlocal EnableDelayedExpansion

for %%f in ("*.wad") do (
cls
echo %header_for_loops%
echo ------------------------------------------------------------------------------------------------------------------------
echo.
echo %string546% [!patching_file!] %string331% [%file_counter%]
echo %string547%: %%~nf
echo.
copy /b "%%f" backup-wads >NUL
set /a temperrorlev=%errorlevel%
set modul=copy.exe
if not %temperrorlev%==0 goto error_patching

WiiWarePatcher\Sharpii.exe WAD -u "%%f" temp >NUL
set /a temperrorlev=%errorlevel%
set modul=Sharpii.exe
if not %temperrorlev%==0 goto error_patching

move temp\00000001.app WiiWarePatcher\00000001.app >NUL
set /a temperrorlev=%errorlevel%
set modul=move.exe
if not %temperrorlev%==0 goto error_patching

cd WiiWarePatcher
call WiiWarePatcher.exe
set /a temperrorlev=%errorlevel%
cd ..
set modul=WiiWarePatcher.exe
if not %temperrorlev%==0 goto error_patching

move WiiWarePatcher\00000001.app temp\00000001.app >NUL
set /a temperrorlev=%errorlevel%
set modul=move.exe
if not %temperrorlev%==0 goto error_patching

del "%%f" >NUL
set /a temperrorlev=%errorlevel%
set modul=del.exe
if not %temperrorlev%==0 goto error_patching

WiiWarePatcher\Sharpii.exe WAD -p temp "wiimmfi-wads/%%f" >NUL
set /a temperrorlev=%errorlevel%
set modul=Sharpii.exe
if not %temperrorlev%==0 goto error_patching

set /a patching_file=%patching_file%+1

rmdir temp /s /q >NUL
)

setlocal DisableDelayedExpansion
cd wiimmfi-wads
for %%a in (*.wad) do ren "%%~a" "%%~na_Wiimmfi%%~xa" >NUL

set /a wiiware_patching=0
cd..

goto wadgames_end_info
:wadgames_end_info
cls
set sound_play=info2&call :sound_play
echo %header%
echo -----------------------------------------------------------------------------------------------------------------------------
echo.
echo %string543%
echo.
echo %string544%
echo %string545%
echo.
echo %string90%
pause>NUL
goto begin_main

:2_uninstall
cls
echo %header%
echo -----------------------------------------------------------------------------------------------------------------------------
echo.
echo :-------------------------------------------------------------------------------------------------------------------:
echo  %string372%
echo  %string373%
echo :-------------------------------------------------------------------------------------------------------------------:
echo.
echo %string374%
echo %string375%
echo - %string204%
echo - %string376%
echo - %string377%
echo.
echo %string378%
echo.
echo %string379%
echo 1. %string245%
echo 2. %string329%
echo.
set /p s=%string26%: 
if %s%==1 set sound_play=confirm1&call :sound_play&goto 2_uninstall_1
if %s%==2 set sound_play=exit1&call :sound_play&goto 1
goto 2_uninstall
:2_uninstall_1
cls
echo %header%
echo -----------------------------------------------------------------------------------------------------------------------------
echo.
echo %string380%
echo %string381%
echo.
echo 1. %string245%
echo 2. %string246%
set /p uninstall_2_1=%string26%: 
if %uninstall_2_1%==1 set sound_play=confirm1&call :sound_play&goto 2_uninstall_2
if %uninstall_2_1%==2 set sound_play=exit1&call :sound_play&goto 2_uninstall_2_2
goto 2_uninstall_1
:2_uninstall_2
cls
echo %header%
echo -----------------------------------------------------------------------------------------------------------------------------
echo.
echo %string382%
echo %string383%
echo %string384%
echo.
echo 1. %string385%
echo 2. %string246%
set /p uninstall_2_2=%string26%: 
if %uninstall_2_2%==1 set sound_play=confirm1&call :sound_play&goto 2_uninstall_2_1
if %uninstall_2_2%==2 set sound_play=exit1&call :sound_play&goto 2_uninstall_2_2
goto 2_uninstall_2
:2_uninstall_2_1
cls
echo %header%
echo -----------------------------------------------------------------------------------------------------------------------------
echo.
echo %string386%
echo %string387%
echo %string388%
echo %string389%
echo.
echo %string390%
echo %string391%
echo.
echo %string392%
ping localhost -n 2 >NUL
pause>NUL
goto 2_uninstall_2_2
:2_uninstall_2_2
cls
echo %header%
echo -----------------------------------------------------------------------------------------------------------------------------
echo.
echo %string566%
echo.
echo 1. %string183% (E)
echo 2. %string184% (U)
echo 3. %string531% (J)
echo.
set /p s=%string223%: 
set sound_play=confirm1&call :sound_play

if "%s%"=="e" set /a evcregion=1& goto 2_uninstall_3
if "%s%"=="u" set /a evcregion=2& goto 2_uninstall_3
if "%s%"=="j" set /a evcregion=3& goto 2_uninstall_3

if "%s%"=="E" set /a evcregion=1& goto 2_uninstall_3
if "%s%"=="U" set /a evcregion=2& goto 2_uninstall_3
if "%s%"=="J" set /a evcregion=3& goto 2_uninstall_3

if "%s%"=="1" set /a evcregion=1& goto 2_uninstall_3
if "%s%"=="2" set /a evcregion=2& goto 2_uninstall_3
if "%s%"=="3" set /a evcregion=3& goto 2_uninstall_3

goto 2_uninstall_2_2


:2_uninstall_3
setlocal disableDelayedExpansion
cls
echo %header%
echo -----------------------------------------------------------------------------------------------------------------------------
echo.
echo %string393%
echo.
echo %string394%
echo.
echo 1. %string229%
echo 2. %string230%
set sdcard=NUL
set /p sdcard=%string26%: 
if %sdcard%==1 set sound_play=confirm1&call :sound_play&set /a sdcardstatus=1& set tempgotonext=2_uninstall_3_summary& goto detect_sd_card
if %sdcard%==2 set sound_play=exit1&call :sound_play&set /a sdcardstatus=0& set sdcard=NUL&set /a sdcard_refresh_pending=1& goto 2_uninstall_3_summary
goto 2_uninstall_3
:2_uninstall_3_summary
set /a temperrorlev=0
set /a counter_done=0
set /a percent=0
set /a temperrorlev=0

cls
echo %header%
echo -----------------------------------------------------------------------------------------------------------------------------
echo.
if %sdcardstatus%==0 echo %string231%
if %sdcardstatus%==1 if %sdcard%==NUL echo %string232%
if %sdcardstatus%==1 if %sdcard%==NUL echo %string233%
if %sdcardstatus%==1 if %sdcard%==NUL echo.
if %sdcardstatus%==1 if %sdcard%==NUL echo %string234%
if %sdcardstatus%==1 if not %sdcard%==NUL echo %string235% %sdcard%
if %sdcardstatus%==1 if not %sdcard%==NUL echo %string236%
echo.
echo %string395%
echo.
echo %string109%
if %sdcardstatus%==0 echo 1. %string239%  2. %string240%
if %sdcardstatus%==1 if %sdcard%==NUL echo 1. %string239% 2. %string240% 3. %string241%
if %sdcardstatus%==1 if not %sdcard%==NUL echo 1. %string239% 2. %string240% 3. %string241%
set /p s=%string26%: 
if %s%==1 set sound_play=confirm1&call :sound_play&goto 2_uninstall_4
if %s%==2 set sound_play=exit1&call :sound_play&goto begin_main
if %s%==3 set sound_play=confirm1&call :sound_play&goto 2_uninstall_change_drive_letter
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
echo  [*] %string396%
echo.
echo    %string253%: 
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

if %percent%==1 call :clean_temp_files

::Download files
if %percent%==1 if not exist IOSPatcher md IOSPatcher
if %percent%==1 if not exist WAD md WAD
if %percent%==1 if not exist "IOSPatcher/00000006-31.delta" curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/IOSPatcher/00000006-31.delta" --output IOSPatcher/00000006-31.delta
if %percent%==1 set /a temperrorlev=%errorlevel%
if %percent%==1 set modul=Downloading 06-31.delta
if %percent%==1 if not %temperrorlev%==0 goto error_patching

if %percent%==3 if not exist "IOSPatcher/00000006-80.delta" curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/IOSPatcher/00000006-80.delta" --output IOSPatcher/00000006-80.delta
if %percent%==3 set /a temperrorlev=%errorlevel%
if %percent%==3 set modul=Downloading 06-80.delta
if %percent%==3 if not %temperrorlev%==0 goto error_patching

if %percent%==6 if not exist "IOSPatcher/00000006-80.delta" curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/IOSPatcher/00000006-80.delta" --output IOSPatcher/00000006-80.delta
if %percent%==6 set /a temperrorlev=%errorlevel%
if %percent%==6 set modul=Downloading 06-80.delta
if %percent%==6 if not %temperrorlev%==0 goto error_patching

if %percent%==9 if not exist "IOSPatcher/libWiiSharp.dll" curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/IOSPatcher/libWiiSharp.dll" --output IOSPatcher/libWiiSharp.dll
if %percent%==9 set /a temperrorlev=%errorlevel%
if %percent%==9 set modul=Downloading libWiiSharp.dll
if %percent%==9 if not %temperrorlev%==0 goto error_patching

if %percent%==12 if not exist "IOSPatcher/Sharpii.exe" curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/IOSPatcher/Sharpii.exe" --output IOSPatcher/Sharpii.exe
if %percent%==12 set /a temperrorlev=%errorlevel%
if %percent%==12 set modul=Downloading Sharpii.exe
if %percent%==12 if not %temperrorlev%==0 goto error_patching

if %percent%==15 if not exist "IOSPatcher/WadInstaller.dll" curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/IOSPatcher/WadInstaller.dll" --output IOSPatcher/WadInstaller.dll
if %percent%==15 set /a temperrorlev=%errorlevel%
if %percent%==15 set modul=Downloading WadInstaller.dll
if %percent%==15 if not %temperrorlev%==0 goto error_patching

if %percent%==17 if not exist "IOSPatcher/xdelta3.exe" curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/IOSPatcher/xdelta3.exe" --output IOSPatcher/xdelta3.exe
if %percent%==17 set /a temperrorlev=%errorlevel%
if %percent%==17 set modul=Downloading xdelta3.exe
if %percent%==17 if not %temperrorlev%==0 goto error_patching


if %percent%==20 if not exist apps md apps

if %percent%==23 if not exist apps/WiiModLite md apps\WiiModLite
if %percent%==23 if not exist apps/WiiXplorer md apps\WiiXplorer
if %percent%==23 if not exist "apps/WiiModLite/boot.dol" curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/apps/WiiModLite/boot.dol" --output apps/WiiModLite/boot.dol
if %percent%==23 set /a temperrorlev=%errorlevel%
if %percent%==23 set modul=Downloading Wii Mod Lite
if %percent%==23 if not %temperrorlev%==0 goto error_patching

if %percent%==25 if not exist "apps/WiiModLite/database.txt" curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/apps/WiiModLite/database.txt" --output apps/WiiModLite/database.txt
if %percent%==25 set /a temperrorlev=%errorlevel%
if %percent%==25 set modul=Downloading Wii Mod Lite
if %percent%==25 if not %temperrorlev%==0 goto error_patching

if %percent%==27 if not exist "apps/WiiModLite/icon.png" curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/apps/WiiModLite/icon.png" --output apps/WiiModLite/icon.png
if %percent%==27 set /a temperrorlev=%errorlevel%
if %percent%==27 set modul=Downloading Wii Mod Lite
if %percent%==27 if not %temperrorlev%==0 goto error_patching

if %percent%==30 if not exist "apps/WiiModLite/icon.png" curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/apps/WiiModLite/icon.png" --output apps/WiiModLite/icon.png
if %percent%==30 set /a temperrorlev=%errorlevel%
if %percent%==30 set modul=Downloading Wii Mod Lite
if %percent%==30 if not %temperrorlev%==0 goto error_patching

if %percent%==32 if not exist "apps/WiiModLite/meta.xml" curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/apps/WiiModLite/meta.xml" --output apps/WiiModLite/meta.xml"
if %percent%==32 set /a temperrorlev=%errorlevel%
if %percent%==32 set modul=Downloading Wii Mod Lite
if %percent%==32 if not %temperrorlev%==0 goto error_patching

if %percent%==34 if not exist "apps/WiiModLite/wiimod.txt" curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/apps/WiiModLite/wiimod.txt" --output apps/WiiModLite/wiimod.txt
if %percent%==34 set /a temperrorlev=%errorlevel%
if %percent%==34 set modul=Downloading Wii Mod Lite
if %percent%==34 if not %temperrorlev%==0 goto error_patching

if %percent%==36 if not exist "apps/WiiXplorer/boot.dol" curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/apps/WiiXplorer/boot.dol" --output apps/WiiXplorer/boot.dol
if %percent%==36 set /a temperrorlev=%errorlevel%
if %percent%==36 set modul=Downloading WiiXplorer
if %percent%==36 if not %temperrorlev%==0 goto error_patching

if %percent%==38 if not exist "apps/WiiXplorer/icon.png" curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/apps/WiiXplorer/icon.png" --output apps/WiiXplorer/icon.png
if %percent%==38 set /a temperrorlev=%errorlevel%
if %percent%==38 set modul=Downloading WiiXplorer
if %percent%==38 if not %temperrorlev%==0 goto error_patching

if %percent%==39 if not exist "apps/WiiXplorer/meta.xml" curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/apps/WiiXplorer/meta.xml" --output apps/WiiXplorer/meta.xml
if %percent%==39 set /a temperrorlev=%errorlevel%
if %percent%==39 set modul=Downloading WiiXplorer
if %percent%==39 if not %temperrorlev%==0 goto error_patching

if %percent%==40 if %uninstall_2_1%==1 if not exist "apps/WiiXplorer/meta.xml" curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/apps/WiiModLite/meta.xml" --output apps/WiiModLite/meta.xml
if %percent%==40 if %uninstall_2_1%==1 set /a temperrorlev=%errorlevel%
if %percent%==40 if %uninstall_2_1%==1 set modul=Downloading WiiXplorer
if %percent%==40 if %uninstall_2_1%==1 if not %temperrorlev%==0 goto error_patching

if %percent%==45 if %uninstall_2_1%==1 if not exist "apps/WiiXplorer/icon.png" curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/apps/WiiModLite/meta.xml" --output apps/WiiModLite/meta.xml
if %percent%==45 if %uninstall_2_1%==1 set /a temperrorlev=%errorlevel%
if %percent%==45 if %uninstall_2_1%==1 set modul=Downloading WiiXplorer
if %percent%==45 if %uninstall_2_1%==1 if not %temperrorlev%==0 goto error_patching

if %percent%==48 if %uninstall_2_1%==1 if not exist "apps/WiiXplorer/boot.dol" curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/apps/WiiModLite/meta.xml" --output apps/WiiModLite/meta.xml
if %percent%==48 if %uninstall_2_1%==1 set /a temperrorlev=%errorlevel%
if %percent%==48 if %uninstall_2_1%==1 set modul=Downloading WiiXplorer
if %percent%==48 if %uninstall_2_1%==1 if not %temperrorlev%==0 goto error_patching


if %percent%==50 md NewsChannelPatcher
if %percent%==50 if not exist "NewsChannelPatcher\libWiiSharp.dll" curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/NewsChannelPatcher/libWiiSharp.dll" --output "NewsChannelPatcher/libWiiSharp.dll">>"%MainFolder%\patching_output.txt"
if %percent%==50 set /a temperrorlev=%errorlevel%
if %percent%==50 set modul=Downloading News Channel files
if %percent%==50 if not %temperrorlev%==0 goto error_patching

if %percent%==53 if not exist "NewsChannelPatcher\Sharpii.exe" curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/NewsChannelPatcher/Sharpii.exe" --output "NewsChannelPatcher/Sharpii.exe">>"%MainFolder%\patching_output.txt"
if %percent%==53 set /a temperrorlev=%errorlevel%
if %percent%==53 set modul=Downloading News Channel files
if %percent%==53 if not %temperrorlev%==0 goto error_patching

if %percent%==57 if not exist "NewsChannelPatcher\WadInstaller.dll" curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/NewsChannelPatcher/WadInstaller.dll" --output "NewsChannelPatcher/WadInstaller.dll">>"%MainFolder%\patching_output.txt"
if %percent%==57 set /a temperrorlev=%errorlevel%
if %percent%==57 set modul=Downloading News Channel files
if %percent%==57 if not %temperrorlev%==0 goto error_patching

if %percent%==62 if not exist "NewsChannelPatcher\xdelta3.exe" curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/NewsChannelPatcher/xdelta3.exe" --output "NewsChannelPatcher/xdelta3.exe">>"%MainFolder%\patching_output.txt"
if %percent%==62 set /a temperrorlev=%errorlevel%
if %percent%==62 set modul=Downloading News Channel files
if %percent%==62 if not %temperrorlev%==0 goto error_patching

if %percent%==64 if "%evcregion%"=="1" call NewsChannelPatcher\sharpii.exe nusd -ID 0001000248414750 -v 7 -wad >>"%MainFolder%\patching_output.txt"
if %percent%==64 if "%evcregion%"=="1" set /a temperrorlev=%errorlevel%
if %percent%==64 if "%evcregion%"=="1" set modul=Downloading News Channel
if %percent%==64 if "%evcregion%"=="1" if not %temperrorlev%==0 goto error_patching
if %percent%==64 if "%evcregion%"=="2" call NewsChannelPatcher\sharpii.exe nusd -ID 0001000248414745 -v 7 -wad >>"%MainFolder%\patching_output.txt"
if %percent%==64 if "%evcregion%"=="2" set /a temperrorlev=%errorlevel%
if %percent%==64 if "%evcregion%"=="2" set modul=Downloading News Channel
if %percent%==64 if "%evcregion%"=="2" if not %temperrorlev%==0 goto error_patching
if %percent%==64 if "%evcregion%"=="3" call NewsChannelPatcher\sharpii.exe nusd -ID 000100024841474A -v 7 -wad >>"%MainFolder%\patching_output.txt"
if %percent%==64 if "%evcregion%"=="3" set /a temperrorlev=%errorlevel%
if %percent%==64 if "%evcregion%"=="3" set modul=Downloading News Channel
if %percent%==64 if "%evcregion%"=="3" if not %temperrorlev%==0 goto error_patching

if %percent%==68 move 0001000248414750v7.wad "WAD\News Channel Wii U (Europe) (Channel) (RiiConnect24).wad"
if %percent%==68 move 0001000248414745v7.wad "WAD\News Channel Wii U (USA) (Channel) (RiiConnect24).wad"
if %percent%==68 move 000100024841474av7.wad "WAD\News Channel Wii U (Japan) (Channel) (RiiConnect24).wad"

if %percent%==73 if %evcregion%==1 call NewsChannelPatcher\sharpii.exe nusd -ID 0001000248414650 -v 7 -wad >>"%MainFolder%\patching_output.txt"
if %percent%==73 if %evcregion%==1 set /a temperrorlev=%errorlevel%
if %percent%==73 if %evcregion%==1 set modul=Downloading Forecast Channel
if %percent%==73 if %evcregion%==1 if not %temperrorlev%==0 goto error_patching
if %percent%==73 if %evcregion%==2 call NewsChannelPatcher\sharpii.exe nusd -ID 0001000248414645 -v 7 -wad >>"%MainFolder%\patching_output.txt"
if %percent%==73 if %evcregion%==2 set /a temperrorlev=%errorlevel%
if %percent%==73 if %evcregion%==2 set modul=Downloading Forecast Channel
if %percent%==73 if %evcregion%==2 if not %temperrorlev%==0 goto error_patching
if %percent%==73 if %evcregion%==3 call NewsChannelPatcher\sharpii.exe nusd -ID 000100024841464A -v 7 -wad >>"%MainFolder%\patching_output.txt"
if %percent%==73 if %evcregion%==3 set /a temperrorlev=%errorlevel%
if %percent%==73 if %evcregion%==3 set modul=Downloading Forecast Channel
if %percent%==73 if %evcregion%==3 if not %temperrorlev%==0 goto error_patching


if %percent%==75 move 0001000248414650v7.wad "WAD\Forecast Channel Wii U (Europe) (Channel) (RiiConnect24).wad"
if %percent%==75 move 0001000248414645v7.wad "WAD\Forecast Channel Wii U (USA) (Channel) (RiiConnect24).wad"
if %percent%==75 move 000100024841464Av7.wad "WAD\Forecast Channel Wii U (Japan) (Channel) (RiiConnect24).wad"


if %percent%==77 if not exist "WAD" md "WAD"
if %percent%==77 call IOSPatcher\Sharpii.exe NUSD -IOS 31 -v latest -o "wad\IOS31 Wii Only (IOS) (Original).wad" -wad >NUL
if %percent%==77 set /a temperrorlev=%errorlevel%
if %percent%==77 set modul=Sharpii.exe
if %percent%==77 if not %temperrorlev%==0 goto error_patching

if %percent%==85 call IOSPatcher\Sharpii.exe NUSD -IOS 80 -v latest -o "wad\IOS80 Wii Only (IOS) (Original).wad" -wad >NUL
if %percent%==85 set /a temperrorlev=%errorlevel%
if %percent%==85 set modul=Sharpii.exe
if %percent%==85 if not %temperrorlev%==0 goto error_patching

if %percent%==95 if not %sdcard%==NUL set /a errorcopying=0
if %percent%==95 if not %sdcard%==NUL if not exist "%sdcard%:\WAD" md "%sdcard%:\WAD"
if %percent%==95 if not %sdcard%==NUL if not exist "%sdcard%:\apps" md "%sdcard%:\apps"

if %percent%==98 if not %sdcard%==NUL xcopy /I /y "WAD" "%sdcard%:\WAD" /e >NUL || set /a errorcopying=1
if %percent%==98 if not %sdcard%==NUL xcopy /I /y "apps" "%sdcard%:\apps" /e >NUL || set /a errorcopying=1

if %percent%==100 rmdir /s /q NewsChannelPatcher
if %percent%==100 rmdir /s /q IOSPatcher
	
if %percent%==100 goto 2_4
goto 2_uninstall_4
:2_uninstall_5
setlocal disableDelayedExpansion
cls
echo %header%
echo -----------------------------------------------------------------------------------------------------------------------------
echo.
echo %string397%
echo.
if %sdcard%==NUL echo - %string398%
if %sdcard%==NUL echo.
echo %string399%
echo 1. %string400%
echo 2. %string401%
echo 3. %string402%
echo 4. %string403%
echo.
echo %string404%
echo 1. %string405% 2. %string302%
set /p s=%string26%: 
if %s%==1 set sound_play=confirm1&call :sound_play&goto 2_uninstall_5_2
if %s%==2 set sound_play=exit1&call :sound_play&goto begin_main
goto 2_uninstall_5
:2_uninstall_5_2
cls
echo %header%
echo -----------------------------------------------------------------------------------------------------------------------------
echo.
echo %string406%
echo.
echo 1. %string407%
echo 2. %string408%
echo    - %string409%
echo 3. %string410%
echo 4. %string411%
echo 5. %string412%
echo 6. %string413%
echo.
echo %string404%
echo 1. %string414% 2. %string405% 3. %string240%
set /p s=%string26%: 
if %s%==1 set sound_play=exit1&call :sound_play&goto 2_uninstall_5
if %s%==2 set sound_play=confirm1&call :sound_play&goto 2_uninstall_5_3
if %s%==3 set sound_play=exit1&call :sound_play&goto begin_main
goto 2_uninstall_5_2
:2_uninstall_5_3
cls
echo %header%
echo -----------------------------------------------------------------------------------------------------------------------------
echo.
echo %string415%
echo.
echo 1. %string416%
echo 2. %string417%
echo 3. %string418%
echo 4. %string419%
echo 5. %string420%
echo 6. %string421%
echo 7. %string422%
echo 8. %string423%
echo 9. %string424%
echo.
echo %string404%
echo 1. %string414% 2. %string405% 3. %sting240%
set /p s=%string26%: 
if %s%==1 set sound_play=exit1&call :sound_play&goto 2_uninstall_5
if %s%==2 set sound_play=confirm1&call :sound_play&goto 2_uninstall_5_4
if %s%==3 set sound_play=exit1&call :sound_play&goto begin_main
goto 2_uninstall_5_3
:2_uninstall_5_4
cls
echo %header%
echo -----------------------------------------------------------------------------------------------------------------------------
echo.
echo %string425%
echo %string426%
echo.
echo %string427%
set /a exitmessage=0
pause>NUL
set sound_play=exit1&call :sound_play
goto end
:2_uninstall_change_drive_letter
cls
echo %header%
echo -----------------------------------------------------------------------------------------------------------------------------
echo [*] SD Card
echo.
echo %string113%: %sdcard%
echo.
echo %string114%
set /p sdcard=
set sound_play=confirm1&call :sound_play
goto 2_uninstall_3_summary
:error_NUS_DOWN
cls
set sound_play=warning3&call :sound_play
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
echo    /---\   %string73%
echo   /     \  %string428%
echo  /   ^!   \ 
echo  --------- %string429%
echo            %string430%
echo.
echo       %string90%
echo ---------------------------------------------------------------------------------------------------------------------------
echo.
echo %string502%
>"%MainFolder%\error_report.txt" echo RiiConnect24 Patcher v%version%
>>"%MainFolder%\error_report.txt" echo.
>>"%MainFolder%\error_report.txt" echo Main Menu
>>"%MainFolder%\error_report.txt" echo.
>>"%MainFolder%\error_report.txt" echo Date: %date%
>>"%MainFolder%\error_report.txt" echo Time: %time:~0,5%
>>"%MainFolder%\error_report.txt" echo.
>>"%MainFolder%\error_report.txt" echo Windows version: %windows_version%
>>"%MainFolder%\error_report.txt" echo Language: %language%
>>"%MainFolder%\error_report.txt" echo.
>>"%MainFolder%\error_report.txt" echo Action: Starting the patcher
>>"%MainFolder%\error_report.txt" echo Module: NUS Check Script. NUS Down.

call :check_rc24_server_connection
if "%errorlevel%"=="1" goto server_connection_lost
curl -s %useragent% --insecure -F "report=@%MainFolder%\error_report.txt" %post_url%?user=%random_identifier%>NUL

echo %string503%

pause>NUL
goto begin_main
:2_prepare_uninstall
cls
echo %header%
echo -----------------------------------------------------------------------------------------------------------------------------
echo.
echo %string116%
echo %string431%

	curl --silent --show-error --fail %CheckNUS.Domain%/ccs/download/0001000248414741/tmd>NUL
	if not "%errorlevel%"=="23" if not "%errorlevel%"=="0" goto error_NUS_DOWN

	curl --silent --show-error --fail %CheckNUS.Domain%/ccs/download/0001000248414745/tmd>NUL
	if not "%errorlevel%"=="23" if not "%errorlevel%"=="0" goto error_NUS_DOWN


	curl --silent --show-error --fail %CheckNUS.Domain%/ccs/download/000100024841474A/tmd>NUL
	if not "%errorlevel%"=="23" if not "%errorlevel%"=="0" goto error_NUS_DOWN


	curl --silent --show-error --fail %CheckNUS.Domain%/ccs/download/0001000248414750/tmd>NUL
	if not "%errorlevel%"=="23" if not "%errorlevel%"=="0" goto error_NUS_DOWN

goto 2_uninstall

:2_prepare
cls
echo %header%
echo -----------------------------------------------------------------------------------------------------------------------------
echo.
echo %string116%
echo %string431%

	curl --silent --show-error --fail %CheckNUS.Domain%/ccs/download/0001000248414741/tmd>NUL
	if not "%errorlevel%"=="23" if not "%errorlevel%"=="0" goto error_NUS_DOWN

	curl --silent --show-error --fail %CheckNUS.Domain%/ccs/download/0001000248414745/tmd>NUL
	if not "%errorlevel%"=="23" if not "%errorlevel%"=="0" goto error_NUS_DOWN


	curl --silent --show-error --fail %CheckNUS.Domain%/ccs/download/000100024841474A/tmd>NUL
	if not "%errorlevel%"=="23" if not "%errorlevel%"=="0" goto error_NUS_DOWN


	curl --silent --show-error --fail %CheckNUS.Domain%/ccs/download/0001000248414750/tmd>NUL
	if not "%errorlevel%"=="23" if not "%errorlevel%"=="0" goto error_NUS_DOWN

:: Checking disk space
set /a patching_size_required_bytes=%patching_size_required_wii_bytes%
set /a patching_size_required_megabytes=%wii_patching_requires%

for /f "usebackq delims== tokens=2" %%x in (`%wmic_path% logicaldisk where "DeviceID='%running_on_drive%:'" get FreeSpace /format:value`) do set free_drive_space_bytes=%%x

if %errorlevel%==0 (
	if /i %free_drive_space_bytes% LSS %patching_size_required_bytes% goto disk_space_insufficient
	)


goto 2_auto_ask

:sd_card_space_insufficient
cls
set sound_play=warning3&call :sound_play
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
echo    /---\   %string73%
echo   /     \  %string580%
echo  /   ^!   \ %string568%
echo  --------- 
echo            %string569% %patching_size_required_megabytes%MB
echo.
echo       %string90%
echo ---------------------------------------------------------------------------------------------------------------------------
pause>NUL
goto begin_main
:disk_space_insufficient
set sound_play=warning3&call :sound_play
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
echo    /---\   %string73%
echo   /     \  %string567%
echo  /   ^!   \ %string568%
echo  --------- 
echo            %string569% %patching_size_required_megabytes%MB
echo.
echo       %string90%
echo ---------------------------------------------------------------------------------------------------------------------------
pause>NUL
goto begin_main

:2_auto_ask
cls
echo %header%
echo -----------------------------------------------------------------------------------------------------------------------------
echo.
echo %string432%
echo.
echo %string201%
echo 1. %string202%
if not "%device%"=="1_dolphin" echo   - %string433%
if "%device%"=="1_dolphin" echo   - %string593%
echo     - %string204%
echo     - %string376%
echo     - %string205%
if not %device%==1_dolphin echo     - %string377%
if %device%==1_dolphin echo     - %string592%
echo     - %string206%
echo     - %string207%
echo.
echo 2. %string208%
echo   - %string209%
set /p s=
if %s%==1 set sound_play=confirm1&call :sound_play&goto 2_auto
if %s%==2 set sound_play=confirm1&call :sound_play&goto 2_choose_custom_instal_type
goto 2_auto_ask


:2_choose_custom_instal_type
set /a evcregion=1
set /a custominstall_ios=1
set /a custominstall_evc=1
set /a custominstall_nc=1
set /a custominstall_cmoc=1
set /a custominstall_news_fore=1

if %device%==1_dolphin (
set /a custominstall_regionselect=1
)



set /a internet_channel_enable=0
set /a photo_channel_enable=0
set /a wii_speak_channel_enable=0
set /a today_and_tomorrow_enable=0

set /a sdcardstatus=0
set /a errorcopying=0
set sdcard=NUL
goto 2_choose_custom_install_type2

:2_choose_custom_install_type2
if "%evcregion%"=="3" set /a custominstall_nc=0

cls
echo %header%
echo -----------------------------------------------------------------------------------------------------------------------------
echo.
echo %string432%
echo.
echo %string201%
echo - %string208%
echo.
if "%info_nothing_selected%"=="1" (
	echo :---------------------------------------------------------------------------------------------------------------------------:
	echo  %string590%
	echo :---------------------------------------------------------------------------------------------------------------------------:
	echo.
set /a info_nothing_selected=0
)

if %evcregion%==1 echo 1. %string211% %string183%
if %evcregion%==2 echo 1. %string211% %string184%
if %evcregion%==3 echo 1. %string211% %string531%
echo.

if "%device%"=="1" (
if "%custominstall_ios%"=="1" echo 2. [X] %string434%
if "%custominstall_ios%"=="0" echo 2. [ ] %string434%
)

if "%device%"=="1_dolphin" (
if "%custominstall_regionselect%"=="1" echo 2. [X] %string592%
if "%custominstall_regionselect%"=="0" echo 2. [ ] %string592%
)

if %custominstall_news_fore%==1 echo 3. [X] %string435%
if %custominstall_news_fore%==0 echo 3. [ ] %string435%
if %custominstall_evc%==1 echo 4. [X] %string205%
if %custominstall_evc%==0 echo 4. [ ] %string205%
if not "%evcregion%"=="3" if %custominstall_nc%==1 echo 5. [X] %string206%
if not "%evcregion%"=="3" if %custominstall_nc%==0 echo 5. [ ] %string206%
if %custominstall_cmoc%==1 echo 6. [X] %string207%
if %custominstall_cmoc%==0 echo 6. [ ] %string207%
echo.
echo - %string540%
echo.
if %internet_channel_enable%==0 echo 7.  [ ] %string560%
if %internet_channel_enable%==1 echo 7.  [X] %string560%
if %photo_channel_enable%==0 echo 8.  [ ] %string557%
if %photo_channel_enable%==1 echo 8.  [X] %string557%
if %wii_speak_channel_enable%==0 echo 9.  [ ] %string558%
if %wii_speak_channel_enable%==1 echo 9.  [X] %string558%
if %today_and_tomorrow_enable%==0 echo 10. [ ] %string559%
if %today_and_tomorrow_enable%==1 echo 10. [X] %string559%
echo.
echo 11. %string212%
echo R. %string213%
set /p s=

	set /a check=0
	if "%custominstall_ios%"=="1" set /a check=%check%+1
	if "%custominstall_news_fore%"=="1" set /a check=%check%+1
	if "%custominstall_evc%"=="1" set /a check=%check%+1
	if "%custominstall_nc%"=="1" set /a check=%check%+1
	if "%custominstall_cmoc%"=="1" set /a check=%check%+1
	if "%internet_channel_enable%"=="1" set /a check=%check%+1
	if "%photo_channel_enable%"=="1" set /a check=%check%+1
	if "%wii_speak_channel_enable%"=="1" set /a check=%check%+1
	if "%today_and_tomorrow_enable%"=="1" set /a check=%check%+1


if "%s%"=="11" (

	if "%check%"=="0" set /a info_nothing_selected=1
	if "%check%"=="0" set sound_play=warning1&call :sound_play
	if "%check%"=="0" goto 2_choose_custom_install_type2
	
	set sound_play=confirm1&call :sound_play&goto 2_2
	)
if "%s%"=="r" set sound_play=exit1&call :sound_play&goto begin_main
if "%s%"=="R" set sound_play=exit1&call :sound_play&goto begin_main

set sound_play=select3&call :sound_play
if "%s%"=="1" goto 2_switch_region
if %device%==1 if "%s%"=="2" goto 2_switch_fore-news-wiimail
if %device%==1_dolphin if "%s%"=="2" goto 2_switch_regionselect
if "%s%"=="3" goto 2_switch_fore_news
if "%s%"=="4" goto 2_switch_evc
if not "%evcregion%"=="3" if "%s%"=="5" goto 2_switch_nc
if "%s%"=="6" goto 2_switch_cmoc
if "%s%"=="7" goto 2_switch_internet_channel
if "%s%"=="8" goto 2_switch_photo_channel
if "%s%"=="9" goto 2_switch_wii_speak_channel
if "%s%"=="10" goto 2_switch_today_and_tomorrow_channel
goto 2_choose_custom_install_type2
:2_switch_internet_channel
if %internet_channel_enable%==1 set /a internet_channel_enable=0&goto 2_choose_custom_install_type2
if %internet_channel_enable%==0 set /a internet_channel_enable=1&goto 2_choose_custom_install_type2

:2_switch_photo_channel
if %photo_channel_enable%==1 set /a photo_channel_enable=0&goto 2_choose_custom_install_type2
if %photo_channel_enable%==0 set /a photo_channel_enable=1&goto 2_choose_custom_install_type2

:2_switch_wii_speak_channel
if %wii_speak_channel_enable%==1 set /a wii_speak_channel_enable=0&goto 2_choose_custom_install_type2
if %wii_speak_channel_enable%==0 set /a wii_speak_channel_enable=1&goto 2_choose_custom_install_type2

:2_switch_today_and_tomorrow_channel
if %today_and_tomorrow_enable%==1 set /a today_and_tomorrow_enable=0&goto 2_choose_custom_install_type2
if %today_and_tomorrow_enable%==0 set /a today_and_tomorrow_enable=1&goto 2_choose_custom_install_type2

:2_switch_fore_news
if %custominstall_news_fore%==1 set /a custominstall_news_fore=0&goto 2_choose_custom_install_type2
if %custominstall_news_fore%==0 set /a custominstall_news_fore=1&goto 2_choose_custom_install_type2
:2_switch_region
if %evcregion%==1 set /a evcregion=2&goto 2_choose_custom_install_type2
if %evcregion%==2 set /a evcregion=3&goto 2_choose_custom_install_type2
if %evcregion%==3 set /a evcregion=1&goto 2_choose_custom_install_type2
:2_switch_fore-news-wiimail
if %custominstall_ios%==1 set /a custominstall_ios=0&goto 2_choose_custom_install_type2
if %custominstall_ios%==0 set /a custominstall_ios=1&goto 2_choose_custom_install_type2
:2_switch_regionselect
if %custominstall_regionselect%==1 set /a custominstall_regionselect=0&goto 2_choose_custom_install_type2
if %custominstall_regionselect%==0 set /a custominstall_regionselect=1&goto 2_choose_custom_install_type2
:2_switch_evc
if %custominstall_evc%==1 set /a custominstall_evc=0&goto 2_choose_custom_install_type2
if %custominstall_evc%==0 set /a custominstall_evc=1&goto 2_choose_custom_install_type2
:2_switch_nc
if %custominstall_nc%==1 set /a custominstall_nc=0&goto 2_choose_custom_install_type2
if %custominstall_nc%==0 set /a custominstall_nc=1&goto 2_choose_custom_install_type2
:2_switch_cmoc
if %custominstall_cmoc%==1 set /a custominstall_cmoc=0&goto 2_choose_custom_install_type2
if %custominstall_cmoc%==0 set /a custominstall_cmoc=1&goto 2_choose_custom_install_type2
	



:2_auto
set /a internet_channel_enable=0
set /a photo_channel_enable=0
set /a wii_speak_channel_enable=0
set /a today_and_tomorrow_enable=0

cls
echo %header%
echo -----------------------------------------------------------------------------------------------------------------------------
echo.
echo %string214% %username%, %string215%
echo.
echo %string216%
echo %string217%
echo.
echo %string218%
echo.
echo %string219% %string204%, %string205%, %string207% %string220% %string206%, %string221% 
echo %string222%
echo.
echo 1. %string183% (E)
echo 2. %string184% (U)
echo 3. %string531% (J)
echo 4. %string537% (K)
echo.
set /p s=%string223%: 
set sound_play=confirm1&call :sound_play
if "%s%"=="e" set /a evcregion=1& goto 2_1_1
if "%s%"=="u" set /a evcregion=2& goto 2_1_1
if "%s%"=="j" set /a evcregion=3& goto 2_1_1
if "%s%"=="k" set /a evcregion=4& goto 2_1_1

if "%s%"=="E" set /a evcregion=1& goto 2_1_1
if "%s%"=="U" set /a evcregion=2& goto 2_1_1
if "%s%"=="J" set /a evcregion=3& goto 2_1_1
if "%s%"=="K" set /a evcregion=4& goto 2_1_1


if "%s%"=="1" set /a evcregion=1& goto 2_1_1
if "%s%"=="2" set /a evcregion=2& goto 2_1_1
if "%s%"=="3" set /a evcregion=3& goto 2_1_1
if "%s%"=="4" set /a evcregion=4& goto 2_1_1

goto 2_auto

:2_1_1
cls
echo %header%
echo -----------------------------------------------------------------------------------------------------------------------------
echo.
echo %string554%
echo.

if "%warning_2_1_1%"=="1" (
echo :----------------------------------------------:
echo  %string608%
echo :----------------------------------------------:
echo.
set /a warning_2_1_1=0
)

echo %string555%.
echo %string556%
echo.
if %photo_channel_enable%==0 echo 1. [ ] %string557%
if %photo_channel_enable%==1 echo 1. [X] %string557%
if %wii_speak_channel_enable%==0 echo 2. [ ] %string558%
if %wii_speak_channel_enable%==1 echo 2. [X] %string558%
if %today_and_tomorrow_enable%==0 echo 3. [ ] %string559%
if %today_and_tomorrow_enable%==1 echo 3. [X] %string559%
if not %evcregion%==4 if %internet_channel_enable%==0 echo 4. [ ] %string560%
if not %evcregion%==4 if %internet_channel_enable%==1 echo 4. [X] %string560%
echo.
echo 5. %string110%
set /p s=%string26%: 
if "%s%"=="5" set sound_play=confirm1&call :sound_play&goto 2_1_2
set sound_play=select3&call :sound_play
if "%s%"=="1" goto 2_1_1_switch_2
if "%s%"=="2" goto 2_1_1_switch_3
if "%s%"=="3" goto 2_1_1_switch_4
if not "%evcregion%"=="4" if "%s%"=="4" goto 2_1_1_switch_1

set /a warning_2_1_1=1
goto 2_1_1
:2_1_1_switch_1
if %internet_channel_enable%==1 set /a internet_channel_enable=0&goto 2_1_1
if %internet_channel_enable%==0 set /a internet_channel_enable=1&goto 2_1_1

:2_1_1_switch_2
if %photo_channel_enable%==1 set /a photo_channel_enable=0&goto 2_1_1
if %photo_channel_enable%==0 set /a photo_channel_enable=1&goto 2_1_1

:2_1_1_switch_3
if %wii_speak_channel_enable%==1 set /a wii_speak_channel_enable=0&goto 2_1_1
if %wii_speak_channel_enable%==0 set /a wii_speak_channel_enable=1&goto 2_1_1

:2_1_1_switch_4
if %today_and_tomorrow_enable%==1 set /a today_and_tomorrow_enable=0&goto 2_1_1
if %today_and_tomorrow_enable%==0 set /a today_and_tomorrow_enable=1&goto 2_1_1

goto 2_1_1



:2_1_2

set /a total_additional=0
set /a total_additional=%internet_channel_enable%+%photo_channel_enable%+%wii_speak_channel_enable%+%today_and_tomorrow_enable%

if not %evcregion%==3 if not %evcregion%==4 (
	set /a custominstall_ios=1
	set /a custominstall_evc=1
	set /a custominstall_nc=1
	set /a custominstall_cmoc=1
	set /a custominstall_news_fore=1
	if %device%==1_dolphin set /a custominstall_regionselect=1
	)
	
if %evcregion%==3 (
	set /a custominstall_ios=1
	set /a custominstall_evc=1
	set /a custominstall_nc=0
	set /a custominstall_cmoc=1
	set /a custominstall_news_fore=1
	if %device%==1_dolphin set /a custominstall_regionselect=1
	)
	
if %evcregion%==4 (
	set /a custominstall_ios=1
	set /a custominstall_evc=0
	set /a custominstall_nc=0
	set /a custominstall_cmoc=0
	set /a custominstall_news_fore=0
	if %device%==1_dolphin set /a custominstall_regionselect=1
	)
	
if %device%==1_dolphin goto 2_1_summary_dolphin


setlocal disableDelayedExpansion
cls
echo %header%
echo -----------------------------------------------------------------------------------------------------------------------------
echo.
echo %string224%
echo %string225% :)
echo.
echo %string226% 
echo %string227%
echo.
if %evcregion%==4 echo :---------------------------------------------------------------------------:
if %evcregion%==4 echo  %string538%
if %evcregion%==4 echo  %string539%
if %evcregion%==4 echo :---------------------------------------------------------------------------:
if %evcregion%==4 echo.

echo %string436%
echo.
echo 1. %string229%
echo 2. %string230%
set /p s=
set sdcard=NUL
if %s%==1 set sound_play=confirm1&call :sound_play&set /a sdcardstatus=1& set tempgotonext=2_1_summary& goto detect_sd_card
if %s%==2 set sound_play=exit1&call :sound_play&set /a sdcardstatus=0& set sdcard=NUL&set /a sdcard_refresh_pending=1& goto 2_1_summary
goto 2_1
:detect_sd_card
setlocal enableDelayedExpansion
set sdcard=NUL
set counter=-1
set letters=ABDEFGHIJKLMNOPQRSTUVWXYZ
set looking_for=
:detect_sd_card_2
set /a check_sdcard_folder=0
set /a counter=%counter%+1
set looking_for=!letters:~%counter%,1!

if exist %looking_for%:/private/wii (
set /a check_sdcard_folder=1
)

if exist %looking_for%:/apps if %check_sdcard_folder%==1 (
set sdcard=%looking_for%
call :%tempgotonext%
exit
exit
)

if %looking_for%==Z (
set sdcard=NUL
setlocal disableDelayedExpansion
call :%tempgotonext%
exit
exit
)
goto detect_sd_card_2
:2_1_summary_dolphin
cls
echo %header%
echo -----------------------------------------------------------------------------------------------------------------------------
echo.
echo %string602%
echo.
echo %string603%
echo %string604%
echo.
echo %string437%
echo.

echo %string109%
echo 1. %string239%  
echo 2. %string240%
echo.
set /p s=%string26%: 
if %s%==1 set sound_play=confirm1&call :sound_play&goto check_for_wad_folder_wii
if %s%==2 set sound_play=exit1&call :sound_play&goto begin_main
goto 2_1_summary_dolphin

:2_1_summary
cls
echo %header%
echo -----------------------------------------------------------------------------------------------------------------------------
echo.
if %sdcardstatus%==0 echo %string231%
if %sdcardstatus%==1 if %sdcard%==NUL echo %string232%
if %sdcardstatus%==1 if %sdcard%==NUL echo %string233%
if %sdcardstatus%==1 if %sdcard%==NUL echo.
if %sdcardstatus%==1 if %sdcard%==NUL echo %string234%
if %sdcardstatus%==1 if not %sdcard%==NUL echo %string235% %sdcard%
if %sdcardstatus%==1 if not %sdcard%==NUL echo %string236%	
echo.
echo %string437%
echo.

echo %string109%
if %sdcardstatus%==0 echo 1. %string239%  2. %string240%
if %sdcardstatus%==1 if %sdcard%==NUL echo 1. %string239% 2. %string240% 3. %string241%
if %sdcardstatus%==1 if not %sdcard%==NUL echo 1. %string239% 2. %string240% 3. %string241%

set /p s=%string26%: 
if %s%==1 set sound_play=confirm1&call :sound_play&goto check_for_wad_folder_wii
if %s%==2 set sound_play=exit1&call :sound_play&goto begin_main
if %s%==3 set sound_play=confirm1&call :sound_play&goto 2_change_drive_letter
goto 2_1_summary
:check_for_wad_folder_wii

:: Checking SD Card space if enabled
set /a patching_size_required_bytes=%patching_size_required_wii_sd_card%
set /a patching_size_required_megabytes=%wii_sd_card_copy_requires%

	if "%sdcardstatus%"=="1" if not "%sdcard%"=="NUL" if exist "%sdcard%:" for /f "usebackq delims== tokens=2" %%x in (`%wmic_path% logicaldisk where "DeviceID='%sdcard%:'" get FreeSpace /format:value`) do set free_sd_card_space_bytes=%%x
	if "%sdcardstatus%"=="1" if not "%sdcard%"=="NUL" if exist "%sdcard%:" if /i %free_sd_card_space_bytes% LSS %patching_size_required_bytes% goto sd_card_space_insufficient

if not exist "WAD" goto 2_2
cls
echo %header%
echo -----------------------------------------------------------------------------------------------------------------------------
echo.
echo %string242%
echo %string243%
echo.
echo %string244%
echo 1. %string245%
echo 2. %string246%
set /p s=%string26%: 
if %s%==1 set sound_play=confirm1&call :sound_play&rmdir /s /q "WAD"
if %s%==1 goto 2_2
if %s%==2 if %device%==1_dolphin set sound_play=exit1&call :sound_play&goto 2_1_summary_dolphin
if %s%==2 set sound_play=exit1&call :sound_play&goto 2_1_summary
goto check_for_wad_folder_wii

:2_change_drive_letter
cls
echo %header%
echo -----------------------------------------------------------------------------------------------------------------------------
echo [*] SD Card
echo.
echo %string113%: %sdcard%
echo.
echo %string114%
set /p sdcard=
goto 2_1_summary
:2_change_drive_letter_wiiu
cls
echo %header%
echo -----------------------------------------------------------------------------------------------------------------------------
echo [*] SD Card
echo.
echo %string113%: %sdcard%
echo.
echo %string114%
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
set /a progress_additional=0
set /a progress_regionselect=0
set /a wiiu_return=0

if %device%==1 set /a custominstall_regionselect=0

if %device%==1_dolphin (
set /a custominstall_ios=0


)




set /a total_additional=0
set /a total_additional=%internet_channel_enable%+%photo_channel_enable%+%wii_speak_channel_enable%+%today_and_tomorrow_enable%


>"%MainFolder%\patching_output.txt" echo Begin saving output.
>>"%MainFolder%\patching_output.txt" echo.

call :check_rc24_server_connection 
if "%errorlevel%"=="1" goto server_connection_lost

goto random_funfact
:random_funfact

set /a funfact_number_before=%funfact_number%

:: Get start time:
for /F "tokens=1-4 delims=:.," %%a in ("%time%") do (
   set /A "start=(((%%a*60)+1%%b %% 100)*60+1%%c %% 100)*100+1%%d %% 100"
)
set /a funfact_number=%random% %% (1 + 30)
if /i %funfact_number% LSS 1 goto random_funfact
if /i %funfact_number% GTR 30 goto random_funfact

if "%funfact_number_before%"=="%funfact_number%" goto random_funfact

if %funfact_number%==1 set funfact=%string438%
if %funfact_number%==2 set funfact=%string439%
if %funfact_number%==3 set funfact=%string440%
if %funfact_number%==4 set funfact=%string441%
if %funfact_number%==5 set funfact=%string442%
if %funfact_number%==6 set funfact=%string443%
if %funfact_number%==7 set funfact=%string444%
if %funfact_number%==8 set funfact=%string445%
if %funfact_number%==9 set funfact=%string446%
if %funfact_number%==10 set funfact=%string447%
if %funfact_number%==11 set funfact=%string448%
if %funfact_number%==12 set funfact=%string449%
if %funfact_number%==13 set funfact=%string450%
if %funfact_number%==14 set funfact=%string451%
if %funfact_number%==15 set funfact=%string452%
if %funfact_number%==16 set funfact=%string453%
if %funfact_number%==17 set funfact=%string454%
if %funfact_number%==18 set funfact=%string455%
if %funfact_number%==19 set funfact=%string456%
if %funfact_number%==20 set funfact=%string457%
if %funfact_number%==21 set funfact=%string458%
if %funfact_number%==22 set funfact=%string459%
if %funfact_number%==23 set funfact=%string460%
if %funfact_number%==24 set funfact=%string461%
if %funfact_number%==25 set funfact=%string462%
if %funfact_number%==26 set funfact=%string463%
if %funfact_number%==27 set funfact=%string464%
if %funfact_number%==28 set funfact=%string465%
if %funfact_number%==29 set funfact=%string466%
if %funfact_number%==30 set funfact=%string467%


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
echo %header%
echo ---------------------------------------------------------------------------------------------------------------------------
echo  [*] %string247%

if %troubleshoot_auto_tool_notification%==1 echo :------------------------------------------------------------------------------------------------------------------------:
if %troubleshoot_auto_tool_notification%==1 echo   %string248%
if %troubleshoot_auto_tool_notification%==1 echo   %string249%
if %troubleshoot_auto_tool_notification%==1 echo :------------------------------------------------------------------------------------------------------------------------:
echo.

set /a refreshing_in=20-"%ss%">>NUL
echo ---------------------------------------------------------------------------------------------------------------------------
echo %string250%: %funfact%
echo ---------------------------------------------------------------------------------------------------------------------------
if /i %refreshing_in% GTR 0 echo %string251%... %refreshing_in% %string252%
if /i %refreshing_in% LEQ 0 echo %string251%... 0 %string252%
echo.
echo    %string253%:
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
if "%progress_downloading%"=="0" echo [ ] %string254%
if "%progress_downloading%"=="1" echo [X] %string254%
if "%custominstall_ios%"=="1" if "%progress_ios%"=="0" echo [ ] %string468%
if "%custominstall_ios%"=="1" if "%progress_ios%"=="1" echo [X] %string468%
if "%custominstall_regionselect%"=="1" if "%progress_regionselect%"=="0" echo [ ] %string592%
if "%custominstall_regionselect%"=="1" if "%progress_regionselect%"=="1" echo [X] %string592%
if "%custominstall_news_fore%"=="1" if "%progress_news_fore%"=="0" echo [ ] %string469%
if "%custominstall_news_fore%"=="1" if "%progress_news_fore%"=="1" echo [X] %string469%
if "%custominstall_evc%"=="1" if "%progress_evc%"=="0" echo [ ] %string205%
if "%custominstall_evc%"=="1" if "%progress_evc%"=="1" echo [X] %string205%
if "%custominstall_cmoc%"=="1" if "%evcregion%"=="1" if %progress_cmoc%==0 echo [ ] %string256%
if "%custominstall_cmoc%"=="1" if "%evcregion%"=="1" if %progress_cmoc%==1 echo [X] %string256%
if "%custominstall_cmoc%"=="1" if "%evcregion%"=="3" if %progress_cmoc%==0 echo [ ] %string256%
if "%custominstall_cmoc%"=="1" if "%evcregion%"=="3" if %progress_cmoc%==1 echo [X] %string256%
if "%custominstall_cmoc%"=="1" if "%evcregion%"=="2" if %progress_cmoc%==0 echo [ ] %string257%
if "%custominstall_cmoc%"=="1" if "%evcregion%"=="2" if %progress_cmoc%==1 echo [X] %string257%
if "%custominstall_nc%"=="1" if %progress_nc%==0 echo [ ] %string206%
if "%custominstall_nc%"=="1" if %progress_nc%==1 echo [X] %string206%
if not "%total_additional%"=="0" if %progress_additional%==0 echo [ ] %string540%
if not "%total_additional%"=="0" if %progress_additional%==1 echo [X] %string540%
if "%progress_finishing%"=="0" echo [ ] %string258%
if "%progress_finishing%"=="1" echo [X] %string258%

>>"%MainFolder%\patching_output.txt" echo [%time:~0,8% / %date%] - %percent%%%
call :patching_fast_travel_%percent%

if %percent%==100 if %device%==1_dolphin goto 2_4_dolphin
if %percent%==100 goto 2_4
::ping localhost -n 1 >NUL

if /i %ss% GEQ 20 goto random_funfact
set /a percent=%percent%+1
goto 2_3



::goto patching_fast_travel_100

::Download files
:patching_fast_travel_1
call :clean_temp_files
	call :check_rc24_server_connection
	if "%errorlevel%"=="1" goto server_connection_lost

if not exist WAD md WAD
if exist NewsChannelPatcher rmdir /s /q NewsChannelPatcher
if not exist NewsChannelPatcher md NewsChannelPatcher
if not exist IOSPatcher md IOSPatcher
if not exist "IOSPatcher/00000006-31.delta" call curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/IOSPatcher/00000006-31.delta" --output IOSPatcher/00000006-31.delta >>"%MainFolder%\patching_output.txt"

set /a temperrorlev=%errorlevel%
set modul=Downloading 06-31.delta
if not %temperrorlev%==0 goto error_patching
echo cURL OK>>"%MainFolder%\patching_output.txt"
if not exist "IOSPatcher/00000006-80.delta" curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/IOSPatcher/00000006-80.delta" --output IOSPatcher/00000006-80.delta>>"%MainFolder%\patching_output.txt"

set /a temperrorlev=%errorlevel%
set modul=Downloading 06-80.delta
if not %temperrorlev%==0 goto error_patching
echo cURL OK>>"%MainFolder%\patching_output.txt"

exit /b 0
:patching_fast_travel_2
if not exist "IOSPatcher/00000006-80.delta" curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/IOSPatcher/00000006-80.delta" --output IOSPatcher/00000006-80.delta>>"%MainFolder%\patching_output.txt"

set /a temperrorlev=%errorlevel%
set modul=Downloading 06-80.delta
if not %temperrorlev%==0 goto error_patching
echo cURL OK>>"%MainFolder%\patching_output.txt"
exit /b 0
:patching_fast_travel_3
if not exist "IOSPatcher/libWiiSharp.dll" curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/IOSPatcher/libWiiSharp.dll" --output IOSPatcher/libWiiSharp.dll>>"%MainFolder%\patching_output.txt"
set /a temperrorlev=%errorlevel%
set modul=Downloading libWiiSharp.dll
if not %temperrorlev%==0 goto error_patching
echo cURL OK>>"%MainFolder%\patching_output.txt"

if not exist "IOSPatcher/Sharpii.exe" curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/IOSPatcher/Sharpii.exe" --output IOSPatcher/Sharpii.exe>>"%MainFolder%\patching_output.txt"
set /a temperrorlev=%errorlevel%
set modul=Downloading Sharpii.exe
if not %temperrorlev%==0 goto error_patching
echo cURL OK>>"%MainFolder%\patching_output.txt"
exit /b 0
:patching_fast_travel_4
if not exist "IOSPatcher/WadInstaller.dll" curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/IOSPatcher/WadInstaller.dll" --output IOSPatcher/WadInstaller.dll>>"%MainFolder%\patching_output.txt"
set /a temperrorlev=%errorlevel%
set modul=Downloading WadInstaller.dll
if not %temperrorlev%==0 goto error_patching
echo cURL OK>>"%MainFolder%\patching_output.txt"

exit /b 0
:patching_fast_travel_5
if not exist "IOSPatcher/xdelta3.exe" curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/IOSPatcher/xdelta3.exe" --output IOSPatcher/xdelta3.exe>>"%MainFolder%\patching_output.txt"
set /a temperrorlev=%errorlevel%
set modul=Downloading xdelta3.exe
if not %temperrorlev%==0 goto error_patching

echo cURL OK>>"%MainFolder%\patching_output.txt"
exit /b 0
::EVC
:patching_fast_travel_6
if not exist EVCPatcher/patch md EVCPatcher\patch
if not exist EVCPatcher/dwn md EVCPatcher\dwn
if not exist EVCPatcher/dwn/0001000148414A45v512 md EVCPatcher\dwn\0001000148414A45v512
if not exist EVCPatcher/dwn/0001000148414A50v512 md EVCPatcher\dwn\0001000148414A50v512
if not exist EVCPatcher/dwn/0001000148414A4Av512 md EVCPatcher\dwn\0001000148414A4Av512
if not exist EVCPatcher/pack md EVCPatcher\pack
if not exist "EVCPatcher/patch/Europe.delta" curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/EVCPatcher/patch/Europe.delta" --output EVCPatcher/patch/Europe.delta>>"%MainFolder%\patching_output.txt"
set /a temperrorlev=%errorlevel%
set modul=Downloading Europe Delta
if not %temperrorlev%==0 goto error_patching
echo cURL OK>>"%MainFolder%\patching_output.txt"

if not exist "EVCPatcher/patch/USA.delta" curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/EVCPatcher/patch/USA.delta" --output EVCPatcher/patch/USA.delta>>"%MainFolder%\patching_output.txt"
set /a temperrorlev=%errorlevel%
set modul=Downloading USA Delta
if not %temperrorlev%==0 goto error_patching
echo cURL OK>>"%MainFolder%\patching_output.txt"


if not exist "EVCPatcher/patch/JPN.delta" curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/EVCPatcher/patch/JPN.delta" --output EVCPatcher/patch/JPN.delta>>"%MainFolder%\patching_output.txt"
set /a temperrorlev=%errorlevel%
set modul=Downloading USA Delta
if not %temperrorlev%==0 goto error_patching
echo cURL OK>>"%MainFolder%\patching_output.txt"

exit /b 0
:patching_fast_travel_7
if not exist "EVCPatcher/NUS_Downloader_Decrypt.exe" curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/EVCPatcher/NUS_Downloader_Decrypt.exe" --output EVCPatcher/NUS_Downloader_Decrypt.exe>>"%MainFolder%\patching_output.txt"
set /a temperrorlev=%errorlevel%
set modul=Downloading decrypter
if not %temperrorlev%==0 goto error_patching

echo cURL OK>>"%MainFolder%\patching_output.txt"
exit /b 0

:patching_fast_travel_8
if not exist "EVCPatcher/patch/xdelta3.exe" curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/EVCPatcher/patch/xdelta3.exe" --output EVCPatcher/patch/xdelta3.exe>>"%MainFolder%\patching_output.txt"
set /a temperrorlev=%errorlevel%
set modul=Downloading xdelta3.exe

if not %temperrorlev%==0 goto error_patching
echo cURL OK>>"%MainFolder%\patching_output.txt"

if not exist "EVCPatcher/pack/libWiiSharp.dll" curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/EVCPatcher/pack/libWiiSharp.dll" --output "EVCPatcher/pack/libWiiSharp.dll">>"%MainFolder%\patching_output.txt"
set /a temperrorlev=%errorlevel%
set modul=Downloading libWiiSharp.dll
if not %temperrorlev%==0 goto error_patching
echo cURL OK>>"%MainFolder%\patching_output.txt"

if not exist "EVCPatcher/pack/Sharpii.exe" curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/EVCPatcher/pack/Sharpii.exe" --output EVCPatcher/pack/Sharpii.exe>>"%MainFolder%\patching_output.txt"
set /a temperrorlev=%errorlevel%
set modul=Downloading Sharpii.exe
if not %temperrorlev%==0 goto error_patching

echo cURL OK>>"%MainFolder%\patching_output.txt"
if not exist "EVCPatcher/dwn/Sharpii.exe" curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/EVCPatcher/dwn/Sharpii.exe" --output EVCPatcher/dwn/Sharpii.exe>>"%MainFolder%\patching_output.txt"
set /a temperrorlev=%errorlevel%
set modul=Downloading Sharpii.exe
if not %temperrorlev%==0 goto error_patching

echo cURL OK>>"%MainFolder%\patching_output.txt"
exit /b 0
:patching_fast_travel_9
if not exist "EVCPatcher/dwn/libWiiSharp.dll" curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/EVCPatcher/dwn/libWiiSharp.dll" --output EVCPatcher/dwn/libWiiSharp.dll>>"%MainFolder%\patching_output.txt"
set /a temperrorlev=%errorlevel%
set modul=Downloading libWiiSharp.dll
if not %temperrorlev%==0 goto error_patching

echo cURL OK>>"%MainFolder%\patching_output.txt"
exit /b 0
:patching_fast_travel_10
if not exist "EVCPatcher/dwn/0001000148414A45v512/cetk" curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/EVCPatcher/dwn/0001000148414A45v512/cetk" --output EVCPatcher/dwn/0001000148414A45v512/cetk>>"%MainFolder%\patching_output.txt"
set /a temperrorlev=%errorlevel%
set modul=Downloading USA CETK
if not %temperrorlev%==0 goto error_patching
echo cURL OK>>"%MainFolder%\patching_output.txt"

if not exist "EVCPatcher/dwn/0001000148414A50v512/cetk" curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/EVCPatcher/dwn/0001000148414A50v512/cetk" --output EVCPatcher/dwn/0001000148414A50v512/cetk>>"%MainFolder%\patching_output.txt"
set /a temperrorlev=%errorlevel%
set modul=Downloading EUR CETK
if not %temperrorlev%==0 goto error_patching
echo cURL OK>>"%MainFolder%\patching_output.txt"

if not exist "EVCPatcher/dwn/0001000148414A4Av512/cetk" curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/EVCPatcher/dwn/0001000148414A4Av512/cetk" --output EVCPatcher/dwn/0001000148414A4Av512/cetk>>"%MainFolder%\patching_output.txt"
set /a temperrorlev=%errorlevel%
set modul=Downloading JPN CETK
if not %temperrorlev%==0 goto error_patching
echo cURL OK>>"%MainFolder%\patching_output.txt"

exit /b 0

::CMOC
:patching_fast_travel_11
if not exist CMOCPatcher/patch md CMOCPatcher\patch
if not exist CMOCPatcher/dwn md CMOCPatcher\dwn
if not exist CMOCPatcher/dwn/0001000148415045v512 md CMOCPatcher\dwn\0001000148415045v512
if not exist CMOCPatcher/dwn/0001000148415050v512 md CMOCPatcher\dwn\0001000148415050v512
if not exist CMOCPatcher/dwn/000100014841504Av512 md CMOCPatcher\dwn\000100014841504Av512

if not exist CMOCPatcher/pack md CMOCPatcher\pack
if not exist "CMOCPatcher/patch/00000001_Europe.delta" curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/CMOCPatcher/patch/00000001_Europe.delta" --output CMOCPatcher/patch/00000001_Europe.delta>>"%MainFolder%\patching_output.txt"
if not exist "CMOCPatcher/patch/00000004_Europe.delta" curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/CMOCPatcher/patch/00000004_Europe.delta" --output CMOCPatcher/patch/00000004_Europe.delta>>"%MainFolder%\patching_output.txt"
set /a temperrorlev=%errorlevel%
set modul=Downloading Europe Delta
if not %temperrorlev%==0 goto error_patching
echo cURL OK>>"%MainFolder%\patching_output.txt"

exit /b 0
:patching_fast_travel_12
if not exist "CMOCPatcher/patch/00000001_USA.delta" curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/CMOCPatcher/patch/00000001_USA.delta" --output CMOCPatcher/patch/00000001_USA.delta>>"%MainFolder%\patching_output.txt"
if not exist "CMOCPatcher/patch/00000004_USA.delta" curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/CMOCPatcher/patch/00000004_USA.delta" --output CMOCPatcher/patch/00000004_USA.delta>>"%MainFolder%\patching_output.txt"
set /a temperrorlev=%errorlevel%
set modul=Downloading USA Delta
if not %temperrorlev%==0 goto error_patching
echo cURL OK>>"%MainFolder%\patching_output.txt"

if not exist "CMOCPatcher/patch/00000001_Japan.delta" curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/CMOCPatcher/patch/00000001_Japan.delta" --output CMOCPatcher/patch/00000001_Japan.delta>>"%MainFolder%\patching_output.txt"
if not exist "CMOCPatcher/patch/00000004_Japan.delta" curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/CMOCPatcher/patch/00000004_Japan.delta" --output CMOCPatcher/patch/00000004_Japan.delta>>"%MainFolder%\patching_output.txt"
set /a temperrorlev=%errorlevel%
set modul=Downloading Japan Delta
if not %temperrorlev%==0 goto error_patching
echo cURL OK>>"%MainFolder%\patching_output.txt"


if not exist "CMOCPatcher/NUS_Downloader_Decrypt.exe" curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/CMOCPatcher/NUS_Downloader_Decrypt.exe" --output CMOCPatcher/NUS_Downloader_Decrypt.exe>>"%MainFolder%\patching_output.txt"
set /a temperrorlev=%errorlevel%
set modul=Downloading decrypter
if not %temperrorlev%==0 goto error_patching

echo cURL OK>>"%MainFolder%\patching_output.txt"
exit /b 0
:patching_fast_travel_13
if not exist "CMOCPatcher/patch/xdelta3.exe" curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/CMOCPatcher/patch/xdelta3.exe" --output CMOCPatcher/patch/xdelta3.exe>>"%MainFolder%\patching_output.txt"
set /a temperrorlev=%errorlevel%
set modul=Downloading xdelta3.exe
if not %temperrorlev%==0 goto error_patching
echo cURL OK>>"%MainFolder%\patching_output.txt"

if not exist "CMOCPatcher/pack/libWiiSharp.dll" curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/CMOCPatcher/pack/libWiiSharp.dll" --output "CMOCPatcher/pack/libWiiSharp.dll">>"%MainFolder%\patching_output.txt"
set /a temperrorlev=%errorlevel%
set modul=Downloading libWiiSharp.dll
if not %temperrorlev%==0 goto error_patching
echo cURL OK>>"%MainFolder%\patching_output.txt"

if not exist "CMOCPatcher/pack/Sharpii.exe" curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/CMOCPatcher/pack/Sharpii.exe" --output CMOCPatcher/pack/Sharpii.exe>>"%MainFolder%\patching_output.txt"
set /a temperrorlev=%errorlevel%
set modul=Downloading Sharpii.exe
if not %temperrorlev%==0 goto error_patching
echo cURL OK>>"%MainFolder%\patching_output.txt"

if not exist "CMOCPatcher/dwn/Sharpii.exe" curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/CMOCPatcher/dwn/Sharpii.exe" --output CMOCPatcher/dwn/Sharpii.exe>>"%MainFolder%\patching_output.txt"
set /a temperrorlev=%errorlevel%
set modul=Downloading Sharpii.exe
if not %temperrorlev%==0 goto error_patching
echo cURL OK>>"%MainFolder%\patching_output.txt"
if not exist "CMOCPatcher/dwn/libWiiSharp.dll" curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/CMOCPatcher/dwn/libWiiSharp.dll" --output CMOCPatcher/dwn/libWiiSharp.dll>>"%MainFolder%\patching_output.txt"
set /a temperrorlev=%errorlevel%
set modul=Downloading libWiiSharp.dll
if not %temperrorlev%==0 goto error_patching
echo cURL OK>>"%MainFolder%\patching_output.txt"
exit /b 0

:patching_fast_travel_14
if not exist NewsChannelPatcher md NewsChannelPatcher

if not exist "NewsChannelPatcher/00000001_Forecast_Europe.delta" curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/NewsChannelPatcher/URL_Patches/Europe/00000001_Forecast.delta" --output "NewsChannelPatcher/00000001_Forecast_Europe.delta">>"%MainFolder%\patching_output.txt"
set /a temperrorlev=%errorlevel%
set modul=Downloading Forecast Channel files
echo cURL OK>>"%MainFolder%\patching_output.txt"
if not exist "NewsChannelPatcher/00000001_Forecast_USA.delta" curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/NewsChannelPatcher/URL_Patches/USA/00000001_Forecast.delta" --output "NewsChannelPatcher/00000001_Forecast_USA.delta">>"%MainFolder%\patching_output.txt"
set /a temperrorlev=%errorlevel%
set modul=Downloading Forecast Channel files
echo cURL OK>>"%MainFolder%\patching_output.txt"
if not exist "NewsChannelPatcher/00000001_News_Europe.delta" curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/NewsChannelPatcher/URL_Patches/Europe/00000001_News.delta" --output "NewsChannelPatcher/00000001_News_Europe.delta">>"%MainFolder%\patching_output.txt"
set /a temperrorlev=%errorlevel%
set modul=Downloading News Channel files
echo cURL OK>>"%MainFolder%\patching_output.txt"
if not exist "NewsChannelPatcher/00000001_News_USA.delta" curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/NewsChannelPatcher/URL_Patches/USA/00000001_News.delta" --output "NewsChannelPatcher/00000001_News_USA.delta">>"%MainFolder%\patching_output.txt"
set /a temperrorlev=%errorlevel%
set modul=Downloading News Channel files
if not %temperrorlev%==0 goto error_patching
echo cURL OK>>"%MainFolder%\patching_output.txt"

if not exist "NewsChannelPatcher/00000001_Forecast_Japan.delta" curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/NewsChannelPatcher/URL_Patches/Japan/00000001_Forecast.delta" --output "NewsChannelPatcher/00000001_Forecast_Japan.delta">>"%MainFolder%\patching_output.txt"
set /a temperrorlev=%errorlevel%
set modul=Downloading Forecast Channel files
echo cURL OK>>"%MainFolder%\patching_output.txt"
if not exist "NewsChannelPatcher/00000001_News_Japan.delta" curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/NewsChannelPatcher/URL_Patches/Japan/00000001_News.delta" --output "NewsChannelPatcher/00000001_News_Japan.delta">>"%MainFolder%\patching_output.txt"
set /a temperrorlev=%errorlevel%
set modul=Downloading News Channel files
if not %temperrorlev%==0 goto error_patching
echo cURL OK>>"%MainFolder%\patching_output.txt"


exit /b 0

:patching_fast_travel_15
if not exist "NewsChannelPatcher\libWiiSharp.dll" curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/NewsChannelPatcher/libWiiSharp.dll" --output "NewsChannelPatcher/libWiiSharp.dll">>"%MainFolder%\patching_output.txt"
set /a temperrorlev=%errorlevel%
set modul=Downloading News Channel files
if not %temperrorlev%==0 goto error_patching
echo cURL OK>>"%MainFolder%\patching_output.txt"

exit /b 0

:patching_fast_travel_16
if not exist "NewsChannelPatcher\Sharpii.exe" curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/NewsChannelPatcher/Sharpii.exe" --output "NewsChannelPatcher/Sharpii.exe">>"%MainFolder%\patching_output.txt"
set /a temperrorlev=%errorlevel%
set modul=Downloading News Channel files
if not %temperrorlev%==0 goto error_patching
echo cURL OK>>"%MainFolder%\patching_output.txt"
exit /b 0

:patching_fast_travel_17
if not exist "NewsChannelPatcher\WadInstaller.dll" curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/NewsChannelPatcher/WadInstaller.dll" --output "NewsChannelPatcher/WadInstaller.dll">>"%MainFolder%\patching_output.txt"
set /a temperrorlev=%errorlevel%
set modul=Downloading News Channel files
if not %temperrorlev%==0 goto error_patching
echo cURL OK>>"%MainFolder%\patching_output.txt"
if not exist "NewsChannelPatcher\xdelta3.exe" curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/NewsChannelPatcher/xdelta3.exe" --output "NewsChannelPatcher/xdelta3.exe">>"%MainFolder%\patching_output.txt"
set /a temperrorlev=%errorlevel%
set modul=Downloading News Channel files
if not %temperrorlev%==0 goto error_patching
echo cURL OK>>"%MainFolder%\patching_output.txt"
exit /b 0

:patching_fast_travel_18
if not exist "CMOCPatcher/dwn/0001000148415045v512/cetk" curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/CMOCPatcher/dwn/0001000148415045v512/cetk" --output CMOCPatcher/dwn/0001000148415045v512/cetk>>"%MainFolder%\patching_output.txt"
if not exist "CMOCPatcher/dwn/0001000148415045v512/cert" curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/CMOCPatcher/dwn/0001000148415045v512/cert" --output CMOCPatcher/dwn/0001000148415045v512/cert>>"%MainFolder%\patching_output.txt"
set /a temperrorlev=%errorlevel%
set modul=Downloading USA CETK
if not %temperrorlev%==0 goto error_patching
echo cURL OK>>"%MainFolder%\patching_output.txt"
exit /b 0
:patching_fast_travel_19
if not exist "CMOCPatcher/dwn/0001000148415050v512/cetk" curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/CMOCPatcher/dwn/0001000148415050v512/cetk" --output CMOCPatcher/dwn/0001000148415050v512/cetk>>"%MainFolder%\patching_output.txt"
if not exist "CMOCPatcher/dwn/0001000148415050v512/cert" curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/CMOCPatcher/dwn/0001000148415050v512/cert" --output CMOCPatcher/dwn/0001000148415050v512/cert>>"%MainFolder%\patching_output.txt"
set /a temperrorlev=%errorlevel%
set modul=Downloading EUR CETK
if not %temperrorlev%==0 goto error_patching
echo cURL OK>>"%MainFolder%\patching_output.txt"

if not exist "CMOCPatcher/dwn/000100014841504Av512/cetk" curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/CMOCPatcher/dwn/000100014841504Av512/cetk" --output CMOCPatcher/dwn/000100014841504Av512/cetk>>"%MainFolder%\patching_output.txt"
if not exist "CMOCPatcher/dwn/000100014841504Av512/cert" curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/CMOCPatcher/dwn/000100014841504Av512/cert" --output CMOCPatcher/dwn/000100014841504Av512/cert>>"%MainFolder%\patching_output.txt"
set /a temperrorlev=%errorlevel%
set modul=Downloading JPN CETK
if not %temperrorlev%==0 goto error_patching
echo cURL OK>>"%MainFolder%\patching_output.txt"


exit /b 0


::NC
:patching_fast_travel_20
if not exist NCPatcher/patch md NCPatcher\patch
if not exist NCPatcher/dwn md NCPatcher\dwn
if not exist NCPatcher/dwn/0001000148415450v1792 md NCPatcher\dwn\0001000148415450v1792
if not exist NCPatcher/dwn/0001000148415445v1792 md NCPatcher\dwn\0001000148415445v1792
if not exist NCPatcher/dwn/000100014841544Av1792 md NCPatcher\dwn\000100014841544Av1792
if not exist NCPatcher/pack md NCPatcher\pack
if not exist "NCPatcher/patch/Europe.delta" curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/NCPatcher/patch/Europe.delta" --output NCPatcher/patch/Europe.delta>>"%MainFolder%\patching_output.txt"
set /a temperrorlev=%errorlevel%
set modul=Downloading Europe Delta [NC]
if not %temperrorlev%==0 goto error_patching
echo cURL OK>>"%MainFolder%\patching_output.txt"

if not exist "NCPatcher/patch/USA.delta" curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/NCPatcher/patch/USA.delta" --output NCPatcher/patch/USA.delta>>"%MainFolder%\patching_output.txt"
set /a temperrorlev=%errorlevel%
set modul=Downloading USA Delta [NC]
if not %temperrorlev%==0 goto error_patching
echo cURL OK>>"%MainFolder%\patching_output.txt"


if not exist "NCPatcher/patch/JPN.delta" curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/NCPatcher/patch/JPN.delta" --output NCPatcher/patch/JPN.delta>>"%MainFolder%\patching_output.txt"
set /a temperrorlev=%errorlevel%
set modul=Downloading JPN Delta [NC]
if not %temperrorlev%==0 goto error_patching
echo cURL OK>>"%MainFolder%\patching_output.txt"



if not exist "NCPatcher/NUS_Downloader_Decrypt.exe" curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/NCPatcher/NUS_Downloader_Decrypt.exe" --output NCPatcher/NUS_Downloader_Decrypt.exe>>"%MainFolder%\patching_output.txt"
set /a temperrorlev=%errorlevel%
set modul=Downloading Decrypter
if not %temperrorlev%==0 goto error_patching
echo cURL OK>>"%MainFolder%\patching_output.txt"

exit /b 0
:patching_fast_travel_21
if not exist "NCPatcher/patch/xdelta3.exe" curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/NCPatcher/patch/xdelta3.exe" --output NCPatcher/patch/xdelta3.exe>>"%MainFolder%\patching_output.txt"
set /a temperrorlev=%errorlevel%
set modul=Downloading xdelta3.exe
if not %temperrorlev%==0 goto error_patching
echo cURL OK>>"%MainFolder%\patching_output.txt"

if not exist "NCPatcher/pack/libWiiSharp.dll" curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/NCPatcher/pack/libWiiSharp.dll" --output NCPatcher/pack/libWiiSharp.dll>>"%MainFolder%\patching_output.txt"
set /a temperrorlev=%errorlevel%
set modul=Downloading libWiiSharp.dll
if not %temperrorlev%==0 goto error_patching
echo cURL OK>>"%MainFolder%\patching_output.txt"

if not exist "NCPatcher/pack/Sharpii.exe" curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/NCPatcher/pack/Sharpii.exe" --output NCPatcher/pack/Sharpii.exe>>"%MainFolder%\patching_output.txt"
set /a temperrorlev=%errorlevel%
set modul=Downloading Sharpii.exe
if not %temperrorlev%==0 goto error_patching
echo cURL OK>>"%MainFolder%\patching_output.txt"

exit /b 0
:patching_fast_travel_22
if not exist "NCPatcher/dwn/Sharpii.exe" curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/NCPatcher/dwn/Sharpii.exe" --output NCPatcher/dwn/Sharpii.exe>>"%MainFolder%\patching_output.txt"
set /a temperrorlev=%errorlevel%
set modul=Downloading Sharpii.exe
if not %temperrorlev%==0 goto error_patching
echo cURL OK>>"%MainFolder%\patching_output.txt"

exit /b 0
:patching_fast_travel_23
if not exist "NCPatcher/dwn/libWiiSharp.dll" curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/NCPatcher/dwn/libWiiSharp.dll" --output NCPatcher/dwn/libWiiSharp.dll>>"%MainFolder%\patching_output.txt"
set /a temperrorlev=%errorlevel%
set modul=Downloading libWiiSharp.dll
if not %temperrorlev%==0 goto error_patching
echo cURL OK>>"%MainFolder%\patching_output.txt"

exit /b 0
:patching_fast_travel_24
if not exist "NCPatcher/dwn/0001000148415445v1792/cetk" curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/NCPatcher/dwn/0001000148415445v1792/cetk" --output NCPatcher/dwn/0001000148415445v1792/cetk>>"%MainFolder%\patching_output.txt"
set /a temperrorlev=%errorlevel%
set modul=Downloading USA CETK
if not %temperrorlev%==0 goto error_patching
echo cURL OK>>"%MainFolder%\patching_output.txt"

if not exist "NCPatcher/dwn/0001000148415450v1792/cetk" curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/NCPatcher/dwn/0001000148415450v1792/cetk" --output NCPatcher/dwn/0001000148415450v1792/cetk>>"%MainFolder%\patching_output.txt"
set /a temperrorlev=%errorlevel%
set modul=Downloading EUR CETK
if not %temperrorlev%==0 goto error_patching
echo cURL OK>>"%MainFolder%\patching_output.txt"


if not exist "NCPatcher/dwn/000100014841544Av1792/cetk" curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/NCPatcher/dwn/000100014841544Av1792/cetk" --output NCPatcher/dwn/000100014841544Av1792/cetk>>"%MainFolder%\patching_output.txt"
set /a temperrorlev=%errorlevel%
set modul=Downloading JPN CETK
if not %temperrorlev%==0 goto error_patching
echo cURL OK>>"%MainFolder%\patching_output.txt"


exit /b 0

::Everything else
:patching_fast_travel_25
if %device%==1_dolphin exit /b 0

if not exist apps md apps
if not exist apps/Mail-Patcher md apps\Mail-Patcher
if not exist "apps/Mail-Patcher/boot.dol" curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/apps/Mail-Patcher/boot.dol" --output apps/Mail-Patcher/boot.dol>>"%MainFolder%\patching_output.txt"
set /a temperrorlev=%errorlevel%
set modul=Downloading Mail Patcher
if not %temperrorlev%==0 goto error_patching
echo cURL OK>>"%MainFolder%\patching_output.txt"


if not exist "apps/Mail-Patcher/icon.png" curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/apps/Mail-Patcher/icon.png" --output apps/Mail-Patcher/icon.png>>"%MainFolder%\patching_output.txt"
set /a temperrorlev=%errorlevel%
set modul=Downloading Mail Patcher
if not %temperrorlev%==0 goto error_patching
echo cURL OK>>"%MainFolder%\patching_output.txt"


if not exist "apps/Mail-Patcher/meta.xml" curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/apps/Mail-Patcher/meta.xml" --output apps/Mail-Patcher/meta.xml>>"%MainFolder%\patching_output.txt"
set /a temperrorlev=%errorlevel%
set modul=Downloading Mail Patcher
if not %temperrorlev%==0 goto error_patching
echo cURL OK>>"%MainFolder%\patching_output.txt"
exit /b 0


:patching_fast_travel_26
if %device%==1_dolphin exit /b 0

if not exist apps/WiiModLite md apps\WiiModLite
if not exist apps/Mail-Patcher md apps\Mail-Patcher
if not exist "apps/WiiModLite/boot.dol" curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/apps/WiiModLite/boot.dol" --output apps/WiiModLite/boot.dol>>"%MainFolder%\patching_output.txt"
set /a temperrorlev=%errorlevel%
set modul=Downloading Wii Mod Lite
if not %temperrorlev%==0 goto error_patching
echo cURL OK>>"%MainFolder%\patching_output.txt"

if not exist "apps/WiiModLite/database.txt" curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/apps/WiiModLite/database.txt" --output apps/WiiModLite/database.txt>>"%MainFolder%\patching_output.txt"
set /a temperrorlev=%errorlevel%
set modul=Downloading Wii Mod Lite
if not %temperrorlev%==0 goto error_patching
echo cURL OK>>"%MainFolder%\patching_output.txt"

exit /b 0
:patching_fast_travel_27
if %device%==1_dolphin exit /b 0

if not exist "apps/WiiModLite/icon.png" curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/apps/WiiModLite/icon.png" --output apps/WiiModLite/icon.png>>"%MainFolder%\patching_output.txt"
set /a temperrorlev=%errorlevel%
set modul=Downloading Wii Mod Lite
if not %temperrorlev%==0 goto error_patching
echo cURL OK>>"%MainFolder%\patching_output.txt"

if not exist "apps/WiiModLite/icon.png" curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/apps/WiiModLite/icon.png" --output apps/WiiModLite/icon.png>>"%MainFolder%\patching_output.txt"
set /a temperrorlev=%errorlevel%
set modul=Downloading Wii Mod Lite
if not %temperrorlev%==0 goto error_patching
echo cURL OK>>"%MainFolder%\patching_output.txt"

exit /b 0

:patching_fast_travel_28
if %device%==1_dolphin exit /b 0

if not exist "apps/WiiModLite/meta.xml" curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/apps/WiiModLite/meta.xml" --output apps/WiiModLite/meta.xml>>"%MainFolder%\patching_output.txt"
set /a temperrorlev=%errorlevel%
set modul=Downloading Wii Mod Lite
if not %temperrorlev%==0 goto error_patching
echo cURL OK>>"%MainFolder%\patching_output.txt"

if not exist "apps/WiiModLite/wiimod.txt" curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/apps/WiiModLite/wiimod.txt" --output apps/WiiModLite/wiimod.txt>>"%MainFolder%\patching_output.txt"
set /a temperrorlev=%errorlevel%
set modul=Downloading Wii Mod Lite
if not %temperrorlev%==0 goto error_patching
echo cURL OK>>"%MainFolder%\patching_output.txt"

exit /b 0
:patching_fast_travel_29
if not exist "EVCPatcher/patch/Europe.delta" curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%EVCPatcher/patch/Europe.delta" --output EVCPatcher/patch/Europe.delta>>"%MainFolder%\patching_output.txt"
set /a temperrorlev=%errorlevel%
set modul=Downloading Europe Delta
if not %temperrorlev%==0 goto error_patching
echo cURL OK>>"%MainFolder%\patching_output.txt"

exit /b 0
:patching_fast_travel_30
if not exist "EVCPatcher/patch/USA.delta" curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/EVCPatcher/patch/USA.delta" --output EVCPatcher/patch/USA.delta>>"%MainFolder%\patching_output.txt"
set /a temperrorlev=%errorlevel%
set modul=Downloading Wii Mod Lite
if not %temperrorlev%==0 goto error_patching
echo cURL OK>>"%MainFolder%\patching_output.txt"

if not exist "EVCPatcher/patch/USA.delta" curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/EVCPatcher/patch/USA.delta" --output EVCPatcher/patch/USA.delta>>"%MainFolder%\patching_output.txt"
set /a temperrorlev=%errorlevel%
set modul=Downloading Wii Mod Lite
if not %temperrorlev%==0 goto error_patching
echo cURL OK>>"%MainFolder%\patching_output.txt"

if not exist "cert.sys" curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/cert.sys" --output cert.sys>>"%MainFolder%\patching_output.txt"
set /a temperrorlev=%errorlevel%
set /a progress_downloading=1
set modul=Downloading cert.sys
if not %temperrorlev%==0 goto error_patching
echo cURL OK>>"%MainFolder%\patching_output.txt"

exit /b 0

::IOS Patcher
:patching_fast_travel_31
	call :check_rc24_server_connection
	if "%errorlevel%"=="1" goto server_connection_lost

if %custominstall_ios%==1 call IOSPatcher\Sharpii.exe NUSD -IOS 31 -v latest -o IOSPatcher\IOS31-old.wad -wad>>"%MainFolder%\patching_output.txt"
if %custominstall_ios%==1 set /a temperrorlev=%errorlevel%
if %custominstall_ios%==1 set modul=Sharpii.exe
if %custominstall_ios%==1 if not %temperrorlev%==0 goto error_patching
if %custominstall_ios%==1 call IOSPatcher\Sharpii.exe NUSD -IOS 80 -v latest -o IOSPatcher\IOS80-old.wad -wad>>"%MainFolder%\patching_output.txt"
if %custominstall_ios%==1 set /a temperrorlev=%errorlevel%
if %custominstall_ios%==1 set modul=Sharpii.exe
if %custominstall_ios%==1 if not %temperrorlev%==0 goto error_patching
if %custominstall_ios%==1 call IOSPatcher\Sharpii.exe WAD -u IOSPatcher\IOS31-old.wad IOSPatcher/IOS31/ >>"%MainFolder%\patching_output.txt"
if %custominstall_ios%==1 set /a temperrorlev=%errorlevel%
if %custominstall_ios%==1 set modul=Sharpii.exe
if %custominstall_ios%==1 if not %temperrorlev%==0 goto error_patching
if %custominstall_ios%==1 call IOSPatcher\Sharpii.exe WAD -u IOSPatcher\IOS80-old.wad IOSPatcher\IOS80/ >>"%MainFolder%\patching_output.txt"
if %custominstall_ios%==1 set /a temperrorlev=%errorlevel%
if %custominstall_ios%==1 set modul=Sharpii.exe
if %custominstall_ios%==1 if not %temperrorlev%==0 goto error_patching
if %custominstall_ios%==1 move /y IOSPatcher\IOS31\00000006.app IOSPatcher\00000006.app >>"%MainFolder%\patching_output.txt"
if %custominstall_ios%==1 set /a temperrorlev=%errorlevel%
if %custominstall_ios%==1 set modul=move.exe
if %custominstall_ios%==1 if not %temperrorlev%==0 goto error_patching



if %custominstall_regionselect%==1 if %evcregion%==1 (
	call IOSPatcher\Sharpii.exe nusd -ID 0001000848414C50 -v 2 -wad -o "WAD\Region Select (Europe) (System) (RiiConnect24).wad" >>"%MainFolder%\patching_output.txt"
	set /a temperrorlev=%errorlevel%
	set modul=Sharpii.exe
	if not %temperrorlev%==0 goto error_patching
)

if %custominstall_regionselect%==1 if %evcregion%==2 (
	call IOSPatcher\Sharpii.exe nusd -ID 0001000848414C45 -v 2 -wad -o "WAD\Region Select (USA) (System) (RiiConnect24).wad" >>"%MainFolder%\patching_output.txt"
	set /a temperrorlev=%errorlevel%
	set modul=Sharpii.exe
	if not %temperrorlev%==0 goto error_patching
)

if %custominstall_regionselect%==1 if %evcregion%==3 (
	call IOSPatcher\Sharpii.exe nusd -ID 0001000848414C4A -v 2 -wad -o "WAD\Region Select (Japan) (System) (RiiConnect24).wad" >>"%MainFolder%\patching_output.txt"
	set /a temperrorlev=%errorlevel%
	set modul=Sharpii.exe
	if not %temperrorlev%==0 goto error_patching
)

if %custominstall_regionselect%==1 if %evcregion%==4 (
	call IOSPatcher\Sharpii.exe nusd -ID 0001000848414C4B -v 2 -wad -o "WAD\Region Select (Korea) (System) (RiiConnect24).wad" >>"%MainFolder%\patching_output.txt"
	set /a temperrorlev=%errorlevel%
	set modul=Sharpii.exe
	if not %temperrorlev%==0 goto error_patching
)

if %custominstall_regionselect%==1 set /a progress_regionselect=1

exit /b 0
:patching_fast_travel_32
if %custominstall_ios%==1 call IOSPatcher\xdelta3.exe -f -d -s IOSPatcher\00000006.app IOSPatcher\00000006-31.delta IOSPatcher\IOS31\00000006.app >>"%MainFolder%\patching_output.txt"
if %custominstall_ios%==1 set /a temperrorlev=%errorlevel%
if %custominstall_ios%==1 set modul=xdelta.exe
if %custominstall_ios%==1 if not %temperrorlev%==0 goto error_patching
exit /b 0
:patching_fast_travel_33
if %custominstall_ios%==1 move /y IOSPatcher\IOS80\00000006.app IOSPatcher\00000006.app >>"%MainFolder%\patching_output.txt"
if %custominstall_ios%==1 set /a temperrorlev=%errorlevel%
if %custominstall_ios%==1 set modul=move.exe
if %custominstall_ios%==1 if not %temperrorlev%==0 goto error_patching
if %custominstall_ios%==1 call IOSPatcher\xdelta3.exe -f -d -s IOSPatcher\00000006.app IOSPatcher\00000006-80.delta IOSPatcher\IOS80\00000006.app >>"%MainFolder%\patching_output.txt"
if %custominstall_ios%==1 set /a temperrorlev=%errorlevel%
if %custominstall_ios%==1 set modul=xdelta3.exe
if %custominstall_ios%==1 if not %temperrorlev%==0 goto error_patching
if %custominstall_ios%==1 if not exist IOSPatcher\WAD mkdir IOSPatcher\WAD
if %custominstall_ios%==1 set /a temperrorlev=%errorlevel%
if %custominstall_ios%==1 set modul=mkdir.exe
if %custominstall_ios%==1 if not %temperrorlev%==0 goto error_patching
exit /b 0
:patching_fast_travel_34
if %custominstall_ios%==1 call IOSPatcher\Sharpii.exe WAD -p IOSPatcher\IOS31\ "WAD\IOS31 Wii Only (IOS) (RiiConnect24).wad" -fs -es -np -vp >>"%MainFolder%\patching_output.txt"
if %custominstall_ios%==1 set /a temperrorlev=%errorlevel%
if %custominstall_ios%==1 set modul=Sharpii.exe
if %custominstall_ios%==1 if not %temperrorlev%==0 goto error_patching
if %custominstall_ios%==1 call IOSPatcher\Sharpii.exe WAD -p IOSPatcher\IOS80\ "WAD\IOS80 Wii Only (IOS) (RiiConnect24).wad" -fs -es -np -vp >>"%MainFolder%\patching_output.txt"
if %custominstall_ios%==1 set /a temperrorlev=%errorlevel%
if %custominstall_ios%==1 set modul=Sharpii.exe
if %custominstall_ios%==1 if not %temperrorlev%==0 goto error_patching
:patching_fast_travel_35
if %custominstall_ios%==1 call IOSPatcher\Sharpii.exe IOS "WAD\IOS31 Wii Only (IOS) (RiiConnect24).wad" -fs -es -np -vp >>"%MainFolder%\patching_output.txt"
if %custominstall_ios%==1 set /a temperrorlev=%errorlevel%
if %custominstall_ios%==1 set modul=Sharpii.exe Adding vulns to IOS31
if %custominstall_ios%==1 if not %temperrorlev%==0 goto error_patching

if %custominstall_ios%==1 call IOSPatcher\Sharpii.exe IOS "WAD\IOS80 Wii Only (IOS) (RiiConnect24).wad" -fs -es -np -vp >>"%MainFolder%\patching_output.txt"
if %custominstall_ios%==1 set /a temperrorlev=%errorlevel%
if %custominstall_ios%==1 set modul=Sharpii.exe Adding vulns to IOS80
if %custominstall_ios%==1 if not %temperrorlev%==0 goto error_patching


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
exit /b 0
:patching_fast_travel_36
if %custominstall_ios%==1 call IOSPatcher\Sharpii.exe IOS "WAD\IOS31 Wii Only (IOS) (RiiConnect24).wad" -fs -es -np -vp >>"%MainFolder%\patching_output.txt"
if %custominstall_ios%==1 set /a temperrorlev=%errorlevel%
if %custominstall_ios%==1 set modul=Sharpii.exe
if %custominstall_ios%==1 if not %temperrorlev%==0 goto error_patching
exit /b 0
:patching_fast_travel_37
if %custominstall_ios%==1 call IOSPatcher\Sharpii.exe IOS "WAD\IOS80 Wii Only (IOS) (RiiConnect24).wad" -fs -es -np -vp >>"%MainFolder%\patching_output.txt"
if %custominstall_ios%==1 set /a temperrorlev=%errorlevel%
if %custominstall_ios%==1 set modul=Sharpii.exe
if %custominstall_ios%==1 if not %temperrorlev%==0 goto error_patching
exit /b 0
:patching_fast_travel_38
if %custominstall_ios%==1 if not exist WAD md WAD
if %custominstall_ios%==1 move "IOSPatcher\WAD\IOS31 Wii Only (IOS) (RiiConnect24).wad" "WAD" >>"%MainFolder%\patching_output.txt"
if %custominstall_ios%==1 move "IOSPatcher\WAD\IOS80 Wii Only (IOS) (RiiConnect24).wad" "WAD" >>"%MainFolder%\patching_output.txt"
exit /b 0
:patching_fast_travel_39
if %custominstall_ios%==1 if exist IOSPatcher rmdir /s /q IOSPatcher 
if %custominstall_ios%==1 set /a progress_ios=1
exit /b 0

::News/Forecast Channel
::News
:patching_fast_travel_40
if %custominstall_news_fore%==1 if not exist NewsChannelPatcher md NewsChannelPatcher
if %custominstall_news_fore%==1 if %evcregion%==1 call NewsChannelPatcher\sharpii.exe nusd -ID 0001000248414750 -v 7 -wad >>"%MainFolder%\patching_output.txt"
if %custominstall_news_fore%==1 	if %evcregion%==1 set /a temperrorlev=%errorlevel%
if %custominstall_news_fore%==1 	if %evcregion%==1 set modul=Downloading News Channel
if %custominstall_news_fore%==1 	if %evcregion%==1 if not %temperrorlev%==0 goto error_patching
if %custominstall_news_fore%==1 if %evcregion%==2 call NewsChannelPatcher\sharpii.exe nusd -ID 0001000248414745 -v 7 -wad >>"%MainFolder%\patching_output.txt"
if %custominstall_news_fore%==1 	if %evcregion%==2 set /a temperrorlev=%errorlevel%
if %custominstall_news_fore%==1 	if %evcregion%==2 set modul=Downloading News Channel
if %custominstall_news_fore%==1 	if %evcregion%==2 if not %temperrorlev%==0 goto error_patching
if %custominstall_news_fore%==1 if %evcregion%==3 call NewsChannelPatcher\sharpii.exe nusd -ID 000100024841474A -v 7 -wad >>"%MainFolder%\patching_output.txt"
if %custominstall_news_fore%==1 	if %evcregion%==3 set /a temperrorlev=%errorlevel%
if %custominstall_news_fore%==1 	if %evcregion%==3 set modul=Downloading News Channel
if %custominstall_news_fore%==1 	if %evcregion%==3 if not %temperrorlev%==0 goto error_patching
exit /b 0
:patching_fast_travel_42

if %custominstall_news_fore%==1 if %evcregion%==1 call NewsChannelPatcher\sharpii.exe wad -u 0001000248414750v7.wad unpacked-temp/ >>"%MainFolder%\patching_output.txt"
if %custominstall_news_fore%==1 	if %evcregion%==1 set /a temperrorlev=%errorlevel%
if %custominstall_news_fore%==1 	if %evcregion%==1 set modul=Unpacking News Channel
if %custominstall_news_fore%==1 	if %evcregion%==1 if not %temperrorlev%==0 goto error_patching
if %custominstall_news_fore%==1 if %evcregion%==2 call NewsChannelPatcher\sharpii.exe wad -u 0001000248414745v7.wad unpacked-temp/ >>"%MainFolder%\patching_output.txt"
if %custominstall_news_fore%==1 	if %evcregion%==2 set /a temperrorlev=%errorlevel%
if %custominstall_news_fore%==1 	if %evcregion%==2 set modul=Unpacking News Channel
if %custominstall_news_fore%==1 	if %evcregion%==2 if not %temperrorlev%==0 goto error_patching

if %custominstall_news_fore%==1 if %evcregion%==3 call NewsChannelPatcher\sharpii.exe wad -u 000100024841474Av7.wad unpacked-temp/ >>"%MainFolder%\patching_output.txt"
if %custominstall_news_fore%==1 	if %evcregion%==3 set /a temperrorlev=%errorlevel%
if %custominstall_news_fore%==1 	if %evcregion%==3 set modul=Unpacking News Channel
if %custominstall_news_fore%==1 	if %evcregion%==3 if not %temperrorlev%==0 goto error_patching
exit /b 0
:patching_fast_travel_43
if %custominstall_news_fore%==1 move "unpacked-temp\00000001.app" "source.app"
if %custominstall_news_fore%==1 	set /a temperrorlev=%errorlevel%
if %custominstall_news_fore%==1 	set modul=Moving News Channel 0000001.app
if %custominstall_news_fore%==1 	if not %temperrorlev%==0 goto error_patching	
if %custominstall_news_fore%==1 if %evcregion%==1 call NewsChannelPatcher\xdelta3 -d -f -s source.app NewsChannelPatcher\00000001_News_Europe.delta unpacked-temp\00000001.app >>"%MainFolder%\patching_output.txt"
if %custominstall_news_fore%==1 if %evcregion%==2 call NewsChannelPatcher\xdelta3 -d -f -s source.app NewsChannelPatcher\00000001_News_USA.delta unpacked-temp\00000001.app >>"%MainFolder%\patching_output.txt"
if %custominstall_news_fore%==1 if %evcregion%==3 call NewsChannelPatcher\xdelta3 -d -f -s source.app NewsChannelPatcher\00000001_News_Japan.delta unpacked-temp\00000001.app >>"%MainFolder%\patching_output.txt"

if %custominstall_news_fore%==1 	set /a temperrorlev=%errorlevel%
if %custominstall_news_fore%==1 	set modul=Patching News Channel delta
if %custominstall_news_fore%==1 	if not %temperrorlev%==0 goto error_patching
exit /b 0
:patching_fast_travel_44
if %custominstall_news_fore%==1 if %evcregion%==1 NewsChannelPatcher\sharpii.exe wad -p unpacked-temp/ "WAD\News Channel (Europe) (Channel) (RiiConnect24).wad" >>"%MainFolder%\patching_output.txt"
if %custominstall_news_fore%==1 	if %evcregion%==1 set /a temperrorlev=%errorlevel%
if %custominstall_news_fore%==1 	if %evcregion%==1 set modul=Packing News Channel
if %custominstall_news_fore%==1 	if %evcregion%==1 if not %temperrorlev%==0 goto error_patching
if %custominstall_news_fore%==1 	if %evcregion%==1 rmdir /s /q unpacked-temp
if %custominstall_news_fore%==1 if %evcregion%==2 NewsChannelPatcher\sharpii.exe wad -p unpacked-temp/ "WAD\News Channel (USA) (Channel) (RiiConnect24).wad" >>"%MainFolder%\patching_output.txt"
if %custominstall_news_fore%==1 	if %evcregion%==2 set /a temperrorlev=%errorlevel%
if %custominstall_news_fore%==1 	if %evcregion%==2 set modul=Packing News Channel
if %custominstall_news_fore%==1 	if %evcregion%==2 if not %temperrorlev%==0 goto error_patching
if %custominstall_news_fore%==1 	if %evcregion%==2 rmdir /s /q unpacked-temp
if %custominstall_news_fore%==1 if %evcregion%==3 NewsChannelPatcher\sharpii.exe wad -p unpacked-temp/ "WAD\News Channel (Japan) (Channel) (RiiConnect24).wad" >>"%MainFolder%\patching_output.txt"
if %custominstall_news_fore%==1 	if %evcregion%==3 set /a temperrorlev=%errorlevel%
if %custominstall_news_fore%==1 	if %evcregion%==3 set modul=Packing News Channel
if %custominstall_news_fore%==1 	if %evcregion%==3 if not %temperrorlev%==0 goto error_patching
if %custominstall_news_fore%==1 	if %evcregion%==3 rmdir /s /q unpacked-temp
exit /b 0

::Forecast
:patching_fast_travel_45
if %custominstall_news_fore%==1 if %evcregion%==1 call NewsChannelPatcher\sharpii.exe nusd -ID 0001000248414650 -v 7 -wad >>"%MainFolder%\patching_output.txt"
if %custominstall_news_fore%==1 	if %evcregion%==1 set /a temperrorlev=%errorlevel%
if %custominstall_news_fore%==1 	if %evcregion%==1 set modul=Downloading Forecast Channel
if %custominstall_news_fore%==1 	if %evcregion%==1 if not %temperrorlev%==0 goto error_patching
if %custominstall_news_fore%==1 if %evcregion%==2 call NewsChannelPatcher\sharpii.exe nusd -ID 0001000248414645 -v 7 -wad >>"%MainFolder%\patching_output.txt"
if %custominstall_news_fore%==1 	if %evcregion%==2 set /a temperrorlev=%errorlevel%
if %custominstall_news_fore%==1 	if %evcregion%==2 set modul=Downloading Forecast Channel
if %custominstall_news_fore%==1 	if %evcregion%==2 if not %temperrorlev%==0 goto error_patching
if %custominstall_news_fore%==1 if %evcregion%==3 call NewsChannelPatcher\sharpii.exe nusd -ID 000100024841464A -v 7 -wad >>"%MainFolder%\patching_output.txt"
if %custominstall_news_fore%==1 	if %evcregion%==3 set /a temperrorlev=%errorlevel%
if %custominstall_news_fore%==1 	if %evcregion%==3 set modul=Downloading Forecast Channel
if %custominstall_news_fore%==1 	if %evcregion%==3 if not %temperrorlev%==0 goto error_patching
exit /b 0
:patching_fast_travel_46

if %custominstall_news_fore%==1 if %evcregion%==1 call NewsChannelPatcher\sharpii.exe wad -u 0001000248414650v7.wad unpacked-temp >>"%MainFolder%\patching_output.txt"
if %custominstall_news_fore%==1 	if %evcregion%==1 set /a temperrorlev=%errorlevel%
if %custominstall_news_fore%==1 	if %evcregion%==1 set modul=Unpacking Forecast Channel
if %custominstall_news_fore%==1 	if %evcregion%==1 if not %temperrorlev%==0 goto error_patching
if %custominstall_news_fore%==1 if %evcregion%==2 call NewsChannelPatcher\sharpii.exe wad -u 0001000248414645v7.wad unpacked-temp/ >>"%MainFolder%\patching_output.txt"
if %custominstall_news_fore%==1 	if %evcregion%==2 set /a temperrorlev=%errorlevel%
if %custominstall_news_fore%==1 	if %evcregion%==2 set modul=Unpacking Forecast Channel
if %custominstall_news_fore%==1 	if %evcregion%==2 if not %temperrorlev%==0 goto error_patching
if %custominstall_news_fore%==1 if %evcregion%==3 call NewsChannelPatcher\sharpii.exe wad -u 000100024841464Av7.wad unpacked-temp/ >>"%MainFolder%\patching_output.txt"
if %custominstall_news_fore%==1 	if %evcregion%==3 set /a temperrorlev=%errorlevel%
if %custominstall_news_fore%==1 	if %evcregion%==3 set modul=Unpacking Forecast Channel
if %custominstall_news_fore%==1 	if %evcregion%==3 if not %temperrorlev%==0 goto error_patching

exit /b 0
:patching_fast_travel_47
if %custominstall_news_fore%==1 ren unpacked-temp\00000001.app source.app
if %custominstall_news_fore%==1 	set /a temperrorlev=%errorlevel%
if %custominstall_news_fore%==1 	set modul=Moving Forecast Channel 0000001.app
if %custominstall_news_fore%==1 	if not %temperrorlev%==0 goto error_patching
if %custominstall_news_fore%==1 if %evcregion%==1 call NewsChannelPatcher\xdelta3 -d -f -s unpacked-temp\source.app NewsChannelPatcher\00000001_Forecast_Europe.delta unpacked-temp\00000001.app >>"%MainFolder%\patching_output.txt"
if %custominstall_news_fore%==1 if %evcregion%==2 call NewsChannelPatcher\xdelta3 -d -f -s unpacked-temp\source.app NewsChannelPatcher\00000001_Forecast_USA.delta unpacked-temp\00000001.app >>"%MainFolder%\patching_output.txt"
if %custominstall_news_fore%==1 if %evcregion%==3 call NewsChannelPatcher\xdelta3 -d -f -s unpacked-temp\source.app NewsChannelPatcher\00000001_Forecast_Japan.delta unpacked-temp\00000001.app >>"%MainFolder%\patching_output.txt"
if %custominstall_news_fore%==1 	set /a temperrorlev=%errorlevel%
if %custominstall_news_fore%==1 	set modul=Patching Forecast Channel delta
if %custominstall_news_fore%==1 	if not %temperrorlev%==0 goto error_patching
exit /b 0
:patching_fast_travel_49
if %custominstall_news_fore%==1 if %evcregion%==1 NewsChannelPatcher\sharpii.exe wad -p unpacked-temp\ "WAD\Forecast Channel (Europe) (Channel) (RiiConnect24).wad" >>"%MainFolder%\patching_output.txt"
if %custominstall_news_fore%==1 	if %evcregion%==1 set /a temperrorlev=%errorlevel%
if %custominstall_news_fore%==1 	if %evcregion%==1 set modul=Packing Forecast Channel
if %custominstall_news_fore%==1 	if %evcregion%==1 if not %temperrorlev%==0 goto error_patching
if %custominstall_news_fore%==1 	if %evcregion%==1 rmdir /s /q unpacked-temp
if %custominstall_news_fore%==1 if %evcregion%==2 NewsChannelPatcher\sharpii.exe wad -p unpacked-temp\ "WAD\Forecast Channel (USA) (Channel) (RiiConnect24).wad" >>"%MainFolder%\patching_output.txt"
if %custominstall_news_fore%==1 	if %evcregion%==2 set /a temperrorlev=%errorlevel%
if %custominstall_news_fore%==1 	if %evcregion%==2 set modul=Packing Forecast Channel
if %custominstall_news_fore%==1 	if %evcregion%==2 if not %temperrorlev%==0 goto error_patching
if %custominstall_news_fore%==1 	if %evcregion%==2 rmdir /s /q unpacked-temp
if %custominstall_news_fore%==1 if %evcregion%==3 NewsChannelPatcher\sharpii.exe wad -p unpacked-temp\ "WAD\Forecast Channel (Japan) (Channel) (RiiConnect24).wad" >>"%MainFolder%\patching_output.txt"
if %custominstall_news_fore%==1 	if %evcregion%==3 set /a temperrorlev=%errorlevel%
if %custominstall_news_fore%==1 	if %evcregion%==3 set modul=Packing Forecast Channel
if %custominstall_news_fore%==1 	if %evcregion%==3 if not %temperrorlev%==0 goto error_patching
if %custominstall_news_fore%==1 	if %evcregion%==3 rmdir /s /q unpacked-temp
set /a progress_news_fore=1
exit /b 0

::EVC Patcher
:patching_fast_travel_50
if %custominstall_evc%==1 if not exist 0001000148414A50v512 md 0001000148414A50v512
if %custominstall_evc%==1 if not exist 0001000148414A45v512 md 0001000148414A45v512
if %custominstall_evc%==1 if not exist 0001000148414A4Av512 md 0001000148414A4Av512
if %custominstall_evc%==1 if not exist 0001000148414A50v512\cetk copy /y "EVCPatcher\dwn\0001000148414A50v512\cetk" "0001000148414A50v512\cetk" >>"%MainFolder%\patching_output.txt"

if %custominstall_evc%==1 if not exist 0001000148414A45v512\cetk copy /y "EVCPatcher\dwn\0001000148414A45v512\cetk" "0001000148414A45v512\cetk" >>"%MainFolder%\patching_output.txt"
if %custominstall_evc%==1 if not exist 0001000148414A4Av512\cetk copy /y "EVCPatcher\dwn\0001000148414A4Av512\cetk" "0001000148414A4Av512\cetk" >>"%MainFolder%\patching_output.txt"

exit /b 0
::USA
:patching_fast_travel_51
if %custominstall_evc%==1 if %evcregion%==2 call EVCPatcher\dwn\sharpii.exe NUSD -ID 0001000148414A45 -v 512 -encrypt >>"%MainFolder%\patching_output.txt"
::JPN
if %custominstall_evc%==1 if %evcregion%==3 call EVCPatcher\dwn\sharpii.exe NUSD -ID 0001000148414A4A -v 512 -encrypt >>"%MainFolder%\patching_output.txt"
::PAL
if %custominstall_evc%==1 if %evcregion%==1 call EVCPatcher\dwn\sharpii.exe NUSD -ID 0001000148414A50 -v 512 -encrypt >>"%MainFolder%\patching_output.txt"
if %custominstall_evc%==1 set /a temperrorlev=%errorlevel%
if %custominstall_evc%==1 set modul=Downloading EVC
if %custominstall_evc%==1 if not %temperrorlev%==0 goto error_patching
exit /b 0
:patching_fast_travel_52
if %custominstall_evc%==1 if %evcregion%==1 copy /y "EVCPatcher\NUS_Downloader_Decrypt.exe" "0001000148414A50v512"&copy "cert.sys" "0001000148414A50v512" >>"%MainFolder%\patching_output.txt"
if %custominstall_evc%==1 if %evcregion%==2 copy /y "EVCPatcher\NUS_Downloader_Decrypt.exe" "0001000148414A45v512"&copy "cert.sys" "0001000148414A45v512" >>"%MainFolder%\patching_output.txt"
if %custominstall_evc%==1 if %evcregion%==3 copy /y "EVCPatcher\NUS_Downloader_Decrypt.exe" "0001000148414A4Av512"&copy "cert.sys" "0001000148414A4Av512" >>"%MainFolder%\patching_output.txt"

if %custominstall_evc%==1 set /a temperrorlev=%errorlevel%
if %custominstall_evc%==1 set modul=Copying NDC.exe
if %custominstall_evc%==1 if not %temperrorlev%==0 goto error_patching
exit /b 0
:patching_fast_travel_54
if %custominstall_evc%==1 if %evcregion%==1 ren "0001000148414A50v512\tmd.512" "tmd" >>"%MainFolder%\patching_output.txt"
if %custominstall_evc%==1 if %evcregion%==2 ren "0001000148414A45v512\tmd.512" "tmd" >>"%MainFolder%\patching_output.txt"
if %custominstall_evc%==1 if %evcregion%==3 ren "0001000148414A4Av512\tmd.512" "tmd" >>"%MainFolder%\patching_output.txt"
if %custominstall_evc%==1 set /a temperrorlev=%errorlevel%
if %custominstall_evc%==1 set modul=Renaming files [Delete everything except RiiConnect24Patcher.bat]
if %custominstall_evc%==1 if not %temperrorlev%==0 goto error_patching
exit /b 0
:patching_fast_travel_55
if %custominstall_evc%==1 if %evcregion%==1 cd 0001000148414A50v512
if %custominstall_evc%==1 	if %evcregion%==1 if %evcregion%==1 call NUS_Downloader_Decrypt.exe >>"%MainFolder%\patching_output.txt"
if %custominstall_evc%==1 if %evcregion%==2 cd 0001000148414A45v512
if %custominstall_evc%==1 	if %evcregion%==2 if %evcregion%==2 call NUS_Downloader_Decrypt.exe >>"%MainFolder%\patching_output.txt"
if %custominstall_evc%==1 if %evcregion%==3 cd 0001000148414A4Av512
if %custominstall_evc%==1 	if %evcregion%==3 if %evcregion%==3 call NUS_Downloader_Decrypt.exe >>"%MainFolder%\patching_output.txt"

if %custominstall_evc%==1 set /a temperrorlev=%errorlevel%
if %custominstall_evc%==1 set modul=Decrypter error
if %custominstall_evc%==1 if not %temperrorlev%==0 cd..& goto error_patching
if %custominstall_evc%==1 cd..
exit /b 0
:patching_fast_travel_56
if %custominstall_evc%==1 if %evcregion%==1 ren "0001000148414A50v512\*.wad" "HAJP.wad" >>"%MainFolder%\patching_output.txt"
if %custominstall_evc%==1 if %evcregion%==2 ren "0001000148414A45v512\*.wad" "HAJE.wad" >>"%MainFolder%\patching_output.txt"
if %custominstall_evc%==1 if %evcregion%==3 ren "0001000148414A4Av512\*.wad" "HAJJ.wad" >>"%MainFolder%\patching_output.txt"


if %custominstall_evc%==1 if %evcregion%==1 move /y "0001000148414A50v512\HAJP.wad" "EVCPatcher\pack" >>"%MainFolder%\patching_output.txt"
if %custominstall_evc%==1 if %evcregion%==2 move /y "0001000148414A45v512\HAJE.wad" "EVCPatcher\pack" >>"%MainFolder%\patching_output.txt"
if %custominstall_evc%==1 if %evcregion%==3 move /y "0001000148414A4Av512\HAJJ.wad" "EVCPatcher\pack" >>"%MainFolder%\patching_output.txt"
if %custominstall_evc%==1 set /a temperrorlev=%errorlevel%
if %custominstall_evc%==1 set modul=move.exe
if %custominstall_evc%==1 if not %temperrorlev%==0 goto error_patching
exit /b 0
:patching_fast_travel_57
if %custominstall_evc%==1 if %evcregion%==1 call EVCPatcher\pack\Sharpii.exe WAD -u EVCPatcher\pack\HAJP.wad EVCPatcher\pack\unencrypted >>"%MainFolder%\patching_output.txt"
if %custominstall_evc%==1 if %evcregion%==2 call EVCPatcher\pack\Sharpii.exe WAD -u EVCPatcher\pack\HAJE.wad EVCPatcher\pack\unencrypted >>"%MainFolder%\patching_output.txt"
if %custominstall_evc%==1 if %evcregion%==3 call EVCPatcher\pack\Sharpii.exe WAD -u EVCPatcher\pack\HAJJ.wad EVCPatcher\pack\unencrypted >>"%MainFolder%\patching_output.txt"
exit /b 0
:patching_fast_travel_58
if %custominstall_evc%==1 move /y "EVCPatcher\pack\unencrypted\00000001.app" "00000001.app" >>"%MainFolder%\patching_output.txt"
if %custominstall_evc%==1 set /a temperrorlev=%errorlevel%
if %custominstall_evc%==1 set modul=move.exe
if %custominstall_evc%==1 if not %temperrorlev%==0 goto error_patching
exit /b 0
:patching_fast_travel_59
if %custominstall_evc%==1 if %evcregion%==1 call EVCPatcher\patch\xdelta3.exe -f -d -s 00000001.app EVCPatcher\patch\Europe.delta EVCPatcher\pack\unencrypted\00000001.app >>"%MainFolder%\patching_output.txt"
if %custominstall_evc%==1 if %evcregion%==2 call EVCPatcher\patch\xdelta3.exe -f -d -s 00000001.app EVCPatcher\patch\USA.delta EVCPatcher\pack\unencrypted\00000001.app >>"%MainFolder%\patching_output.txt"
if %custominstall_evc%==1 if %evcregion%==3 call EVCPatcher\patch\xdelta3.exe -f -d -s 00000001.app EVCPatcher\patch\JPN.delta EVCPatcher\pack\unencrypted\00000001.app >>"%MainFolder%\patching_output.txt"
if %custominstall_evc%==1 set /a temperrorlev=%errorlevel%
if %custominstall_evc%==1 set modul=xdelta.exe EVC
if %custominstall_evc%==1 if not %temperrorlev%==0 goto error_patching
exit /b 0
:patching_fast_travel_60
if %custominstall_evc%==1 if %evcregion%==1 call EVCPatcher\pack\Sharpii.exe WAD -p "EVCPatcher\pack\unencrypted" "WAD\Everybody Votes Channel (Europe) (Channel) (RiiConnect24)" -f >>"%MainFolder%\patching_output.txt"
if %custominstall_evc%==1 if %evcregion%==2 call EVCPatcher\pack\Sharpii.exe WAD -p "EVCPatcher\pack\unencrypted" "WAD\Everybody Votes Channel (USA) (Channel) (RiiConnect24)" -f >>"%MainFolder%\patching_output.txt"
if %custominstall_evc%==1 if %evcregion%==3 call EVCPatcher\pack\Sharpii.exe WAD -p "EVCPatcher\pack\unencrypted" "WAD\Everybody Votes Channel (Japan) (Channel) (RiiConnect24)" -f >>"%MainFolder%\patching_output.txt"
if %custominstall_evc%==1 set /a temperrorlev=%errorlevel%
if %custominstall_evc%==1 set modul=Packing EVC WAD
if %custominstall_evc%==1 set /a progress_evc=1
if %custominstall_evc%==1 if not %temperrorlev%==0 goto error_patching
exit /b 0

::CMOC
:patching_fast_travel_61
if %custominstall_cmoc%==1 if not exist 0001000148415050v512 md 0001000148415050v512
if %custominstall_cmoc%==1 if not exist 0001000148415045v512 md 0001000148415045v512
if %custominstall_cmoc%==1 if not exist 000100014841504Av512 md 000100014841504Av512

if %custominstall_cmoc%==1 if not exist 0001000148415050v512\cetk copy /y "CMOCPatcher\dwn\0001000148415050v512\cetk" "0001000148415050v512\cetk" >>"%MainFolder%\patching_output.txt"
if %custominstall_cmoc%==1 if not exist 0001000148415045v512\cetk copy /y "CMOCPatcher\dwn\0001000148415045v512\cetk" "0001000148415045v512\cetk" >>"%MainFolder%\patching_output.txt"
if %custominstall_cmoc%==1 if not exist 000100014841504Av512\cetk copy /y "CMOCPatcher\dwn\000100014841504Av512\cetk" "000100014841504Av512\cetk" >>"%MainFolder%\patching_output.txt"

exit /b 0
::USA
:patching_fast_travel_62

if %custominstall_cmoc%==1 if %evcregion%==2 call CMOCPatcher\dwn\sharpii.exe NUSD -ID 0001000148415045 -v 512 -encrypt >>"%MainFolder%\patching_output.txt"
::PAL
if %custominstall_cmoc%==1 if %evcregion%==1 call CMOCPatcher\dwn\sharpii.exe NUSD -ID 0001000148415050 -v 512 -encrypt >>"%MainFolder%\patching_output.txt"
::JPN
if %custominstall_cmoc%==1 if %evcregion%==3 call CMOCPatcher\dwn\sharpii.exe NUSD -ID 000100014841504A -v 512 -encrypt >>"%MainFolder%\patching_output.txt"
if %custominstall_cmoc%==1 set /a temperrorlev=%errorlevel%
if %custominstall_cmoc%==1 set modul=Downloading CMOC
if %custominstall_cmoc%==1 if not %temperrorlev%==0 goto error_patching
exit /b 0
:patching_fast_travel_63
if %custominstall_cmoc%==1 if %evcregion%==1 copy /y "CMOCPatcher\NUS_Downloader_Decrypt.exe" "0001000148415050v512" >>"%MainFolder%\patching_output.txt"
if %custominstall_cmoc%==1 if %evcregion%==2 copy /y "CMOCPatcher\NUS_Downloader_Decrypt.exe" "0001000148415045v512" >>"%MainFolder%\patching_output.txt"
if %custominstall_cmoc%==1 if %evcregion%==3 copy /y "CMOCPatcher\NUS_Downloader_Decrypt.exe" "000100014841504Av512" >>"%MainFolder%\patching_output.txt"

if %custominstall_cmoc%==1 set /a temperrorlev=%errorlevel%
if %custominstall_cmoc%==1 set modul=Copying NDC.exe
if %custominstall_cmoc%==1 if not %temperrorlev%==0 goto error_patching
exit /b 0
:patching_fast_travel_65
if %custominstall_cmoc%==1 if %evcregion%==1 ren "0001000148415050v512\tmd.512" "tmd" >>"%MainFolder%\patching_output.txt"
if %custominstall_cmoc%==1 if %evcregion%==2 ren "0001000148415045v512\tmd.512" "tmd" >>"%MainFolder%\patching_output.txt"
if %custominstall_cmoc%==1 if %evcregion%==3 ren "000100014841504Av512\tmd.512" "tmd" >>"%MainFolder%\patching_output.txt"
if %custominstall_cmoc%==1 set /a temperrorlev=%errorlevel%
if %custominstall_cmoc%==1 set modul=Renaming files [Delete everything except RiiConnect24Patcher.bat]
if %custominstall_cmoc%==1 if not %temperrorlev%==0 goto error_patching

if %custominstall_cmoc%==1 if %evcregion%==1 cd 0001000148415050v512
if %custominstall_cmoc%==1 if %evcregion%==1 call NUS_Downloader_Decrypt.exe >>"%MainFolder%\patching_output.txt"
if %custominstall_cmoc%==1 if %evcregion%==2 cd 0001000148415045v512
if %custominstall_cmoc%==1 if %evcregion%==2 call NUS_Downloader_Decrypt.exe >>"%MainFolder%\patching_output.txt"
if %custominstall_cmoc%==1 if %evcregion%==3 cd 000100014841504Av512
if %custominstall_cmoc%==1 if %evcregion%==3 call NUS_Downloader_Decrypt.exe >>"%MainFolder%\patching_output.txt"

if %custominstall_cmoc%==1 set /a temperrorlev=%errorlevel%
if %custominstall_cmoc%==1 set modul=Decrypter error
if %custominstall_cmoc%==1 if not %temperrorlev%==0 cd..& goto error_patching
if %custominstall_cmoc%==1 cd..
exit /b 0
:patching_fast_travel_66
if %custominstall_cmoc%==1 if %evcregion%==1 ren "0001000148415050v512\*.wad" "HAPP.wad" >>"%MainFolder%\patching_output.txt"
if %custominstall_cmoc%==1 if %evcregion%==2 ren "0001000148415045v512\*.wad" "HAPE.wad" >>"%MainFolder%\patching_output.txt"
if %custominstall_cmoc%==1 if %evcregion%==3 ren "000100014841504Av512\*.wad" "HAPJ.wad" >>"%MainFolder%\patching_output.txt"


if %custominstall_cmoc%==1 if %evcregion%==1 move /y "0001000148415050v512\HAPP.wad" "CMOCPatcher\pack" >>"%MainFolder%\patching_output.txt"
if %custominstall_cmoc%==1 if %evcregion%==2 move /y "0001000148415045v512\HAPE.wad" "CMOCPatcher\pack" >>"%MainFolder%\patching_output.txt"
if %custominstall_cmoc%==1 if %evcregion%==3 move /y "000100014841504Av512\HAPJ.wad" "CMOCPatcher\pack" >>"%MainFolder%\patching_output.txt"
if %custominstall_cmoc%==1 set /a temperrorlev=%errorlevel%
if %custominstall_cmoc%==1 set modul=move.exe
if %custominstall_cmoc%==1 if not %temperrorlev%==0 goto error_patching
exit /b 0
:patching_fast_travel_68
if %custominstall_cmoc%==1 if %evcregion%==1 call CMOCPatcher\pack\Sharpii.exe WAD -u CMOCPatcher\pack\HAPP.wad CMOCPatcher\pack\unencrypted >>"%MainFolder%\patching_output.txt"
if %custominstall_cmoc%==1 if %evcregion%==2 call CMOCPatcher\pack\Sharpii.exe WAD -u CMOCPatcher\pack\HAPE.wad CMOCPatcher\pack\unencrypted >>"%MainFolder%\patching_output.txt"
if %custominstall_cmoc%==1 if %evcregion%==3 call CMOCPatcher\pack\Sharpii.exe WAD -u CMOCPatcher\pack\HAPJ.wad CMOCPatcher\pack\unencrypted >>"%MainFolder%\patching_output.txt"
exit /b 0
:patching_fast_travel_70
if %custominstall_cmoc%==1 move /y "CMOCPatcher\pack\unencrypted\00000001.app" "00000001.app" >>"%MainFolder%\patching_output.txt"
if %custominstall_cmoc%==1 move /y "CMOCPatcher\pack\unencrypted\00000004.app" "00000004.app" >>"%MainFolder%\patching_output.txt"
if %custominstall_cmoc%==1 set /a temperrorlev=%errorlevel%
if %custominstall_cmoc%==1 set modul=move.exe
if %custominstall_cmoc%==1 if not %temperrorlev%==0 goto error_patching
exit /b 0
:patching_fast_travel_71
if %custominstall_cmoc%==1 if %evcregion%==1 call CMOCPatcher\patch\xdelta3.exe -f -d -s 00000001.app CMOCPatcher\patch\00000001_Europe.delta CMOCPatcher\pack\unencrypted\00000001.app >>"%MainFolder%\patching_output.txt"
if %custominstall_cmoc%==1 if %evcregion%==1 call CMOCPatcher\patch\xdelta3.exe -f -d -s 00000004.app CMOCPatcher\patch\00000004_Europe.delta CMOCPatcher\pack\unencrypted\00000004.app >>"%MainFolder%\patching_output.txt"
if %custominstall_cmoc%==1 if %evcregion%==2 call CMOCPatcher\patch\xdelta3.exe -f -d -s 00000001.app CMOCPatcher\patch\00000001_USA.delta CMOCPatcher\pack\unencrypted\00000001.app >>"%MainFolder%\patching_output.txt"
if %custominstall_cmoc%==1 if %evcregion%==2 call CMOCPatcher\patch\xdelta3.exe -f -d -s 00000004.app CMOCPatcher\patch\00000004_USA.delta CMOCPatcher\pack\unencrypted\00000004.app >>"%MainFolder%\patching_output.txt"
if %custominstall_cmoc%==1 if %evcregion%==3 call CMOCPatcher\patch\xdelta3.exe -f -d -s 00000001.app CMOCPatcher\patch\00000001_Japan.delta CMOCPatcher\pack\unencrypted\00000001.app >>"%MainFolder%\patching_output.txt"
if %custominstall_cmoc%==1 if %evcregion%==3 call CMOCPatcher\patch\xdelta3.exe -f -d -s 00000004.app CMOCPatcher\patch\00000004_Japan.delta CMOCPatcher\pack\unencrypted\00000004.app >>"%MainFolder%\patching_output.txt"
if %custominstall_cmoc%==1 set /a temperrorlev=%errorlevel%
if %custominstall_cmoc%==1 set modul=xdelta.exe CMOC
if %custominstall_cmoc%==1 if not %temperrorlev%==0 goto error_patching
exit /b 0
:patching_fast_travel_72
	call :check_rc24_server_connection
	if "%errorlevel%"=="1" goto server_connection_lost

if %custominstall_cmoc%==1 if %evcregion%==1 call CMOCPatcher\pack\Sharpii.exe WAD -p "CMOCPatcher\pack\unencrypted" "WAD\Mii Contest Channel (Europe) (Channel) (RiiConnect24)" -f >>"%MainFolder%\patching_output.txt"
if %custominstall_cmoc%==1 if %evcregion%==2 call CMOCPatcher\pack\Sharpii.exe WAD -p "CMOCPatcher\pack\unencrypted" "WAD\Check Mii Out Channel (USA) (Channel) (RiiConnect24)" -f >>"%MainFolder%\patching_output.txt"
if %custominstall_cmoc%==1 if %evcregion%==3 call CMOCPatcher\pack\Sharpii.exe WAD -p "CMOCPatcher\pack\unencrypted" "WAD\Mii Contest Channel (Japan) (Channel) (RiiConnect24)" -f >>"%MainFolder%\patching_output.txt"
if %custominstall_cmoc%==1 set /a temperrorlev=%errorlevel%
if %custominstall_cmoc%==1 set modul=Packing CMOC WAD
if %custominstall_cmoc%==1 set /a progress_cmoc=1
if %custominstall_cmoc%==1 if not %temperrorlev%==0 goto error_patching
exit /b 0

::NC

:patching_fast_travel_73
if %custominstall_nc%==1 if not exist 0001000148415450v1792 md 0001000148415450v1792
if %custominstall_nc%==1 if not exist 0001000148415445v1792 md 0001000148415445v1792
if %custominstall_nc%==1 if not exist 000100014841544Av1792 md 000100014841544Av1792
if %custominstall_nc%==1 if not exist 0001000148415450v1792\cetk copy /y "NCPatcher\dwn\0001000148415450v1792\cetk" "0001000148415450v1792\cetk" >>"%MainFolder%\patching_output.txt"
if %custominstall_nc%==1 if not exist 0001000148415445v1792\cetk copy /y "NCPatcher\dwn\0001000148415445v1792\cetk" "0001000148415445v1792\cetk" >>"%MainFolder%\patching_output.txt"
if %custominstall_nc%==1 if not exist 000100014841544Av1792\cetk copy /y "NCPatcher\dwn\000100014841544Av1792\cetk" "000100014841544Av1792\cetk" >>"%MainFolder%\patching_output.txt"

:patching_fast_travel_75
::USA
if %custominstall_nc%==1 if %evcregion%==3 call NCPatcher\dwn\sharpii.exe NUSD -ID 000100014841544A -v 1792 -encrypt >>"%MainFolder%\patching_output.txt"
::JPN
if %custominstall_nc%==1 if %evcregion%==2 call NCPatcher\dwn\sharpii.exe NUSD -ID 0001000148415445 -v 1792 -encrypt >>"%MainFolder%\patching_output.txt"
::PAL
if %custominstall_nc%==1 if %evcregion%==1 call NCPatcher\dwn\sharpii.exe NUSD -ID 0001000148415450 -v 1792 -encrypt >>"%MainFolder%\patching_output.txt"
if %custominstall_nc%==1 set /a temperrorlev=%errorlevel%
if %custominstall_nc%==1 set modul=Downloading NC
if %custominstall_nc%==1 if not %temperrorlev%==0 goto error_patching
exit /b 0
:patching_fast_travel_76
if %custominstall_nc%==1 if %evcregion%==1 copy /y "NCPatcher\NUS_Downloader_Decrypt.exe" "0001000148415450v1792" >>"%MainFolder%\patching_output.txt"
if %custominstall_nc%==1 if %evcregion%==2 copy /y "NCPatcher\NUS_Downloader_Decrypt.exe" "0001000148415445v1792" >>"%MainFolder%\patching_output.txt"
if %custominstall_nc%==1 if %evcregion%==3 copy /y "NCPatcher\NUS_Downloader_Decrypt.exe" "000100014841544Av1792" >>"%MainFolder%\patching_output.txt"

if %custominstall_nc%==1 set /a temperrorlev=%errorlevel%
if %custominstall_nc%==1 set modul=Copying NDC.exe
if %custominstall_nc%==1 if not %temperrorlev%==0 goto error_patching
exit /b 0
:patching_fast_travel_77
if %custominstall_nc%==1 if %evcregion%==1 ren "0001000148415450v1792\tmd.1792" "tmd" >>"%MainFolder%\patching_output.txt"
if %custominstall_nc%==1 if %evcregion%==2 ren "0001000148415445v1792\tmd.1792" "tmd" >>"%MainFolder%\patching_output.txt"
if %custominstall_nc%==1 if %evcregion%==3 ren "000100014841544Av1792\tmd.1792" "tmd" >>"%MainFolder%\patching_output.txt"
if %custominstall_nc%==1 set /a temperrorlev=%errorlevel%
if %custominstall_nc%==1 set modul=Renaming files
if %custominstall_nc%==1 if not %temperrorlev%==0 goto error_patching
exit /b 0
:patching_fast_travel_78
if %custominstall_nc%==1 if %evcregion%==1 cd 0001000148415450v1792
if %custominstall_nc%==1 if %evcregion%==2 cd 0001000148415445v1792
if %custominstall_nc%==1 if %evcregion%==3 cd 000100014841544Av1792
if %custominstall_nc%==1 call NUS_Downloader_Decrypt.exe >>"%MainFolder%\patching_output.txt"
if %custominstall_nc%==1 set /a temperrorlev=%errorlevel%
if %custominstall_nc%==1 set modul=Decrypter error
if %custominstall_nc%==1 if not %temperrorlev%==0 cd..& goto error_patching
if %custominstall_nc%==1 cd..
exit /b 0
:patching_fast_travel_79
if %custominstall_nc%==1 if %evcregion%==1 ren "0001000148415450v1792\*.wad" "HATP.wad" >>"%MainFolder%\patching_output.txt"
if %custominstall_nc%==1 if %evcregion%==2 ren "0001000148415445v1792\*.wad" "HATE.wad" >>"%MainFolder%\patching_output.txt"
if %custominstall_nc%==1 if %evcregion%==3 ren "000100014841544Av1792\*.wad" "HATJ.wad" >>"%MainFolder%\patching_output.txt"

if %custominstall_nc%==1 if %evcregion%==1 move /y "0001000148415450v1792\HATP.wad" "NCPatcher\pack" >>"%MainFolder%\patching_output.txt"
if %custominstall_nc%==1 if %evcregion%==2 move /y "0001000148415445v1792\HATE.wad" "NCPatcher\pack" >>"%MainFolder%\patching_output.txt"
if %custominstall_nc%==1 if %evcregion%==3 move /y "000100014841544Av1792\HATJ.wad" "NCPatcher\pack" >>"%MainFolder%\patching_output.txt"
if %custominstall_nc%==1 set /a temperrorlev=%errorlevel%
if %custominstall_nc%==1 set modul=move.exe
if %custominstall_nc%==1 if not %temperrorlev%==0 goto error_patching
exit /b 0
:patching_fast_travel_80
if %custominstall_nc%==1 if %evcregion%==1 call NCPatcher\pack\Sharpii.exe WAD -u NCPatcher\pack\HATP.wad NCPatcher\pack\unencrypted >>"%MainFolder%\patching_output.txt"
if %custominstall_nc%==1 if %evcregion%==2 call NCPatcher\pack\Sharpii.exe WAD -u NCPatcher\pack\HATE.wad NCPatcher\pack\unencrypted >>"%MainFolder%\patching_output.txt"
if %custominstall_nc%==1 if %evcregion%==3 call NCPatcher\pack\Sharpii.exe WAD -u NCPatcher\pack\HATJ.wad NCPatcher\pack\unencrypted >>"%MainFolder%\patching_output.txt"
exit /b 0
:patching_fast_travel_81
if %custominstall_nc%==1 move /y "NCPatcher\pack\unencrypted\00000001.app" "00000001_NC.app"
if %custominstall_nc%==1 set /a temperrorlev=%errorlevel%
if %custominstall_nc%==1 set modul=move.exe
if %custominstall_nc%==1 if not %temperrorlev%==0 goto error_patching
exit /b 0
:patching_fast_travel_82
if %custominstall_nc%==1 if %evcregion%==1 call NCPatcher\patch\xdelta3.exe -f -d -s 00000001_NC.app NCPatcher\patch\Europe.delta NCPatcher\pack\unencrypted\00000001.app >>"%MainFolder%\patching_output.txt"
if %custominstall_nc%==1 if %evcregion%==2 call NCPatcher\patch\xdelta3.exe -f -d -s 00000001_NC.app NCPatcher\patch\USA.delta NCPatcher\pack\unencrypted\00000001.app >>"%MainFolder%\patching_output.txt"
if %custominstall_nc%==1 if %evcregion%==3 call NCPatcher\patch\xdelta3.exe -f -d -s 00000001_NC.app NCPatcher\patch\JPN.delta NCPatcher\pack\unencrypted\00000001.app >>"%MainFolder%\patching_output.txt"
if %custominstall_nc%==1 set /a temperrorlev=%errorlevel%
if %custominstall_nc%==1 set modul=xdelta.exe NC
if %custominstall_nc%==1 if not %temperrorlev%==0 goto error_patching
exit /b 0
:patching_fast_travel_83
if %custominstall_nc%==1 if %evcregion%==1 call NCPatcher\pack\Sharpii.exe WAD -p "NCPatcher\pack\unencrypted" "WAD\Nintendo Channel (Europe) (Channel) (RiiConnect24)" -f >>"%MainFolder%\patching_output.txt"
if %custominstall_nc%==1 if %evcregion%==2 call NCPatcher\pack\Sharpii.exe WAD -p "NCPatcher\pack\unencrypted" "WAD\Nintendo Channel (USA) (Channel) (RiiConnect24)" -f >>"%MainFolder%\patching_output.txt"
if %custominstall_nc%==1 if %evcregion%==3 call NCPatcher\pack\Sharpii.exe WAD -p "NCPatcher\pack\unencrypted" "WAD\Nintendo Channel (Japan) (Channel) (RiiConnect24)" -f >>"%MainFolder%\patching_output.txt"
if %custominstall_nc%==1 set /a temperrorlev=%errorlevel%
if %custominstall_nc%==1 set modul=Packing NC WAD
if %custominstall_nc%==1 if not %temperrorlev%==0 goto error_patching
if %custominstall_nc%==1 set /a progress_nc=1
exit /b 0

:patching_fast_travel_90
if exist cetk del /q cetk

if %internet_channel_enable%==1 if %evcregion%==1 (

if not exist 0001000148414450v1024 md 0001000148414450v1024
copy "cert.sys" "0001000148414450v1024" >>"%MainFolder%\patching_output.txt"
curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/AdditionalChannels_Patches/InternetChannel/Europe.cetk" --output "0001000148414450v1024\cetk"
	set /a temperrorlev=%errorlevel%
	set modul=Downloading Internet Channel CETK
	if not %temperrorlev%==0 goto error_patching
CMOCPatcher\pack\Sharpii.exe NUSD -id 0001000148414450 -v 1024 -encrypt>>"%MainFolder%\patching_output.txt"
	set /a temperrorlev=%errorlevel%
	set modul=Downloading Internet Channel
	if not %temperrorlev%==0 goto error_patching

	copy "CMOCPatcher\NUS_Downloader_Decrypt.exe" "0001000148414450v1024\NUS_Downloader_Decrypt.exe"  >>"%MainFolder%\patching_output.txt"
	cd 0001000148414450v1024
	ren tmd.1024 tmd
	call NUS_Downloader_Decrypt.exe >>"%MainFolder%\patching_output.txt"
	cd ..
	move "0001000148414450v1024\*.wad" "WAD\Internet Channel (Europe) (Channel).wad" >>"%MainFolder%\patching_output.txt"
)

if %internet_channel_enable%==1 if %evcregion%==2 (
if not exist 0001000148414445v1024 md 0001000148414445v1024
copy "cert.sys" "0001000148414445v1024" >>"%MainFolder%\patching_output.txt"
curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/AdditionalChannels_Patches/InternetChannel/USA.cetk" --output "0001000148414445v1024\cetk"
	set /a temperrorlev=%errorlevel%
	set modul=Downloading Internet Channel CETK
	if not %temperrorlev%==0 goto error_patching
CMOCPatcher\pack\Sharpii.exe NUSD -id 0001000148414445 -v 1024 -wad >>"%MainFolder%\patching_output.txt"
	set /a temperrorlev=%errorlevel%
	set modul=Downloading Internet Channel
	if not %temperrorlev%==0 goto error_patching
move "0001000148414445v1024.wad" "WAD\Internet Channel (USA) (Channel).wad" >>"%MainFolder%\patching_output.txt"

)

if %internet_channel_enable%==1 if %evcregion%==3 (
if not exist 000100014841444av1024 md 000100014841444av1024
copy "cert.sys" "000100014841444av1024" >>"%MainFolder%\patching_output.txt"
curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/AdditionalChannels_Patches/InternetChannel/Japan.cetk" --output "000100014841444av1024\cetk" >>"%MainFolder%\patching_output.txt"
	set /a temperrorlev=%errorlevel%
	set modul=Downloading Internet Channel CETK
	if not %temperrorlev%==0 goto error_patching
CMOCPatcher\pack\Sharpii.exe NUSD -id 000100014841444a -v 1024 -wad >>"%MainFolder%\patching_output.txt"
	set /a temperrorlev=%errorlevel%
	set modul=Downloading Internet Channel
	if not %temperrorlev%==0 goto error_patching
move "000100014841444av1024.wad" "WAD\Internet Channel (Japan) (Channel).wad" >>"%MainFolder%\patching_output.txt"
)

if exist cetk del /q cetk
exit /b 0

:patching_fast_travel_93
set /a temperrorlev=0

if %today_and_tomorrow_enable%==1 if %evcregion%==1 (
	if not exist 0001000148415650v512 md 0001000148415650v512
	copy "cert.sys" "0001000148415650v512" >>"%MainFolder%\patching_output.txt" >>"%MainFolder%\patching_output.txt"

	curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/AdditionalChannels_Patches/TodayandTomorrowChannel/Europe.cetk" --output "0001000148415650v512\cetk" >>"%MainFolder%\patching_output.txt"
		if not exist "0001000148415650v512\cetk" set /a temperrorlev=1
		set modul=Downloading Today and Tomorrow Channel CETK
		if not %temperrorlev%==0 goto error_patching
	CMOCPatcher\dwn\Sharpii.exe NUSD -id 0001000148415650 -v 512 -encrypt >>"%MainFolder%\patching_output.txt"
		set /a temperrorlev=%errorlevel%
		set modul=Downloading Today and Tomorrow Channel
		if not %temperrorlev%==0 goto error_patching
	
	copy "CMOCPatcher\NUS_Downloader_Decrypt.exe" "0001000148415650v512\NUS_Downloader_Decrypt.exe"  >>"%MainFolder%\patching_output.txt"
	cd 0001000148415650v512
	ren tmd.512 tmd >>"%MainFolder%\patching_output.txt"
	call NUS_Downloader_Decrypt.exe >>"%MainFolder%\patching_output.txt"
	cd ..
	move "0001000148415650v512\*.wad" "WAD\Today and Tomorrow Channel (Europe) (Channel).wad" >>"%MainFolder%\patching_output.txt"
	)

if %today_and_tomorrow_enable%==1 if %evcregion%==2 (
	if not exist 0001000148415650v512 md 0001000148415650v512
	copy "cert.sys" "0001000148415650v512" >>"%MainFolder%\patching_output.txt" >>"%MainFolder%\patching_output.txt"
	curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/AdditionalChannels_Patches/TodayandTomorrowChannel/Europe.cetk" --output "0001000148415650v512\cetk" >>"%MainFolder%\patching_output.txt"
		set /a temperrorlev=%errorlevel%
		set modul=Downloading Today and Tomorrow Channel CETK
		if not %temperrorlev%==0 goto error_patching
	CMOCPatcher\dwn\Sharpii.exe NUSD -id 0001000148415650 -v 512 -encrypt >>"%MainFolder%\patching_output.txt"
		set /a temperrorlev=%errorlevel%
		set modul=Downloading Today and Tomorrow Channel
		if not %temperrorlev%==0 goto error_patching
	
	copy "CMOCPatcher\NUS_Downloader_Decrypt.exe" "0001000148415650v512\NUS_Downloader_Decrypt.exe"  >>"%MainFolder%\patching_output.txt"
	cd 0001000148415650v512
	
	del /s /q tmd.512 >>"%MainFolder%\patching_output.txt"
	curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/AdditionalChannels_Patches/TodayandTomorrowChannel/EuropeToUSA.tmd" --output "tmd" >>"%MainFolder%\patching_output.txt"
		set /a temperrorlev=%errorlevel%
		set modul=Downloading Today and Tomorrow Channel CETK
		if not %temperrorlev%==0 goto error_patching

	call NUS_Downloader_Decrypt.exe >>"%MainFolder%\patching_output.txt"
	cd ..
	move "0001000148415650v512\*.wad" "WAD\Today and Tomorrow Channel (USA) (Channel).wad" >>"%MainFolder%\patching_output.txt"
	)



if %today_and_tomorrow_enable%==1 if %evcregion%==3 (
	if not exist 000100014841564av512 md 000100014841564av512
	copy "cert.sys" "000100014841564av512" >>"%MainFolder%\patching_output.txt" >>"%MainFolder%\patching_output.txt"
	curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/AdditionalChannels_Patches/TodayandTomorrowChannel/Japan.cetk" --output "000100014841564av512\cetk" >>"%MainFolder%\patching_output.txt"
		set /a temperrorlev=%errorlevel%
		set modul=Downloading Today and Tomorrow Channel CETK
		if not %temperrorlev%==0 goto error_patching
	CMOCPatcher\dwn\Sharpii.exe NUSD -id 000100014841564a -v 512 -encrypt >>"%MainFolder%\patching_output.txt"
		set /a temperrorlev=%errorlevel%
		set modul=Downloading Today and Tomorrow Channel
		if not %temperrorlev%==0 goto error_patching
	
	copy "CMOCPatcher\NUS_Downloader_Decrypt.exe" "000100014841564av512\NUS_Downloader_Decrypt.exe" >>"%MainFolder%\patching_output.txt" 
	cd 000100014841564av512
	ren tmd.512 tmd >>"%MainFolder%\patching_output.txt"
	call NUS_Downloader_Decrypt.exe >>"%MainFolder%\patching_output.txt"
	cd ..
	move "000100014841564av512\*.wad" "WAD\Today and Tomorrow Channel (Japan) (Channel).wad" >>"%MainFolder%\patching_output.txt"
	)

if %today_and_tomorrow_enable%==1 if %evcregion%==4 (
	if not exist 000100014841564bv512 md 000100014841564bv512
	copy "cert.sys" "000100014841564bv512" >>"%MainFolder%\patching_output.txt" >>"%MainFolder%\patching_output.txt"
	curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/AdditionalChannels_Patches/TodayandTomorrowChannel/Korea.cetk" --output "000100014841564bv512\cetk" >>"%MainFolder%\patching_output.txt"
		set /a temperrorlev=%errorlevel%
		set modul=Downloading Today and Tomorrow Channel CETK
		if not %temperrorlev%==0 goto error_patching
	CMOCPatcher\dwn\Sharpii.exe NUSD -id 000100014841564b -v 512 -encrypt >>"%MainFolder%\patching_output.txt"
		set /a temperrorlev=%errorlevel%
		set modul=Downloading Today and Tomorrow Channel
		if not %temperrorlev%==0 goto error_patching
	
	copy "CMOCPatcher\NUS_Downloader_Decrypt.exe" "000100014841564bv512\NUS_Downloader_Decrypt.exe"  >>"%MainFolder%\patching_output.txt"
	cd 000100014841564bv512
	ren tmd.512 tmd >>"%MainFolder%\patching_output.txt"
	call NUS_Downloader_Decrypt.exe >>"%MainFolder%\patching_output.txt"
	cd ..
	move "000100014841564bv512\*.wad" "WAD\Today and Tomorrow Channel (Korea) (Channel).wad" >>"%MainFolder%\patching_output.txt"
	)

if exist cetk del /q cetk

exit /b 0

:patching_fast_travel_95
	
if %photo_channel_enable%==1 if not exist 0001000248414141v2 md 0001000248414141v2
if %photo_channel_enable%==1 copy "cert.sys" "0001000248414141v2" >>"%MainFolder%\patching_output.txt"
if %photo_channel_enable%==1 curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/AdditionalChannels_Patches/PhotoChannel/1.0.cetk" --output "0001000248414141v2\cetk" >>"%MainFolder%\patching_output.txt"
	if %photo_channel_enable%==1 set /a temperrorlev=%errorlevel%
	if %photo_channel_enable%==1 set modul=Downloading Photo Channel 1.0 CETK
	if %photo_channel_enable%==1 if not %temperrorlev%==0 goto error_patching
if %photo_channel_enable%==1 CMOCPatcher\pack\Sharpii.exe NUSD -id 0001000248414141 -v 2 -wad >>"%MainFolder%\patching_output.txt"
	if %photo_channel_enable%==1 set /a temperrorlev=%errorlevel%
	if %photo_channel_enable%==1 set modul=Downloading Photo Channel
	if %photo_channel_enable%==1 if not %temperrorlev%==0 goto error_patching
if %photo_channel_enable%==1 move "0001000248414141v2.wad" "WAD\Photo Channel 1.0 (Channel).wad" >>"%MainFolder%\patching_output.txt"
if exist cetk del /q cetk

if %photo_channel_enable%==1 if not exist 0001000248415941v3 md 0001000248415941v3
if %photo_channel_enable%==1 copy "cert.sys" "0001000248415941v3" >>"%MainFolder%\patching_output.txt"
if %photo_channel_enable%==1 curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/AdditionalChannels_Patches/PhotoChannel/1.1.cetk" --output "0001000248415941v3\cetk" >>"%MainFolder%\patching_output.txt"
	if %photo_channel_enable%==1 set /a temperrorlev=%errorlevel%
	if %photo_channel_enable%==1 set modul=Downloading Photo Channel 1.1 CETK
	if %photo_channel_enable%==1 if not %temperrorlev%==0 goto error_patching
if %photo_channel_enable%==1 CMOCPatcher\pack\Sharpii.exe NUSD -id 0001000248415941 -v 3 -wad >>"%MainFolder%\patching_output.txt"
	if %photo_channel_enable%==1 set /a temperrorlev=%errorlevel%
	if %photo_channel_enable%==1 set modul=Downloading Photo Channel
	if %photo_channel_enable%==1 if not %temperrorlev%==0 goto error_patching

if %photo_channel_enable%==1 move "0001000248415941v3.wad" "WAD\Photo Channel 1.1 (Update).wad" >>"%MainFolder%\patching_output.txt"

exit /b 0
:patching_fast_travel_97


if %wii_speak_channel_enable%==1 if not exist WiiWarePatcher md WiiWarePatcher
if %wii_speak_channel_enable%==1 curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/WiiWarePatcher/libWiiSharp.dll" --output "WiiWarePatcher\libWiiSharp.dll"
	if %wii_speak_channel_enable%==1 set /a temperrorlev=%errorlevel%
	if %wii_speak_channel_enable%==1 set modul=Downloading executables for WiiWarePatcher
	if %wii_speak_channel_enable%==1 if not %temperrorlev%==0 goto error_patching

if %wii_speak_channel_enable%==1 curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/WiiWarePatcher/lzx.exe" --output "WiiWarePatcher\lzx.exe"
	if %wii_speak_channel_enable%==1 set /a temperrorlev=%errorlevel%
	if %wii_speak_channel_enable%==1 set modul=Downloading executables for WiiWarePatcher
	if %wii_speak_channel_enable%==1 if not %temperrorlev%==0 goto error_patching
if %wii_speak_channel_enable%==1 curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/WiiWarePatcher/Sharpii.exe" --output "WiiWarePatcher\Sharpii.exe"
	if %wii_speak_channel_enable%==1 set /a temperrorlev=%errorlevel%
	if %wii_speak_channel_enable%==1 set modul=Downloading executables for WiiWarePatcher
	if %wii_speak_channel_enable%==1 if not %temperrorlev%==0 goto error_patching
if %wii_speak_channel_enable%==1 curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/WiiWarePatcher/WadInstaller.dll" --output "WiiWarePatcher\WadInstaller.dll"
	if %wii_speak_channel_enable%==1 set /a temperrorlev=%errorlevel%
	if %wii_speak_channel_enable%==1 set modul=Downloading executables for WiiWarePatcher
	if %wii_speak_channel_enable%==1 if not %temperrorlev%==0 goto error_patching
if %wii_speak_channel_enable%==1 curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/WiiWarePatcher/WiiWarePatcher.exe" --output "WiiWarePatcher\WiiWarePatcher.exe"
	if %wii_speak_channel_enable%==1 set /a temperrorlev=%errorlevel%
	if %wii_speak_channel_enable%==1 set modul=Downloading executables for WiiWarePatcher
	if %wii_speak_channel_enable%==1 if not %temperrorlev%==0 goto error_patching
if %wii_speak_channel_enable%==1 if %evcregion%==1 WiiWarePatcher\Sharpii.exe NUSD -ID 0001000148434650 -v 512 -all >>"%MainFolder%\patching_output.txt"
	if %wii_speak_channel_enable%==1 if %evcregion%==1 set /a temperrorlev=%errorlevel%
	if %wii_speak_channel_enable%==1 if %evcregion%==1 set modul=Downloading Wii Speak Channel
	if %wii_speak_channel_enable%==1 if %evcregion%==1 if not %temperrorlev%==0 goto error_patching
if %wii_speak_channel_enable%==1 if %evcregion%==2 WiiWarePatcher\Sharpii.exe NUSD -ID 0001000148434645 -v 512 -all >>"%MainFolder%\patching_output.txt"
	if %wii_speak_channel_enable%==1 if %evcregion%==2 set /a temperrorlev=%errorlevel%
	if %wii_speak_channel_enable%==1 if %evcregion%==2 set modul=Downloading Wii Speak Channel
	if %wii_speak_channel_enable%==1 if %evcregion%==2 if not %temperrorlev%==0 goto error_patching
if %wii_speak_channel_enable%==1 if %evcregion%==3 WiiWarePatcher\Sharpii.exe NUSD -ID 000100014843464a -v 512 -all >>"%MainFolder%\patching_output.txt"
	if %wii_speak_channel_enable%==1 if %evcregion%==3 set /a temperrorlev=%errorlevel%
	if %wii_speak_channel_enable%==1 if %evcregion%==3 set modul=Downloading Wii Speak Channel
	if %wii_speak_channel_enable%==1 if %evcregion%==3 if not %temperrorlev%==0 goto error_patching

if %wii_speak_channel_enable%==1 if %evcregion%==4 WiiWarePatcher\Sharpii.exe NUSD -ID 000100014843464b -v 512 -all >>"%MainFolder%\patching_output.txt"
	if %wii_speak_channel_enable%==1 if %evcregion%==4 set /a temperrorlev=%errorlevel%
	if %wii_speak_channel_enable%==1 if %evcregion%==4 set modul=Downloading Wii Speak Channel
	if %wii_speak_channel_enable%==1 if %evcregion%==4 if not %temperrorlev%==0 goto error_patching

if %wii_speak_channel_enable%==1 if %evcregion%==1 move "0001000148434650v512\*.wad" "Wii Speak Channel.wad" >>"%MainFolder%\patching_output.txt"
if %wii_speak_channel_enable%==1 if %evcregion%==2 move "0001000148434645v512\*.wad" "Wii Speak Channel.wad" >>"%MainFolder%\patching_output.txt"
if %wii_speak_channel_enable%==1 if %evcregion%==3 move "000100014843464av512\*.wad" "Wii Speak Channel.wad" >>"%MainFolder%\patching_output.txt"
if %wii_speak_channel_enable%==1 if %evcregion%==4 move "000100014843464bv512\*.wad" "Wii Speak Channel.wad" >>"%MainFolder%\patching_output.txt"

if %wii_speak_channel_enable%==1 WiiWarePatcher\Sharpii.exe WAD -u "Wii Speak Channel.wad" temp >>"%MainFolder%\patching_output.txt"
	if %wii_speak_channel_enable%==1 set /a temperrorlev=%errorlevel%
	if %wii_speak_channel_enable%==1 set modul=Unpacking Wii Speak Channel
	if %wii_speak_channel_enable%==1 if not %temperrorlev%==0 goto error_patching
	
if %wii_speak_channel_enable%==1 move "temp\00000001.app" "WiiWarePatcher\00000001.app" >>"%MainFolder%\patching_output.txt"
if %wii_speak_channel_enable%==1 cd WiiWarePatcher
if %wii_speak_channel_enable%==1 call WiiWarePatcher.exe >>"%MainFolder%\patching_output.txt"
if %wii_speak_channel_enable%==1 cd ..
if %wii_speak_channel_enable%==1 move "WiiWarePatcher\00000001.app" "temp\00000001.app" >>"%MainFolder%\patching_output.txt"
if %wii_speak_channel_enable%==1 del /q "Wii Speak Channel.wad"  >>"%MainFolder%\patching_output.txt"
if %wii_speak_channel_enable%==1 if %evcregion%==1 WiiWarePatcher\Sharpii.exe WAD -p temp "WAD\Wii Speak Channel (Europe) (Channel) (Wiimmfi).wad"  >>"%MainFolder%\patching_output.txt"
if %wii_speak_channel_enable%==1 if %evcregion%==1 if %wii_speak_channel_enable%==1 set /a temperrorlev=%errorlevel%
if %wii_speak_channel_enable%==1 if %evcregion%==1 set modul=Packing Wii Speak Channel
if %wii_speak_channel_enable%==1 if %evcregion%==1 if not %temperrorlev%==0 goto error_patching


if %wii_speak_channel_enable%==1 if %evcregion%==2 WiiWarePatcher\Sharpii.exe WAD -p temp "WAD\Wii Speak Channel (USA) (Channel (Wiimmfi).wad"  >>"%MainFolder%\patching_output.txt"
if %wii_speak_channel_enable%==1 if %evcregion%==2 if %wii_speak_channel_enable%==1 set /a temperrorlev=%errorlevel%
if %wii_speak_channel_enable%==1 if %evcregion%==2 set modul=Packing Wii Speak Channel
if %wii_speak_channel_enable%==1 if %evcregion%==2 if not %temperrorlev%==0 goto error_patching
	
if %wii_speak_channel_enable%==1 if %evcregion%==3 WiiWarePatcher\Sharpii.exe WAD -p temp "WAD\Wii Speak Channel (Japan) (Channel) (Wiimmfi).wad"  >>"%MainFolder%\patching_output.txt"
if %wii_speak_channel_enable%==1 if %evcregion%==3 if %wii_speak_channel_enable%==1 set /a temperrorlev=%errorlevel%
if %wii_speak_channel_enable%==1 if %evcregion%==3 set modul=Packing Wii Speak Channel
if %wii_speak_channel_enable%==1 if %evcregion%==3 if not %temperrorlev%==0 goto error_patching
	
if %wii_speak_channel_enable%==1 if %evcregion%==4 WiiWarePatcher\Sharpii.exe WAD -p temp "WAD\Wii Speak Channel (Korea) (Channel) (Wiimmfi).wad" >>"%MainFolder%\patching_output.txt"
if %wii_speak_channel_enable%==1 if %evcregion%==4 if %wii_speak_channel_enable%==1 set /a temperrorlev=%errorlevel%
if %wii_speak_channel_enable%==1 if %evcregion%==4 set modul=Packing Wii Speak Channel
if %wii_speak_channel_enable%==1 if %evcregion%==4 if not %temperrorlev%==0 goto error_patching

if %wii_speak_channel_enable%==1 rmdir temp /s /q >>"%MainFolder%\patching_output.txt"

exit /b 0

:patching_fast_travel_98
::Final commands
if not %sdcard%==NUL set /a errorcopying=0
if not %sdcard%==NUL if not exist "%sdcard%:\WAD" md "%sdcard%:\WAD" 
if not %sdcard%==NUL if not exist "%sdcard%:\apps" md "%sdcard%:\apps"
exit /b 0

:patching_fast_travel_99
echo.&echo %string470%
if not %sdcard%==NUL xcopy /I /y "WAD" "%sdcard%:\WAD" /e || set /a errorcopying=1
if not %sdcard%==NUL xcopy /I /y "apps" "%sdcard%:\apps" /e|| set /a errorcopying=1

set /a progress_finishing=1
call :clean_temp_files

exit /b 0

:clean_temp_files
if exist 0001000148415045v512 rmdir /s /q 0001000148415045v512
if exist 0001000148415050v512 rmdir /s /q 0001000148415050v512
if exist 000100014841504Av512 rmdir /s /q 000100014841504Av512

if exist 0001000148414A45v512 rmdir /s /q 0001000148414A45v512
if exist 0001000148414A50v512 rmdir /s /q 0001000148414A50v512
if exist 0001000148414A4Av512 rmdir /s /q 0001000148414A4Av512
if exist 000100014841564av512 rmdir /s /q 000100014841564av512


if exist 0001000148415450v1792 rmdir /s /q 0001000148415450v1792
if exist 0001000148415445v1792 rmdir /s /q 0001000148415445v1792
if exist 000100014841544Av1792 rmdir /s /q 000100014841544Av1792

if exist 0001000148414450v1024 rmdir /s /q 0001000148414450v1024
if exist 0001000148415650v512 rmdir /s /q 0001000148415650v512
if exist 0001000248414141v2 rmdir /s /q 0001000248414141v2
if exist 0001000248415941v3 rmdir /s /q 0001000248415941v3
if exist 0001000248415941v65280 rmdir /s /q 0001000248415941v65280

if exist 000100014841444av1024 rmdir /s /q 000100014841444av1024
if exist 000100014841564bv512 rmdir /s /q 000100014841564bv512
if exist 000100014843464av512 rmdir /s /q 000100014843464av512
if exist 000100014843464bv512 rmdir /s /q 000100014843464bv512
if exist 0001000148414445v1024 rmdir /s /q 0001000148414445v1024
if exist 0001000148434645v512 rmdir /s /q 0001000148434645v512

if exist 0001000148434650v512 rmdir /s /q 0001000148434650v512

if exist unpacked-temp rmdir /s /q unpacked-temp
if exist IOSPatcher rmdir /s /q IOSPatcher
if exist EVCPatcher rmdir /s /q EVCPatcher
if exist NCPatcher rmdir /s /q NCPatcher
if exist CMOCPatcher rmdir /s /q CMOCPatcher
if exist WiiWarePatcher rmdir /s /q WiiWarePatcher
if exist NewsChannelPatcher rmdir /s /q NewsChannelPatcher
if exist source.app del /q source.app
if exist cert.sys del /q cert.sys
if exist 00000001.app del /q 00000001.app
if exist libWiiSharp.dll del /q libWiiSharp.dll
if exist 0001000248414650v7.wad del /q 0001000248414650v7.wad
if exist 0001000248414645v7.wad del /q 0001000248414645v7.wad
if exist 0001000248414750v7.wad del /q 0001000248414750v7.wad
if exist 0001000248414745v7.wad del /q 0001000248414745v7.wad
if exist 000100024841464Av7.wad del /q 000100024841464Av7.wad
if exist 000100024841474Av7.wad del /q 000100024841474Av7.wad
if exist 00000004.app del /q 00000004.app
if exist 00000001_NC.app del /q 00000001_NC.app


exit /b 0

:2_4_dolphin
cls
set sound_play=info2&call :sound_play
echo %header%
echo ---------------------------------------------------------------------------------------------------------------------------
echo %string268%
echo.
echo %string591%
echo.
echo %string188%
echo.
echo 1. %string189%
echo 2. %string190%
echo 3. %string506%
echo.
set /p s=%string26%: 
if %s%==1 set sound_play=exit1&call :sound_play&goto script_start
if %s%==2 set sound_play=exit1&call :sound_play&goto end
if %s%==3 set sound_play=confirm1&call :sound_play&goto feedback_respond
goto 2_4_dolphin



:2_4
cls
set sound_play=info2&call :sound_play
echo %header%
echo ---------------------------------------------------------------------------------------------------------------------------
echo %string268%
echo.
if %sdcardstatus%==0 echo %string471%
if %sdcardstatus%==1 if %sdcard%==NUL echo %string471%

if %sdcardstatus%==1 if not %sdcard%==NUL if %errorcopying%==0 echo %string472%
if %sdcardstatus%==1 if not %sdcard%==NUL if %errorcopying%==1 echo %string473%
echo.
echo %string474%
echo.
echo %string188%
echo.
echo 1. %string189%
echo 2. %string190%
echo 3. %string506%
if %preboot_environment%==1 echo 4. %string489%
echo.
set /p s=%string26%: 
if %s%==1 set sound_play=exit1&call :sound_play&goto script_start
if %s%==2 set sound_play=exit1&call :sound_play&goto end
if %s%==3 set sound_play=confirm1&call :sound_play&goto feedback_respond
if %preboot_environment%==1 if %s%==3 "X:\TOTALCMD.exe"
goto 2_4

:feedback_respond
cls
echo %header%
echo ---------------------------------------------------------------------------------------------------------------------------
echo.
echo %string507%
echo.
echo %string508%
echo.
echo 1. %string509%
echo 2. %string510%
echo 3. %string511%
echo 4. %string512%
echo 5. %string513%
echo.
set /p report1=%string26%: 
set sound_play=select3&call :sound_play
if %report1%==1 goto feedback_respond2
if %report1%==2 goto feedback_respond2
if %report1%==3 goto feedback_respond2
if %report1%==4 goto feedback_respond2
if %report1%==5 goto feedback_respond2
goto feedback_respond
:feedback_respond2
cls
echo %header%
echo ---------------------------------------------------------------------------------------------------------------------------
echo.
echo %string507%
echo.
echo %string514%
echo.
echo 1. %string515%
echo 2. %string516%
echo 3. %string517%
echo 4. %string518%
echo 5. %string519%
echo 6. %string520%
echo.
set /p report2=%string26%: 
set sound_play=select3&call :sound_play
if %report2%==1 goto feedback_respond2
if %report2%==2 goto feedback_respond2
if %report2%==3 goto feedback_respond2
if %report2%==4 goto feedback_respond2
if %report2%==5 goto feedback_respond2
if %report2%==6 goto feedback_respond2
goto feedback_respond2
:feedback_respond2
cls
echo %header%
echo ---------------------------------------------------------------------------------------------------------------------------
echo.
echo %string507%
echo.
echo %string521%
echo.
echo 1. %string522%
echo 2. %string523%
echo 3. %string61%.
echo.
set /p report3=%string26%: 
set sound_play=select3&call :sound_play
if %report3%==1 goto feedback_respond3
if %report3%==2 goto feedback_respond3
if %report3%==3 goto feedback_respond3
goto feedback_respond2
:feedback_respond3
cls
echo %header%
echo ---------------------------------------------------------------------------------------------------------------------------
echo.
echo %string507%
echo.
echo %string524%
echo.
echo 1. %string498%
echo 2. %string525%

set /p message_confirm=%string26%: 
if %message_confirm%==1 set sound_play=confirm1&call :sound_play&goto feedback_respond_write_message
if %message_confirm%==2 set sound_play=exit1&call :sound_play&goto feedback_send
goto feedback_respond3

:feedback_respond_write_message
cls
echo %header%
echo ---------------------------------------------------------------------------------------------------------------------------
echo.
echo %string526%
echo %string527%
echo.
set /p message_content=^>
set sound_play=confirm1&call :sound_play
goto feedback_respond_write_message_confirm
:feedback_respond_write_message_confirm
cls
echo %header%
echo ---------------------------------------------------------------------------------------------------------------------------
echo.
echo %string528%
echo %message_content%
echo.
echo %string529%
echo.
echo 1. %string61%
echo 2. %string62%
set /p s=%string26%: 
if "%s%"=="1" set sound_play=confirm1&call :sound_play&goto feedback_send 
if "%s%"=="2" set sound_play=confirm1&call :sound_play&goto feedback_respond3
goto feedback_respond_write_message_confirm

:feedback_send
cls
echo %header%
echo ---------------------------------------------------------------------------------------------------------------------------
echo.
echo %string530%

	call :check_rc24_server_connection
	if "%errorlevel%"=="1" goto server_connection_lost


>"%MainFolder%\error_report.txt" echo RiiConnect24 Patcher v%version%
>>"%MainFolder%\error_report.txt" echo.
>>"%MainFolder%\error_report.txt" echo Patching successful, sending feedback.
>>"%MainFolder%\error_report.txt" echo.
>>"%MainFolder%\error_report.txt" echo Date: %date%
>>"%MainFolder%\error_report.txt" echo Time: %time:~0,5%
>>"%MainFolder%\error_report.txt" echo.
>>"%MainFolder%\error_report.txt" echo Windows version: %windows_version%
>>"%MainFolder%\error_report.txt" echo Windows language: %OSLanguage%
>>"%MainFolder%\error_report.txt" echo Language: %language%
>>"%MainFolder%\error_report.txt" echo Processor architecture: %processor_architecture%
>>"%MainFolder%\error_report.txt" echo Device: %device%
>>"%MainFolder%\error_report.txt" echo.
if "%report1%"=="1" >>"%MainFolder%\error_report.txt" echo Which one best fits the app: The app is bad
if "%report1%"=="2" >>"%MainFolder%\error_report.txt" echo Which one best fits the app: I encountered a lot of issues when patching
if "%report1%"=="3" >>"%MainFolder%\error_report.txt" echo Which one best fits the app: Not intuitive
if "%report1%"=="4" >>"%MainFolder%\error_report.txt" echo Which one best fits the app: It's alright
if "%report1%"=="5" >>"%MainFolder%\error_report.txt" echo Which one best fits the app: The app is really easy to use
if "%report2%"=="1" >>"%MainFolder%\error_report.txt" echo How did you find out about RC24: I've heard about it from my friend
if "%report2%"=="2" >>"%MainFolder%\error_report.txt" echo How did you find out about RC24: I've heard about it on Discord
if "%report2%"=="3" >>"%MainFolder%\error_report.txt" echo How did you find out about RC24: YouTube
if "%report2%"=="4" >>"%MainFolder%\error_report.txt" echo How did you find out about RC24: wii.guide
if "%report2%"=="5" >>"%MainFolder%\error_report.txt" echo How did you find out about RC24: I found out about it on Google
if "%report2%"=="6" >>"%MainFolder%\error_report.txt" echo How did you find out about RC24: Other
if "%report3%"=="1" >>"%MainFolder%\error_report.txt" echo Ever used another features: No, I don't plan to
if "%report3%"=="2" >>"%MainFolder%\error_report.txt" echo Ever used another features: No, I plan to
if "%report3%"=="3" >>"%MainFolder%\error_report.txt" echo Ever used another features: Yes
>>"%MainFolder%\error_report.txt" echo.
if "%message_confirm%"=="1" >>"%MainFolder%\error_report.txt" echo Message: %message_content%

set /a post_send_success=0



	if "%message_confirm%"=="2" call curl -s %useragent% --insecure -F "report=@%MainFolder%\error_report.txt" %post_url%?user=%random_identifier%_feedback>NUL

	if "%message_confirm%"=="1" call curl -s %useragent% --insecure -F "report=@%MainFolder%\error_report.txt" %post_url%?user=%random_identifier%_feedback_message>NUL

set sound_play=info2&call :sound_play

echo %string585%
%timeout_path% 5 /nobreak>NUL

goto end
:end
set /a exiting=10
set /a timeouterror=1
%timeout_path% 1 /nobreak >NUL && set /a timeouterror=0
goto end1
:end1
setlocal disableDelayedExpansion
cls
echo %header%
echo ---------------------------------------------------------------------------------------------------------------------------
echo  [*] %string475%
echo.
if %exitmessage%==1 echo %string476%
echo %string477%
echo.
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
if %timeouterror%==0 %timeout_path% 1 /nobreak >NUL
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
set sound_play=warning3&call :sound_play
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
echo    /---\   %string73%
echo   /     \  %string478%
echo  /   ^!   \ 
echo  --------- %string479% 
echo            %string480%
echo.
echo       %string90%
echo ---------------------------------------------------------------------------------------------------------------------------
pause>NUL
goto begin_main

:error_patching
:: Check RC24 connection before displaying error

call :check_rc24_server_connection
if "%errorlevel%"=="1" goto server_connection_lost

if "%temperrorlev%"=="6" goto no_internet_connection
if "%temperrorlev%"=="7" goto no_internet_connection
::if "%modul%"=="Decrypter error" if "%processor_architecture%"=="AMD64" if "%temperrorlev%"=="-1" goto install_vc_plus_plus_redist
if "%modul%"=="Renaming files [Delete everything except RiiConnect24Patcher.bat]" goto troubleshooting_auto_tool
if "%percent%"=="1" goto troubleshooting_auto_tool
cls
set sound_play=warning3&call :sound_play
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
echo    /---\   %string73%
echo   /     \  %string481%
echo  /   ^!   \ 
echo  --------- %string482%: %temperrorlev%
echo            %string483%: %modul% / %percent% / %random_identifier%
echo.
echo %string484%
if %temperrorlev%==-532459699 echo %string485%
if %temperrorlev%==23 echo %string486%
if %temperrorlev%==-2146232576 echo %string487%  
echo       %string90%
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
echo %string502%
if not "%wiiware_patching%"=="1" (
	>"%MainFolder%\error_report.txt" echo RiiConnect24 Patcher v%version%
	>>"%MainFolder%\error_report.txt" echo.
	>>"%MainFolder%\error_report.txt" echo Install RiiConnect24 Patcher
	>>"%MainFolder%\error_report.txt" echo.
	>>"%MainFolder%\error_report.txt" echo Date: %date%
	>>"%MainFolder%\error_report.txt" echo Time: %time:~0,5%
	>>"%MainFolder%\error_report.txt" echo.
	>>"%MainFolder%\error_report.txt" echo Windows version: %windows_version%
	>>"%MainFolder%\error_report.txt" echo Language: %language%
	>>"%MainFolder%\error_report.txt" echo Processor architecture: %processor_architecture%
	>>"%MainFolder%\error_report.txt" echo Device: %device%
	>>"%MainFolder%\error_report.txt" echo.
	>>"%MainFolder%\error_report.txt" echo Action: Patching
	>>"%MainFolder%\error_report.txt" echo Region: %evcregion%
	>>"%MainFolder%\error_report.txt" echo Module: %modul%
	>>"%MainFolder%\error_report.txt" echo Progress: %percent%%
	>>"%MainFolder%\error_report.txt" echo Exit code: %temperrorlev%
	>>"%MainFolder%\error_report.txt" echo.
	>>"%MainFolder%\error_report.txt" echo Attaching output:
	>>"%MainFolder%\error_report.txt" type "%MainFolder%\patching_output.txt"
	curl -s %useragent% --insecure -F "report=@%MainFolder%\error_report.txt" %post_url%?user=%random_identifier%
	echo %string503%
	pause>NUL
	goto begin_main
	
	)

if "%wiiware_patching%"=="1" (
	>"%MainFolder%\error_report.txt" echo RiiConnect24 Patcher v%version%
	>>"%MainFolder%\error_report.txt" echo.
	>>"%MainFolder%\error_report.txt" echo WiiWare Patcher
	>>"%MainFolder%\error_report.txt" echo.
	>>"%MainFolder%\error_report.txt" echo Date: %date%
	>>"%MainFolder%\error_report.txt" echo Time: %time:~0,5%
	>>"%MainFolder%\error_report.txt" echo.
	>>"%MainFolder%\error_report.txt" echo Windows version: %windows_version%
	>>"%MainFolder%\error_report.txt" echo Language: %language%
	>>"%MainFolder%\error_report.txt" echo Processor architecture: %processor_architecture%
	>>"%MainFolder%\error_report.txt" echo Device: %device%
	>>"%MainFolder%\error_report.txt" echo.
	>>"%MainFolder%\error_report.txt" echo Action: Patching for Wiimmfi usage
	>>"%MainFolder%\error_report.txt" echo Module: %modul%
	>>"%MainFolder%\error_report.txt" echo Exit code: %temperrorlev%
	curl -s %useragent% --insecure -F "report=@%MainFolder%\error_report.txt" %post_url%?user=%random_identifier%
	echo %string503%
	pause>NUL
	goto begin_main
	)

goto begin_main

:install_vc_plus_plus_redist
cls
echo %header%
echo ---------------------------------------------------------------------------------------------------------------------------
echo.
echo %string494%
echo %string495%
echo.
echo %string496%
echo.
echo %string497%
echo.
echo 1. %string498% (%string499%)
echo 2. %string500%
echo.
set /p s=%string26%:
if %s%==1 set sound_play=confirm1&call :sound_play&goto install_vc_plus_plus_redist_2
if %s%==2 set sound_play=exit1&call :sound_play&goto begin_main

goto install_vc_plus_plus_redist

:install_vc_plus_plus_redist_2
cls
echo %header%
echo ---------------------------------------------------------------------------------------------------------------------------
echo.
echo %string87%
echo %string501%...
curl -f -L -s -S %useragent% --insecure "%FilesHostedOn%/VC_redist.x64.exe" --output VC_redist.x64.exe

"VC_redist.x64.exe" /install /passive /norestart>NUL

del /q "VC_redist.x64.exe"


goto 2_2

:: The end - what did you expect? Join our Discord server! https://discord.gg/b4Y7jfD 
:: Find me as KcrPL#4625 ;)
