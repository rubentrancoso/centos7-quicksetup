#!/bin/bash -x
echo "disconnectiong..." >> /tmp/vpn.log

log=`ps -ax | grep openconnect; ps -ax | grep vpnstart`

sudo pkill -f "openconnect"
sudo pkill -f "vpnstart"

log=`ps -ax | grep openconnect; ps -ax | grep vpnstart`

echo "$log" >> /tmp/vpn.log

zenity --notification --text "vpn disconnected"
