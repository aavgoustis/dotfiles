#!/bin/env bash
#xrdb -merge $HOME/.Xresources
setxkbmap us -variant workman

# Xmonad
exec xmonad

# DWM
## Statusbar loop
## EXAMPLE: [Brightness: 50%] Tue 2021-11-16 12:17:30 CET
#while true; do
#	xsetroot -name "[Brightness: $(brightnessctl -m | awk -F "," '{print $4}')] $( date +"%a %Y-%m-%d %T %Z")"
#	sleep 1s
#done &

## Autostart section
#exec sh ~/bin/startdwm
#exec sudo tlp start
exec xmodmap ~/.Xmodmap
exec xinput --set-prop 'SynPS/2 Synaptics TouchPad' 'libinput Accel Profile Enabled' 0, 1
exec xinput --set-prop 'SynPS/2 Synaptics TouchPad' 'libinput Natural Scrolling Enabled' 1
exec xinput --set-prop 'SynPS/2 Synaptics TouchPad' 'libinput Tapping Enabled' 1
exec xinput --set-prop 'Logitech Gaming Mouse G502' 'libinput Accel Profile Enabled' 0, 1
