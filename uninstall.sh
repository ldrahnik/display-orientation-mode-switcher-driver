#!/bin/bash

if [[ $(id -u) != 0 ]]
then
	echo "Please, run this script as root (using sudo for example)"
	exit 1
fi

systemctl stop display_orientation_mode_switcher
if [[ $? != 0 ]]
then
	echo "display_orientation_mode_switcher.service cannot be stopped correctly..."
	exit 1
fi

systemctl disable display_orientation_mode_switcher
if [[ $? != 0 ]]
then
	echo "display_orientation_mode_switcher.service cannot be disabled correctly..."
	exit 1
fi

rm -f /lib/systemd/system/display_orientation_mode_switcher.service
if [[ $? != 0 ]]
then
	echo "/lib/systemd/system/display_orientation_mode_switcher.service cannot be removed correctly..."
	exit 1
fi

CONF_DIR="/usr/share/display_orientation_mode_switcher-driver/conf/"

CONF_DIR_DIFF=""
if test -d "$CONF_DIR"; then
    CONF_DIR_DIFF=$(diff conf $CONF_DIR)
fi

if [ "$CONF_DIR_DIFF" != "" ]
then
    read -r -p "Installed config scripts contain modifications compared to the default ones. Do you want remove them for each mode [y/N]" response
    case "$response" in [yY][eE][sS]|[yY])
		rm -rf /usr/share/display_orientation_mode_switcher-driver/
		if [[ $? != 0 ]]
		then
			echo "/usr/share/display_orientation_mode_switcher-driver/ cannot be removed correctly..."
			exit 1
		fi
        ;;
    *)
		shopt -s extglob
		rm -rf /usr/share/display_orientation_mode_switcher-driver/!(conf)
		if [[ $? != 0 ]]
		then
			echo "/usr/share/display_orientation_mode_switcher-driver/ cannot be removed correctly..."
			exit 1
		fi
		echo "Config scripts in /usr/share/power_supply_mode_switcher-driver/conf/ have not been removed and remain in system:"
        ls /usr/share/display_orientation_mode_switcher-driver/conf
        ;;
    esac
else
	rm -rf /usr/share/display_orientation_mode_switcher-driver/
	if [[ $? != 0 ]]
	then
		echo "/usr/share/display_orientation_mode_switcher-driver/ cannot be removed correctly..."
		exit 1
	fi
fi

rm -rf /var/log/display_orientation_mode_switcher-driver
if [[ $? != 0 ]]
then
	echo "/var/log/display_orientation_mode_switcher-driver cannot be removed correctly..."
	exit 1
fi

echo "Display orientation mode switcher python driver uninstalled"
exit 0
