#!/usr/bin/env bash

# Run script as sudo: sudo ./setup.sh
########################################################################################
##########            This is a scriptet version of this tutorial:  ####################
#### https://www.digitalocean.com/community/tutorials/install-tomcat-9-ubuntu-1804  ####
########################################################################################

########################################################################################
## IMPORTANT: If you run this script on a public server, change the passwords below ####
########################################################################################

MANAGER_GUI_PW="a1234"
MANAGER_SCRIPT_PW="a1234"


echo "########################## Install Java     #########################"
sudo -E apt-get install -y openjdk-8-jre

echo ""
echo "########################## Tomcat Setup     #########################"

sudo groupadd tomcat
sudo useradd -s /bin/false -g tomcat -d /opt/tomcat tomcat

cd /tmp
sudo curl -O http://mirrors.dotsrc.org/apache/tomcat/tomcat-9/v9.0.21/bin/apache-tomcat-9.0.21.tar.gz
sudo mkdir /opt/tomcat
sudo tar xzvf apache-tomcat-9*tar.gz -C /opt/tomcat --strip-components=1

sudo rm -r /opt/tomcat/webapps/examples
sudo rm -r /opt/tomcat/webapps/docs

cd /opt/tomcat
sudo chgrp -R tomcat /opt/tomcat
sudo chmod -R g+r conf
sudo chmod g+x conf
sudo chown -R tomcat webapps/ work/ temp/ logs/

echo "##############################################################################"
echo "###########             Setup Tomcat-users.xml                ################"
echo "###########   Change passwords if used on a public server ####################"
echo "##############################################################################"

sudo rm /opt/tomcat/conf/tomcat-users.xml
sudo cat <<- EOF_TCU > /opt/tomcat/conf/tomcat-users.xml
<?xml version="1.0" encoding="UTF-8"?>
<tomcat-users xmlns="http://tomcat.apache.org/xml"
              xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
              xsi:schemaLocation="http://tomcat.apache.org/xml tomcat-users.xsd"
              version="1.0">
<!--
         NOTE:  DO NOT USE THIS FILE IN PRODUCTION.
         IT'S MEANT ONLY FOR A LOCAL DEVELOPMENT SERVER USED BY NETBEANS
-->
  <user username="netbeans" password="$MANAGER_GUI_PW" roles="manager-gui"/>
  <user username="mavendeploy" password="$MANAGER_SCRIPT_PW" roles="manager-script"/>
</tomcat-users>
EOF_TCU

echo ""
echo "################################################################################"
echo "#######             Setup manager context.xml                            #######"
echo "####### Allows access from browsers NOT running on same server as Tomcat #######"
echo "################################################################################"

sudo rm /opt/tomcat/webapps/manager/META-INF/context.xml
sudo cat <<- EOF_CONTEXT > /opt/tomcat/webapps/manager/META-INF/context.xml
<?xml version="1.0" encoding="UTF-8"?>
<Context antiResourceLocking="false" privileged="true" >
  <!-- <Valve className="org.apache.catalina.valves.RemoteAddrValve"
         allow="127\.\d+\.\d+\.\d+|::1|0:0:0:0:0:0:0:1" /> -->
</Context>
EOF_CONTEXT

sudo rm /opt/tomcat/webapps/host-manager/META-INF/context.xml
sudo cat <<- EOF_CONTEXT_H > /opt/tomcat/webapps/host-manager/META-INF/context.xml
<?xml version="1.0" encoding="UTF-8"?>
<Context antiResourceLocking="false" privileged="true" >
  <!-- <Valve className="org.apache.catalina.valves.RemoteAddrValve"
         allow="127\.\d+\.\d+\.\d+|::1|0:0:0:0:0:0:0:1" /> -->
</Context>
EOF_CONTEXT_H


echo ""
echo "################################################################################"
echo "#######                       Setup setenv.sh                            #######"
echo "#######      Sets different environment variables read by Tomcat         #######"
echo "################################################################################"

sudo cat <<- EOF_SETENV > /opt/tomcat/bin/setenv.sh
# export JPDA_OPTS="-agentlib:jdwp=transport=dt_socket, address=9999, server=y, suspend=n"
export CATALINA_OPTS="-agentlib:jdwp=transport=dt_socket,address=9999,server=y,suspend=n"
EOF_SETENV


echo ""
echo "################################################################################"
echo "############################ Create tomcat.service file ########################"
echo "################################################################################"
# Inspired by this tutorial: https://www.digitalocean.com/community/tutorials/install-tomcat-9-ubuntu-1804

sudo cat <<- EOF > /etc/systemd/system/tomcat.service
 [Unit]
 Description=Apache Tomcat Web Applicatiprivilegedon Container
 After=network.target

 [Service]
 Type=forking
 
 Environment=JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-amd64
 Environment=CATALINA_PID=/opt/tomcat/temp/tomcat.pid
 Environment=CATALINA_HOME=/opt/tomcat
 Environment=CATALINA_BASE=/opt/tomcat
 Environment='CATALINA_OPTS=-Xms512M -Xmx1024M -server -XX:+UseParallelGC'
 Environment='JAVA_OPTS=-Djava.awt.headless=true -Djava.security.egd=file:/dev/./urandom'
 
 ExecStart=/opt/tomcat/bin/startup.sh
 ExecStop=/opt/tomcat/bin/shutdown.sh
 
 User=tomcat
 Group=tomcat
 UMask=0007
 RestartSec=10
 Restart=always

 [Install]
 WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl start tomcat
sudo systemctl enable tomcat