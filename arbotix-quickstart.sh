#!/bin/bash
#title           :arbotix-quickstart.sh
#description     :This script downloads and initialises your arbotix workspace in the current directory, installing needed files for compatibility with ros-kinetic, the correct versions for: Processing (+controlP5, +dynaManager), Arduino (+Arbotix Repos), Catkin Workspace (+PhantomX and Turtlebot hardware descriptions, as well as arbotix-ros)
#author          :Nathan Michlo
#date            :2019/05/07
#version         :0.1
#notes           :requires ubuntu 16.04
#usage           :bash arbotix-quickstart.sh

# wrap the script in a function, so that if a partial file is downloaded due to an error,
# and the script is being piped to bash, it does not run and cause havok.
_run_script() {

# ========================================================================= #
# VARS                                                                      #
# ========================================================================= #

SCRIPT_DIR=$( cd $(dirname $0) ; pwd )
# install dirs
PKG_DIR="${SCRIPT_DIR}/pkg"
BIN_DIR="${SCRIPT_DIR}/bin"
WS_DIR="${SCRIPT_DIR}/ws"
# workspace dirs
ARDN_WS="${WS_DIR}/arduino_ws"
CTKN_WS="${WS_DIR}/catkin_ws"
PROC_WS="${WS_DIR}/processing_ws"
# cache folder
CACHE_DIR="${HOME}/.cache/arbotix-arm-init"

# ========================================================================= #
# HELPER                                                                    #
# ========================================================================= #

# <string>
clr() {
    color="\\033[$1m"; shift
    printf "$color%b\033[0m" "$@"
}

# <prompt-message>
confirm() {
    read -p "$(clr 92 "$@ (y/n)"): " choice
    case "$choice" in
        y|Y) return 0 ;;
        n|N) return 1 ;;
        *)   echo $(clr 91 "Invalid: '${choice}'")
             confirm "$@"
             return $? ;;
    esac
}

# <string>
heading() {
    echo
    clr 90 "# ==================================================== #\n"
    clr 90 "# $@\n"
    clr 90 "# ==================================================== #\n"
    echo
}

# <path>
set_wd() {
    cd "$@"
    echo $(clr 90 "Working Directory") ": $@"
}

# <file-url> <local-file-name>
wget_cached() {
    if [ ! -f "${CACHE_DIR}/$2" ] && [ ! -d "${CACHE_DIR}/$2" ]; then
        mkdir -pv "${CACHE_DIR}"
        wget "$1" -O "${CACHE_DIR}/$2"
    else
        echo $(clr 90 "Using cached: ") "$1 (${CACHE_DIR}/$2)"
    fi
    cp -R "${CACHE_DIR}/$2" "${PWD}/$2" && echo "Downloaded to: ${PWD}/$2"
}

# <git-branch-name> <git-url> <local-folder-name>
git_clone_cached() {
    if [ ! -f "${CACHE_DIR}/$3" ] && [ ! -d "${CACHE_DIR}/$3" ]; then
        mkdir -pv "${CACHE_DIR}"
        git clone --single-branch --branch "$1" "$2" "${CACHE_DIR}/$3"
    else
        echo $(clr 90 "Using cached: ") "$2 (${CACHE_DIR}/$3)"
    fi
    cp -R "${CACHE_DIR}/$3" "${PWD}/$3" && echo "Cloned to: ${PWD}/$3"
}

# =========================================================================    #
# FUNCTIONS                                                                    #
# =========================================================================    #

