#!/bin/bash
#Auto building ROM, by MrYacha, Timur and AleD219

export LC_ALL=C #Magic patch for Ubuntu 18.04

# Viriebles section
script_dir="BuildROM"
script_file="Build.sh"
script_ver="R0.7"
#

#TGBot variables
tgbot_path="/home/$USER/BuildROM/TGBot"
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

# Main functions
function start() {
	echo -e "\n${BLUE}BuildROM script ${CYAN}$script_ver${BLUE} | By MrYacha, Timur and AleD219"
	echo -e "${CYAN}Current ROM - $rom_name"

	echo -e "\n${GREEN}[1] Build ROM"
	echo -e "[2] Source cleanup (clean)"
	echo -e "[3] Source cleanup (installclean)"
	echo -e "[4] Sync repo"
	echo -e "[5] Misc"
	echo -e "[6] Mega Setup"
	echo -e "[7] SourceForge Setup"
	echo -e "[8] Settings (config)"
	echo -e "[9] Script settings"
	echo -e "[10] TG Bot menu"
	echo -e "[Q] Quit"
	echo -ne "\n${BLUE}(i)Please enter a choice[1-9/Q]:${NC} "

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

function tgbot_menu() {
	while :; do
		echo -e "${BLUE}Telegram bot menu${NC}"
		echo -e 
		echo -e "${GREEN}[1] Start"
		echo -e "[2] Kill"
		echo -e "[3] Settings"
		echo -e "[4] Current proxy - ${NC}${curr_proxy}"
		echo -e "${GREEN}[5] Use proxy - ${NC}${use_proxy}"
		echo
		echo -ne "${BLUE}(i)Please enter a choice[1-5/Q]:${NC} "

		read choice

		case $choice in
			1 ) tgbot_start;;
			2 ) tgbot_kill;;
			3 ) show_tgbot_settings;;
			4 ) proxy_edit;;
			5 ) if [ $use_proxy = "true" ];then
					use_proxy="false"
				else
					use_proxy="true"
				fi
				echo "use_proxy=$use_proxy" >> ~/$script_dir/tgbot_conf.txt;;
			6 | Q | q ) break
		esac
	done
}

function tgbot_start() {
	proxy_set
	cd $tgbot_path
	source $tgbot_path/bashbot.sh source
	bash $tgbot_path/bashbot.sh start && use_tgbot="true"
	cd ~/$script_dir
	proxy_unset
}

function tgbot_kill() {
	proxy_set
	cd $tgbot_path
	bash $tgbot_path/bashbot.sh kill && use_tgbot="false"
	cd ~/$script_dir
	proxy_unset
}

function show_tgbot_settings() {
	while :; do
		echo
		echo -e "${BLUE}Current TG Bot settings: ${NC}"
		echo
		echo -e "${GREEN}User ID - ${NC}${tg_user_id}"
		echo -e "${GREEN}Run bot on script start-up - ${NC}${tgbot_autostart}"
		echo
		echo -e "${BLUE}Commands avaible: ${NC}"
		echo -e "${CYAN}[Q] - for go back \n[S] - for changing current settings"
		echo -ne "${BLUE}Your command: ${NC}"
		read curr_cmd

		case "$curr_cmd" in
			S | s ) edit_tgbot_settings ;;
			Q | q ) break ;;
		esac
	done
}

function edit_tgbot_settings() {
	echo "TG Bot settings"
	echo
	echo -ne "${BLUE}Enter your user ID: ${NC}"
	read tg_user_id
	echo -ne "${BLUE}Do you want to run bot on script start-up? [Y/n]: ${NC}"
	read tgbot_autostart
	if [ "$tgbot_autostart" = "y" ] || [ "$tgbot_autostart" = "Y" ]; then
		tgbot_autostart="true"
	else
		tgbot_autostart="false"
	fi
	echo -e "${CYAN}Ok, done, please review your settings:${NC}"
	echo
	echo -e "${BLUE}User ID - ${NC}${tg_user_id}"
	echo -e "${BLUE}Run bot on script start-up - ${NC}${tgbot_autostart}"
	echo
	echo -ne "${BLUE}Save changes? [y/N]: ${NC}"
	read save
	if [ "$save" = "y" ] || [ "$save" = "Y" ]; then
		echo "Saving settings..."
		echo "tg_user_id=$tg_user_id" >> ~/$script_dir/tgbot_conf.txt
		echo "tgbot_autostart=$tgbot_autostart" >> ~/$script_dir/tgbot_conf.txt
		echo "Settings saved!"
	else
		echo "Settings don't changed!"
		. ~/$script_dir/tgbot_conf.txt
	fi
}

function proxy_edit() {
	echo
	echo -ne "${BLUE}Enter new proxy: ${NC}"
	read curr_proxy
	echo "curr_proxy=\"$curr_proxy\"" >> ~/$script_dir/tgbot_conf.txt
	echo
}

