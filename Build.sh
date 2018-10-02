#!/bin/bash
#Auto building ROM, by MrYacha, Timur and AleD219

export LC_ALL=C #Magic patch for Ubuntu 18.04

# Viriebles section
script_dir="BuildROM"
script_file="Build.sh"
script_ver="R0.7"
username="$USER"

curr_conf="configs/conf4.txt"
#

# Add colors variables
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
PURPLE='\033[1;35m'
CYAN='\033[0;36m'
NC='\033[0m'
#

# Init section
if [ $0 = /bin/bash ];then
	echo -e "Please run using \"bash Build.sh\""
	exit
fi

if [ ! -e ~/$script_dir/$script_file ];then
	echo -e "${RED}Wrong script location, please move to ~/$script_dir/$script_file ${NC}"
	exit
fi

#Some system functions

function restart() {
	if [ "$Z" = "1" ]; then
		clear
		bash ~/$script_dir/$script_file settings_info
	fi

	bash ~/$script_dir/$script_file
}

function settings() {
	echo "Script settings"
	echo -ne "${BLUE}Please your device codename: ${NC}"
	read device_codename
	echo -ne "${BLUE}Please write ROM name: ${NC}"
	read rom_name
	echo -ne "${BLUE}Please write path to ROM dir:${NC} ~/"
	read rom_dir
	echo -ne "${BLUE}Please write your rom version: ${NC}"
	read version
	echo -ne "${BLUE}Please write the type of build that you want (eng; user; userdebug): ${NC}"
	read buildtype
	echo -ne "${BLUE}Are you building official or unofficial?${NC}"
  	read official
	echo -ne "${BLUE}Please write command to init sources: ${NC}"
	read repo_init
	echo -ne "${BLUE}Do you want to use ccache? [Y/n]: ${NC}"
	read use_ccache

	if [ "$use_ccache" = "y" ] || [ "$use_ccache" = "Y" ]; then
		use_ccache="1"
		use_ccacheP="Yes"
	else
		use_ccache="0"
		use_ccacheP="No"
	fi
	
	echo -e "${CYAN}Ok, done, please review your settings:${NC}"
	echo -e "${BLUE}Device Codename - ${NC}$device_codename"
	echo -e "${BLUE}Rom name - ${NC}$rom_name"
	echo -e "${BLUE}Rom path - ${NC}$rom_dir"
	echo -e "${BLUE}Version - ${NC}$version"
	echo -e "${BLUE}Build Type - ${NC}$buildtype"
	echo -e "${BLUE}Official? - ${NC}$official"
	echo -e "${BLUE}Init ROM sources command - ${NC}$repo_init"
	echo -e "${BLUE}Use ccache - ${NC}$use_ccacheP"


	echo -ne "${BLUE}Save changes? [y/N]: ${NC}"
	read save
	if [ "$save" = "y" ] || [ "$save" = "Y" ]; then
		echo "Saving settings..."
		echo "device_codename=$device_codename" > ~/$script_dir/${curr_conf}
		echo "rom_name=$rom_name" >> ~/$script_dir/${curr_conf}
		echo "rom_dir=$rom_dir" >> ~/$script_dir/${curr_conf}
		echo "version=$version" >> ~/$script_dir/${curr_conf}
		echo "buildtype=$buildtype" >> ~/$script_dir/${curr_conf}
		echo "official=$official" >> ~/$script_dir/${curr_conf}
		echo "repo_init=\"$repo_init\"" >> ~/$script_dir/${curr_conf}
		echo "use_ccache=$use_ccache" >> ~/$script_dir/${curr_conf}
		echo "use_ccacheP=$use_ccacheP" >> ~/$script_dir/${curr_conf}
		echo "Settings saved, please reopen script"
		exit
	else
		echo "Settings don't changed!"
		restart
	fi
}

if [ ! -e ~/$script_dir/${curr_conf} ];then
	echo -e "${BLUE}No configuration file, please setup${NC}"

	if [ ! -e ~/$script_dir/configs/ ];then
	mkdir ~/$script_dir/configs/
	fi

	touch ~/$script_dir/${curr_conf}
	settings
fi

#Import variables from current config file
. ~/$script_dir/${curr_conf}
#

# Other functions
function start() {
	echo -e "\n${BLUE}BuildROM script ${CYAN}$script_ver${BLUE} | By MrYacha, Timur and AleD219"
	echo -e "${CYAN}Current ROM - $rom_name"

	echo -e "\n${GREEN}[1] Build ROM"
	echo -e "[2] Source cleanup (clean)"
	echo -e "[3] Source cleanup (installclean)"
	echo -e "[4] Sync repo"
	echo -e "[5] Misc"
	echo -e "[6] Mega Setup"
	echo -e "[7] Settings"
	echo -e "[Q] Quit"
	echo -ne "\n${BLUE}(i)Please enter a choice[1-8/Q]:${NC} "

	read choice
}

