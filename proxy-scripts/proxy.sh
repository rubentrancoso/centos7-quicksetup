#!/bin/bash
#
# https://www.linuxsecrets.com/en/entry/6managing-linux-systems/2015/05/26/1490-manually-change-ubuntu-proxy-settings-from-cli-command-line-terminal
#

COMMAND=$1
USER_HOME=`eval echo ~$USER`
HOME_PATH="$USER_HOME/Desktop/.proxy-scripts"

echo $PROXY_SERVER

function reloadDocker {
   sudo systemctl daemon-reload
   sudo service docker restart
}

function turnON {
   echo -e ""
   echo -e "-------------------------------------------------------------------------------------------------------------------------------"
   echo -e ">>>> turn proxy ON"
   echo -e ""
   echo -e "-------------------------------------------------------------------------------------------------------------------------------"
   echo -e ">>>> load PARAMS"

   . "$HOME_PATH/PARAMS"
   cat "$HOME_PATH/PARAMS"
   echo -e ""
   echo -e "-------------------------------------------------------------------------------------------------------------------------------"
   echo -e ">>>> enable proxy on docker"
   envsubst < ~/Desktop/.proxy-scripts/http-proxy.conf.on.tpl > ~/Desktop/.proxy-scripts/http-proxy.conf.on
   envsubst < ~/Desktop/.proxy-scripts/docker.config.json.tpl > ~/Desktop/.proxy-scripts/docker.config.json
   sudo cp "$HOME_PATH/http-proxy.conf.on" "/etc/systemd/system/docker.service.d/http-proxy.conf"
   sudo mkdir "$USER_HOME/.docker"
   sudo cp "$HOME_PATH/docker.config.json" "$USER_HOME/.docker/config.json"
   cat /etc/systemd/system/docker.service.d/http-proxy.conf
   cat "$USER_HOME/.docker/config.json"
   reloadDocker

   # .bash_profile
   echo -e ""
   echo -e "-------------------------------------------------------------------------------------------------------------------------------"
   echo -e ">>>> enable proxy on bash_profile"

   echo -e "export http_proxy=$PROXY_SERVER_WITHPASS" >> ~/.bash_profile
   echo -e "export https_proxy=$PROXY_SERVER_WITHPASS" >> ~/.bash_profile
   echo -e "export HTTP_PROXY=$PROXY_SERVER_WITHPASS" >> ~/.bash_profile
   echo -e "export HTTPS_PROXY=$PROXY_SERVER_WITHPASS" >> ~/.bash_profile

   cat ~/.bash_profile

   source /etc/profile && source ~/.bash_profile

   # /etc/yum.conf
   echo -e ""
   echo -e "-------------------------------------------------------------------------------------------------------------------------------"
   echo -e ">>>> enable proxy on /etc/yum.conf"
   sudo sh -c "echo -e \"proxy=$PROXY_SERVER\nproxy_username=$PROXY_USERNAME\nproxy_password=$PROXY_PASSWORD\" >> /etc/yum.conf"

   cat /etc/yum.conf

   # GNOME
   echo -e ""
   echo -e "-------------------------------------------------------------------------------------------------------------------------------"
   echo -e ">>>> enable gnome proxy"
   gsettings set org.gnome.system.proxy mode 'manual'

   # ~/.m2/settings.xml
   echo -e ""
   echo -e "-------------------------------------------------------------------------------------------------------------------------------"
   echo -e ">>>> enable .m2 proxy gnome proxy"


   if [ ! -f ~/.m2/settings.xml ]; then
      cp "$HOME_PATH/settings.xml" ~/.m2/settings.xml
   fi
   envsubst < ~/Desktop/.proxy-scripts/settings.proxies.xml.on.tpl > ~/Desktop/.proxy-scripts/settings.proxies.xml.on
   element=`xmlstarlet sel -N x="http://maven.apache.org/SETTINGS/1.0.0" -t -c "/x:settings/x:proxies" ~/.m2/settings.xml`
   if [ -z "$element" ]; then
     xmlstarlet ed -L -N x="http://maven.apache.org/SETTINGS/1.0.0" --insert "//x:profiles" -t elem -n "proxies" -v "" ~/.m2/settings.xml
   fi
   proxies_element=$(<~/Desktop/.proxy-scripts/settings.proxies.xml.on)
   proxies_element="${proxies_element// /}"
   proxies_element=`echo $proxies_element|tr -d '\n'`
   sed -i "s@<proxies/>@$proxies_element@g" ~/.m2/settings.xml

   echo -e ""
   echo -e "-------------------------------------------------------------------------------------------------------------------------------"
   echo -e ">>>> done."

   zenity --notification --text "proxy ON"
}