function proxy_set() {
	if [ "$use_proxy" = "true" ];then
		export {http,https,ftp}_proxy="$curr_proxy"
	fi
}

function proxy_unset() {
	if [ "$use_proxy" = "true" ];then
		unset {http,https,ftp}_proxy
	fi
}

function send_tg_notification() {
	if [ "$use_tgbot" = "true" ]; then
		proxy_set
		cd $tgbot_path
		send_text ${tg_user_id} "markdown_parse_mode${tg_msg}" 
		proxy_unset
	fi
}

function send_tg_file() {
	if [ "$use_tgbot" = "true" ]; then
		proxy_set
		cd $tgbot_path
		send_file "${tg_user_id}" "$tg_file" 
		proxy_unset
	fi
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

function show_script_settings() {
	while :; do
		echo
		echo -e "${BLUE}Current script settings: ${NC}"
		echo
		echo -e "${GREEN}Use logs - ${NC}${use_logs}"
		echo
		echo -e "${BLUE}Commands avaible: ${NC}"
		echo -e "${CYAN}[Q] - for go back \n[S] - for changing current settings"
		echo -ne "${BLUE}Your command: ${NC}"
		read curr_cmd

		case "$curr_cmd" in
			S | s ) edit_script_settings ;;
			Q | q ) break ;;
		esac
	done
}

function edit_script_settings() {
	echo "Script settings"
	echo -ne "${BLUE}Do you want to use logs? [Y/n]: ${NC}"
	read use_logs
	if [ "$use_logs" = "y" ] || [ "$use_logs" = "Y" ]; then
		use_logs="true"
	else
		use_logs="false"
	fi
	echo -e "${CYAN}Ok, done, please review your settings:${NC}"
	echo -e "${BLUE}Use logs - ${NC}$use_logs"
	echo
	echo -ne "${BLUE}Save changes? [y/N]: ${NC}"
	read save
	if [ "$save" = "y" ] || [ "$save" = "Y" ]; then
		echo "Saving settings..."
		echo "use_logs"="$use_logs" > ~/$script_dir/script_conf.txt
		echo "Settings saved!"
	else
		echo "Settings don't changed!"
		. ~/$script_dir/script_conf.txt
	fi
}

function create_conf() {
	touch ~/$script_dir/configs/conf$N.txt
	echo -e "Created"
	show_config_settings
}

function del_conf() {
	let "G = $N - 1"
	rm ~/$script_dir/configs/conf$G.txt
	echo -e "Removed"
	echo "curr_conf=\"configs/conf1.txt\"" > ~/$script_dir/script_conf.txt
	show_config_settings
}

function show_config_settings() {
while :; do

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

	#Read current configs
	. ~/$script_dir/${curr_conf}

	echo -e "${BLUE}Current config settings: ${NC}"
	echo
	echo -e "${GREEN}Device Name - ${NC}$device_codename"
	echo -e "${GREEN}Rom name - ${NC}$rom_name"
	echo -e "${GREEN}Rom path - ${NC}$rom_dir"
	echo -e "${GREEN}Version - ${NC}$version"
	echo -e "${GREEN}Build type - ${NC}$buildtype"
	echo -e "${GREEN}Official? - ${NC}$official"
	echo -e "${GREEN}Init ROM sources command - ${NC}$repo_init"
	echo -e "${GREEN}Use ccache - ${NC}$use_ccacheP"
	echo
	echo -e "${BLUE}Commands avaible: ${NC}"
	echo -e "${CYAN}Q - for go back | S - for setting current config | C - create new config | R - Remove current config | [1/~] For change config file" #TODO: Simplify this text
	echo -ne "${BLUE}Your command: ${NC}"
	read curr_cmd

	case "$curr_cmd" in
		S | s ) edit_config_settings ;;
		C | c ) create_conf ;;
		R | r ) del_conf ;;
		Q | q ) break ;;
	esac

	if [[ $curr_cmd =~ $re && $curr_cmd -gt 0 && $curr_cmd -le $N ]] ; then
		echo "curr_conf=\"configs/conf$curr_cmd.txt\"" > ~/$script_dir/script_conf.txt
		. ~/$script_dir/script_conf.txt
	fi
done
}

function edit_config_settings() {
	echo "Config settings"
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
		echo "Settings saved!"
	else
		echo "Settings don't changed!"
		. ~/$script_dir/${curr_conf}
	fi
}

function init() {
	echo -e "\n${BLUE}(i)Initializing Repo...${NC}"
	mkdir ~/$rom_dir
	cd ~/$rom_dir
	$repo_init #Use command from variable | TODO: use link for repo, no need to force the user to remember repo
	cd ~/$script_dir
}

