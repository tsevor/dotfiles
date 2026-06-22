#!/usr/bin/env bash
sleep 1
killall -e xdg-desktop-portal-gtk
killall -e xdg-desktop-portal-hyprland
killall -e xdg-desktop-portal
dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP
