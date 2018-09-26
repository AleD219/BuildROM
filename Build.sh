#!/bin/bash
#Auto building ROM, by MrYacha and Timur
export LC_ALL=C #Magic patch for Ubuntu 18.04

# Viriebles section
script_dir="BuildROM"
script_file="Build.sh"
script_ver="R0.5"
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

#Script Settings

function settings() {
  echo "Script settings"
  echo -ne "\n${BLUE}Please your device codename: ${NC}"
  read device
  echo -ne "\n${BLUE}Please write ROM name: ${NC}"
  read rom_name
  echo -ne "${BLUE}Please write path to ROM dir: ${NC}"
  read rom_dir
  echo -ne "${BLUE}Please write the type of build that you want (eng; user; userdebug): ${NC}"
  read buildtype
  echo -ne "${BLUE}Are you building official or unofficial?${NC}"
  read official
  echo -ne "${BLUE}Please write command to init sources: ${NC}"
  read repo_init
  echo -ne "${BLUE}Do y want to use ccache? [Y/n]: ${NC}"
  read use_ccache

  if [ "$use_ccache" = "y" ] || [ "$use_ccache" = "Y" ]; then
    use_ccache="1"
    use_ccacheP="Yes"
  else
    use_ccache="0"
    use_ccacheP="No"
  fi
  
  echo -e "${CYAN}Ok, done, please review your settings:${NC}"
  echo -e "${BLUE}Device Codename - ${NC}$device"
  echo -e "${BLUE}Rom name - ${NC}$rom_name"
  echo -e "${BLUE}Rom path - ${NC}$rom_dir"
  echo -e "${BLUE}Build Type - ${NC}$buildtype"
  echo -e "${BLUE}Official? - ${NC}$official"
  echo -e "${BLUE}Init ROM sources command - ${NC}$repo_init"
  echo -e "${BLUE}Use ccache - ${NC}$use_ccacheP"


  echo -ne "${BLUE}Save changes? [y/N]: ${NC}"
  read save
  if [ "$save" = "y" ] || [ "$save" = "Y" ]; then
    echo "Saving settings..."
    echo "device=$device" > ~/$script_dir/config.txt
    echo "rom_name=$rom_name" > ~/$script_dir/config.txt
    echo "rom_dir=$rom_dir" >> ~/$script_dir/config.txt
    echo "buildtype=$buildtype" >> ~/$script_dir/config.txt
    echo "official=$official" >> ~/$script_dir/config.txt
    echo "repo_init=\"$repo_init\"" >> ~/$script_dir/config.txt
    echo "use_ccache=$use_ccache" >> ~/$script_dir/config.txt
    echo "use_ccacheP=$use_ccacheP" >> ~/$script_dir/config.txt
    echo "Settings saved, please reopen script"
    exit
  else
    echo "Settings don't changed!"
    start
  fi
}

if [ ! -e ~/$script_dir/config.txt ];then
  echo -e "${BLUE}No configuration file, please setup${NC}"
  settings
fi

#Import variables from config file
. ~/$script_dir/config.txt
#

# Functions section
function start() {
  echo -e "\n${BLUE}BuildROM script $script_ver | By MrYacha & Timur"

  echo -e "\n${GREEN}[1]Build ROM"
  echo -e "\n${GREEN}[2]Build ROM (full)"
  echo -e "[3]Source cleanup (clean)"
  echo -e "[4]Source cleanup (installclean)"
  echo -e "[5]Sync repo"
  echo -e "[6]Misc"
  echo -e "[7]Mega Setup"
  echo -e "[8]Settings"
  echo -e "[9]Quit${NC}"
  echo -ne "\n${BLUE}(i)Please enter a choice[1-9]:${NC} "

  read choice
}

function misc() {
while :; do
  echo -e "\n${GREEN}[1]Setup local build enviroment"
  echo -e "[2]Repo init"
  echo -e "[3]Get help"
  echo -e "[4]Back to main menu${NC}"
  echo -ne "\n${BLUE}(i)Please enter a choice[1-4]:${NC} "

  read choice2

  case $choice2 in
    1 ) setup;;
    2 ) init;;
    3 ) help;;
    4 ) break
  esac
done
}

function help() {
  echo -e "\n${RED}ROM building script ${BLUE}R0.4-Beta${NC}"
  echo -e "${BLUE}Help:${NC}"
  echo "Run script with \"--setup\" parameter for setup local build enviroment"
  echo "\"--init\" will be init repo of ROM source"
  echo "\"--sync\" will be download ROM sources"
  echo "\"-c\" will be clean up out dir"
  echo "\"-b\" will build your ROM"
}

function setup() {
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

  echo -e "${BLUE}Current script settings: ${NC}"

  echo -e "${CYAN}Device Name - ${NC}$device"
  echo -e "${CYAN}Rom name - ${NC}$rom_name"
  echo -e "${CYAN}Rom path - ${NC}$rom_dir"
  echo -e "${CYAN}Build type - ${NC}$buildtype"
  echo -e "${CYAN}Official? - ${NC}$official"
  echo -e "${CYAN}Init ROM sources command - ${NC}$repo_init"
  echo -e "${CYAN}Use ccache - ${NC}$use_ccacheP"

  echo -ne "${BLUE}Do y wanna change? [Y/n]: ${NC}"
  read change_setings

  if [ "$change_setings" = "y" ] || [ "$change_setings" = "Y" ]; then
    settings
  else
    echo "going to main screen"
    start
  fi

  exit
}

