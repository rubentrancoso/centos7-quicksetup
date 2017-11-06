#!/bin/bash -x
USER_HOME=`eval echo ~$USER`
HOME_PATH="$USER_HOME/Desktop/.vpn-scripts"

echo "loading credentials..." >> /tmp/vpn.log

. "$HOME_PATH/PARAMS"

log=`ps -ax | grep openconnect; ps -ax | grep vpnstart`
echo "$log" >> /tmp/vpn.log

echo "killing openconnect..." >> /tmp/vpn.log

sudo pkill -f openconnect

log=`ps -ax | grep openconnect; ps -ax | grep vpnstart`
echo "$log" >> /tmp/vpn.log

echo "asking for token..." >> /tmp/vpn.log

token=`zenity --password --title "vpn token"`
pass="$PASSWORDX$token"

echo "calling openconnect..." >> /tmp/vpn.log

echo "$pass" | sudo openconnect -b -u "$USERNAMEX" --authgroup="$VPN_GROUP" $VPN_HOST --passwd-on-stdin
sleep 5

echo "removing routes..." >> /tmp/vpn.log

sudo route -v del -net 172.16.0.0/12 >> /tmp/vpn.log
sudo route -v del -net 172.16.0.0/12 >> /tmp/vpn.log
sudo route add -net 172.16.133.0/24 tun0

echo "calling chrome..." >> /tmp/vpn.log

google-chrome "$TEST_URL"
zenity --notification --text "vpn connected"

sudo sed -i '/172.18.218.60/d' /etc/hosts
echo "172.18.218.60        $PROXY_HOST # added by vpn script" | sudo tee --append /etc/hosts

log=`ps -ax | grep openconnect; ps -ax | grep vpnstart`

echo "$log" >> /tmp/vpn.log