function sync() {
	echo -e "\n${BLUE}(i)Syncing $rom_name repo...${NC}"
	tg_msg="*(i)Syncing $rom_name repo...*"
	send_tg_notification
	cd ~/$rom_dir
	if [ "$FORCE_SYNC" = 1 ]; then
		echo "Force sync!"
		repo sync -f -c --force-sync --no-clone-bundle --no-tags
	else
		echo "Normal sync"
		repo sync -f -c --no-clone-bundle --no-tags
	fi
	tg_msg="*(i)Syncing $rom_name repo completed!*"
	send_tg_notification
	cd ~/$script_dir
}

function clean() {
	cd ~/$rom_dir

	#Make a clean
	. build/envsetup.sh
	make clean
	make clobber
	#

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
	echo $result > ~/$script_dir/tmp
}

function build() {

	#Enable CCache
	if [ "$use_ccache" = "1" ]; then
		echo "Setupping ccache..."
		export USE_CCACHE=1
		export CCACHE_DIR=/home/$USER/.ccache
		ccache -M 35G
	fi
	#

	BUILD_START=$(date +"%s")
	DATE=`date`
	echo -e "\n${CYAN}#######################################################################${NC}"
	echo -e "${BLUE}(i)Build started at $DATE${NC}\n"
	export SELINUX_IGNORE_NEVERALLOWS=true
	export "${rom_name^^}"_BUILD_TYPE="${official^^}"
	tg_msg="*Build started at* \`$DATE\`"
	send_tg_notification
	cd ~/$rom_dir
	if [ "$uselogs" = "true" ]; then
		use_logs
	else
		build_rom
	fi
	result=$(cat ~/$script_dir/tmp)
	rm -f ~/$script_dir/tmp
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
	if [ "$result" = "0" ];
	then
		echo -e "\n${GREEN}(i)ROM compilation completed successfully"
		echo -e "#######################################################################"
		echo -e "(i)Total time elapsed: $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds."
		echo -e "#######################################################################${NC}"
		tg_msg="*(i)ROM compilation completed successfully* | Total time elapsed: $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds."
	else
		echo -e "\n${RED}(!)ROM compilation failed"
		echo -e "#######################################################################"
		echo -e "(i)Total time elapsed: $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds."
		echo -e "#######################################################################${NC}"
		tg_msg="*(!)ROM compilation failed* | Total time elapsed: $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds."
		if [ "$uselogs" = "true" ]; then
			echo -ne "\nDo you want to upload logs to paste.ubuntu.com? [Y/n]:"
			read curr_cmd
			if [ "$curr_cmd" = "y" ] || [ "$curr_cmd" = "Y" ]; then
				upload_logs
			fi
		fi
	fi
	send_tg_notification
	cd ~/$script_dir
}

function mega_setup() {
	#TODO: if we change script we recive blank mega settings? No, its not right!
	echo -ne "\n${BLUE}Please write your mega email: ${NC}"
	read megaemail
	echo -ne "\n${BLUE}Please write your mega password: ${NC}"
	read megapass
	echo "megaemail=$megaemail" >> ~/$script_dir/script_conf.txt
	echo "megapass=$megapass" >> ~/$script_dir/script_conf.txt
	echo -ne "\n${BLUE}now the full build will upload the file on mega.nz!${NC}"
	. ~/$script_dir/script_conf.txt
}

function sf_setup() {
	echo -ne "\n${BLUE}Please write your SourceForge username: ${NC}"
	read sfuser
	echo -ne "\n${BLUE}Please write your SourceForge password: ${NC}"
	read sfpass
	echo -ne "\n${BLUE}Please write your SourceForge Project name: ${NC}"
	read sfproject
	echo "sfproject=$sfproject" >> ~/$script_dir/${curr_conf}
	echo "sfuser=$sfuser" >> ~/$script_dir/script_conf.txt
	echo "sfpass=$sfpass" >> ~/$script_dir/script_conf.txt
}

function mega_upload() {
	cd ~/$rom_dir
	DATE=`date +%Y%m%d`
	changelog=$(find out/target/product/"$device_codename" -maxdepth 1  -name "$rom_name"*.txt)
	echo -e ${cya}"Uploading to mega.nz"
	tg_msg="*(i)Starting uploading to mega.nz*"
	send_tg_notification
	cd ~/$rom_dir
	mega-login "$megaemail" "$megapass"
	mega-put out/target/product/"$device_codename"/"$rom_name"_"$device_codename"-"$version"-"$DATE"*.zip /"$device_codename"_builds/"$rom_name"/
	megaout=$(mega-export -a /"$device_codename"_builds/"$rom_name"/"$rom_name"_"$device_codename"-"$version"-"$DATE"*.zip)
	mega-logout
	megalink=$(echo $megaout | grep -Eo '(http|https)://[^"]+')
	echo -e ${grn}"Uploaded file successfully! link : $megalink "
	tg_msg="*(i)Uploaded file to mega.nz successfully!* link : $megalink"
	send_tg_notification
	tg_msg="*New Build Of $rom_name is up!* it can be downloaded [here]($megalink)"	
	send_tg_notification
	tg_file="/home/$USER/$rom_dir/$changelog"
	send_tg_file
}

