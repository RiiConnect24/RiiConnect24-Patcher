#!/usr/bin/env bash

# RiiConnect24 Patcher for Unix v1.2.1
#
# Copyright (C) 2024  Sketch, HTV04, and TheShadowEevee
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

# Print with word wrap
print () {
	printf "${1}" | fold -s -w $(tput cols)
}

# Print string and wait for input to store in variable
input () {
	print "${1}"
	read -r ${2}
}

# Prints "Press any key to " + string given, and then a period, then wait for a key to be pressed
anykey () {
	print "Press any key to ${1}."
	read -n 1 -r
}

# Print title
title () {
	print "${rc24_str}====${1}"
	printf "=%.0s" $(seq 1 $(($(tput cols) - (${#1} + 4))))
	print "\n\n"
}

# Print subtitle
subtitle () {
	print "\055---${1}"
	printf "\055%.0s" $(seq 1 $(($(tput cols) - (${#1} + 4))))
	print "\n${2}\n"
	printf "\055%.0s" $(seq 1 $(tput cols))
	print "\n\n"
}



# Get file from SketchMaster2001's website
sketchget () {
	curl --create-dirs -f -k -L -o "${2}" -S -s --user-agent "RiiConnect24 Patcher Unix ${ver}" --insecure https://patcher.rc24.xyz/update/RiiConnect24-Patcher_Unix/v1/${1}
}

# Get file from RiiConnect24 website and save it to output
rc24get () {
	curl --create-dirs -f -k -L -o "${2}" -S -s --user-agent "RiiConnect24 Patcher Unix ${ver}" --insecure https://patcher.rc24.xyz/update/RiiConnect24-Patcher/v1/${1}
}



# Get cetk file from SketchMaster2001's website
sketchgetcetk () {
	sketchget ${1}/${2}/cetk Temp/Files/Patcher/${1}/${2}/cetk
}



# Patch IOS
patchios () {
	mkdir -p Temp/Working/Wii/IOS${1}

	./Sharpii nusd -ios ${1} -v ${2} -o Temp/Working/Wii/IOS${1}/Temp.wad -wad -q
	./Sharpii wad -u Temp/Working/Wii/IOS${1}/Temp.wad Temp/Working/Wii/IOS${1} -q

	xdelta3 -d -f -s Temp/Working/Wii/IOS${1}/00000006.app Temp/Files/Patcher/Wii/IOS${1}/00000006.delta Temp/Working/Wii/IOS${1}/00000006_patched.app

	mv -f Temp/Working/Wii/IOS${1}/00000006_patched.app Temp/Working/Wii/IOS${1}/00000006.app

	./Sharpii wad -p Temp/Working/Wii/IOS${1} "${out_path}/WAD/IOS${1} (RiiConnect24).wad" -f -q

	./Sharpii ios "${out_path}/WAD/IOS${1} (RiiConnect24).wad" -fs -es -np -vp -q
}

# Patch title
patchtitle () {
	mkdir -p Temp/Working/${1}
	if [ -f Temp/Files/Patcher/${1}/${region}/cetk ]
	then
		cp Temp/Files/Patcher/${1}/${region}/cetk Temp/Working/${1}
	fi

	./Sharpii nusd -id ${2}${region_hex} -v ${3} -o Temp/Working/${1} -wad -q
	./Sharpii wad -u Temp/Working/${1}/${2}${region_hex}v${3}.wad Temp/Working/${1} -q

	xdelta3 -d -f -s Temp/Working/${1}/${4}.app Temp/Files/Patcher/${1}/${region}/${4}.delta Temp/Working/${1}/${4}_patched.app

	mv -f Temp/Working/${1}/${4}_patched.app Temp/Working/${1}/${4}.app

	./Sharpii wad -p Temp/Working/${1} "${out_path}/WAD/${5} (${region}) (RiiConnect24).wad" -f -q
}

# Patch title with two patch files
patchtitle2 () {
	mkdir -p Temp/Working/${1}
	if [ -f Temp/Files/Patcher/${1}/${region}/cetk ]
	then
		cp Temp/Files/Patcher/${1}/${region}/cetk Temp/Working/${1}
	fi

	./Sharpii nusd -id ${2}${region_hex} -v ${3} -o Temp/Working/${1} -wad -q
	./Sharpii wad -u Temp/Working/${1}/${2}${region_hex}v${3}.wad Temp/Working/${1} -q

	xdelta3 -d -f -s Temp/Working/${1}/${4}.app Temp/Files/Patcher/${1}/${region}/${4}.delta Temp/Working/${1}/${4}_patched.app
	xdelta3 -d -f -s Temp/Working/${1}/${5}.app Temp/Files/Patcher/${1}/${region}/${5}.delta Temp/Working/${1}/${5}_patched.app

	mv -f Temp/Working/${1}/${4}_patched.app Temp/Working/${1}/${4}.app
	mv -f Temp/Working/${1}/${5}_patched.app Temp/Working/${1}/${5}.app

	./Sharpii wad -p Temp/Working/${1} "${out_path}/WAD/${6} (${region}) (RiiConnect24).wad" -f -q
}

# Patch title with vWii attributes
patchtitlevwii () {
	mkdir -p Temp/Working/${1}

	./Sharpii nusd -id ${2}${region_hex} -v ${3} -o Temp/Working/${1} -wad -q
	./Sharpii wad -u Temp/Working/${1}/${2}${region_hex}v${3}.wad Temp/Working/${1} -q

	xdelta3 -d -f -s Temp/Working/${1}/${4}.app Temp/Files/Patcher/${1}/${4}.delta Temp/Working/${1}/${4}_patched.app

	mv -f Temp/Working/${1}/${4}_patched.app Temp/Working/${1}/${4}.app

	./Sharpii wad -p Temp/Working/${1} "${out_path}/WAD/${5} vWii ${region} (RiiConnect24).wad" -f -q
}

patchwiiware() {
	while true
	do
		clear
		title "Preparing to patch a WiiWare Game"

		print "You will now be taken to the Wiimmfi WiiWare Patcher. Make sure the WAD is in the \"rc24-data\" directory.\n\n1. Start Patching\n2. Back\n\n"

		input "Choose: " choice

		case ${choice} in
			1)
				sketchget "Wiimmfi-stuff/wiiwarepatcher.sh" "wiiwarepatcher.sh"
				chmod +x wiiwarepatcher.sh
				./wiiwarepatcher.sh

				break
				;;
			2)
				break
				;;
		esac
	done
}

patchgameprep() {
	while true
	do

		clear
		title "Preparing to Patch a Wii Game"

		print "This section will patch any Wii Game that is not a WiiWare Game. Make sure the ISO/WBFS is in the \"rc24-data\" directory.\n\n1. Start Patching\n2. Back\n\n"

		input "Choose: " choice

		case ${choice} in
				1)
					clear
					title "Download Wiimmfi Patcher"
					printf "Loading..."
					sketchget "Wiimmfi-stuff/patch-images.sh" "patch-images.sh"
					sketchget "Wiimmfi-stuff/bin/setup.sh" "bin/setup.sh"
					chmod +x patch-images.sh
					chmod +x bin/setup.sh
					./patch-images.sh
					break
					;;
				2)
					break
					;;
		esac

	done
}

# Try to detect SD card by looking for "apps" directory in its root
detectsd () {
	for i in ${mount}/*/
	do
		if [ -d "${i}/apps" ]
		then
			out_path="${i}"
		fi
	done
}

# Change the output path manually
changeoutpath () {
	clear

	title "Change Output Path"

	print "Current output path: ${out_path}\n\n"

	input "Type in the new path to store files (i.e. ${mount}/Wii): " out_path
}

# Choose device to patch (to do: remove "prepare" from Wii and vWii options after uninstall mode added)
device () {
	while true
	do
		clear

		title "Choose Device"
		print "Welcome to the RiiConnect24 Patcher!\nWith this program, you can patch your Wii or Wii U for use with RiiConnect24.\n\nSo, what device are we patching today?\n\n1. Wii\n2. vWii (Wii U)\n3. Dolphin\n\n"

		input "Choose an option: " choice
		case ${choice} in
			1)
				device=wii

				wii

				break
				;;
			2)
				device=vwii

				vwii

				break
				;;
            3)
                device=dolphin

                dolphin

                break
                ;;
		esac
	done
}

# Credits
credits () {
	clear

	title "Credits"
	print "Credits:\n    - Sketch, HTV04, and TheShadowEevee: Developers\n    - TheShadowEevee: Sharpii-NetCore\n    - person66, and leathl: Original Sharpii and libWiiSharp developers\n    - KcrPL and Larsenv: Original RiiConnect24 Patcher developers\n    - And you!\n\nSource code: https://github.com/RiiConnect24/RiiConnect24-Patcher\n\nRiiConnect24 website: https://rc24.xyz/\n\nBy Wii fans, for Wii fans!\n\n"

	anykey "return to the main menu"
}

vffdownloader () {
	clear

	title "VFF Downloader for Dolphin"

	print "Now loading...\n\n"

	if command -v crontab >/dev/null 2>&1
	then
		sketchget VFF-Downloader-for-Dolphin.sh VFF-Downloader-for-Dolphin.sh
		chmod +x VFF-Downloader-for-Dolphin.sh
		./VFF-Downloader-for-Dolphin.sh
	else
		print "\"crontab\" command not found! Please install the \"crontab\" package using your package manager.\n\n"

		anykey "continue"
	fi
}


# Refresh patcher screen (updates screen after patcher phase is completed)
refresh () {
	clear

	if [ ${device} = wii ]
	then
		title "Installing RiiConnect24 (Wii)"
	elif [ ${device} = vwii ]
	then
		title "Installing RiiConnect24 (vWii)"
    elif [ ${device} = dolphin ]
    then
        title "Installing RiiConnect24 (Dolphin Emulator)"
	fi
	print "Now patching. This may take a few minutes, depending on your internet speed.\n\n"

	if [ ${patch[0]} = 1 ]
	then
		if [ ${patched[0]} = 1 ]
		then
			print "[X] System Patches\n"
		else
			print "[ ] System Patches\n"
		fi
	fi
	if [ ${patch[1]} = 1 ]
	then
		if [ ${patched[1]} = 1 ]
		then
			print "[X] Forecast and News Channels\n"
		else
			print "[ ] Forecast and News Channels\n"
		fi
	fi
	if [ ${patch[2]} = 1 ]
	then
		if [ ${patched[2]} = 1 ]
		then
			print "[X] Check Mii Out/Mii Contest Channel\n"
		else
			print "[ ] Check Mii Out/Mii Contest Channel\n"
		fi
	fi
	if [ ${patch[3]} = 1 ]
	then
		if [ ${patched[3]} = 1 ]
		then
			print "[X] Everybody Votes Channel\n"
		else
			print "[ ] Everybody Votes Channel\n"
		fi
	fi
	if [ ${patch[4]} = 1 ]
	then
		if [ ${patched[4]} = 1 ]
		then
			print "[X] Nintendo Channel\n"
		else
			print "[ ] Nintendo Channel\n"
		fi
	fi

	subtitle "Fun Fact" "${fun_facts[${RANDOM} % ${#fun_facts[@]}]}"
}

# Patcher finish message
finish () {
	clear

	rm -rf Temp

	title "Complete"
	print "The RiiConnect24 Patcher has succesfully completed the requested operation.\n\nOutput has been saved to \"rc24output.txt,\" in case you need it.\n\n"

	anykey "return to the main menu"
}

# Choose region
region () {
	while true
	do
		clear

		title "Choose Region"
		print "What region is your device from?\n1. Europe (PAL)\n2. Japan (NTSC-J)\n3. USA (NTSC-U)\n\n"

		input "Choose an option: " choice
		case ${choice} in
			1)
				region=EUR
				region_hex=50

				break
				;;
			2)
				region=JPN
				region_hex=4a

				break
				;;
			3)
				region=USA
				region_hex=45

				break
				;;
		esac
	done
}

# Custom patch options
custom () {
	patch=(1 1 0 0 0)
	apps=1

	while true
	do
		clear

		if [ ${device} = wii ]
		then
			title "Custom Install (Wii)"
		elif [ ${device} = vwii ]
		then
			title "Custom Install (vWii)"
		fi
		print "The recommended options for a new RiiConnect24 install are toggled on by default.\n\n"

		if [ ${patch[0]} = 1 ]
		then
			print "1. [X] System Patches (Required, only toggle off if already installed!)\n"
		else
			print "1. [ ] System Patches (Required, only toggle off if already installed!)\n"
		fi
		if [ ${patch[1]} = 1 ]
		then
			print "2. [X] Forecast and News Channels\n"
		else
			print "2. [ ] Forecast and News Channels\n"
		fi
		if [ ${patch[2]} = 1 ]
		then
			print "3. [X] Check Mii Out/Mii Contest Channel\n"
		else
			print "3. [ ] Check Mii Out/Mii Contest Channel\n"
		fi
		if [ ${patch[3]} = 1 ]
		then
			print "4. [X] Everybody Votes Channel\n"
		else
			print "4. [ ] Everybody Votes Channel\n"
		fi
		if [ ${patch[4]} = 1 ]
		then
			if [ ${region} != JPN ]
			then
				print "5. [X] Nintendo Channel\n\n"
			else
				print "5. [X] Nintendo Channel (Not working!)\n\n"
			fi
		else
			if [ ${region} != JPN ]
			then
				print "5. [ ] Nintendo Channel\n\n"
			else
				print "5. [ ] Nintendo Channel (Not working!)\n\n"
			fi
		fi

		if [ ${apps} = 1 ]
		then
			print "6. [X] Download Utilities (Required, only toggle off if already installed!)\n\n"
		else
			print "6. [ ] Download Utilities (Required, only toggle off if already installed!)\n\n"
		fi

		print "7. Continue\n\n"

		print "Type the number of an option to toggle it: "
		read -n 1 -r choice
		case ${choice} in
			1)
				patch[0]=$((1 - ${patch[0]}))
				;;
			2)
				patch[1]=$((1 - ${patch[1]}))
				;;
			3)
				patch[2]=$((1 - ${patch[2]}))
				;;
			4)
				patch[3]=$((1 - ${patch[3]}))
				;;
			5)
				patch[4]=$((1 - ${patch[4]}))
				;;

			6)
				apps=$((1 - ${apps}))
				;;

			7)
				break
				;;
		esac
	done
}

# Uninstall preparation
uninstallprep() {
	while true
	do
		clear

		title "Uninstall RiiConnect24 (Wii)"
		subtitle "Warning" "If you are troubleshooting, uninstalling RiiConnect24 probably won't help fix your problem. Please contact the RiiConnect24 developers at support@riiconnect24.net or join the RiiConnect24 Discord server."

		print "This part of the patcher will help you uninstall RiiConnect24 from your Wii\nBy completing these steps you will lose access to:\n- News Channel\n- Forecast Channel\n- Wii Mail\n\nIf you have any other channels installed on your Wii, you will have to uninstall them manually.\nDo you want to procced with the guide?\n1. Yes\n2. No, go back\n\n"

		input "Choose: " choice
		case ${choice} in
			1)
				clear

				title
				print "Would you like to include a tutorial with how to delete your mwc24msg.cfg file?\n(This is a mail configuration file.)\n\n1. Yes\n2. No\n\n"

				input "Choose: " choice_2

				uninstall

				break
				;;
			2)
				break
				;;
		esac
	done
}

# More uninstall preparation
uninstall () {
	clear

	title "Downloading Uninstaller Files (Wii)"

	print "Please wait..."

	mkdir -p "${out_path}/WAD"

	./Sharpii nusd -ios 31 -v 3608 -o "${out_path}/WAD/IOS31.wad" -wad
	./Sharpii nusd -ios 80 -v 6944 -o "${out_path}/WAD/IOS80.wad" -wad


	rc24get apps/WiiXplorer/boot.dol "${out_path}/apps/WiiXplorer/boot.dol"
	rc24get apps/WiiXplorer/icon.png "${out_path}/apps/WiiXplorer/icon.png"
	rc24get apps/WiiXplorer/meta.xml "${out_path}/apps/WiiXplorer/meta.xml"
	rc24get apps/WiiModLite/boot.dol "${out_path}/apps/WiiModLite/boot.dol"
	rc24get apps/WiiModLite/icon.png "${out_path}/apps/WiiModLite/icon.png"
	rc24get apps/WiiModLite/meta.xml "${out_path}/apps/WiiModLite/meta.xml"

	uninstallinstuct1
}

# Uninstall instruction 1
uninstallinstuct1 () {
	while true
	do
		clear

		title "Uninstall Instructions (Wii)"

		print "Part 1 - Reinstalling stock IOS 31 and IOS 80\n\n1. Please open the Homebrew Channel and start Wii Mod Lite\n2. Using the D-Pad on your Wii Remote, navigate to WAD Manager and then navigate to the WAD Folder\n3. When IOS31.wad is highlighted, press +. Do the same for IOS 80 then press the A button\n4. When you are done, press the HOME Button to go back to Homebrew Channel.\n\n"

		anykey "continue"

		uninstallinstuct2

		break
	done
}

# Uninstall instruction 2
uninstallinstuct2 () {
	while true
	do
		clear

		title "Uninstall Instructions"

		print "Part 2 - Disconnecting from RiiConnect24\n\n1. Go to Wii Options\n2. Go to Wii Settings\n3. Go to Page 2, then click on Internet\n4. Go to Connection Settings\n5. Select your current connection\n6. Go to Change Settings\n7. Go to Auto-Obtain-DNS (not IP Address), then select Yes\n8. Select Save and do the connection test\nWhen asking to update, press No to skip it.\n\n"

		anykey "continue"

		if [ ${choice_2} == 1 ]
		then
			uninstallinstuct3
		else
			uninstallfinish
		fi

		break
	done
}

# Uninstall instruction 3
uninstallinstuct3 () {
	while true
	do
		clear

		title "Uninstall Instructions"

		print "Part 3 - Restoring the nwc24msg.cfg to its factory defaults\n\n1. Launch WiiXplorer from the Homebrew Channel\n2. In WiiXplorer, press Start - Settings - Boot Settings. Turn NAND Write Access on.\n3. Change your device to NAND (the bar on the top)\n4. Go to shared2 - wc24\n5. Hover your cursor over the nwc24msg.cfg then press + on your Wii Remote and delete it.\n\n"

		anykey "continue"

		uninstallfinish

		break
	done
}

# Uninstall finish
uninstallfinish() {
	clear

	title "Uninstall Finished"

	print "That's it! RiiConnect24 should now be removed from your Wii!\n\nWe hope you have enjoyed your time with us, and that you will come back soon :)\n\n"

	anykey "return to the main menu"
}



# Choose Wii patcher mode
wii () {
	while true
	do
		clear

		title "Patcher Mode (Wii)"
		print "1. Install RiiConnect24 on your Wii\n   - The patcher will guide you through process of installing RiiConnect24.\n\n2. Uninstall RiiConnect24 from your Wii\n   - This will help you uninstall RiiConnect24 from your Wii.\n\n3. Patch WiiWare games for use with Wiimmfi\n   -This patches WiiWare games so you can play them online\n\n4. Patch Wii ISO/WBFS\n   -Use this to patch any game for use online, even Mario Kart Wii\n\n"

		input "Choose an option: " choice
		case ${choice} in
			1)
				wiiprepare

				break
				;;
			2)
				uninstallprep

				break
				;;
			3)
				patchwiiware
				;;
			4)
				patchgameprep
				;;
		esac
	done
}

# Prepare Wii patch
wiiprepare () {
	while true
	do
		clear

		title "Preparing to Install RiiConnect24 (Wii)"
		print "Choose instalation type:\n1. Express (Recommended)\n  - This will patch every channel for later use on your Wii. This includes:\n    - Check Mii Out Channel/Mii Contest Channel\n    - Everybody Votes Channel\n    - Forecast Channel\n    - News Channel\n    - Nintendo Channel\n    - Wii Mail\n\n2. Custom\n   - You will be asked what you want to patch.\n\n3. Back\n\n"

		input "Choose an option: " choice
		case ${choice} in
			1)
				region
				if [ ${region} != "JPN" ]
				then
					patch=(1 1 1 1 1)
				else
					patch=(1 1 1 1 0)
				fi
				apps=1
				wiipatch
				finish

				break
				;;
			2)
				region
				custom
				wiipatch
				finish

				break
				;;
			3)
				break
				;;
		esac
	done
}

# Wii patching process
wiipatch () {
	patched=(0 0 0 0 0 0)
	refresh

	mkdir -p "${out_path}/WAD"
	mkdir -p "${out_path}/apps"

	if [ ${patch[0]} = 1 ]
	then
		rc24get IOSPatcher/00000006-31.delta Temp/Files/Patcher/Wii/IOS31/00000006.delta
		rc24get IOSPatcher/00000006-80.delta Temp/Files/Patcher/Wii/IOS80/00000006.delta

		patchios 31 3608
		patchios 80 6944

		patched[0]=1
		refresh
	fi
	if [ ${patch[1]} = 1 ]
	then
		if [ ${region} = EUR ]
		then
			rc24get NewsChannelPatcher/URL_Patches/Europe/00000001_Forecast.delta Temp/Files/Patcher/Wii/FC/${region}/00000001.delta
			rc24get NewsChannelPatcher/URL_Patches/Europe/00000001_News.delta Temp/Files/Patcher/Wii/NC/${region}/00000001.delta
		elif [ ${region} = JPN ]
		then
			rc24get NewsChannelPatcher/URL_Patches/Japan/00000001_Forecast.delta Temp/Files/Patcher/Wii/FC/${region}/00000001.delta
			rc24get NewsChannelPatcher/URL_Patches/Japan/00000001_News.delta Temp/Files/Patcher/Wii/NC/${region}/00000001.delta
		elif [ ${region} = USA ]
		then
			rc24get NewsChannelPatcher/URL_Patches/USA/00000001_Forecast.delta Temp/Files/Patcher/Wii/FC/${region}/00000001.delta
			rc24get NewsChannelPatcher/URL_Patches/USA/00000001_News.delta Temp/Files/Patcher/Wii/NC/${region}/00000001.delta
		fi

		patchtitle Wii/FC 00010002484146 7 00000001 "Forecast Channel"
		patchtitle Wii/NC 00010002484147 7 00000001 "News Channel"

		patched[1]=1
		refresh
	fi
	if [ ${patch[2]} = 1 ]
	then
		if [ ${region} = EUR ]
		then
			sketchgetcetk CMOC EUR

			rc24get CMOCPatcher/patch/00000001_Europe.delta Temp/Files/Patcher/CMOC/EUR/00000001.delta
			rc24get CMOCPatcher/patch/00000004_Europe.delta Temp/Files/Patcher/CMOC/EUR/00000004.delta
		elif [ ${region} = JPN ]
		then
			rc24get CMOCPatcher/patch/00000001_Japan.delta Temp/Files/Patcher/CMOC/JPN/00000001.delta
			rc24get CMOCPatcher/patch/00000004_Japan.delta Temp/Files/Patcher/CMOC/JPN/00000004.delta
		elif [ ${region} = USA ]
		then
			sketchgetcetk CMOC USA

			rc24get CMOCPatcher/patch/00000001_USA.delta Temp/Files/Patcher/CMOC/USA/00000001.delta
			rc24get CMOCPatcher/patch/00000004_USA.delta Temp/Files/Patcher/CMOC/USA/00000004.delta
		fi

		if [ ${region} = EUR ]
		then
			patchtitle2 CMOC 00010001484150 512 00000001 00000004 "Mii Contest Channel"
		else
			patchtitle2 CMOC 00010001484150 512 00000001 00000004 "Check Mii Out Channel"
		fi

		patched[2]=1
		refresh
	fi
	if [ ${patch[3]} = 1 ]
	then
		if [ ${region} = EUR ]
		then
			sketchgetcetk EVC EUR
			rc24get EVCPatcher/patch/Europe.delta Temp/Files/Patcher/EVC/EUR/00000001.delta
		elif [ ${region} = JPN ]
		then
			rc24get EVCPatcher/patch/JPN.delta Temp/Files/Patcher/EVC/JPN/00000001.delta
		elif [ ${region} = USA ]
		then
			sketchgetcetk EVC USA
			rc24get EVCPatcher/patch/USA.delta Temp/Files/Patcher/EVC/USA/00000001.delta
		fi

		patchtitle EVC 0001000148414a 512 00000001 "Everybody Votes Channel"

		patched[3]=1
		refresh
	fi
	if [ ${patch[4]} = 1 ]
	then
		if [ ${region} = EUR ]
		then
			sketchgetcetk NC EUR
			rc24get NCPatcher/patch/Europe.delta Temp/Files/Patcher/NC/EUR/00000001.delta
		elif [ ${region} = JPN ]
		then
			rc24get NCPatcher/patch/JPN.delta Temp/Files/Patcher/NC/JPN/00000001.delta
		elif [ ${region} = USA ]
		then
			sketchgetcetk NC USA
			rc24get NCPatcher/patch/USA.delta Temp/Files/Patcher/NC/USA/00000001.delta
		fi

		patchtitle NC 00010001484154 1792 00000001 "Nintendo Channel"

		patched[4]=1
		refresh
	fi

	if [ ${apps} = 1 ]
	then
		rc24get apps/Mail-Patcher/boot.dol "${out_path}/apps/Mail-Patcher/boot.dol"
		rc24get apps/Mail-Patcher/icon.png "${out_path}/apps/Mail-Patcher/icon.png"
		rc24get apps/Mail-Patcher/meta.xml "${out_path}/apps/Mail-Patcher/meta.xml"
		rc24get apps/WiiModLite/boot.dol "${out_path}/apps/WiiModLite/boot.dol"
		rc24get apps/WiiModLite/icon.png "${out_path}/apps/WiiModLite/icon.png"
		rc24get apps/WiiModLite/meta.xml "${out_path}/apps/WiiModLite/meta.xml"
	fi

	rm -rf Files
}



# Choose vWii patcher mode (currently unused)
vwii () {
	while true
	do
		clear

		title "Patcher Mode (vWii)"
		print "1. Install RiiConnect24 on your vWii\n   - The patcher will guide you through process of installing RiiConnect24.\n\n2. Patch WiiWare games for use with Wiimmfi\n   -This patches WiiWare games so you can play them online\n\n3. Patch Wii ISO/WBFS\n   -Use this to patch any game for use online, even Mario Kart Wii\n\n"

		input "Choose an option: " choice
		case ${choice} in
			1)
				vwiiprepare
				break
				;;
			2)
				patchwiiware
				;;
			3)
				patchgameprep
				;;
		esac
	done
}

# Prepare vWii patch
vwiiprepare () {
	while true
	do
		clear

		title "Preparing to Install RiiConnect24 (vWii)"
		print "Choose instalation type:\n1. Express (Recommended)\n  - This will patch every channel for later use on your vWii. This includes:\n    - Check Mii Out Channel/Mii Contest Channel\n    - Everybody Votes Channel\n    - Forecast Channel\n    - News Channel\n    - Nintendo Channel\n\n2. Custom\n   - You will be asked what you want to patch.\n\n3. Back\n\n"

		input "Choose an option: " choice
		case ${choice} in
			1)
				region
				if [ ${region} != "JPN" ]
				then
					patch=(1 1 1 1 1)
				else
					patch=(1 1 1 1 0)
				fi
				apps=1
				vwiipatch
				finish

				break
				;;
			2)
				region
				custom
				vwiipatch
				finish

				break
				;;
			3)
				break
				;;
		esac
	done
}

# vWii patching process
vwiipatch () {
	patched=(0 0 0 0 0 0)
	refresh

	mkdir -p "${out_path}/WAD"
	mkdir -p "${out_path}/apps"

	if [ ${patch[0]} = 1 ]
	then
		rc24get IOSPatcher/IOS31_vwii.wad "${out_path}/WAD/IOS31_vWii_Only (RiiConnect24).wad"

		patched[0]=1
		refresh
	fi
	if [ ${patch[1]} = 1 ]
	then
		rc24get NewsChannelPatcher/00000001.delta Temp/Files/Patcher/vWii/NC/00000001.delta
		rc24get NewsChannelPatcher/URL_Patches_WiiU/00000001_Forecast_All.delta Temp/Files/Patcher/vWii/FC/00000001.delta

		patchtitlevwii vWii/FC 00010002484146 7 00000001 "Forecast Channel"
		patchtitlevwii vWii/NC 00010002484147 7 00000001 "News Channel"

		patched[1]=1
		refresh
	fi
	if [ ${patch[2]} = 1 ]
	then
		if [ ${region} = EUR ]
		then
			sketchgetcetk CMOC EUR
			rc24get CMOCPatcher/patch/00000001_Europe.delta Temp/Files/Patcher/CMOC/EUR/00000001.delta
			rc24get CMOCPatcher/patch/00000004_Europe.delta Temp/Files/Patcher/CMOC/EUR/00000004.delta
		elif [ ${region} = JPN ]
		then
			rc24get CMOCPatcher/patch/00000001_Japan.delta Temp/Files/Patcher/CMOC/JPN/00000001.delta
			rc24get CMOCPatcher/patch/00000004_Japan.delta Temp/Files/Patcher/CMOC/JPN/00000004.delta
		elif [ ${region} = USA ]
		then
			sketchgetcetk CMOC USA
			rc24get CMOCPatcher/patch/00000001_USA.delta Temp/Files/Patcher/CMOC/USA/00000001.delta
			rc24get CMOCPatcher/patch/00000004_USA.delta Temp/Files/Patcher/CMOC/USA/00000004.delta
		fi

		if [ ${region} = EUR ]
		then
			patchtitle2 CMOC 00010001484150 512 00000001 00000004 "Mii Contest Channel"
		else
			patchtitle2 CMOC 00010001484150 512 00000001 00000004 "Check Mii Out Channel"
		fi

		patched[2]=1
		refresh
	fi
	if [ ${patch[3]} = 1 ]
	then
		if [ ${region} = EUR ]
		then
			sketchgetcetk EVC EUR
			rc24get EVCPatcher/patch/Europe.delta Temp/Files/Patcher/EVC/EUR/00000001.delta
		elif [ ${region} = JPN ]
		then
			rc24get EVCPatcher/patch/JPN.delta Temp/Files/Patcher/EVC/JPN/00000001.delta
		elif [ ${region} = USA ]
		then
			sketchgetcetk EVC USA
			rc24get EVCPatcher/patch/USA.delta Temp/Files/Patcher/EVC/USA/00000001.delta
		fi

		patchtitle EVC 0001000148414a 512 00000001 "Everybody Votes Channel"

		patched[3]=1
		refresh
	fi
	if [ ${patch[4]} = 1 ]
	then
		if [ ${region} = EUR ]
		then
			sketchgetcetk NC EUR
			rc24get NCPatcher/patch/Europe.delta Temp/Files/Patcher/NC/EUR/00000001.delta
		elif [ ${region} = JPN ]
		then
			rc24get NCPatcher/patch/JPN.delta Temp/Files/Patcher/NC/JPN/00000001.delta
		elif [ ${region} = USA ]
		then
			sketchgetcetk NC USA
			rc24get NCPatcher/patch/USA.delta Temp/Files/Patcher/NC/USA/00000001.delta
		fi

		patchtitle NC 00010001484154 1792 00000001 "Nintendo Channel"

		patched[4]=1
		refresh
	fi

	if [ ${apps} = 1 ]
	then
		rc24get apps/ConnectMii_WAD/ConnectMii.wad "${out_path}/WAD/ConnectMii.wad"
		rc24get apps/ww-43db-patcher/boot.dol "${out_path}/apps/ww-43db-patcher/boot.dol"
		rc24get apps/ww-43db-patcher/icon.png "${out_path}/apps/ww-43db-patcher/icon.png"
		rc24get apps/ww-43db-patcher/meta.xml "${out_path}/apps/ww-43db-patcher/meta.xml"
		rc24get apps/WiiModLite/boot.dol "${out_path}/apps/WiiModLite/boot.dol"
		rc24get apps/WiiModLite/icon.png "${out_path}/apps/WiiModLite/icon.png"
		rc24get apps/WiiModLite/meta.xml "${out_path}/apps/WiiModLite/meta.xml"
	fi

	rm -rf Files
}

dolphin () {
    while true
    do
        clear

        title "Patcher Mode (Dolphin Emulator)"
        print "1. Install RiiConnect24 on Dolphin Emulator\n   - The patcher will guide you through process of installing RiiConnect24.\n\n2. Patch WiiWare games for use with Wiimmfi\n   -This patches WiiWare games so you can play them online\n\n3. Patch Wii ISO/WBFS\n   -Use this to patch any game for use online, even Mario Kart Wii\n\n"

        input "Choose an option: " choice
        case ${choice} in
            1)
                dolphinprepare

                break
                ;;
            2)
                patchwiiware
                ;;
            3)
                patchgameprep
                ;;
        esac
    done
}

# Prepare Wii patch
dolphinprepare () {
    while true
    do
        clear

        title "Preparing to Install RiiConnect24 (Dolphin Emulator)"
        print "Note: This will only work on Dolphin version 5.0-17613 and later. For older versions, please use the VFF Downloader.\n\n"
        print "Install or go back:\n1. Install\n  - This will patch every channel for later use on Dolphin. This includes:\n    - Check Mii Out Channel/Mii Contest Channel\n    - Everybody Votes Channel\n    - Forecast Channel\n    - News Channel\n    - Nintendo Channel\n\n2. Back\n\n"

        input "Choose an option: " choice
        case ${choice} in
            1)
                region
                if [ ${region} != "JPN" ]
                then
                    patch=(0 1 1 1 1)
                else
                    patch=(0 1 1 1 0)
                fi
                apps=0
                wiipatch
                finish

                break
                ;;
            2)
                break
                ;;
        esac
    done
}

if ! command -v tput >/dev/null 2>&1; then

        echo "Ncurses could not be found. Please install ncurses or ncurses-utils via your package manager."

        exit 1

fi

# Setup
clear

cd $(dirname ${0})

rm -rf rc24-data
mkdir rc24-data
pushd rc24-data > /dev/null

ver=v1.2.0

rc24_str="RiiConnect24 Patcher for Unix ${ver}\nBy Sketch, HTV04, and TheShadowEevee\n\n"

print "${rc24_str}Now loading...\n\n"

print "${rc24_str}==Output Start==\n\n" > rc24output.txt

fun_facts=(
	"Did you know that the Wii was the best selling game-console of 2006?"
	"RiiConnect24 originally started out as \"CustomConnect24!\""
	"Did you know that the RiiConnect24 logo was made by NeoRame, the same person who made the Wiimmfi logo?"
	"The Wii was codenamed \"Revolution\" during its development stage."
	"Did you know the letters in the Wii model number \"RVL\" stands for the Wii's codename, \"Revolution\"?"
	"The music used in many of the Wii's channels (including the Wii Shop, Mii, Check Mii Out, and Forecast Channels) was composed by Kazumi Totaka."
	"The Internet Channel once costed 500 Wii Points, but was later made freeware."
	"It's possible to use candles as a Wii Sensor Bar."
	"The blinking blue light that indicates a system message has been received is actually synced to the bird call of the Japanese bush warbler."
	"Wii Sports is the most sold game on the Wii. It sold 82.85 million copies."
	"Did you know that most of the scripts used to make RiiConnect24 work are written in Python?"
	"Thanks to Spotlight for making RiiConnect24's mail system secure!"
	"Did you know that RiiConnect24 has a Discord server where you can stay updated about the project status?"
	"The Everybody Votes Channel was originally an idea about sending quizzes and questions daily to Wii consoles."
	"The News Channel developers had an idea at some point about making a dad's Mii the news caster in the channel, but it probably didn't make the cut because some articles aren't appropriate for kids."
	"The Everybody Votes Channel was originally called the \"Questionnaire Channel\", then \"Citizens Vote Channel.\""
	"The Forecast Channel has a \"laundry index\" to show how appropriate it is to dry your clothes outside, and a \"pollen count\" in the Japanese version."
	"During the development of the Forecast Channel, Nintendo of America's department got hit by a thunderstorm, and the developers of the channel in Japan lost contact with them."
	"The News Channel has an alternate slide show song that plays at night." "During E3 2006, Satoru Iwata said WiiConnect24 uses as much power as a miniature lightbulb while the console is in Standby mode."
	"The effect used when rapidly zooming in and out of photos on the Photo Channel was implemented into the News Channel to zoom in and out of text."
	"The help cats in the News Channel and the Photo Channel are brother and sister (the one in the News Channel being male, and the Photo Channel being a younger female)."
	"The Japanese version of the Forecast Channel does not show the current forecast."
	"The Forecast Channel, News Channel and the Photo Channel were made by nearly the same team."
	"The first worldwide Everybody Votes Channel question about if you like dogs or cats more got more than 500,000 votes."
	"The night song that plays when viewing the local forecast in the Forecast Channel was made before the day song, that was requested to make people not feel sleepy when it was played during the day."
	"The globe used in the Forecast and News Channels is based on imagery from NASA, and the same globe was used in Mario Kart Wii."
	"You can press the RESET button while the Wii is in Standby mode to turn off the blue light that glows when you receive a message."
)

#Error Detection
error() {
    clear
    title "ERROR"
    print "\033[1;91mAn error has occurred.\033[0m\n\nERROR DETAILS:\n\t* Task: ${task}\n\t* Command: ${BASH_COMMAND}\n\t* Line: ${1}\n\t* Exit code: ${2}\n\n"  | fold -s -w "$(tput cols)"

	printf "${helpmsg}\n\n" | fold -s -w "$(tput cols)"

	exit
}

trap 'error $LINENO $?' ERR
set -o pipefail
set -o errtrace

helpmsg="Open an issue on https://github.com/RiiConnect24/RiiConnect24-Patcher/issues regarding your error. Alternatively, contact Sketch (hero.of.time) on Discord."

case $(uname -m),$(uname) in
	x86_64,Darwin)
		sys="(macOS-x64)"
		mount=/Volumes
		;;
	arm64,Darwin)
		sys="(macOS-x64)"
		mount=/Volumes
		;;
	x86_64,*)
		sys="(linux-x64)"
		mount=/mnt
		;;
	aarch64,*)
		sys="(linux-arm64)"
		mount=/mnt
		;;
	*,*)
		sys="(linux-arm)"
		mount=/mnt
		;;
esac

sketchget Sharpii/sharpii${sys} Sharpii
chmod +x Sharpii

if ! command -v curl >/dev/null 2>&1
then
	print "\"curl\" command not found! Please install the \"curl\" package using your package manager.\n\n"

	exit
fi
if ! command -v xdelta3 >/dev/null 2>&1
then
	case $(uname) in
		Darwin)
			print "\"xdelta3\" command not found! Please install brew by going to the website \"https://brew.sh\" then install xdelta3 by typing \"brew install xdelta\" into your terminal.\n\n"
			exit
			;;
		*)
			print "\"xdelta3\" command not found! Please install the \"xdelta3\" package using your package manager.\n\n"
			exit
			;;
	esac
fi



# SD card setup
clear

title "Detecting SD Card"

print "Looking for SD card (drive with \"apps\" folder in root)...\n\n"

out_path=Copy-to-SD
detectsd

case ${out_path} in
	Copy-to-SD)
		mkdir Copy-to-SD

		print "Looks like an SD card wasn't found in your system.\n\nPlease choose the \"Change Path\" option to set your SD card or other destination path manually, otherwise you will have to copy them later from the \"Copy-to-SD\" folder stored in the \"rc24-data\" folder.\n\n"
		;;
	*)
		print "Successfully detected your SD card: \"${out_path}\"\n\nEverything will be automatically downloaded and installed onto your SD card!\n\n" | fold -s -w "$(tput cols)"
		;;
esac

anykey "continue"



# Main menu
while true
do
	clear

	title "Main Menu"
	print "\"RiiConnect\" your Wii!\n\n1. Start\n   - Start patching\n2. Credits\n   - See who made this possible!\n\n3. Start VFF Downloader\n   - Assists with downloading VFF files for Dolphin 5.0-17611 and earlier\n\n4. Exit\n   - Exit\n\n"

	input "Choose an option (by typing its number and pressing return): " choice

	case ${choice} in
		1)
			device
			;;
		2)
			credits
			;;
		3)
			vffdownloader
			;;
		4)
			clear

			print "Thank you for using this patcher! If you encountered any issues, please report them here:\n\nhttps://github.com/RiiConnect24/RiiConnect24-Patcher/issues\n\n"

			popd > /dev/null

			break
			;;
	esac
done
