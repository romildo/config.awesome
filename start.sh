#! /usr/bin/env bash

## run (only once) processes which spawn with a different name
function run2 {
    if (command -v $2 && ! pgrep -a -f -u $USER -x $1); then
         shift
         notify-send "Auto starting" "$@" --icon=dialog-information
         $@ &
    fi
}

## run (only once) processes which spawn with the same name
function run {
    run2 $1 $@
}

notify-send "start.sh" "Auto starting some applications" --icon=dialog-information

command -v phwmon.py && pgrep -a -f -u $USER phwmon.py || phwmon.py &
#command -v albert    && pgrep -a -f -u $USER albert    || albert &

if connmanctl state; then
    run cmst --minimized
    run connman-notify
else
    command -v nm-applet && pgrep -a -f -u $USER nm-applet || nm-applet &
fi

if command -v blueman-applet; then
    pgrep -a -f -u $USER blueman-applet || blueman-applet &
else
    if command -v blueberry-tray; then
        pgrep -a -f -u $USER blueberry-tray || blueberry-tray &
    fi
fi

eDP=$(xrandr --listmonitors | cut -d ' ' -f 6 | grep eDP)
HDMI=$(xrandr --listmonitors | cut -d ' ' -f 6 | grep HDMI)
if [ -n "$eDP" -a -n "$HDMI" ]; then
    xrandr --verbose --output "$eDP" --auto --primary --output "$HDMI" --left-of "$eDP" --auto
fi
# xrandr --verbose --output HDMI-0 --mode 1440x900
# autorandr --change

xhost +local:

xrdb -merge $HOME/.Xresources

#run compton -cCGb -i 0.97 -e 0.94
#run syndaemon -t -k -i 2 -d
run xsettingsd
#run pnmixer

command -v volctl && pgrep -a -f -u $USER volctl || volctl &
#run volctl

#run liferea
run2 xfce4-power-man xfce4-power-manager
###!run2 mate-power-man mate-power-manager
#run cbatticon
#run jgmenu --hide-on-startup

#run dolphin --daemon
run pcmanfm-qt --daemon-mode
