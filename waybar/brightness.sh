#!/bin/bash

BACKLIGHT_DIR="/sys/class/backlight/$(ls /sys/class/backlight)"
BRIGHTNESS_FILE="$BACKLIGHT_DIR/brightness"
MAX_FILE="$BACKLIGHT_DIR/max_brightness"

get_brightness() {
	current=$(cat "$BRIGHTNESS_FILE")
	max=$(cat "$MAX_FILE")
	percent=$(( current * 100 / max ))
	echo $percent
}

set_brightness() {
	new=$1
	max=$(cat "$MAX_FILE")

	# Clamp between 1 and max
	if [ "$new" -lt 1 ]; then
		new=1
	elif [ "$new" -gt "$max" ]; then
		new=$max
	fi

	echo $new > "$BRIGHTNESS_FILE"
}

case "$1" in
	get)
		get_brightness
		;;
	up)
		current=$(cat "$BRIGHTNESS_FILE")
		max=$(cat "$MAX_FILE")
		step=$(( max / 20 )) # ~5%
		set_brightness $(( current + step ))
		;;
	down)
		current=$(cat "$BRIGHTNESS_FILE")
		max=$(cat "$MAX_FILE")
		step=$(( max / 20 )) # ~5%
		set_brightness $(( current - step ))
		;;
esac