function misc() {
	while :; do
		echo -e "\n${GREEN}[1] Setup local build enviroment"
		echo -e "[2] Repo init"
		echo -e "[3] Get help"
		echo -e "[Q] Back to restart menu"
		echo -ne "\n${BLUE}(i)Please enter a choice[1-4]:${NC} "

		read choice2

		case $choice2 in
			1 ) setup;;
			2 ) init;;
			3 ) help;;
			Q ) break
		esac
	done
}

function help() {
	echo
	echo -e "${BLUE}BuildROM script ${CYAN}$script_ver${BLUE} | By MrYacha, Timur and AleD219"
	echo -e "${BLUE}Script parameters help:${NC}"
	echo "Run script with \"--setup\" parameter for setup local build enviroment"
	echo "\"--init\" will be init repo of ROM source"
	echo "\"--sync\" will be download ROM sources"
	echo "\"-c\" will be clean up out dir"
	echo "\"-b\" will build your ROM"
}

function setup() {
	#Make a magic with your PC
	echo "\nSetuping local build enviroment..."
	echo "Step 1 - Installing git"
	sudo apt install git -y
	echo "Step 2 - Installing some usefull utilities needed by script"
	sudo apt install pastebinit -y
	echo "Step 3 - Downloading setup script"
	git clone https://github.com/akhilnarang/scripts ~/scripts
	echo "Step 4 - Execute setup script"
	cd ~/scripts
	sudo bash setup/android_build_env.sh
	sudo bash setup/install_android_sdk.bash
	cd ~/$script_dir
	rm -rf ~/scripts
}

function settings_info() {

	echo -e "${BLUE}Change script config"
	echo -e "${CYAN}Current config: ${rom_name}${GREEN}"
	N="1" #Start from 1, don't kick me!

	for i in $( ls ~/$script_dir/configs )
	do
		. ~/$script_dir/configs/conf$N.txt
		#Highlight current config
		if [ "${curr_conf}" = "configs/conf$N.txt" ];then
			echo -e "${CYAN}[$N]: ${rom_name}"
		else
    		echo -e "${GREEN}[$N]: ${NC}${rom_name}"
		fi
		#Add 1 in var for end of cycle
		let "N = $N + 1"
	done

	#Restore current configs
	. ~/$script_dir/${curr_conf}

	echo -e "${BLUE}Current config settings: ${NC}"
	echo
	echo -e "${GREEN}Device Name - ${NC}$device_codename"
	echo -e "${GREEN}Rom name - ${NC}$rom_name"
	echo -e "${GREEN}Rom path - ${NC}$rom_dir"
	echo -e "${GREEN}Version - ${NC}$version"
	echo -e "${GREEN}Build type - ${NC}$buildtype"
	echo -e "${CYAN}Official? - ${NC}$official"
	echo -e "${GREEN}Init ROM sources command - ${NC}$repo_init"
	echo -e "${GREEN}Use ccache - ${NC}$use_ccacheP"
	echo
	echo -e "${BLUE}Commands avaible: ${NC}"
	echo -e "${CYAN}Q - for go back | S - for setting current config | [1/~] For change config file" #TODO: Simplify this text
	echo -ne "${BLUE}Your command: ${NC}"
	read curr_cmd

	if [ "$curr_cmd" = "S" ] || [ "$change_setings" = "s" ]; then
		settings
	fi

	if [ "$curr_cmd" = "Q" ] || [ "$change_setings" = "q" ]; then
		restart
	fi

	if [[ $curr_cmd =~ $re ]] ; then
		#Make a sed on Build.sh for change curr_conf variable
		#Magic! Don't touch!
		sed -i -e "s/curr_conf=\".*\"/curr_conf=\"configs\/conf$curr_cmd.txt\"/" -l 10 Build.sh
		Z="1"
		echo $Z
		restart
	fi

	exit
}

function init() {
	echo -e "\n${BLUE}(i)Initializing Repo...${NC}"
	mkdir ~/$rom_dir
	cd ~/$rom_dir
	$repo_init #Use command from variable | TODO: use link for repo, no need to force the user to remember repo
	cd ~/$script_dir
}

function sync() {
	cd ~/$rom_dir
	echo -e "\n${BLUE}(i)Syncing $rom_name repo...${NC}"
	if [ "$FORCE_SYNC" = 1 ]; then
		echo "Force sync!"
		repo sync -f -c --force-sync
	else
		echo "Normal sync"
		repo sync -f -c
	fi
	cd ~/$script_dir
}

