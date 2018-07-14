#!/bin/bash

FilesHostedOn="https://raw.githubusercontent.com/KcrPL/KcrPL.github.io/master/Patchers_Auto_Update/RiiConnect24Patcher"

version=1.0.0

last_build=2018/07/05
at=1:14PM
header="RiiConnect24 Patcher - (C) KcrPL, (C) Larsenv, (C) ApfelTV v$version (Compiled on $last_build at $at)"

function main {
    clear
    echo $header
    echo ""
    echo "RiiConnect your Wii."
    echo ""
    echo "1. Start"
    echo "2. Credits"
    echo ""
    echo "Do you have problems or want to contact us?"
    echo "Mail us at support@riiconnect24.net"
    echo ""
    read -p "Type a number that you can see above next to the command and hit ENTER: " p
}

main

tempiospatcher=0
tempevcpatcher=0
tempsdcardapps=0

unameOut="$(uname -s)"
case "${unameOut}" in
    Linux*)     machine="linux";;
    Darwin*)    machine="mac";;
esac

if ! [ -x "$(command -v mono)" ] && [ "$machine" == "mac" ]
then
    clear
    echo $header
    echo ""
	echo "Mono not found! Please install it with:\nbrew install mono\nIf you don't have brew, learn how to install it at https://brew.sh/"
	exit
elif ! [ -x "$(command -v mono)" ] && [ "$machine" == "linux" ]
then
    clear
    echo $header
    echo ""
	echo "Mono not found! Please learn how to install it at:\nhttps://www.mono-project.com/download/stable/#download-lin"
	exit
fi

if ! [ -x "$(command -v xdelta3)" ] && [ "$machine" == "mac" ]
then
    clear
    echo $header
    echo ""
	echo "xdelta3 not found! Please install it with:\nbrew install xdelta3\nIf you don't have brew, learn how to install it at https://brew.sh/"
	exit
elif ! [ -x "$(command -v xdelta3)" ] && [ "$machine" == "linux" ]
then
    clear
    echo $header
    echo ""
	echo "xdelta3 not found! Please install it with:\nsudo apt-get install xdelta3"
	exit
fi

function number_1 {
    clear
    echo $header
    echo "-----------------------------------------------------------------------------------------------------------------------------"

    echo ""
    echo "Which mode should I run?"
    echo "1. Automatic Guided Installation (Recommended)"
    echo "  - The patcher will guide you through process of installing RiiConnect24"
    echo ""
    echo "2. Manual Install"
    echo "  - In this mode you will be able to choose what you want to do and in which order"
    echo ""
    read -p "Choose: " s

    if [ "$s" == "1" ]; then number_2_auto
    elif [ "$s" == "2" ]; then number_2_manual; fi
}

function credits {
    clear
    echo $header
    echo "---------------------------------------------------------------------------------------------------------------------------"
    echo "RiiConnect24 Patcher for RiiConnect24 v$version"
    echo "	Created by:"
    echo "- KcrPL"
    echo "  Main Windows patcher, UI, scripts."
    echo ""
    echo "- Larsenv"
    echo "  Help with scripts, main Mac/Linux pather, original IOS Patcher script. Overall help with scripts and commands syntax."
    echo ""
    echo "- ApfelTV"
    echo "  Help with Everybody Votes Channel patching and Sharpii syntax."
    echo ""
    echo "- Brawl345"
    echo "  Help with resolving ticket issues."
    echo ""
    echo " For the entire RiiConnect24 Community."
    echo " Want to contact us? Mail us at support@riiconnect24.net"
    echo ""
    read -n 1 -s -r -p "Press any button to go back to main menu."
    
    main
}

function number_2_auto {
    clear
    echo $header
    echo "-----------------------------------------------------------------------------------------------------------------------------"

    echo ""
    echo "Hello $(whoami), welcome to the automatic guided installation of RiiConnect24."
    echo ""
    echo "The patcher will download any files that are required to run the patcher if you are missing them."
    echo "The entire process should take about 1 to 2 minutes."
    echo ""
    echo "But before starting, you need to tell me one thing:"
    echo ""
    echo "For Everybody Votes Channel, which region should I download and patch? (Where do you live?)"
    echo ""
    echo "1. Europe"
    echo "2. USA"
    read -p "Choose one: " s

    if [ "$s" == "1" ]; then
        evcregion=1
    elif [ "$s" == "2" ]; then
        evcregion=2
    fi

    number_2_1
}

function number_2_1 {
    clear
    echo $header
    echo "-----------------------------------------------------------------------------------------------------------------------------"
    echo ""
    echo "Great!"
    echo "After passing this screen, any user interation won't be needed so you can relax and let me do the work! :)"
    echo ""
    echo "Did I forget about something? Yes! To make patching even easier, I can download everything that you need and put it on"
    echo "your SD Card!"
    echo ""
    echo "Please connect your Wii SD Card to the computer."
    echo ""
    echo "1. Connected!"
    echo "2. I can't connect an SD Card to the computer."
    read -p "Choose one: " s

    if [ "$s" == "1" ]; then
        sdcardstatus=1
        detect_sd_card
    elif [ "$s" == "2" ]; then
        sdcardstatus=0
        number_2_1_summary
    fi
}

