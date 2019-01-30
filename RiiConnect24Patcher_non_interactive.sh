#!/bin/bash

# Credits and usage
################################################################################
function credits {
    echo "
---------------------------------------------------------------------------------------------------------------------------
Forked Non Interactive RiiConnect24 Patcher for RiiConnect24 by odrevet
---------------------------------------------------------------------------------------------------------------------------
RiiConnect24 Patcher - (C) KcrPL, (C) Larsenv, (C) Apfel
Original Interactive RiiConnect24 Patcher for RiiConnect24
Created by:
- KcrPL
Main Windows patcher, UI, scripts.
- Larsenv
Help with scripts, main Mac/Linux pather, original IOS Patcher script. Overall help with scripts and commands syntax.

- ApfelTV
Help with Everybody Votes Channel patching and Sharpii syntax.

- Brawl345
Help with resolving ticket issues.

For the entire RiiConnect24 Community.
Want to contact us? Mail us at support@riiconnect24.net"
}

function usage {
    echo "-h print this help and quit
-a ACTION
  help: print this help
  credits: print credits
  apps: download and apply patch on apps (MailPatcher and WiiModeLite)
  ios: download and apply patch on IOS
  evc: download and apply patch on Everybody Vote Channel
-r REGION set region
  EUR: Set region to Europe
  USA: Set Region to USA"
}

# Variable initialization and Arguments parse
################################################################################
OPTIND=1

evcregion=""
cleanup=true
action="help"
FilesHostedOn="https://raw.githubusercontent.com/KcrPL/KcrPL.github.io/master/Patchers_Auto_Update/RiiConnect24Patcher"
dl_cmd="curl -s -o"

while getopts "h?r:a:" opt; do
    case "$opt" in
    h|\?)
        usage
        exit 0
        ;;
    r)  evcregion=$OPTARG
        ;;
    a)  action=$OPTARG
        ;;
    esac
done

shift $((OPTIND-1))
[ "${1:-}" = "--" ] && shift

# check OS, required dependencies and evc region
################################################################################

function set_machine {
    unameOut="$(uname -s)"
    case "$unameOut" in
	Linux*)     machine="linux";;
	Darwin*)    machine="mac";;
    esac
}

# Check if required binaries are installed
function check_required_dependencies {
    missing_deps=false
    if ! [ -x "$(command -v mono)" ]
    then
	echo "Mono not found"
	missing_deps=true
    fi

    if ! [ -x "$(command -v xdelta3)" ]
    then
	echo "xdelta3 not found"
	missing_deps=true
    fi

    if ! [ -x "$(command -v curl)" ]
    then
	echo "curl not found"
	missing_deps=true
    fi

    if "$missing_deps"; then
	exit
    fi

}
function check_region {
    if ! [[ "$evcregion" =~ ^(EUR|USA|)$ ]]; then
	echo "Region must be either EUR or USA. Region can set with the -r flag"
	exit
    fi
}

# Core functions
################################################################################
function download_apps {
    echo " Downloading apps..."
    if [ ! -d "apps" ]; then mkdir "apps"; fi
    if [ ! -d "apps/Mail-Patcher" ]; then mkdir "apps/Mail-Patcher"; fi
    $dl_cmd "apps/Mail-Patcher/boot.dol" "$FilesHostedOn/apps/Mail-Patcher/boot.dol" > /dev/null
    $dl_cmd "apps/Mail-Patcher/icon.png" "$FilesHostedOn/apps/Mail-Patcher/icon.png" > /dev/null
    $dl_cmd "apps/Mail-Patcher/meta.xml" "$FilesHostedOn/apps/Mail-Patcher/meta.xml" > /dev/null
    if [ ! -d "apps/WiiModLite" ]; then mkdir -p "apps/WiiModLite"; fi
    $dl_cmd "apps/WiiModLite/boot.dol" "$FilesHostedOn/apps/WiiModLite/boot.dol" > /dev/null
    $dl_cmd "apps/WiiModLite/icon.png" "$FilesHostedOn/apps/WiiModLite/icon.png" > /dev/null
    $dl_cmd "apps/WiiModLite/meta.xml" "$FilesHostedOn/apps/WiiModLite/meta.xml" > /dev/null
    $dl_cmd "apps/WiiModLite/wiimod.txt" "$FilesHostedOn/apps/WiiModLite/wiimod.txt" > /dev/null;
}

