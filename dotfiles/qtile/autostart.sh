#!/bin/sh
alacritty &
picom &
wired &
xfce4-clipman &
mullvad-vpn &
xidlehook --not-when-fullscreen --not-when-audio --timer 600 'systemctl suspend' '' &
xrandr --output DP-1  --auto --primary --output HDMI-1 --right-of DP-1 &
pcloud &
