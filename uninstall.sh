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

rm -rf /usr/share/display_orientation_mode_switcher-driver/
if [[ $? != 0 ]]
then
	echo "/usr/share/display_orientation_mode_switcher-driver/ cannot be removed correctly..."
	exit 1
fi

rm -rf /var/log/display_orientation_mode_switcher-driver
if [[ $? != 0 ]]
then
	echo "/var/log/display_orientation_mode_switcher-driver cannot be removed correctly..."
	exit 1
fi

echo "Display orientation mode switcher python driver uninstalled"
exit 0
