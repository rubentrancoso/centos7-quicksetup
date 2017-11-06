#!/bin/bash -x
export user_home=`eval echo ~$USER`
sudo mkdir /etc/systemd/system/docker.service.d
cd ..
cp -R proxy-scripts ~/Desktop/.proxy-scripts
envsubst < ~/Desktop/.proxy-scripts/proxyon.desktop > ~/Desktop/proxyon.desktop
envsubst < ~/Desktop/.proxy-scripts/proxyoff.desktop > ~/Desktop/proxyoff.desktop
chmod +x ~/Desktop/proxyon.desktop
chmod +x ~/Desktop/proxyoff.desktop