function apps {
    echo "Downloading IOS Patcher "

    check_region
    set_machine

    mkdir IOSPatcher
    $dl_cmd "IOSPatcher/00000006-80.delta" "$FilesHostedOn/IOSPatcher/00000006-80.delta" > /dev/null
    $dl_cmd "libWiiSharp.dll" "$FilesHostedOn/IOSPatcher/libWiiSharp.dll" > /dev/null
    $dl_cmd "Sharpii.exe" "$FilesHostedOn/IOSPatcher/Sharpii.exe" > /dev/null
    $dl_cmd "WadInstaller.dll" "$FilesHostedOn/WadInstaller.dll" > /dev/null

    mkdir -p "EVCPatcher/patch"
    mkdir -p "EVCPatcher/dwn"
    mkdir -p "EVCPatcher/dwn/0001000148414A45/512"
    mkdir -p "EVCPatcher/dwn/0001000148414A50/512"

    $dl_cmd "EVCPatcher/patch/USA.delta" "$FilesHostedOn/EVCPatcher/patch/USA.delta" > /dev/null
    $dl_cmd "EVCPatcher/patch/Europe.delta" "$FilesHostedOn/EVCPatcher/patch/Europe.delta" > /dev/null
    $dl_cmd "EVCPatcher/dwn/nustool" "$FilesHostedOn/EVCPatcher/nustool-${machine}" > /dev/null
    chmod +x "EVCPatcher/dwn/nustool"

    $dl_cmd "EVCPatcher/dwn/0001000148414A45/512/cetk" "$FilesHostedOn/EVCPatcher/dwn/0001000148414A45v512/cetk" > /dev/null
    $dl_cmd "EVCPatcher/dwn/0001000148414A45/512/cert" "$FilesHostedOn/EVCPatcher/dwn/0001000148414A45v512/cert" > /dev/null
    $dl_cmd "EVCPatcher/dwn/0001000148414A50/512/cetk" "$FilesHostedOn/EVCPatcher/dwn/0001000148414A50v512/cetk" > /dev/null
    $dl_cmd "EVCPatcher/dwn/0001000148414A50/512/cert" "$FilesHostedOn/EVCPatcher/dwn/0001000148414A50v512/cert" > /dev/null

    download_apps

    mono Sharpii.exe NUSD -ios 31 -v latest -all
    mv "IOS31-64-3608/000000010000001fv3608.wad" "IOSPatcher/IOS31-old.wad"

    mono Sharpii.exe NUSD -ios 80 -v latest -all
    mv "IOS80-64-6944/0000000100000050v6944.wad" "IOSPatcher/IOS80-old.wad"

    mono Sharpii.exe WAD -u "IOSPatcher/IOS31-old.wad" "IOSPatcher/IOS31/"
    mono Sharpii.exe WAD -u "IOSPatcher/IOS80-old.wad" "IOSPatcher/IOS80/"
    mv "IOSPatcher/IOS31/00000006.app" "IOSPatcher/00000006.app" > /dev/null

    xdelta3 -f -d -s "IOSPatcher/00000006.app" "IOSPatcher/00000006-31.delta" "IOSPatcher/IOS31/00000006.app" > /dev/null
    mv "IOSPatcher/IOS80/00000006.app" "IOSPatcher/00000006.app" > /dev/null

    xdelta3 -f -d -s "IOSPatcher/00000006.app" "IOSPatcher/00000006-80.delta" "IOSPatcher/IOS80/00000006.app" > /dev/null
    mkdir -p "IOSPatcher/WAD"

    mono Sharpii.exe WAD -p "IOSPatcher/IOS31/" "IOSPatcher/WAD/IOS31.wad" -fs
    mono Sharpii.exe WAD -p "IOSPatcher/IOS80/" "IOSPatcher/WAD/IOS80.wad" -fs

    if "$cleanup"; then
	rm "IOSPatcher/00000006.app"
	rm "IOSPatcher/IOS31-old.wad"
	rm "IOSPatcher/IOS80-old.wad"
	rm -rf "IOSPatcher/IOS31"
	rm -rf "IOSPatcher/IOS80"
    fi

    mono Sharpii.exe IOS "IOSPatcher/WAD/IOS31.wad" -fs -es -np -vp
    mono Sharpii.exe IOS "IOSPatcher/WAD/IOS80.wad" -fs -es -np -vp

    mkdir "WAD"
    mv "IOSPatcher/WAD/IOS31.wad" "WAD"
    mv "IOSPatcher/WAD/IOS80.wad" "WAD"

    if "$cleanup"; then
	rm -rf "IOSPatcher"
    fi

    if [ "$evcregion" = "EUR" ]; then
	mkdir -p "0001000148414A50/512"
	"EVCPatcher/dwn/nustool" -K "aef74d7c37f1f2bbe76d4e6f5e0b15a4" -p -m "0001000148414A50"
	mv 0001000148414a50/512/* EVCPatcher/dwn/0001000148414A50/512/
	cp "EVCPatcher/dwn/0001000148414A50/512/00000018" "0001000148414A50/512/00000000.app"
	cp "EVCPatcher/dwn/0001000148414A50/512/00000019" "0001000148414A50/512/00000001.app"
	cp "EVCPatcher/dwn/0001000148414A50/512/00000002" "0001000148414A50/512/00000002.app"
	cp "EVCPatcher/dwn/0001000148414A50/512/00000003" "0001000148414A50/512/00000003.app"
	cp "EVCPatcher/dwn/0001000148414A50/512/00000004" "0001000148414A50/512/00000004.app"
	cp "EVCPatcher/dwn/0001000148414A50/512/0000001a" "0001000148414A50/512/00000005.app"
	cp "EVCPatcher/dwn/0001000148414A50/512/0000001b" "0001000148414A50/512/00000006.app"
	cp "EVCPatcher/dwn/0001000148414A50/512/00000007" "0001000148414A50/512/00000007.app"
	cp "EVCPatcher/dwn/0001000148414A50/512/00000008" "0001000148414A50/512/00000008.app"
	cp "EVCPatcher/dwn/0001000148414A50/512/00000010" "0001000148414A50/512/00000009.app"
	cp "EVCPatcher/dwn/0001000148414A50/512/0000001c" "0001000148414A50/512/0000000a.app"
	cp "EVCPatcher/dwn/0001000148414A50/512/0000000b" "0001000148414A50/512/0000000b.app"
	cp "EVCPatcher/dwn/0001000148414A50/512/0000000c" "0001000148414A50/512/0000000c.app"
	cp "EVCPatcher/dwn/0001000148414A50/512/0000001d" "0001000148414A50/512/0000000d.app"
	cp "EVCPatcher/dwn/0001000148414A50/512/cert" "0001000148414A50/512/0001000148414a50.cert"
	cp "EVCPatcher/dwn/0001000148414A50/512/00000018" "0001000148414A50/512/0001000148414a50.footer"
	cp "EVCPatcher/dwn/0001000148414A50/512/cetk" "0001000148414A50/512/0001000148414a50.tik"
	cp "EVCPatcher/dwn/0001000148414A50/512/tmd" "0001000148414A50/512/0001000148414a50.tmd"
	mono Sharpii.exe WAD -p "0001000148414A50/512/" "WAD/Everybody Votes Channel RiiConnect24 Europe.wad" -f
	xdelta3 -f -d -s "0001000148414A50/512/00000001.app" "EVCPatcher/patch/Europe.delta" "0001000148414A50/512/00000001.app"
	cp "EVCPatcher/dwn/0001000148414A50/512/cetk" "0001000148414A50/512/cetk"
    elif [ "$evcregion" = "USA" ]; then
	mkdir -p "0001000148414A45/512"
	cp "EVCPatcher/dwn/0001000148414A45/512/cetk" "0001000148414A45/512/cetk"
	"EVCPatcher/dwn/nustool" -K "4fcb81ec20d5177f542311905d72886f" -p -m "0001000148414A45"
	mv 0001000148414a45/512/* EVCPatcher/dwn/0001000148414A45/512/
	cp "EVCPatcher/dwn/0001000148414A45/512/00000018" "0001000148414A45/512/00000000.app"
	cp "EVCPatcher/dwn/0001000148414A45/512/00000019" "0001000148414A45/512/00000001.app"
	cp "EVCPatcher/dwn/0001000148414A45/512/00000002" "0001000148414A45/512/00000002.app"
	cp "EVCPatcher/dwn/0001000148414A45/512/00000003" "0001000148414A45/512/00000003.app"
	cp "EVCPatcher/dwn/0001000148414A45/512/00000004" "0001000148414A45/512/00000004.app"
	cp "EVCPatcher/dwn/0001000148414A45/512/0000001a" "0001000148414A45/512/00000005.app"
	cp "EVCPatcher/dwn/0001000148414A45/512/0000001b" "0001000148414A45/512/00000006.app"
	cp "EVCPatcher/dwn/0001000148414A45/512/00000007" "0001000148414A45/512/00000007.app"
	cp "EVCPatcher/dwn/0001000148414A45/512/00000008" "0001000148414A45/512/00000008.app"
	cp "EVCPatcher/dwn/0001000148414A45/512/00000010" "0001000148414A45/512/00000009.app"
	cp "EVCPatcher/dwn/0001000148414A45/512/0000001c" "0001000148414A45/512/0000000a.app"
	cp "EVCPatcher/dwn/0001000148414A45/512/0000000b" "0001000148414A45/512/0000000b.app"
	cp "EVCPatcher/dwn/0001000148414A45/512/0000000c" "0001000148414A45/512/0000000c.app"
	cp "EVCPatcher/dwn/0001000148414A45/512/0000001d" "0001000148414A45/512/0000000d.app"
	cp "EVCPatcher/dwn/0001000148414A45/512/cert" "0001000148414A45/512/0001000148414a45.cert"
	cp "EVCPatcher/dwn/0001000148414A45/512/00000018" "0001000148414A45/512/0001000148414a45.footer"
	cp "EVCPatcher/dwn/0001000148414A45/512/cetk" "0001000148414A45/512/0001000148414a45.tik"
	cp "EVCPatcher/dwn/0001000148414A45/512/tmd" "0001000148414A45/512/0001000148414a45.tmd"
	xdelta3 -f -d -s "0001000148414A45/512/00000001.app" "EVCPatcher/patch/USA.delta" "0001000148414A45/512/00000001.app"
	mono Sharpii.exe WAD -p "0001000148414A45/512/" "WAD/Everybody Votes Channel RiiConnect24 USA.wad" -f
    fi

    # cleanup
    if "$cleanup"; then
	rm -rf "0001000148414A45"
	rm -rf "0001000148414a45"
	rm -rf "0001000148414A50"
	rm -rf "0001000148414a50"
	rm -rf "IOSPatcher"
	rm -rf "EVCPatcher"
	rm -rf "IOS31-64-3608"
	rm -rf "IOS80-64-6944"
	rm -rf ../$(basename "$PWD")"\libWiiSharp.dll"
	rm -rf "00000001.app"
	rm -rf "libWiiSharp.dll"
	rm -rf "Sharpii.exe"
	rm -rf "WadInstaller.dll"
    fi
}

function patch_ios {
    if [ ! -d "IOSPatcher" ]; then mkdir IOSPatcher; fi
    $dl_cmd "IOSPatcher/00000006-31.delta" "$FilesHostedOn/IOSPatcher/00000006-31.delta" > /dev/null
    $dl_cmd "IOSPatcher/00000006-80.delta" "$FilesHostedOn/IOSPatcher/00000006-80.delta" > /dev/null
    $dl_cmd "libWiiSharp.dll" "$FilesHostedOn/IOSPatcher/libWiiSharp.dll" > /dev/null
    $dl_cmd "Sharpii.exe" "$FilesHostedOn/IOSPatcher/Sharpii.exe" > /dev/null
    $dl_cmd "WadInstaller.dll" "$FilesHostedOn/WadInstaller.dll" > /dev/null
    cp "libWiiSharp.dll" ../$(basename "$PWD")"\libWiiSharp.dll"

    mono Sharpii.exe NUSD -ios 31 -v latest -all
    mv "IOS31-64-3608/000000010000001fv3608.wad" "IOSPatcher/IOS31-old.wad"
    mono Sharpii.exe NUSD -ios 80 -v latest -all
    mv "IOS80-64-6944/0000000100000050v6944.wad" "IOSPatcher/IOS80-old.wad"
    mono Sharpii.exe WAD -u "IOSPatcher/IOS31-old.wad" "IOSPatcher/IOS31/"
    mono Sharpii.exe WAD -u "IOSPatcher/IOS80-old.wad" "IOSPatcher/IOS80/"
    mv "IOSPatcher/IOS31/00000006.app" "IOSPatcher/00000006.app" > /dev/null
    xdelta3 -f -d -s "IOSPatcher/00000006.app" "IOSPatcher/00000006-31.delta" "IOSPatcher/IOS31/00000006.app" > /dev/null
    mv "IOSPatcher/IOS80/00000006.app" "IOSPatcher/00000006.app" > /dev/null
    xdelta3 -f -d -s "IOSPatcher/00000006.app" "IOSPatcher/00000006-80.delta" "IOSPatcher/IOS80/00000006.app" > /dev/null
    if [ ! -d "IOSPatcher/WAD" ]; then mkdir -p "IOSPatcher/WAD"; fi

    mono Sharpii.exe WAD -p "IOSPatcher/IOS31/" "IOSPatcher/WAD/IOS31.wad" -fs
    mono Sharpii.exe WAD -p "IOSPatcher/IOS80/" "IOSPatcher/WAD/IOS80.wad" -fs

    rm "IOSPatcher/00000006.app"
    rm "IOSPatcher/IOS31-old.wad"
    rm "IOSPatcher/IOS80-old.wad"

    if [ -d "IOSPatcher/IOS31" ]; then rm -rf "IOSPatcher/IOS31"; fi
    if [ -d "IOSPatcher/IOS80" ]; then rm -rf "IOSPatcher/IOS80"; fi
    mono Sharpii.exe IOS "IOSPatcher/WAD/IOS31.wad" -fs -es -np -vp
    mono Sharpii.exe IOS "IOSPatcher/WAD/IOS80.wad" -fs -es -np -vp

    if [[ ! -d "WAD" ]]; then mkdir "WAD"; fi
    mv "IOSPatcher/WAD/IOS31.wad" "WAD"
    mv "IOSPatcher/WAD/IOS80.wad" "WAD"

    rm -rf "IOSPatcher"
    rm -rf "IOS31-64-3608"
    rm -rf "IOS80-64-6944"
    rm -rf ../$(basename "$PWD")"\libWiiSharp.dll"
    rm -rf "libWiiSharp.dll"
    rm -rf "Sharpii.exe"
    rm -rf "WadInstaller.dll"
}

function patch_evc {
    check_region
    set_machine

    $dl_cmd "libWiiSharp.dll" "$FilesHostedOn/IOSPatcher/libWiiSharp.dll" > /dev/null
    $dl_cmd "Sharpii.exe" "$FilesHostedOn/IOSPatcher/Sharpii.exe" > /dev/null
    $dl_cmd "WadInstaller.dll" "$FilesHostedOn/WadInstaller.dll" > /dev/null
    cp "libWiiSharp.dll" ../$(basename "$PWD")"\libWiiSharp.dll"

    mkdir -p "EVCPatcher/patch"
    mkdir -p "EVCPatcher/dwn"

    $dl_cmd "EVCPatcher/dwn/nustool" "$FilesHostedOn/EVCPatcher/nustool-${machine}" > /dev/null
    chmod +x "EVCPatcher/dwn/nustool"

    if [ "$evcregion" = "EUR" ]; then
	mkdir -p "EVCPatcher/dwn/0001000148414A50/512"
	$dl_cmd "EVCPatcher/patch/Europe.delta" "$FilesHostedOn/EVCPatcher/patch/Europe.delta" > /dev/null
	$dl_cmd "EVCPatcher/dwn/0001000148414A50/512/cetk" "$FilesHostedOn/EVCPatcher/dwn/0001000148414A50v512/cetk" > /dev/null
	$dl_cmd "EVCPatcher/dwn/0001000148414A50/512/cert" "$FilesHostedOn/EVCPatcher/dwn/0001000148414A50v512/cert" > /dev/null
	mkdir -p "0001000148414A50/512"
	cp "EVCPatcher/dwn/0001000148414A50/512/cetk" "0001000148414A50/512/cetk"
	"EVCPatcher/dwn/nustool" -K "aef74d7c37f1f2bbe76d4e6f5e0b15a4" -p -m "0001000148414A50"
	mv 0001000148414a50/512/* EVCPatcher/dwn/0001000148414A50/512/
	cp "EVCPatcher/dwn/0001000148414A50/512/00000018" "0001000148414A50/512/00000000.app"
	cp "EVCPatcher/dwn/0001000148414A50/512/00000019" "0001000148414A50/512/00000001.app"
	cp "EVCPatcher/dwn/0001000148414A50/512/00000002" "0001000148414A50/512/00000002.app"
	cp "EVCPatcher/dwn/0001000148414A50/512/00000003" "0001000148414A50/512/00000003.app"
	cp "EVCPatcher/dwn/0001000148414A50/512/00000004" "0001000148414A50/512/00000004.app"
	cp "EVCPatcher/dwn/0001000148414A50/512/0000001a" "0001000148414A50/512/00000005.app"
	cp "EVCPatcher/dwn/0001000148414A50/512/0000001b" "0001000148414A50/512/00000006.app"
	cp "EVCPatcher/dwn/0001000148414A50/512/00000007" "0001000148414A50/512/00000007.app"
	cp "EVCPatcher/dwn/0001000148414A50/512/00000008" "0001000148414A50/512/00000008.app"
	cp "EVCPatcher/dwn/0001000148414A50/512/00000010" "0001000148414A50/512/00000009.app"
	cp "EVCPatcher/dwn/0001000148414A50/512/0000001c" "0001000148414A50/512/0000000a.app"
	cp "EVCPatcher/dwn/0001000148414A50/512/0000000b" "0001000148414A50/512/0000000b.app"
	cp "EVCPatcher/dwn/0001000148414A50/512/0000000c" "0001000148414A50/512/0000000c.app"
	cp "EVCPatcher/dwn/0001000148414A50/512/0000001d" "0001000148414A50/512/0000000d.app"
	cp "EVCPatcher/dwn/0001000148414A50/512/cert" "0001000148414A50/512/0001000148414a50.cert"
	cp "EVCPatcher/dwn/0001000148414A50/512/00000018" "0001000148414A50/512/0001000148414a50.footer"
	cp "EVCPatcher/dwn/0001000148414A50/512/cetk" "0001000148414A50/512/0001000148414a50.tik"
	cp "EVCPatcher/dwn/0001000148414A50/512/tmd" "0001000148414A50/512/0001000148414a50.tmd"
	xdelta3 -f -d -s "0001000148414A50/512/00000001.app" "EVCPatcher/patch/Europe.delta" "0001000148414A50/512/00000001.app"
	mono Sharpii.exe WAD -p "0001000148414A50/512/" "WAD/Everybody Votes Channel RiiConnect24 Europe.wad" -f
    elif [ "$evcregion" = "USA" ]; then
	mkdir -p "EVCPatcher/dwn/0001000148414A45/512"
	$dl_cmd "EVCPatcher/patch/USA.delta" "$FilesHostedOn/EVCPatcher/patch/USA.delta" > /dev/null
	$dl_cmd "EVCPatcher/dwn/0001000148414A45/512/cetk" "$FilesHostedOn/EVCPatcher/dwn/0001000148414A45v512/cetk" > /dev/null
	$dl_cmd "EVCPatcher/dwn/0001000148414A45/512/cert" "$FilesHostedOn/EVCPatcher/dwn/0001000148414A45v512/cert" > /dev/null
	mkdir -p "0001000148414A45/512"
	cp "EVCPatcher/dwn/0001000148414A45/512/cetk" "0001000148414A45/512/cetk"
	xdelta3 -f -d -s "0001000148414A45/512/00000001.app" "EVCPatcher/patch/USA.delta" "0001000148414A45/512/00000001.app"
	mono Sharpii.exe WAD -p "0001000148414A45/512/" "WAD/Everybody Votes Channel RiiConnect24 USA.wad" -f

	"EVCPatcher/dwn/nustool" -K "4fcb81ec20d5177f542311905d72886f" -p -m "0001000148414A45"
	mv 0001000148414a45/512/* EVCPatcher/dwn/0001000148414A45/512/
	cp "EVCPatcher/dwn/0001000148414A45/512/00000018" "0001000148414A45/512/00000000.app"
	cp "EVCPatcher/dwn/0001000148414A45/512/00000019" "0001000148414A45/512/00000001.app"
	cp "EVCPatcher/dwn/0001000148414A45/512/00000002" "0001000148414A45/512/00000002.app"
	cp "EVCPatcher/dwn/0001000148414A45/512/00000003" "0001000148414A45/512/00000003.app"
	cp "EVCPatcher/dwn/0001000148414A45/512/00000004" "0001000148414A45/512/00000004.app"
	cp "EVCPatcher/dwn/0001000148414A45/512/0000001a" "0001000148414A45/512/00000005.app"
	cp "EVCPatcher/dwn/0001000148414A45/512/0000001b" "0001000148414A45/512/00000006.app"
	cp "EVCPatcher/dwn/0001000148414A45/512/00000007" "0001000148414A45/512/00000007.app"
	cp "EVCPatcher/dwn/0001000148414A45/512/00000008" "0001000148414A45/512/00000008.app"
	cp "EVCPatcher/dwn/0001000148414A45/512/00000010" "0001000148414A45/512/00000009.app"
	cp "EVCPatcher/dwn/0001000148414A45/512/0000001c" "0001000148414A45/512/0000000a.app"
	cp "EVCPatcher/dwn/0001000148414A45/512/0000000b" "0001000148414A45/512/0000000b.app"
	cp "EVCPatcher/dwn/0001000148414A45/512/0000000c" "0001000148414A45/512/0000000c.app"
	cp "EVCPatcher/dwn/0001000148414A45/512/0000001d" "0001000148414A45/512/0000000d.app"
	cp "EVCPatcher/dwn/0001000148414A45/512/cert" "0001000148414A45/512/0001000148414a45.cert"
	cp "EVCPatcher/dwn/0001000148414A45/512/00000018" "0001000148414A45/512/0001000148414a45.footer"
	cp "EVCPatcher/dwn/0001000148414A45/512/cetk" "0001000148414A45/512/0001000148414a45.tik"
	cp "EVCPatcher/dwn/0001000148414A45/512/tmd" "0001000148414A45/512/0001000148414a45.tmd"
    fi

    if "$cleanup" ; then
	rm -rf "0001000148414A45"
	rm -rf "0001000148414a45"
	rm -rf "0001000148414A50"
	rm -rf "0001000148414a50"
	rm -rf "EVCPatcher"
	rm -rf ../$(basename "$PWD")"\libWiiSharp.dll"
	rm -rf "00000001.app"
	rm -rf "libWiiSharp.dll"
	rm -rf "Sharpii.exe"
	rm -rf "WadInstaller.dll"
    fi
}

################################################################################
# main

check_required_dependencies

# Dispatch action
case $action in
    help) usage;;
    credits) credits;;
    apps) apps;;
    ios) patch_ios;;
    evc) patch_evc;;
    *) usage;;
esac