function detect_sd_card {
    sdcard=null
    for f in /Volumes/*/; do
        if [[ -d $f/apps ]]; then
            sdcard="$f"
            echo $sdcard
        fi
    done

    number_2_1_summary
}

function number_2_1_summary {
    clear
    echo "$header"
    echo "-----------------------------------------------------------------------------------------------------------------------------"
    echo ""
    if [ $sdcardstatus == 0 ]; then echo "Aww, no worries. You will be able to copy files later after patching."; fi
    if [[ $sdcardstatus == 1 && $sdcard == null ]]; then echo "Hmm... looks like an SD Card wasn't found in your system. Please choose the "Change volume name" option"; fi
    if [[ $sdcardstatus == 1 && $sdcard == null ]]; then echo "to set your SD Card volume name manually."; fi
    if [[ $sdcardstatus == 1 && $sdcard == null ]]; then echo ""; fi
    if [[ $sdcardstatus == 1 && $sdcard == null ]]; then echo "Otherwise, starting patching will set copying to manual so you will have to copy them later."; fi
    if [[ $sdcardstatus == 1 && $sdcard != null ]]; then echo "Congrats! I've successfully detected your SD Card! Volume name: $sdcard"; fi
    if [[ $sdcardstatus == 1 && $sdcard != null ]]; then echo "I will be able to automatically download and install everything on your SD Card!"; fi
    echo ""
    echo "The entire patching process will download about 30MB of data."
    echo ""
    echo "What's next?"
    if [ $sdcardstatus == 0 ]; then echo "1. Start Patching  2. Exit"; fi
    if [ $sdcardstatus == 1 ]; then echo "1. Start Patching 2. Exit 3. Change volume name"; fi

    read -p "Choose: " s

    if [ "$s" == 1 ]; then number_2_2
    elif [ "$s" == 2 ]; then begin_main
    elif [ "$s" == 3 ]; then number_2_change_volume_name; fi
}

function number_2_change_volume_name {
    clear
    echo "$header"
    echo "-----------------------------------------------------------------------------------------------------------------------------"
    echo "[*] SD Card"
    echo ""
    echo "Current SD Card Volume Name: $sdcard"
    echo ""
    echo "Type in the new volume name (e.g. /Volumes/Wii)"
    read -p "" sdcard

    number_2_1_summary
}

function number_2_2 {
    clear
    counter_done=0
    percent=0

    for i in {0..99}; do
        number_2_3
    done
}

function number_2_3 {
    percent=$((percent+1))
    
    if [[ $percent -gt 0 && $percent -lt 10 ]]; then counter_done=0; fi
    if [[ $percent -ge 10 && $percent -lt 20 ]]; then counter_done=1; fi
    if [[ $percent -ge 20 && $percent -lt 30 ]]; then counter_done=2; fi
    if [[ $percent -ge 30 && $percent -lt 40 ]]; then counter_done=3; fi
    if [[ $percent -ge 40 && $percent -lt 50 ]]; then counter_done=4; fi
    if [[ $percent -ge 50 && $percent -lt 60 ]]; then counter_done=5; fi
    if [[ $percent -ge 60 && $percent -lt 70 ]]; then counter_done=6; fi
    if [[ $percent -ge 70 && $percent -lt 80 ]]; then counter_done=7; fi
    if [[ $percent -ge 80 && $percent -lt 90 ]]; then counter_done=8; fi
    if [[ $percent -ge 90 && $percent -lt 100 ]]; then counter_done=9; fi
    if [ $percent == 100 ]; then counter_done=10; fi

    clear
    echo ""
    echo "$header"
    echo "---------------------------------------------------------------------------------------------------------------------------"
    echo " [*] Patching... this can take some time"
    echo ""
    echo "  Progress:"

    if [ $counter_done == 0 ]; then echo ":          : $percent"; fi
    if [ $counter_done == 1 ]; then echo ":-         : $percent"; fi
    if [ $counter_done == 2 ]; then echo ":--        : $percent"; fi
    if [ $counter_done == 3 ]; then echo ":---       : $percent"; fi
    if [ $counter_done == 4 ]; then echo ":----      : $percent"; fi
    if [ $counter_done == 5 ]; then echo ":-----     : $percent"; fi
    if [ $counter_done == 6 ]; then echo ":------    : $percent"; fi
    if [ $counter_done == 7 ]; then echo ":-------   : $percent"; fi
    if [ $counter_done == 8 ]; then echo ":--------  : $percent"; fi
    if [ $counter_done == 9 ]; then echo ":--------- : $percent"; fi
    if [ $counter_done == 10 ]; then echo ":----------: $percent"; fi

    if [[ $percent == 1 && ! -d "IOSPatcher" ]]; then mkdir IOSPatcher; fi
    if [[ $percent == 1 && ! -f "IOSPatcher/00000006-31.delta" ]]; then curl -s -o "IOSPatcher/00000006-31.delta" "$FilesHostedOn/IOSPatcher/00000006-31.delta" > /dev/null; fi

    if [[ $percent == 2 && ! -f "IOSPatcher/00000006-80.delta" ]]; then curl -s -o "IOSPatcher/00000006-80.delta" "$FilesHostedOn/IOSPatcher/00000006-80.delta" > /dev/null; fi

    if [[ $percent == 4 && ! -f "libWiiSharp.dll" ]]; then curl -s -o "libWiiSharp.dll" "$FilesHostedOn/IOSPatcher/libWiiSharp.dll" > /dev/null; fi

    if [[ $percent == 5 && ! -f "Sharpii.exe" ]]; then curl -s -o "Sharpii.exe" "$FilesHostedOn/IOSPatcher/Sharpii.exe" > /dev/null; fi

    if [[ $percent == 6 && ! -f "WadInstaller.dll" ]]; then curl -s -o "WadInstaller.dll" "$FilesHostedOn/WadInstaller.dll" > /dev/null; fi

    if [[ $percent == 9 && ! -d "EVCPatcher/patch" ]]; then mkdir -p "EVCPatcher/patch"; fi
    if [[ $percent == 9 && ! -d "EVCPatcher/dwn" ]]; then mkdir -p "EVCPatcher/dwn"; fi
    if [[ $percent == 9 && ! -d "EVCPatcher/dwn/0001000148414A45/512" && $evcregion == 2 ]]; then mkdir -p "EVCPatcher/dwn/0001000148414A45/512"; fi
    if [[ $percent == 9 && ! -d "EVCPatcher/dwn/0001000148414A50/512" && $evcregion == 1 ]]; then mkdir -p "EVCPatcher/dwn/0001000148414A50/512"; fi
    if [[ $percent == 0 && ! -f "EVCPatcher/patch/USA.delta" && $evcregion == 2 ]]; then curl -s -o "EVCPatcher/patch/USA.delta" "$FilesHostedOn/EVCPatcher/patch/USA.delta" > /dev/null; fi

    if [[ $percent == 10 && ! -f "EVCPatcher/patch/Europe.delta" && $evcregion == 1 ]]; then curl -s -o "EVCPatcher/patch/Europe.delta" "$FilesHostedOn/EVCPatcher/patch/Europe.delta" > /dev/null; fi

    if [[ $percent == 13 && ! -f "EVCPatcher/dwn/nustool-${machine}" ]]; then curl -s -o "EVCPatcher/dwn/nustool" "$FilesHostedOn/EVCPatcher/nustool-${machine}" > /dev/null; fi
    if [ $percent == 13 ]; then chmod +x "EVCPatcher/dwn/nustool"; fi

    if [[ $percent == 16 && ! -f "EVCPatcher/dwn/0001000148414A45/512/cetk" && $evcregion == 2 ]]; then curl -s -o "EVCPatcher/dwn/0001000148414A45/512/cetk" "$FilesHostedOn/EVCPatcher/dwn/0001000148414A45v512/cetk" > /dev/null; fi
    if [[ $percent == 16 && ! -f "EVCPatcher/dwn/0001000148414A45/512/cert" && $evcregion == 2 ]]; then curl -s -o "EVCPatcher/dwn/0001000148414A45/512/cert" "$FilesHostedOn/EVCPatcher/dwn/0001000148414A45v512/cert" > /dev/null; fi

    if [[ $percent == 17 && ! -f "EVCPatcher/dwn/0001000148414A50/512/cetk" && $evcregion == 1 ]]; then curl -s -o "EVCPatcher/dwn/0001000148414A50/512/cetk" "$FilesHostedOn/EVCPatcher/dwn/0001000148414A50v512/cetk" > /dev/null; fi
    if [[ $percent == 17 && ! -f "EVCPatcher/dwn/0001000148414A50/512/cert" && $evcregion == 1 ]]; then curl -s -o "EVCPatcher/dwn/0001000148414A50/512/cert" "$FilesHostedOn/EVCPatcher/dwn/0001000148414A50v512/cert" > /dev/null; fi

    if [[ $percent == 18 && ! -d "apps" ]]; then mkdir "apps"; fi
    if [[ $percent == 18 && ! -d "apps/Mail-Patcher" ]]; then mkdir "apps/Mail-Patcher"; fi
    if [[ $percent == 18 && ! -f "apps/Mail-Patcher/boot.dol" ]]; then curl -s -o "apps/Mail-Patcher/boot.dol" "$FilesHostedOn/apps/Mail-Patcher/boot.dol" > /dev/null; fi

    if [[ $percent == 19 && ! -f "apps/Mail-Patcher/icon.png" ]]; then curl -s -o "apps/Mail-Patcher/icon.png" "$FilesHostedOn/apps/Mail-Patcher/icon.png" > /dev/null; fi

    if [[ $percent == 20 && ! -f "apps/Mail-Patcher/meta.xml" ]]; then curl -s -o "apps/Mail-Patcher/meta.xml" "$FilesHostedOn/apps/Mail-Patcher/meta.xml" > /dev/null; fi

    if [[ $percent == 21 && ! -d "apps/WiiModLite" ]]; then mkdir -p "apps/WiiModLite"; fi
    if [[ $percent == 21 && ! -f "apps/WiiModLite/boot.dol" ]]; then curl -s -o "apps/WiiModLite/boot.dol" "$FilesHostedOn/apps/WiiModLite/boot.dol" > /dev/null; fi

    if [[ $percent == 23 && ! -f "apps/WiiModLite/icon.png" ]]; then curl -s -o "apps/WiiModLite/icon.png" "$FilesHostedOn/apps/WiiModLite/icon.png" > /dev/null; fi

    if [[ $percent == 25 && ! -f "apps/WiiModLite/meta.xml" ]]; then curl -s -o "apps/WiiModLite/meta.xml" "$FilesHostedOn/apps/WiiModLite/meta.xml" > /dev/null; fi

    if [[ $percent == 26 && ! -f "apps/WiiModLite/wiimod.txt" ]]; then curl -s -o "apps/WiiModLite/wiimod.txt" "$FilesHostedOn/apps/WiiModLite/wiimod.txt" > /dev/null; fi

    if [[ $percent == 27 && ! -f "EVCPatcher/patch/Europe.delta" && $evcregion == 1 ]]; then curl -s -o "EVCPatcher/patch/Europe.delta" "$FilesHostedOn/EVCPatcher/patch/Europe.delta" > /dev/null; fi

    if [[ $percent == 28 && ! -f "EVCPatcher/patch/USA.delta" && $evcregion == 2 ]]; then curl -s -o "EVCPatcher/patch/USA.delta" "$FilesHostedOn/EVCPatcher/patch/USA.delta" > /dev/null; fi

    if [ $percent == 29 ]; then mono Sharpii.exe NUSD -ios 31 -v latest -all; fi
    if [ $percent == 29 ]; then mv "IOS31-64-3608/000000010000001fv3608.wad" "IOSPatcher/IOS31-old.wad"; fi

    if [ $percent == 30 ]; then mono Sharpii.exe NUSD -ios 80 -v latest -all > /dev/null; fi
    if [ $percent == 30 ]; then mv "IOS80-64-6944/0000000100000050v6944.wad" "IOSPatcher/IOS80-old.wad"; fi

    if [ $percent == 31 ]; then mono Sharpii.exe WAD -u "IOSPatcher/IOS31-old.wad" "IOSPatcher/IOS31/" > /dev/null; fi

    if [ $percent == 32 ]; then mono Sharpii.exe WAD -u "IOSPatcher/IOS80-old.wad" "IOSPatcher/IOS80/" > /dev/null; fi

    if [ $percent == 34 ]; then mv "IOSPatcher/IOS31/00000006.app" "IOSPatcher/00000006.app" > /dev/null; fi

    if [ $percent == 36 ]; then xdelta3 -f -d -s "IOSPatcher/00000006.app" "IOSPatcher/00000006-31.delta" "IOSPatcher/IOS31/00000006.app" > /dev/null; fi

    if [ $percent == 38 ]; then mv "IOSPatcher/IOS80/00000006.app" "IOSPatcher/00000006.app" > /dev/null; fi

    if [ $percent == 40 ]; then xdelta3 -f -d -s "IOSPatcher/00000006.app" "IOSPatcher/00000006-80.delta" "IOSPatcher/IOS80/00000006.app" > /dev/null; fi

    if [[ $percent == 42 && ! -d "IOSPatcher/WAD" ]]; then mkdir -p "IOSPatcher/WAD"; fi

    if [ $percent == 44 ]; then mono Sharpii.exe WAD -p "IOSPatcher/IOS31/" "IOSPatcher/WAD/IOS31.wad" -fs > /dev/null; fi

    if [ $percent == 45 ]; then mono Sharpii.exe WAD -p "IOSPatcher/IOS80/" "IOSPatcher/WAD/IOS80.wad" -fs > /dev/null; fi

    if [ $percent == 47 ]; then rm "IOSPatcher/00000006.app"; fi

    if [ $percent == 48 ]; then rm "IOSPatcher/IOS31-old.wad"; fi

    if [ $percent == 49 ]; then rm "IOSPatcher/IOS80-old.wad"; fi

    if [[ $percent == 50 && -d "IOSPatcher/IOS31" ]]; then rm -rf "IOSPatcher/IOS31"; fi

    if [[ $percent == 51 && -d "IOSPatcher/IOS80" ]]; then rm -rf "IOSPatcher/IOS80"; fi

    if [ $percent == 52 ]; then mono Sharpii.exe IOS "IOSPatcher/WAD/IOS31.wad" -fs -es -np -vp > /dev/null; fi

    if [ $percent == 53 ]; then mono Sharpii.exe IOS "IOSPatcher/WAD/IOS80.wad" -fs -es -np -vp > /dev/null; fi

    if [[ $percent == 54 && ! -d "WAD" ]]; then mkdir "WAD"; fi
    if [ $percent == 54 ]; then mv "IOSPatcher/WAD/IOS31.wad" "WAD"; fi
    if [ $percent == 54 ]; then mv "IOSPatcher/WAD/IOS80.wad" "WAD"; fi

    if [[ $percent == 55 && -d "IOSPatcher" ]]; then rm -rf "IOSPatcher"; fi

    if [[ $percent == 57 && ! -d "0001000148414A45/512" && $evcregion == 2 ]]; then mkdir -p "0001000148414A45/512"; fi
    if [[ $percent == 57 && ! -d "0001000148414A50/512" && $evcregion == 1 ]]; then mkdir -p "0001000148414A50/512"; fi
    if [[ $percent == 57 && ! -f "0001000148414A45/512/cetk" && $evcregion == 2 ]]; then cp "EVCPatcher/dwn/0001000148414A45/512/cetk" "0001000148414A45/512/cetk"; fi
    if [[ $percent == 57 && ! -f "0001000148414A50/512/cetk" && $evcregion == 1 ]]; then cp "EVCPatcher/dwn/0001000148414A50/512/cetk" "0001000148414A50/512/cetk"; fi

    if [[ $percent == 60 && $evcregion == 2 ]]; then "EVCPatcher/dwn/nustool" -K "4fcb81ec20d5177f542311905d72886f" -p -m "0001000148414A45"; fi
    if [[ $percent == 60 && $evcregion == 2 ]]; then mv 0001000148414a45/512/* EVCPatcher/dwn/0001000148414A45/512/; fi
    if [[ $percent == 60 && $evcregion == 1 ]]; then "EVCPatcher/dwn/nustool" -K "aef74d7c37f1f2bbe76d4e6f5e0b15a4" -p -m "0001000148414A50"; fi
    if [[ $percent == 60 && $evcregion == 1 ]]; then mv 0001000148414a50/512/* EVCPatcher/dwn/0001000148414A50/512/; fi

    if [[ $percent == 61 && $evcregion == 2 ]]; then cp "EVCPatcher/dwn/0001000148414A45/512/00000018" "0001000148414A45/512/00000000.app"; fi
    if [[ $percent == 61 && $evcregion == 2 ]]; then cp "EVCPatcher/dwn/0001000148414A45/512/00000019" "0001000148414A45/512/00000001.app"; fi
    if [[ $percent == 61 && $evcregion == 2 ]]; then cp "EVCPatcher/dwn/0001000148414A45/512/00000002" "0001000148414A45/512/00000002.app"; fi
    if [[ $percent == 61 && $evcregion == 2 ]]; then cp "EVCPatcher/dwn/0001000148414A45/512/00000003" "0001000148414A45/512/00000003.app"; fi
    if [[ $percent == 61 && $evcregion == 2 ]]; then cp "EVCPatcher/dwn/0001000148414A45/512/00000004" "0001000148414A45/512/00000004.app"; fi
    if [[ $percent == 61 && $evcregion == 2 ]]; then cp "EVCPatcher/dwn/0001000148414A45/512/0000001a" "0001000148414A45/512/00000005.app"; fi
    if [[ $percent == 61 && $evcregion == 2 ]]; then cp "EVCPatcher/dwn/0001000148414A45/512/0000001b" "0001000148414A45/512/00000006.app"; fi
    if [[ $percent == 61 && $evcregion == 2 ]]; then cp "EVCPatcher/dwn/0001000148414A45/512/00000007" "0001000148414A45/512/00000007.app"; fi
    if [[ $percent == 61 && $evcregion == 2 ]]; then cp "EVCPatcher/dwn/0001000148414A45/512/00000008" "0001000148414A45/512/00000008.app"; fi
    if [[ $percent == 61 && $evcregion == 2 ]]; then cp "EVCPatcher/dwn/0001000148414A45/512/00000010" "0001000148414A45/512/00000009.app"; fi
    if [[ $percent == 61 && $evcregion == 2 ]]; then cp "EVCPatcher/dwn/0001000148414A45/512/0000001c" "0001000148414A45/512/0000000a.app"; fi
    if [[ $percent == 61 && $evcregion == 2 ]]; then cp "EVCPatcher/dwn/0001000148414A45/512/0000000b" "0001000148414A45/512/0000000b.app"; fi
    if [[ $percent == 61 && $evcregion == 2 ]]; then cp "EVCPatcher/dwn/0001000148414A45/512/0000000c" "0001000148414A45/512/0000000c.app"; fi
    if [[ $percent == 61 && $evcregion == 2 ]]; then cp "EVCPatcher/dwn/0001000148414A45/512/0000001d" "0001000148414A45/512/0000000d.app"; fi
    if [[ $percent == 61 && $evcregion == 2 ]]; then cp "EVCPatcher/dwn/0001000148414A45/512/cert" "0001000148414A45/512/0001000148414a45.cert"; fi
    if [[ $percent == 61 && $evcregion == 2 ]]; then cp "EVCPatcher/dwn/0001000148414A45/512/00000018" "0001000148414A45/512/0001000148414a45.footer"; fi
    if [[ $percent == 61 && $evcregion == 2 ]]; then cp "EVCPatcher/dwn/0001000148414A45/512/cetk" "0001000148414A45/512/0001000148414a45.tik"; fi
    if [[ $percent == 61 && $evcregion == 2 ]]; then cp "EVCPatcher/dwn/0001000148414A45/512/tmd" "0001000148414A45/512/0001000148414a45.tmd"; fi
    if [[ $percent == 61 && $evcregion == 1 ]]; then cp "EVCPatcher/dwn/0001000148414A50/512/00000018" "0001000148414A50/512/00000000.app"; fi
    if [[ $percent == 61 && $evcregion == 1 ]]; then cp "EVCPatcher/dwn/0001000148414A50/512/00000019" "0001000148414A50/512/00000001.app"; fi
    if [[ $percent == 61 && $evcregion == 1 ]]; then cp "EVCPatcher/dwn/0001000148414A50/512/00000002" "0001000148414A50/512/00000002.app"; fi
    if [[ $percent == 61 && $evcregion == 1 ]]; then cp "EVCPatcher/dwn/0001000148414A50/512/00000003" "0001000148414A50/512/00000003.app"; fi
    if [[ $percent == 61 && $evcregion == 1 ]]; then cp "EVCPatcher/dwn/0001000148414A50/512/00000004" "0001000148414A50/512/00000004.app"; fi
    if [[ $percent == 61 && $evcregion == 1 ]]; then cp "EVCPatcher/dwn/0001000148414A50/512/0000001a" "0001000148414A50/512/00000005.app"; fi
    if [[ $percent == 61 && $evcregion == 1 ]]; then cp "EVCPatcher/dwn/0001000148414A50/512/0000001b" "0001000148414A50/512/00000006.app"; fi
    if [[ $percent == 61 && $evcregion == 1 ]]; then cp "EVCPatcher/dwn/0001000148414A50/512/00000007" "0001000148414A50/512/00000007.app"; fi
    if [[ $percent == 61 && $evcregion == 1 ]]; then cp "EVCPatcher/dwn/0001000148414A50/512/00000008" "0001000148414A50/512/00000008.app"; fi
    if [[ $percent == 61 && $evcregion == 1 ]]; then cp "EVCPatcher/dwn/0001000148414A50/512/00000010" "0001000148414A50/512/00000009.app"; fi
    if [[ $percent == 61 && $evcregion == 1 ]]; then cp "EVCPatcher/dwn/0001000148414A50/512/0000001c" "0001000148414A50/512/0000000a.app"; fi
    if [[ $percent == 61 && $evcregion == 1 ]]; then cp "EVCPatcher/dwn/0001000148414A50/512/0000000b" "0001000148414A50/512/0000000b.app"; fi
    if [[ $percent == 61 && $evcregion == 1 ]]; then cp "EVCPatcher/dwn/0001000148414A50/512/0000000c" "0001000148414A50/512/0000000c.app"; fi
    if [[ $percent == 61 && $evcregion == 1 ]]; then cp "EVCPatcher/dwn/0001000148414A50/512/0000001d" "0001000148414A50/512/0000000d.app"; fi
    if [[ $percent == 61 && $evcregion == 1 ]]; then cp "EVCPatcher/dwn/0001000148414A50/512/cert" "0001000148414A50/512/0001000148414a50.cert"; fi
    if [[ $percent == 61 && $evcregion == 1 ]]; then cp "EVCPatcher/dwn/0001000148414A50/512/00000018" "0001000148414A50/512/0001000148414a50.footer"; fi
    if [[ $percent == 61 && $evcregion == 1 ]]; then cp "EVCPatcher/dwn/0001000148414A50/512/cetk" "0001000148414A50/512/0001000148414a50.tik"; fi
    if [[ $percent == 61 && $evcregion == 1 ]]; then cp "EVCPatcher/dwn/0001000148414A50/512/tmd" "0001000148414A50/512/0001000148414a50.tmd"; fi

    if [[ $percent == 63 && $evcregion == 2 ]]; then xdelta3 -f -d -s "0001000148414A45/512/00000001.app" "EVCPatcher/patch/USA.delta" "0001000148414A45/512/00000001.app"; fi
    if [[ $percent == 63 && $evcregion == 1 ]]; then xdelta3 -f -d -s "0001000148414A50/512/00000001.app" "EVCPatcher/patch/Europe.delta" "0001000148414A50/512/00000001.app"; fi

    if [[ $percent == 80 && $evcregion == 2 ]]; then mono Sharpii.exe WAD -p "0001000148414A45/512/" "WAD/Everybody Votes Channel RiiConnect24 USA.wad" -f; fi
    if [[ $percent == 80 && $evcregion == 1 ]]; then mono Sharpii.exe WAD -p "0001000148414A50/512/" "WAD/Everybody Votes Channel RiiConnect24 Europe.wad" -f; fi

    if [[ $percent == 85 && $sdcard != null ]]; then errorcopying=0; fi
    if [[ $percent == 85 && ! -d "$sdcard/WAD" && $sdcard != null ]]; then mkdir "$sdcard/WAD"; fi
    if [[ $percent == 85 && $sdcard != null && "$?" -ne "0" ]]; then errorcopying=1; fi
    if [[ $percent == 85 && ! -d "$sdcard/WAD" && $sdcard != null ]]; then cp "WAD/*" "$sdcard/WAD"; fi
    if [[ $percent == 85 && $sdcard != null && "$?" -ne "0" ]]; then errorcopying=1; fi
    if [[ $percent == 85 && $sdcard != null ]]; then cp -r "apps/*" "$sdcard/apps"; fi
    if [[ $percent == 85 && $sdcard != null && "$?" -ne "0" ]]; then errorcopying=1; fi

    if [[ $percent == 99 && -d "0001000148414A45" ]]; then rm -rf "0001000148414A45"; fi
    if [[ $percent == 99 && -d "0001000148414a45" ]]; then rm -rf "0001000148414a45"; fi
    if [[ $percent == 99 && -d "0001000148414A50" ]]; then rm -rf "0001000148414A50"; fi
    if [[ $percent == 99 && -d "0001000148414a50" ]]; then rm -rf "0001000148414a50"; fi
    if [[ $percent == 99 && -d "IOSPatcher" ]]; then rm -rf "IOSPatcher"; fi
    if [[ $percent == 99 && -d "EVCPatcher" ]]; then rm -rf "EVCPatcher"; fi
    if [[ $percent == 99 && -d "IOS31-64-3608" ]]; then rm -rf "IOS31-64-3608"; fi
    if [[ $percent == 99 && -d "IOS80-64-6944" ]]; then rm -rf "IOS80-64-6944"; fi
    if [[ $percent == 99 && -f ../$(basename "$PWD")"\libWiiSharp.dll" ]]; then rm -rf ../$(basename "$PWD")"\libWiiSharp.dll"; fi
    if [[ $percent == 99 && -f "00000001.app" ]]; then rm -rf "00000001.app"; fi
    if [[ $percent == 99 && -f "libWiiSharp.dll" ]]; then rm -rf "libWiiSharp.dll"; fi
    if [[ $percent == 99 && -f "Sharpii.exe" ]]; then rm -rf "Sharpii.exe"; fi
    if [[ $percent == 99 && -f "WadInstaller.dll" ]]; then rm -rf "WadInstaller.dll"; fi

    if [ $percent == 100 ]; then number_2_4; fi
}

function number_2_4 {
    clear
    echo $header
    echo "---------------------------------------------------------------------------------------------------------------------------"
    echo "Patching done!"
    echo ""
    if [ $sdcardstatus == 0 ]; then echo "Please connect your Wii SD Card and copy the "apps" and "WAD" folders to the root (main folder) of your SD Card. You can find these folders next to RiiConnect24Patcher.sh"; fi
    if [[ $sdcardstatus == 1 && $sdcard == null ]]; then echo "Please connect your Wii SD Card and copy the "apps" and "WAD" folders to the root (main folder) of your SD Card. You can find these folders next to RiiConnect24Patcher.sh"; fi

    if [[ $sdcardstatus == 1 && $sdcard == null && $errorcopying == 0 ]]; then "Every file is in its place on your SD Card!"; fi
    if [[ $sdcardstatus == 1 && $sdcard == null && $errorcopying == 1 ]]; then echo "Unfortunately, I wasn't able to put some of the files on your SD Card. Please copy the "apps" and "WAD" folders to the root (main folder) of your SD Card. You can find these folders next to RiiConnect24Patcher.sh"; fi

    echo ""
    echo "Please proceed with the tutorial that you can find on https://wii.guide/riiconnect24"
    echo ""
    read -n 1 -s -r -p "Press any key to close this patcher."

    end
}

function end {
    clear
    exiting=10

    for i in {10..0}; do
        end_1
    done
}

function end_1 {
    exiting=$((exiting-1))

    clear
    echo ""
    echo $header
    echo "---------------------------------------------------------------------------------------------------------------------------"
    echo " [*] Thank you very much for using this patcher! :)"
    echo ""
    echo "Have fun using RiiConnect24!"
    echo ""
    echo "Closing the patcher in:"

    if [ $exiting == 10 ]; then echo ":----------: 10"; fi
    if [ $exiting == 9 ]; then echo ":--------- : 9"; fi
    if [ $exiting == 8 ]; then echo ":--------  : 8"; fi
    if [ $exiting == 7 ]; then echo ":-------   : 7"; fi
    if [ $exiting == 6 ]; then echo ":------    : 6"; fi
    if [ $exiting == 5 ]; then echo ":-----     : 5"; fi
    if [ $exiting == 4 ]; then echo ":----      : 4"; fi
    if [ $exiting == 3 ]; then echo ":---       : 3"; fi
    if [ $exiting == 2 ]; then echo ":--        : 2"; fi
    if [ $exiting == 1 ]; then echo ":-         : 1"; fi
    if [ $exiting == 0 ]; then echo ":          :"; fi
    if [ $exiting == 0 ]; then exit; fi

    sleep 1
}

function number_2_manual {
    clear
    echo $header
    echo "-----------------------------------------------------------------------------------------------------------------------------"
    echo ""
    echo "RiiConnect24 Patcher Manual Mode."

    if [ $tempiospatcher == 1 ]; then echo "--- Patching IOS Complete ---"; fi
    if [ $tempiospatcher == 1 ]; then echo "Please copy IOS31.wad and IOS80.wad inside the WAD folder to your Wii SD Card."; fi
    if [ $tempevcpatcher == 1 ]; then echo "--- Patching Everybody Votes Channel Complete ---"; fi
    if [ $tempevcpatcher == 1 ]; then echo "Please copy the Everybody Votes Channel.wad file inside the WAD folder to your Wii SD Card."; fi
    if [ $tempsdcardapps == 1 ]; then echo "--- Downloading Apps Complete ---"; fi
    if [ $tempsdcardapps == 1 ]; then echo "Please copy the apps folder to your Wii SD Card."; fi

    echo ""
    echo "Please choose what you want to patch."
    echo ""
    echo "1. Patch RiiConnect24 IOS 31 and IOS 80"
    echo "2. Patch Everybody Votes Channel"
    echo "3. Download Wii Mod Lite and Mail Patcher"
    echo "R. Return to previous menu"
    echo ""
    read -p "Choose: " s

    if [ "$s" == "1" ]; then number_3_iospatch
    elif [ "$s" == "2" ]; then number_3_evc_patch
    elif [ "$s" == "3" ]; then number_3_download
    elif [ "$s" == "r" ]; then number_1
    elif [ "$s" == "R" ]; then number_1; fi

    number_2_manual
}

function number_3_iospatch {
    clear
    echo ""
    echo $header
    echo "---------------------------------------------------------------------------------------------------------------------------"
    echo " [*] Patching IOS's... this can take some time."

    if [ ! -d "IOSPatcher" ]; then mkdir IOSPatcher; fi
    if [ ! -f "IOSPatcher/00000006-31.delta" ]; then curl -s -o "IOSPatcher/00000006-31.delta" "$FilesHostedOn/IOSPatcher/00000006-31.delta" > /dev/null; fi

    if [ ! -f "IOSPatcher/00000006-80.delta" ]; then curl -s -o "IOSPatcher/00000006-80.delta" "$FilesHostedOn/IOSPatcher/00000006-80.delta" > /dev/null; fi

    if [ ! -f "libWiiSharp.dll" ]; then curl -s -o "libWiiSharp.dll" "$FilesHostedOn/IOSPatcher/libWiiSharp.dll" > /dev/null; fi

    if [ ! -f "Sharpii.exe" ]; then curl -s -o "Sharpii.exe" "$FilesHostedOn/IOSPatcher/Sharpii.exe" > /dev/null; fi

    if [ ! -f "WadInstaller.dll" ]; then curl -s -o "WadInstaller.dll" "$FilesHostedOn/WadInstaller.dll" > /dev/null; fi

    if [ -f "libWiiSharp.dll" ]; then cp "libWiiSharp.dll" ../$(basename "$PWD")"\libWiiSharp.dll"; fi

    mono Sharpii.exe NUSD -ios 31 -v latest -all > /dev/null
    mv "IOS31-64-3608/000000010000001fv3608.wad" "IOSPatcher/IOS31-old.wad"

    mono Sharpii.exe NUSD -ios 80 -v latest -all > /dev/null
    mv "IOS80-64-6944/0000000100000050v6944.wad" "IOSPatcher/IOS80-old.wad"

    mono Sharpii.exe WAD -u "IOSPatcher/IOS31-old.wad" "IOSPatcher/IOS31/" > /dev/null

    mono Sharpii.exe WAD -u "IOSPatcher/IOS80-old.wad" "IOSPatcher/IOS80/" > /dev/null

    mv "IOSPatcher/IOS31/00000006.app" "IOSPatcher/00000006.app" > /dev/null

    xdelta3 -f -d -s "IOSPatcher/00000006.app" "IOSPatcher/00000006-31.delta" "IOSPatcher/IOS31/00000006.app" > /dev/null

    mv "IOSPatcher/IOS80/00000006.app" "IOSPatcher/00000006.app" > /dev/null

    xdelta3 -f -d -s "IOSPatcher/00000006.app" "IOSPatcher/00000006-80.delta" "IOSPatcher/IOS80/00000006.app" > /dev/null

    if [ ! -d "IOSPatcher/WAD" ]; then mkdir -p "IOSPatcher/WAD"; fi

    mono Sharpii.exe WAD -p "IOSPatcher/IOS31/" "IOSPatcher/WAD/IOS31.wad" -fs > /dev/null

    mono Sharpii.exe WAD -p "IOSPatcher/IOS80/" "IOSPatcher/WAD/IOS80.wad" -fs > /dev/null

    rm "IOSPatcher/00000006.app"

    rm "IOSPatcher/IOS31-old.wad"

    rm "IOSPatcher/IOS80-old.wad"

    if [ -d "IOSPatcher/IOS31" ]; then rm -rf "IOSPatcher/IOS31"; fi

    if [ -d "IOSPatcher/IOS80" ]; then rm -rf "IOSPatcher/IOS80"; fi

    mono Sharpii.exe IOS "IOSPatcher/WAD/IOS31.wad" -fs -es -np -vp > /dev/null

    mono Sharpii.exe IOS "IOSPatcher/WAD/IOS80.wad" -fs -es -np -vp > /dev/null

    if [[ ! -d "WAD" ]]; then mkdir "WAD"; fi
    mv "IOSPatcher/WAD/IOS31.wad" "WAD"
    mv "IOSPatcher/WAD/IOS80.wad" "WAD"

    if [ -d "IOSPatcher" ]; then rm -rf "IOSPatcher"; fi
    if [ -d "IOS31-64-3608" ]; then rm -rf "IOS31-64-3608"; fi
    if [ -d "IOS80-64-6944" ]; then rm -rf "IOS80-64-6944"; fi
    if [ -f ../$(basename "$PWD")"\libWiiSharp.dll" ]; then rm -rf ../$(basename "$PWD")"\libWiiSharp.dll"; fi
    if [ -f "libWiiSharp.dll" ]; then rm -rf "libWiiSharp.dll"; fi
    if [ -f "Sharpii.exe" ]; then rm -rf "Sharpii.exe"; fi
    if [ -f "WadInstaller.dll" ]; then rm -rf "WadInstaller.dll"; fi

    tempiospatcher=1
}

function number_3_evc_patch {
    clear
    echo ""
    echo "$header"
    echo "---------------------------------------------------------------------------------------------------------------------------"
    echo " [*] Everybody Votes Channel Region"
    echo ""
    echo "Which region should I patch?"
    echo ""
    echo "1. Europe"
    echo "2. USA"
    read -p "Choose: " s

    if [ "$s" == "1" ]; then evcregion=1
    elif [ "$s" == "2" ]; then evcregion=2; fi

    number_3_evc_patch_2
}

function number_3_evc_patch_2 {
    clear
    echo ""
    echo $header
    echo "---------------------------------------------------------------------------------------------------------------------------"
    echo " [*] Patching Everybody Votes Channel... this can take some time"
    echo ""

    if [ ! -f "libWiiSharp.dll" ]; then curl -s -o "libWiiSharp.dll" "$FilesHostedOn/IOSPatcher/libWiiSharp.dll" > /dev/null; fi

    if [ ! -f "Sharpii.exe" ]; then curl -s -o "Sharpii.exe" "$FilesHostedOn/IOSPatcher/Sharpii.exe" > /dev/null; fi

    if [ ! -f "WadInstaller.dll" ]; then curl -s -o "WadInstaller.dll" "$FilesHostedOn/WadInstaller.dll" > /dev/null; fi

    if [ -f "libWiiSharp.dll" ]; then cp "libWiiSharp.dll" ../$(basename "$PWD")"\libWiiSharp.dll"; fi

    if [ ! -d "EVCPatcher/patch" ]; then mkdir -p "EVCPatcher/patch"; fi
    if [ ! -d "EVCPatcher/dwn" ]; then mkdir -p "EVCPatcher/dwn"; fi
    if [[ ! -d "EVCPatcher/dwn/0001000148414A45/512" && $evcregion == 2 ]]; then mkdir -p "EVCPatcher/dwn/0001000148414A45/512"; fi
    if [[ ! -d "EVCPatcher/dwn/0001000148414A50/512" && $evcregion == 1 ]]; then mkdir -p "EVCPatcher/dwn/0001000148414A50/512"; fi
    if [[ ! -f "EVCPatcher/patch/USA.delta" && $evcregion == 2 ]]; then curl -s -o "EVCPatcher/patch/USA.delta" "$FilesHostedOn/EVCPatcher/patch/USA.delta" > /dev/null; fi

    if [[ ! -f "EVCPatcher/patch/Europe.delta" && $evcregion == 1 ]]; then curl -s -o "EVCPatcher/patch/Europe.delta" "$FilesHostedOn/EVCPatcher/patch/Europe.delta" > /dev/null; fi

    if [ ! -f "EVCPatcher/dwn/nustool-${machine}" ]; then curl -s -o "EVCPatcher/dwn/nustool" "$FilesHostedOn/EVCPatcher/nustool-${machine}" > /dev/null; fi
    chmod +x "EVCPatcher/dwn/nustool"

    if [[ ! -f "EVCPatcher/dwn/0001000148414A45/512/cetk" && $evcregion == 2 ]]; then curl -s -o "EVCPatcher/dwn/0001000148414A45/512/cetk" "$FilesHostedOn/EVCPatcher/dwn/0001000148414A45v512/cetk" > /dev/null; fi
    if [[ ! -f "EVCPatcher/dwn/0001000148414A45/512/cert" && $evcregion == 2 ]]; then curl -s -o "EVCPatcher/dwn/0001000148414A45/512/cert" "$FilesHostedOn/EVCPatcher/dwn/0001000148414A45v512/cert" > /dev/null; fi

    if [[ ! -f "EVCPatcher/dwn/0001000148414A50/512/cetk" && $evcregion == 1 ]]; then curl -s -o "EVCPatcher/dwn/0001000148414A50/512/cetk" "$FilesHostedOn/EVCPatcher/dwn/0001000148414A50v512/cetk" > /dev/null; fi
    if [[ ! -f "EVCPatcher/dwn/0001000148414A50/512/cert" && $evcregion == 1 ]]; then curl -s -o "EVCPatcher/dwn/0001000148414A50/512/cert" "$FilesHostedOn/EVCPatcher/dwn/0001000148414A50v512/cert" > /dev/null; fi

    if [[ ! -d "0001000148414A45/512" && $evcregion == 2 ]]; then mkdir -p "0001000148414A45/512"; fi
    if [[ ! -d "0001000148414A50/512" && $evcregion == 1 ]]; then mkdir -p "0001000148414A50/512"; fi
    if [[ ! -f "0001000148414A45/512/cetk" && $evcregion == 2 ]]; then cp "EVCPatcher/dwn/0001000148414A45/512/cetk" "0001000148414A45/512/cetk"; fi
    if [[ ! -f "0001000148414A50/512/cetk" && $evcregion == 1 ]]; then cp "EVCPatcher/dwn/0001000148414A50/512/cetk" "0001000148414A50/512/cetk"; fi

    if [ $evcregion == 2 ]; then "EVCPatcher/dwn/nustool" -K "4fcb81ec20d5177f542311905d72886f" -p -m "0001000148414A45"; fi
    if [ $evcregion == 2 ]; then mv 0001000148414a45/512/* EVCPatcher/dwn/0001000148414A45/512/; fi
    if [ $evcregion == 1 ]; then "EVCPatcher/dwn/nustool" -K "aef74d7c37f1f2bbe76d4e6f5e0b15a4" -p -m "0001000148414A50"; fi
    if [ $evcregion == 1 ]; then mv 0001000148414a50/512/* EVCPatcher/dwn/0001000148414A50/512/; fi

    if [ $evcregion == 2 ]; then cp "EVCPatcher/dwn/0001000148414A45/512/00000018" "0001000148414A45/512/00000000.app"; fi
    if [ $evcregion == 2 ]; then cp "EVCPatcher/dwn/0001000148414A45/512/00000019" "0001000148414A45/512/00000001.app"; fi
    if [ $evcregion == 2 ]; then cp "EVCPatcher/dwn/0001000148414A45/512/00000002" "0001000148414A45/512/00000002.app"; fi
    if [ $evcregion == 2 ]; then cp "EVCPatcher/dwn/0001000148414A45/512/00000003" "0001000148414A45/512/00000003.app"; fi
    if [ $evcregion == 2 ]; then cp "EVCPatcher/dwn/0001000148414A45/512/00000004" "0001000148414A45/512/00000004.app"; fi
    if [ $evcregion == 2 ]; then cp "EVCPatcher/dwn/0001000148414A45/512/0000001a" "0001000148414A45/512/00000005.app"; fi
    if [ $evcregion == 2 ]; then cp "EVCPatcher/dwn/0001000148414A45/512/0000001b" "0001000148414A45/512/00000006.app"; fi
    if [ $evcregion == 2 ]; then cp "EVCPatcher/dwn/0001000148414A45/512/00000007" "0001000148414A45/512/00000007.app"; fi
    if [ $evcregion == 2 ]; then cp "EVCPatcher/dwn/0001000148414A45/512/00000008" "0001000148414A45/512/00000008.app"; fi
    if [ $evcregion == 2 ]; then cp "EVCPatcher/dwn/0001000148414A45/512/00000010" "0001000148414A45/512/00000009.app"; fi
    if [ $evcregion == 2 ]; then cp "EVCPatcher/dwn/0001000148414A45/512/0000001c" "0001000148414A45/512/0000000a.app"; fi
    if [ $evcregion == 2 ]; then cp "EVCPatcher/dwn/0001000148414A45/512/0000000b" "0001000148414A45/512/0000000b.app"; fi
    if [ $evcregion == 2 ]; then cp "EVCPatcher/dwn/0001000148414A45/512/0000000c" "0001000148414A45/512/0000000c.app"; fi
    if [ $evcregion == 2 ]; then cp "EVCPatcher/dwn/0001000148414A45/512/0000001d" "0001000148414A45/512/0000000d.app"; fi
    if [ $evcregion == 2 ]; then cp "EVCPatcher/dwn/0001000148414A45/512/cert" "0001000148414A45/512/0001000148414a45.cert"; fi
    if [ $evcregion == 2 ]; then cp "EVCPatcher/dwn/0001000148414A45/512/00000018" "0001000148414A45/512/0001000148414a45.footer"; fi
    if [ $evcregion == 2 ]; then cp "EVCPatcher/dwn/0001000148414A45/512/cetk" "0001000148414A45/512/0001000148414a45.tik"; fi
    if [ $evcregion == 2 ]; then cp "EVCPatcher/dwn/0001000148414A45/512/tmd" "0001000148414A45/512/0001000148414a45.tmd"; fi
    if [ $evcregion == 1 ]; then cp "EVCPatcher/dwn/0001000148414A50/512/00000018" "0001000148414A50/512/00000000.app"; fi
    if [ $evcregion == 1 ]; then cp "EVCPatcher/dwn/0001000148414A50/512/00000019" "0001000148414A50/512/00000001.app"; fi
    if [ $evcregion == 1 ]; then cp "EVCPatcher/dwn/0001000148414A50/512/00000002" "0001000148414A50/512/00000002.app"; fi
    if [ $evcregion == 1 ]; then cp "EVCPatcher/dwn/0001000148414A50/512/00000003" "0001000148414A50/512/00000003.app"; fi
    if [ $evcregion == 1 ]; then cp "EVCPatcher/dwn/0001000148414A50/512/00000004" "0001000148414A50/512/00000004.app"; fi
    if [ $evcregion == 1 ]; then cp "EVCPatcher/dwn/0001000148414A50/512/0000001a" "0001000148414A50/512/00000005.app"; fi
    if [ $evcregion == 1 ]; then cp "EVCPatcher/dwn/0001000148414A50/512/0000001b" "0001000148414A50/512/00000006.app"; fi
    if [ $evcregion == 1 ]; then cp "EVCPatcher/dwn/0001000148414A50/512/00000007" "0001000148414A50/512/00000007.app"; fi
    if [ $evcregion == 1 ]; then cp "EVCPatcher/dwn/0001000148414A50/512/00000008" "0001000148414A50/512/00000008.app"; fi
    if [ $evcregion == 1 ]; then cp "EVCPatcher/dwn/0001000148414A50/512/00000010" "0001000148414A50/512/00000009.app"; fi
    if [ $evcregion == 1 ]; then cp "EVCPatcher/dwn/0001000148414A50/512/0000001c" "0001000148414A50/512/0000000a.app"; fi
    if [ $evcregion == 1 ]; then cp "EVCPatcher/dwn/0001000148414A50/512/0000000b" "0001000148414A50/512/0000000b.app"; fi
    if [ $evcregion == 1 ]; then cp "EVCPatcher/dwn/0001000148414A50/512/0000000c" "0001000148414A50/512/0000000c.app"; fi
    if [ $evcregion == 1 ]; then cp "EVCPatcher/dwn/0001000148414A50/512/0000001d" "0001000148414A50/512/0000000d.app"; fi
    if [ $evcregion == 1 ]; then cp "EVCPatcher/dwn/0001000148414A50/512/cert" "0001000148414A50/512/0001000148414a50.cert"; fi
    if [ $evcregion == 1 ]; then cp "EVCPatcher/dwn/0001000148414A50/512/00000018" "0001000148414A50/512/0001000148414a50.footer"; fi
    if [ $evcregion == 1 ]; then cp "EVCPatcher/dwn/0001000148414A50/512/cetk" "0001000148414A50/512/0001000148414a50.tik"; fi
    if [ $evcregion == 1 ]; then cp "EVCPatcher/dwn/0001000148414A50/512/tmd" "0001000148414A50/512/0001000148414a50.tmd"; fi

    if [ $evcregion == 2 ]; then xdelta3 -f -d -s "0001000148414A45/512/00000001.app" "EVCPatcher/patch/USA.delta" "0001000148414A45/512/00000001.app"; fi
    if [ $evcregion == 1 ]; then xdelta3 -f -d -s "0001000148414A50/512/00000001.app" "EVCPatcher/patch/Europe.delta" "0001000148414A50/512/00000001.app"; fi

    if [ $evcregion == 2 ]; then mono Sharpii.exe WAD -p "0001000148414A45/512/" "WAD/Everybody Votes Channel RiiConnect24 USA.wad" -f; fi
    if [ $evcregion == 1 ]; then mono Sharpii.exe WAD -p "0001000148414A50/512/" "WAD/Everybody Votes Channel RiiConnect24 Europe.wad" -f; fi

    if [ -d "0001000148414A45" ]; then rm -rf "0001000148414A45"; fi
    if [ -d "0001000148414a45" ]; then rm -rf "0001000148414a45"; fi
    if [ -d "0001000148414A50" ]; then rm -rf "0001000148414A50"; fi
    if [ -d "0001000148414a50" ]; then rm -rf "0001000148414a50"; fi
    if [ -d "EVCPatcher" ]; then rm -rf "EVCPatcher"; fi
    if [ -f ../$(basename "$PWD")"\libWiiSharp.dll" ]; then rm -rf ../$(basename "$PWD")"\libWiiSharp.dll"; fi
    if [ -f "00000001.app" ]; then rm -rf "00000001.app"; fi
    if [ -f "libWiiSharp.dll" ]; then rm -rf "libWiiSharp.dll"; fi
    if [ -f "Sharpii.exe" ]; then rm -rf "Sharpii.exe"; fi
    if [ -f "WadInstaller.dll" ]; then rm -rf "WadInstaller.dll"; fi

    tempevcpatcher=1
}

function number_3_download {
    clear
    echo ""
    echo "$header"
    echo "---------------------------------------------------------------------------------------------------------------------------"
    echo " [*] Downloading apps... this can take some time."
    echo ""

    if [ ! -d "apps" ]; then mkdir "apps"; fi
    if [ ! -d "apps/Mail-Patcher" ]; then mkdir "apps/Mail-Patcher"; fi
    if [ ! -f "apps/Mail-Patcher/boot.dol" ]; then curl -s -o "apps/Mail-Patcher/boot.dol" "$FilesHostedOn/apps/Mail-Patcher/boot.dol" > /dev/null; fi
    if [ ! -f "apps/Mail-Patcher/icon.png" ]; then curl -s -o "apps/Mail-Patcher/icon.png" "$FilesHostedOn/apps/Mail-Patcher/icon.png" > /dev/null; fi
    if [ ! -f "apps/Mail-Patcher/meta.xml" ]; then curl -s -o "apps/Mail-Patcher/meta.xml" "$FilesHostedOn/apps/Mail-Patcher/meta.xml" > /dev/null; fi
    if [ ! -d "apps/WiiModLite" ]; then mkdir -p "apps/WiiModLite"; fi
    if [ ! -f "apps/WiiModLite/boot.dol" ]; then curl -s -o "apps/WiiModLite/boot.dol" "$FilesHostedOn/apps/WiiModLite/boot.dol" > /dev/null; fi
    if [ ! -f "apps/WiiModLite/icon.png" ]; then curl -s -o "apps/WiiModLite/icon.png" "$FilesHostedOn/apps/WiiModLite/icon.png" > /dev/null; fi
    if [ ! -f "apps/WiiModLite/meta.xml" ]; then curl -s -o "apps/WiiModLite/meta.xml" "$FilesHostedOn/apps/WiiModLite/meta.xml" > /dev/null; fi
    if [ ! -f "apps/WiiModLite/wiimod.txt" ]; then curl -s -o "apps/WiiModLite/wiimod.txt" "$FilesHostedOn/apps/WiiModLite/wiimod.txt" > /dev/null; fi\

    tempsdcardapps=1
}

if [ "$p" == "1" ]; then number_1
elif [ "$p" == "2" ]; then credits; fi
