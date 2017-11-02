#!/bin/bash
# from https://www.vultr.com/docs/how-to-install-gradle-on-centos-7
mkdir gradle-files
cd gradle-files
wget https://services.gradle.org/distributions/gradle-4.3-bin.zip
sudo unzip -d /opt gradle-4.3-bin.zip
sudo ln -s /opt/gradle-4.3 /opt/gradle

sudo tee /etc/profile.d/gradle.sh <<-'EOF'
export PATH=$PATH:/opt/gradle/bin
EOF

cd ..
rm -rf gradle-files
