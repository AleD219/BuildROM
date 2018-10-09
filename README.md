# BuildROM script

Complex system for ROM maintainers by MrYacha, Timur & AleD219

##Features:
* Setup local enviroment
* Syncing and update ROM sources
* Source cleanup
* Smart ROM
* And more others features for maintainers

##Using:
For start using BuildROM you need clone it to ~/BuildROM

    sudo apt install git
    git clone https://github.com/AleD219/BuildRom ~/BuildROM
    cd ~/BuildROM

## Now pull tg bot api
    git submodule update --init --recursive --remote

## now start the script
    bash Build.sh
    or
    . Build.sh