do_clean() {
    heading "CLEANING"
    # workspaces
    rm -rf "${ARDN_WS}/"*
    rm -rfv "${ARDN_WS}"
    rm -rf "${PROC_WS}/"*
    rm -rfv "${PROC_WS}"
    rm -rf "${CTKN_WS}/"*
    rm -rfv "${CTKN_WS}"
    # binaries
    rm -rf "${BIN_DIR}/"*/*
    rm -rfv "${BIN_DIR}"
    # install dir
    rm -rf "${PKG_DIR}/"*/*
    rm -rfv "${PKG_DIR}"
    # workspace dir
    rm -rf "${WS_DIR}/"*/*
    rm -rfv "${WS_DIR}"
}

do_install() {

    _arduino() {
        heading "INSTALL - Arduino 1.8.9"
        mkdir -pv "${BIN_DIR}"
        mkdir -pv "${PKG_DIR}"
        set_wd "${PKG_DIR}"
            wget_cached "https://downloads.arduino.cc/arduino-1.8.9-linux64.tar.xz" "arduino.tar.xz"
            echo "Extract: arduino.tar.xz" ; tar -xf arduino.tar.xz ; rm arduino.tar.xz
            ln -sv "${PKG_DIR}/arduino-1.8.9/arduino" "${BIN_DIR}/arduino"
        export ardn=1
    }

    _arduino_ws() {
        heading "SETUP - Arduino"
        mkdir -pv "${ARDN_WS}/.."
        set_wd "${ARDN_WS}/.."
            git_clone_cached "arduino-1-6" "https://github.com/Interbotix/arbotix.git" "arduino_ws"
        export ardn_ws=1
    }

    _processing() {
        heading "INSTALL - Processing 2.2.1"
            mkdir -pv "${BIN_DIR}"
            mkdir -pv "${PKG_DIR}"
        set_wd "${PKG_DIR}"
            wget_cached "http://download.processing.org/processing-2.2.1-linux64.tgz" "processing.tgz"
            echo "Extract: processing.tgz" ; tar -xf "processing.tgz" ; rm "processing.tgz"
            ln -sv "${PKG_DIR}/processing-2.2.1/processing" "${BIN_DIR}/processing"
        export proc=1
    }

    _processing_ws() {
        heading "SETUP - Processing"
        mkdir -pv "${PROC_WS}/libraries"
        set_wd "${PROC_WS}"
            git_clone_cached "master" "https://github.com/Interbotix/dynaManager.git" "dynaManager"
        set_wd "${PROC_WS}/libraries"
            wget_cached "https://storage.googleapis.com/google-code-archive-downloads/v2/code.google.com/controlp5/controlP5-2.0.3.zip" "controlP5.zip"
            echo "Extract: controlP5.zip" ; unzip -q "controlP5.zip" ; rm "controlP5.zip"
        export proc_ws=1
    }

    _ros() {
        _install_ros() {
            _install_ros_rc() {
                (echo "\n# Added by arbotix-ws-init.sh:\nsource /opt/ros/kinetic/setup.bash\n" >> "${HOME}/.bashrc") && \
                    source "/opt/ros/kinetic/setup.bash"
            }
            heading "INSTALL: ros-kinetic" # http://wiki.ros.org/kinetic/Installation/Ubuntu
            sudo sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list' && \
                sudo apt-key adv --keyserver hkp://ha.pool.sks-keyservers.net:80 --recv-key 421C365BD9FF1F717815A3895523BAEEB01FA116 && \
                sudo apt-get update && \
                sudo apt-get install -y ros-kinetic-desktop-full && \
                (sudo rosdep init || true) && \
                rosdep update && \
                ((confirm "Would you like to add \"source /opt/ros/kinetic/setup.bash\" to your ~/.bashrc?" && _install_ros_rc) || \
                    clr 91 "Source ros automatically, run: $ echo \"\\\\nsource /opt/ros/kinetic/setup.bash\\\\n\" >> ~/.bashrc\n") && \
                sudo apt install -y python-rosinstall python-rosinstall-generator python-wstool build-essential
            return $?
        }
        if [ ! -x "$(command -v rosrun)" ]; then
            (confirm "ros-kinetic for ubuntu 16.04 is not installed. Would you like to install it?" && \
                    (_install_ros || (clr 91 "An error occured installing ros, contact your system admin, you might not have sudo access?\n" && exit 1))) || \
                (clr 93 "Follow the install instructions at: http://wiki.ros.org/kinetic/Installation/Ubuntu\n" && exit 1)
        fi
    }

    _arbotix_ros() {
        if [ ! -x "$(command -v rosrun)" ]; then
            clr 91 "WARNING: Skipping arbotix-ros (ros-kinetic is not installed)"
            return 1
        fi
        if [ ! -x "$(command -v arbotix_terminal)" ]; then
            confirm "$ apt install ros-kinetic-arbotix" && \
                (sudo apt install -y ros-kinetic-arbotix || \
                    clr 91 "An error occured installing ros-kinetic-arbotix, This package will be downloaded manually any into your workspace!") || \
                clr 93 "This package will be downloaded manually anyway into your workspace!\n"
        fi
        # install moveit
        # install math lib
    }

    _catkin_ws() {
        heading "SETUP - Catkin"
        mkdir -pv "${CTKN_WS}/src"
        # ([ -x "$(command -v catkin_make)" ] && (set_wd "${CTKN_WS}" && catkin_make)) || \
        #     (clr 91 "WARNING: Skipping Catkin Workspace Setup (ros-kinetic is not installed)")
        set_wd "${CTKN_WS}/src"
            git_clone_cached "kinetic-devel" "https://github.com/turtlebot/turtlebot_arm.git" "turtlebot_arm"
            git_clone_cached "master" "https://github.com/Interbotix/phantomx_pincher_arm.git" "phantomx_pincher_arm"
            git_clone_cached "indigo-devel" "https://github.com/vanadiumlabs/arbotix_ros.git" "arbotix_ros"
        export ctkn_ws=1
    }

    # INSTALL

    _ros
    _arbotix_ros
    _arduino
    _arduino_ws
    _processing
    _processing_ws
    _catkin_ws

    # INFO

    heading "INFO"

    [ -n "$ardn" ] && clr 92 "Arduino binary located at: $ \"${BIN_DIR}/arduino\"\n"
    [ -n "$ardn_ws" ] && clr 91 "Make sure to update your Arduino workspace. (default is: \"~/Arduino\")\n"
    [ -n "$ardn_ws" ] && clr 90 "- Option A: Update Arduino settings (File -> Preferences) to point to: \"${ARDN_WS}\"\n"
    [ -n "$ardn_ws" ] && clr 90 "- Option B: Create a simlink in place of the default directory with: $ ln -sv \"${ARDN_WS}\" \"${HOME}/Arduino\"\n"
    echo
    [ -n "$proc" ] && clr 92 "Processing binary located at: $ \"${BIN_DIR}/processing\"\n"
    [ -n "$proc_ws" ] && clr 91 "Make sure to update your Processing workspace. (default is: \"~/sketchbook\")\n"
    [ -n "$proc_ws" ] && clr 90 "- Option A: Update Processing settings (File -> Preferences) to point to: \"${PROC_WS}\"\n"
    [ -n "$proc_ws" ] && clr 90 "- Option B: Create a simlink in place of the default directory with: $ ln -sv \"${PROC_WS}\" \"${HOME}/sketchbook\"\n"
    echo
    echo $(clr 33 "Downloads have been cached in \"${CACHE_DIR}\"")
    clr 90 "This directory can be deleted to save space! $ rm -rf \"${CACHE_DIR}\"\n"
    echo
    clr 92 "Workspaces located in: \"${WS_DIR}\"\n"
    [ -n "$ardn_ws" ] && clr 90 "Arduino Workspace: \"${ARDN_WS}\"\n"
    [ -n "$proc_ws" ] && clr 90 "Processing Workspace: \"${PROC_WS}\"\n"
    [ -n "$ctkn_ws" ] && clr 90 "Catkin Workspace: \"${CTKN_WS}\"\n"
    [ -n "$ctkn_ws" ] && clr 90 "- Optional: Create a simlink: $ ln -sv \"${CTKN_WS}\" \"${HOME}/catkin_ws\"\n"
    clr 91 "To uninstall all files run the script again with the \"-c\" flag\n"
    echo
}

do_help() {
    echo
    echo " -h -? | Show these results"
    echo " -c    | Clean"
    echo " -i    | Install"
    echo
}

# =========================================================================    #
# ARGS - https://stackoverflow.com/questions/192249                         #
# =========================================================================    #

unset force_install
unset force_clean

while getopts "h?ic" opt; do
    case "$opt" in
    h|\?)
        do_help
        exit 0
        ;;
    i)  force_install=1
        ;;
    c)  force_clean=1
        ;;
    *)
        do_help
        echo $(clr "Unknown args")
        exit 1;
    esac
done

# CHECK NOT ROOT
if [ "$USER" == "root" ]; then
    clr 91 "You are currently running the script as root or with sudo...\n"
    confirm "$(clr 91 "Are you sure you want to continue? This script is not well tested.")" || exit 1
fi

# ENTRY POINT
do_clean
if [ -z "$force_clean" ] || [ -n "$force_install" ]; then
    do_install
fi

# =========================================================================    #
# END OF SCRIPT                                                                #
# =========================================================================    #

}

_run_script $@