function turnOFF {
   echo -e ""
   echo -e "-------------------------------------------------------------------------------------------------------------------------------"
   echo -e ">>>> turn proxy OFF"

   echo -e ""
   echo -e "-------------------------------------------------------------------------------------------------------------------------------"
   echo -e ">>>> disable proxy for docker."
   sudo cp "$HOME_PATH/http-proxy.conf.off" "/etc/systemd/system/docker.service.d/http-proxy.conf"
   sudo rm -rf "$USER_HOME/.docker/config.json"
   cat /etc/systemd/system/docker.service.d/http-proxy.conf
   reloadDocker

   # .bash_profile
   echo -e ""
   echo -e "-------------------------------------------------------------------------------------------------------------------------------"
   echo -e ">>>> disable proxy on bash_profile."


   sed -i '/http_proxy=/d' ~/.bash_profile
   sed -i '/https_proxy=/d' ~/.bash_profile
   sed -i '/HTTP_PROXY=/d' ~/.bash_profile
   sed -i '/HTTPS_PROXY=/d' ~/.bash_profile

   cat ~/.bash_profile

   source /etc/profile && source ~/.bash_profile

   echo -e ""
   echo -e "-------------------------------------------------------------------------------------------------------------------------------"
   echo -e ">>>> set | grep proxy."
   
   set | grep proxy

   # /etc/yum.conf
   echo -e ""
   echo -e "-------------------------------------------------------------------------------------------------------------------------------"
   echo -e ">>>> disable proxy on yum.conf"


   sudo sed -i '/proxy=/d' /etc/yum.conf
   sudo sed -i '/proxy_username=/d' /etc/yum.conf
   sudo sed -i '/proxy_password=/d' /etc/yum.conf

   cat /etc/yum.conf

   # GNOME
   echo -e ""
   echo -e "-------------------------------------------------------------------------------------------------------------------------------"
   echo -e ">>>> disble gnome proxy"

   gsettings set org.gnome.system.proxy mode 'none'

   # wget

   # ~/.m2/settings.xml
   echo -e ""
   echo -e "-------------------------------------------------------------------------------------------------------------------------------"
   echo -e ">>>> disble .m2 proxy"


   # use this code to extract proxies section from settings.xml
   # xmlstarlet --no-doc-namespace sel -N x="http://maven.apache.org/SETTINGS/1.0.0" -t -c "/x:settings/x:proxies" settings.xml | sed -e 's/ xmlns.*=".*"//g' | xmlstarlet fo -s 3 -o > settings.proxies.xml

   xmlstarlet ed -L -N x="http://maven.apache.org/SETTINGS/1.0.0" -d "/x:settings/x:proxies" ~/.m2/settings.xml
  
   echo -e ""
   echo -e "-------------------------------------------------------------------------------------------------------------------------------"
   echo -e ">>>> done"

   zenity --notification --text "proxy OFF"
}

function proxyStatus {
   echo -e "----------------------------------------------"
   echo -e "DOCKER"
   echo -e "# cat /etc/systemd/system/docker.service.d/http-proxy.conf"
   echo -e ""
   cat /etc/systemd/system/docker.service.d/http-proxy.conf
   echo -e "---"
   echo -e ""
}

clear
echo -e "run sudo $HOME_PATH/proxy.sh on"

shopt -s nocasematch
case "${COMMAND}"
in
 on)
    turnON
    ;;
 off)
    turnOFF
    ;;
 status)
    proxyStatus
    ;;
  *)
    echo -e "usage"
    echo -e "proxy ON|OFF"
esac