function sf_upload() {
	cd ~/$rom_dir
	DATE=`date +%Y%m%d`
	changelog=$(find out/target/product/"$device_codename" -maxdepth 1  -name "$rom_name"*.txt)
	echo -e ${cya}"Uploading to SourceForge"
	tg_msg="*(i)Starting uploading to SourceForge*"
	send_tg_notification
	cd ~/$rom_dir
	sshpass -p "$sfpass" scp out/target/product/"$device_codename"/"$rom_name"_"$device_codename"-"$version"-"$DATE"*.zip "$sfuser"@frs.sourceforge.net:/home/frs/project/"$sfproject"/"$device_codename"
	zip_path=$(find out/target/product/"$device_codename" -name "$rom_name"_"$device_codename"-"$version"-"$DATE"*.zip)
	zip_name=$( basename "$zip_path" )
	sflink="https://sourceforge.net/projects/$sfproject/files/$device_codename/$zip_name/download"
	echo -e ${grn}"Uploaded file successfully"
	tg_msg="*(i)Uploaded file to SourceForge successfully!* link : "$sflink" "
	send_tg_notification
	tg_msg="*New Build Of $rom_name is up!* it can be downloaded [here]($sflink)"
	send_tg_notification
	tg_file="/home/$USER/$rom_dir/$changelog"
	send_tg_file
}

function delfwb() {
	rm -rf ~/$rom_dir/frameworks/base
	echo "FWB Deleted!"
}

function use_logs() {
	mkdir -p _logs
	LOG_FILE="_logs/$(date +"%m-%d-%Y_%H-%M-%S").log"
	build_rom | tee "$LOG_FILE"
	echo -e "${BLUE}(i)Log writed in $LOG_FILE${NC}"
}

function upload_logs() {
	echo "uploading to pastebin.."
	echo -n "Done, pastebin link: "
	cat $LOG_FILE | pastebinit -b https://paste.ubuntu.com
}
#

#TG Bot config
if [ ! -e ~/$script_dir/tgbot_conf.txt ];then
	echo -e "Creating tgbot_conf.txt..."
	touch ~/$script_dir/tgbot_conf.txt
fi

. ~/$script_dir/tgbot_conf.txt


#Script config
if [ ! -e ~/$script_dir/script_conf.txt ];then
	echo -e "Creating script_conf.txt..."
	echo "curr_conf=\"configs/conf1.txt\"" > ~/$script_dir/script_conf.txt
fi

. ~/$script_dir/script_conf.txt

if [ -z ${curr_conf} ];then
	echo -e "\n${PURPLE}WARNING:${NC} variable curr_conf is empty. Set current config to configs/conf1.txt"
	echo "curr_conf=\"configs/conf1.txt\"" >> ~/$script_dir/script_conf.txt
	curr_conf="configs/conf1.txt"
fi

#We check conf file
if [ ! -e ~/$script_dir/${curr_conf} ];then
	echo -e "${BLUE}No configuration file, please setup${NC}"

	if [ ! -e ~/$script_dir/configs/ ];then
	mkdir ~/$script_dir/configs/
	fi
	
	#Create new conf file and setup it
	touch ~/$script_dir/${curr_conf}
	edit_config_settings
fi

#Import variables from current config file
. ~/$script_dir/${curr_conf}
#

#Autostart TGBot | Currently beta
if [[ "$tgbot_autostart" = "true" ]]; then
	tgbot_start
fi

if [ -n "$1" ];then
	while [ -n "$1" ]
	do
		case "$1" in
			-fwb ) delfwb ;;
			--help | -h) help ;;
			--setup) setup ;;
			--init) init ;;
			--sync | -s)
			if [[ "$2" = "-force" || "$2" = "-f" ]];then
				FORCE_SYNC=1
			fi
			sync
			shift;;
			--clean | -c) clean ;;
			--installclean | -ic) installclean ;;
			--mega | -m ) mega_upload ;;
			--sourceforge | -sf ) sf_upload ;;
			--build | -b) build ;;
		esac
		shift
	done
	if [ "$use_tgbot" = "true" ]; then
		tgbot_kill
	fi
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
		6 ) mega_setup;;
		7 ) sf_setup;;
		8 ) show_config_settings;;
		9 ) show_script_settings;;
		10 ) tgbot_menu;;
		Q ) 
		if [ "$use_tgbot" = "true" ]; then
			tgbot_kill
		fi
		exit 0;;
	esac
done