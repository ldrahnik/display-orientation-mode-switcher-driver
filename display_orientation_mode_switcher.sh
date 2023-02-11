#!/bin/bash

PARENT_PATH=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )

function rotate {
	ORIENTATION=$1
	echo $(date -u) "Orientation changed to: $ORIENTATION"
	if [[ $ORIENTATION = "normal" ]]; then
	    test $PARENT_PATH/conf/normal.sh && sh $PARENT_PATH/conf/normal.sh
	elif [[ $ORIENTATION = "left-up" ]]; then
	    test $PARENT_PATH/conf/left_up.sh && sh $PARENT_PATH/conf/left_up.sh
	elif [[ $ORIENTATION = "right-up" ]]; then
	    test $PARENT_PATH/conf/right_up.sh && sh $PARENT_PATH/conf/right_up.sh
	elif [[ $ORIENTATION = "bottom-up" ]]; then
	    test $PARENT_PATH/conf/bottom_up.sh && sh $PARENT_PATH/conf/bottom_up.sh
	fi
}

LOG_FILE=/tmp/monitor-sensor.log
killall monitor-sensor
monitor-sensor > $LOG_FILE 2>&1 &

while inotifywait -e modify $LOG_FILE; do

	# Read the last line that was added to the file and get the orientation
	ORIENTATION=$(tail -n 1 $LOG_FILE | grep 'orientation' | grep -oE '[^ ]+$')
	#grep -oE '(?<=id=).*(?=\\t)')

	if [ ! -z $ORIENTATION ] ; then
		rotate $ORIENTATION
	fi

done