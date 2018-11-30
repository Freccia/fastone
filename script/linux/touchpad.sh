#!/bin/bash

# Set properties for touchpad on Linux

# More info:
# xinput --list-props "SynPS/2 Synaptics TouchPad"

xinput --set-prop --type=int --format=8  "SynPS/2 Synaptics TouchPad" "libinput Tapping Enabled" 1

xinput --set-prop --type=int --format=32 "SynPS/2 Synaptics TouchPad" "Synaptics Two-Finger Pressure" 4

# Below width 1 finger touch, above width simulate 2 finger touch. - value=pad-pixels
xinput --set-prop --type=int --format=32 "SynPS/2 Synaptics TouchPad" "Synaptics Two-Finger Width" 8

# vertical scrolling, horizontal scrolling - values: 0=disable 1=enable
xinput --set-prop --type=int --format=8  "SynPS/2 Synaptics TouchPad" "Synaptics Two-Finger Scrolling" 1 1

# vertical, horizontal, corner - values: 0=disable  1=enable
xinput --set-prop --type=int --format=8  "SynPS/2 Synaptics TouchPad" "Synaptics Edge Scrolling" 0 0 0

# stabilize 2 finger actions - value=pad-pixels
xinput --set-prop --type=int --form
