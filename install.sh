#!/bin/bash

# Checking if the script is runned as root (via sudo or other)
if [[ $(id -u) != 0 ]]; then
    echo "Please run the installation script as root (using sudo for example)"
    exit 1
fi

parent_path=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )

if [[ $(apt install 2>/dev/null) ]]; then
    echo 'apt is here' && apt -y install iio-sensor-proxy inotify-tools
elif [[ $(pacman -h 2>/dev/null) ]]; then
    echo 'pacman is here' && pacman --noconfirm --needed -S iio-sensor-proxy inotify-tools
elif [[ $(dnf install 2>/dev/null) ]]; then
    echo 'dnf is here' && dnf -y install iio-sensor-proxy inotify-tools
fi

DRIVER_INSTALL_DIR="/usr/share/display_orientation_mode_switcher-driver"

cp display_orientation_mode_switcher.service /etc/systemd/system/
mkdir -p $DRIVER_INSTALL_DIR/conf
mkdir -p /var/log/display_orientation_mode_switcher-driver
install display_orientation_mode_switcher.sh $DRIVER_INSTALL_DIR

echo
for CONF_FILE in conf/*.sh; do
    DRIVER_INSTALLED_CONF_FILE="$DRIVER_INSTALL_DIR/$CONF_FILE"

    if [ -f $DRIVER_INSTALLED_CONF_FILE ]; then
        DEFAULT_VS_INSTALLED_CONFIG_DIFF=""
        if test -f "$DRIVER_INSTALLED_CONF_FILE"; then
            DEFAULT_VS_INSTALLED_CONFIG_DIFF=$(diff <(grep -v '^#' $CONF_FILE) <(grep -v '^#' $DRIVER_INSTALLED_CONF_FILE))
        fi

        if [ "$DEFAULT_VS_INSTALLED_CONFIG_DIFF" != "" ]
        then
            read -r -p "Overwrite existing config script for mode $CONF_FILE? [y/N]" response
            case "$response" in [yY][eE][sS]|[yY])
                echo "Replaced existing config file for mode $CONF_FILE with default one."
                cp $CONF_FILE $DRIVER_INSTALL_DIR/conf
                ;;
            *)
                echo "Used existing config file for mode $CONF_FILE."
                ;;
            esac
        else
            echo "Used existing config file for mode $CONF_FILE. Is the same as default one."
        fi
    else
        echo "Not existing config file for mode $CONF_FILE. Used default one."
        cp $CONF_FILE $DRIVER_INSTALL_DIR/conf
    fi
    echo "For futher editing is here: $DRIVER_INSTALLED_CONF_FILE"
    chmod +x $DRIVER_INSTALLED_CONF_FILE
done
echo

systemctl enable display_orientation_mode_switcher

if [[ $? != 0 ]]; then
    echo "Something went wrong when enabling the display_orientation_mode_switcher.service"
    exit 1
else
    echo "Display orientation mode switcher service enabled"
fi

systemctl restart display_orientation_mode_switcher
if [[ $? != 0 ]]; then
    echo "Something went wrong when enabling the display_orientation_mode_switcher.service"
    exit 1
else
    echo "Display orientation mode switcher service started"
fi

echo "Install finished"

exit 0