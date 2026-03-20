#!/bin/bash

# --- DUAL SCREEN KIOSK CONFIGURATION ---

export DISPLAY=:0

# Dashboards links
URL_DISPLAY_1="https://google.de"
URL_DISPLAY_2="https://duck.com"

# check at which position the second monitor is located
MOVE_DISTANCE_TO_SECOND_MONITOR=$(xrandr | grep "HDMI-A-2 connected" | cut -d'+' -f2)

# Chromium flags to force kiosk mode without any interruption
COMMON_FLAGS="--kiosk --cursor-visibility=hidden --hide-scrollbars --touch-events=enabled --disable-pinch --noerrdialogs --disable-session-crashed-bubble --simulate-outdated-no-au='Tue, 31 Dec 2099 23:59:59 GMT' --disable-component-update --overscroll-history-navigation=0 --disable-features=TranslateUI --autoplay-policy=no-user-gesture-required"

# create chrome profile ordner if not present
mkdir -p "/home/pi/chromium-1"
mkdir -p "/home/pi/chromium-2"

sleep 5 # wait for start up GUI, maybe you need to adjust this, works fine with Pi5 for me
wlrctl pointer move -10000 -10000 # move to upper left corner
wlrctl pointer move 10 50 # move it bit to point cursor on the desktop
sleep 2

# open first browser on first display
chromium $COMMON_FLAGS \
  --user-data-dir=/home/pi/chromium-1 \
  --app=$URL_DISPLAY_1 &

sleep 10 # short delay, so the first instance could load

wlrctl pointer move $MOVE_DISTANCE_TO_SECOND_MONITOR 0 # move to next monitor
sleep 5

# open second browser on second display
chromium $COMMON_FLAGS \
  --user-data-dir=/home/pi/chromium-2 \
  --app=$URL_DISPLAY_2 &

wlrctl pointer move 10000 10000 # move to down right corner to hide
sleep 2
unclutter &