function init() {
  echo -e "\n${BLUE}(i)Initializing Repo...${NC}"
  mkdir ~/$rom_dir
  cd ~/$rom_dir
  $repo_init #Use command from variable
  cd ~/$script_dir
}

function sync() {
  cd ~/$rom_dir
  echo -e "\n${BLUE}(i)Syncing $rom_name repo...${NC}"
  if [ "$FORCE_SYNC" = 1 ]; then
    echo "Force sync!"
    repo sync -f -c --no-clone-bundle --no-tags --force-sync
  else
    echo "Normal sync"
    repo sync -f -c --no-clone-bundle --no-tags
  fi
  cd ~/$script_dir
}

function clean() {
  cd ~/$rom_dir
  . build/envsetup.sh && make clean && make clobber
  cd ~/$script_dir
  if [ "$use_ccache" = "1" ]; then
  echp "Cleaning ccache.."
  export CCACHE_DIR=/home/ccache/$username
  ccache -C
  wait
  echo "CCACHE Cleared"
  fi
}

function installclean() {
  cd ~/$rom_dir
  rm -rf frameworks/base
  . build/envsetup.sh && make installclean
  cd ~/$script_dir
}

function build_rom() {
  lunch "$rom_name"_$device-$buildtype
  brunch $device
  result="$?"
  return $result
}

function build() {
  cd ~/$rom_dir
  if [ "$use_ccache" = "1" ]; then
  echo "Setupping ccache..."
  export USE_CCACHE=1
  export CCACHE_DIR=/home/ccache/$username
  prebuilts/misc/linux-x86/ccache/ccache -M 35G
  fi

  mkdir -p '_logs'
  BUILD_START=$(date +"%s")
  DATE=`date`
  echo -e "\n${CYAN}#######################################################################${NC}"
  echo -e "${BLUE}(i)Build started at $DATE${NC}\n"
  . build/envsetup.sh
  LOG_FILE="_logs/$(date +"%m-%d-%Y_%H-%M-%S").log"
  build_rom && result="$?" | tee "$LOG_FILE"
  echo -e "${BLUE}(i)Log writed in $LOG_FILE${NC}"
  echo "uploading to pastebin.."
  echo -n "Done, pastebin link: "
  cat $LOG_FILE | pastebinit -b https://paste.ubuntu.com
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
  else
    echo -e "\n${RED}(!)ROM compilation failed"
    echo -e "#######################################################################"
    echo -e "(i)Total time elapsed: $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds."
    echo -e "#######################################################################${NC}"
  fi
  cd ~/$script_dir
}

function build_full() {
  cd ~/$rom_dir
  if [ "$use_ccache" = "1" ]; then
  echo "Setupping ccache..."
  export USE_CCACHE=1
  export CCACHE_DIR=/home/ccache/$username
  prebuilts/misc/linux-x86/ccache/ccache -M 35G
  fi

  mkdir -p '_logs'
  BUILD_START=$(date +"%s")
  date2="$(date '+%Y%m%d')"
  DATE=`date`
  echo -e "\n${CYAN}#######################################################################${NC}"
  echo -e "${BLUE}(i)Build started at $DATE${NC}\n"
  . build/envsetup.sh
  LOG_FILE="_logs/$(date +"%m-%d-%Y_%H-%M-%S").log"
  export "${rom_name^^}"_BUILD_TYPE="${official^^}"
  installclean && sync && build_rom && result="$?" | tee "$LOG_FILE"
  echo -e "${BLUE}(i)Log writed in $LOG_FILE${NC}"
  echo "uploading to pastebin.."
  echo -n "Done, pastebin link: "
  cat $LOG_FILE | pastebinit -b https://paste.ubuntu.com
  echo -ne "\n${BLUE}[...] ${spin[0]}${NC}"
  echo -e ${cya}"Uploading to mega.nz"
  mega-login "$megauser" "$megapass"
  mega-put out/target/product/"$device"/"$rom_name"_"$device"*.zip /"$device"_builds/"$rom_name"/
  mega-logout
  wait
  echo -e ${grn}"Uploaded file successfully"
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
  else
    echo -e "\n${RED}(!)ROM compilation failed"
    echo -e "#######################################################################"
    echo -e "(i)Total time elapsed: $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds."
    echo -e "#######################################################################${NC}"
  fi
  cd ~/$script_dir
}

function megasetup() {
  echo -ne "\n${BLUE}Please write your mega email: ${NC}"
  read megaemail
  echo -ne "\n${BLUE}Please write your mega password: ${NC}"
  read megapass
  echo "megaemail=$megaemail" > ~/$script_dir/config.txt
  echo "megapass=$megapass" > ~/$script_dir/config.txt
  echo -ne "\n${BLUE}now the full build will upload the file on mega.nz!${NC}"
}
#

if [ -n "$1" ];then
  while [ -n "$1" ]
  do
    case "$1" in
      --help | -h) help ;;
      --setup) setup ;;
      --init) init ;;
      --sync)
      if [[ "$2" = "-force" || "$2" = "-f" ]];then
        FORCE_SYNC=1
      fi
      sync
      shift;;
      --clean | -c) clean ;;
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
    2 ) build_full;;
    3 ) clean;;
    4 ) installclean;;
    5 ) sync;;
    6 ) misc;;
    7 ) megasetup;;
    8 ) settings_info;;
    9 ) exit 0;;
  esac
done