function clean() {
	cd ~/$rom_dir

	#Make a clean
	. build/envsetup.sh
	make clean
	make clobber
	#

	#Clear CCache if enabled
	if [ "$use_ccache" = "1" ]; then
		echo "Cleaning ccache.."
		export CCACHE_DIR=/home/$username/.ccache
		ccache -C
		wait
		echo "CCACHE Cleared"
	fi

	cd ~/$script_dir
}

function installclean() {
	cd ~/$rom_dir

	. build/envsetup.sh
	lunch "$rom_name"_"$device_codename"-$buildtype
	make installclean

	cd ~/$script_dir
}

function build_rom() {
	. build/envsetup.sh
	lunch "$rom_name"_"$device_codename"-$buildtype #TODO: auto detect current build system, many roms based on lineage, so its not working for it
	if [ "$rom_name" = "aosip" ]; then #Crutch for now
		time mka kronic
	else
		brunch $device_codename
	fi
	result="$?"
	return $result
}

function build() {
	cd ~/$rom_dir

	#Enable CCache
	if [ "$use_ccache" = "1" ]; then
		echo "Setupping ccache..."
		export USE_CCACHE=1
		export CCACHE_DIR=/home/$username/.ccache
		ccache -M 35G
	fi
	#

	#TODO: move logs, uploading to own functions
	mkdir -p '_logs'
	BUILD_START=$(date +"%s")
	DATE=`date`
	echo -e "\n${CYAN}#######################################################################${NC}"
	echo -e "${BLUE}(i)Build started at $DATE${NC}\n"
	export SELINUX_IGNORE_NEVERALLOWS=true
	. build/envsetup.sh
	export "${rom_name^^}"_BUILD_TYPE="${official^^}"
	LOG_FILE="_logs/$(date +"%m-%d-%Y_%H-%M-%S").log"
	build_rom && result="$?" | tee "$LOG_FILE"
	echo -e "${BLUE}(i)Log writed in $LOG_FILE${NC}"
	echo "uploading to pastebin.."
	echo -n "Done, pastebin link: "
	cat $LOG_FILE | pastebinit -b https://paste.ubuntu.com
	echo -e ${cya}"Uploading to mega.nz"
	mega-login "$megaemail" "$megapass"
	mega-put out/target/product/"$device_codename"/*.zip /"$device_codename"_builds/"$rom_name"/
	mega-logout
	wait
	echo -e ${grn}"Uploaded file successfully"
	echo -ne "\n${BLUE}[...] ${spin[0]}${NC}"
	while kill -0 $pid &>/dev/null
	do
		for i in "${spin[@]}"
		do
			echo -ne "\b$i"
			sleep 0.1
		done
	done
	BUILD_END=$(date +"%s")
	DIFF=$(($BUILD_END - $BUILD_START))
	if [ "$result" = "0" ]; #This stuff only for show compilation successfully, I do not see the point in this.
	then
		echo -e "\n${GREEN}(i)ROM compilation completed successfully"
		echo -e "#######################################################################"
		echo -e "(i)Total time elapsed: $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds."
		echo -e "#######################################################################${NC}"
	else
		echo -e "\n${RED}(!)ROM compilation failed"
		echo -e "#######################################################################"
		echo -e "(i)Total time elapsed: $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds."
		echo -e "#######################################################################${NC}"
	fi
	cd ~/$script_dir
}

function cloud_setup() {
	#TODO: if we change script we recive blank mega settings? No, its not right!
	echo -ne "\n${BLUE}Please write your mega email: ${NC}"
	read megaemail
	echo -ne "\n${BLUE}Please write your mega password: ${NC}"
	read megapass
	echo "megaemail=$megaemail" >> ~/$script_dir/${curr_conf}
	echo "megapass=$megapass" >> ~/$script_dir/${curr_conf}
	echo -ne "\n${BLUE}now the full build will upload the file on mega.nz! Restart the script.${NC}"
	exit
}

function delfwb() {
	rm -rf ~/$rom_dir/frameworks/base
	echo "FWB Deleted!"
}

#

if [ -n "$1" ];then
	while [ -n "$1" ]
	do
		case "$1" in
			-fwb ) delfwb ;;
			--help | -h) help ;;
			--setup) setup ;;
			--init) init ;;
			settings_info) settings_info;;
			--sync | -s)
			if [[ "$2" = "-force" || "$2" = "-f" ]];then
				FORCE_SYNC=1
			fi
			sync
			shift;;
			--clean | -c) clean ;;
			--installclean | -ic) installclean ;;
			--build | -b) build ;;
		esac
		shift
	done
	exit 0
fi

while :; do
	start
	case $choice in
		1 ) build;;
		2 ) clean;;
		3 ) installclean;;
		4 ) sync;;
		5 ) misc;;
		6 ) cloud_setup;;
		7 ) settings_info;;
		Q ) exit 0;;
	esac
done