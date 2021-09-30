#!/bin/env bash
xrdb -merge $HOME/.Xresources # <--- this line
# Xmonad
exec xmonad
