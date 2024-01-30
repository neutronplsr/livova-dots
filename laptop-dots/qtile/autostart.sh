#!/bin/sh
alacritty &
picom &
wired &
xfce4-clipman &
mullvad-vpn &
xautolock -time 10 -locker "systemctl suspend" -detectsleep &
xidlehook --not-when-fullscreen --not-when-audio --timer 600 'systemctl suspend'  '' &
pcloud &
nm-applet &
