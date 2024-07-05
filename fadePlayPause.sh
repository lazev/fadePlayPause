#!/bin/bash

MAX_VOLUME=90
MIN_VOLUME=0

set_volume() {
	local VOLUME=$1
	amixer sset 'Master' $VOLUME%
}


get_volume() {
	amixer get 'Master' | grep -o -m 1 '[0-9]*%' | tr -d '%'
}


fade_out() {
	FADE_DURATION=5
	local VOLUME=$(get_volume)
	local STEP=$((VOLUME / FADE_DURATION))
	for ((i = 0; i < FADE_DURATION; i++)); do
		VOLUME=$((VOLUME - STEP))
		set_volume $VOLUME
		sleep 0.1
	done
	set_volume $MIN_VOLUME
}


fade_in() {
	local FADE_DURATION=20
	local VOLUME=$MIN_VOLUME
	local STEP=$((MAX_VOLUME / FADE_DURATION))
	for ((i = 0; i < FADE_DURATION; i++)); do
		VOLUME=$((VOLUME + STEP))
		set_volume $VOLUME
		sleep 0.1
	done
	set_volume $MAX_VOLUME
}


VOLUME_THRESHOLD=0
CURRENT_VOLUME=$(get_volume)
STATUS=$(playerctl status)

if [ "$CURRENT_VOLUME" -lt "$VOLUME_THRESHOLD" ]; then
	if [ "$STATUS" =  "Paused" ]; then
		playerctl --all-players play-pause
	fi
	fade_in
else
	fade_out
	if [ "$STATUS" = "Playing" ]; then
		playerctl --all-players play-pause
	fi
fi
