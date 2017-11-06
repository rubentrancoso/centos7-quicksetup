export user_home=`eval echo ~$USER`
cd ..
cp -R vpn-scripts ~/Desktop/.vpn-scripts
envsubst < ~/Desktop/.vpn-scripts/vpnon.desktop > ~/Desktop/vpnon.desktop
envsubst < ~/Desktop/.vpn-scripts/vpnoff.desktop > ~/Desktop/vpnoff.desktop
chmod +x ~/Desktop/vpnon.desktop
chmod +x ~/Desktop/vpnoff.desktop
