#!/bin/bash

#########################################################################
# Don't remove this file from /root !!
#########################################################################

set -e
set -x

if [[ -f /root/README ]]; then
   echo "ScadaBR already set up. Skipping initial configuration"
   service mysql start
   service tomcat7 start
   exit
fi

echo "##################################################"
echo "# This is the first time you run this container. #"
echo "# Finishing up configuration                     #"
echo "##################################################"

###########################################################################################################
# Set up mysql
###########################################################################################################
service mysql start
set +e
mysql -uroot -pPASS -e "SET PASSWORD = PASSWORD('password');"
mysql -uroot -ppassword -e "CREATE DATABASE scadabr;"
mysql -uroot -ppassword -e "CREATE USER 'scadabr' IDENTIFIED BY 'scadabr';"
mysql -uroot -ppassword -e "GRANT ALL PRIVILEGES ON scadabr. * TO scadabr;"
mysql -uroot -ppassword -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY 'password' WITH GRANT OPTION;"
mysql -uroot -ppassword -e "GRANT ALL PRIVILEGES ON scadabr.* TO 'scadabr'@'%' IDENTIFIED BY 'scadabr' WITH GRANT OPTION;"
sed -i "s/bind-address\s*= 127.0.0.1/bind-address            = 0.0.0.0/g" /etc/mysql/mariadb.conf.d/50-server.cnf


###########################################################################################################
# Stop tomcat7. service tomcat7 stop doesnt work at the moment.
# Ugly workaround with kill
###########################################################################################################
kill -TERM $(ps aux | grep tomcat7 | grep -v grep | awk '{print $2}')
set -e


###########################################################################################################
# Deploy ScadaBR
###########################################################################################################
rm -rf /var/lib/tomcat7/webapps/ScadaBR*
#cd /var/lib/tomcat7/webapps && wget https://sourceforge.net/projects/scadabr/files/Software/WAR/ScadaBR.war
cp /root/ScadaBR.war /var/lib/tomcat7/webapps/
service tomcat7 start
kill -TERM $(ps aux | grep tomcat7 | grep -v grep | awk '{print $2}')
mkdir /var/lib/tomcat7/bin
chown -R tomcat7.tomcat7 /var/lib/tomcat7/
gpasswd -a tomcat7 dialout


###########################################################################################################
# Configure ScadaBR
###########################################################################################################
sed -i "s/^db.username=root/db.username=scadabr/g" /var/lib/tomcat7/webapps/ScadaBR/WEB-INF/classes/env.properties
sed -i "s/^db.password=/db.password=scadabr/g" /var/lib/tomcat7/webapps/ScadaBR/WEB-INF/classes/env.properties
sed -i "s/^convert.db.type=/#convert.db.type=/g" /var/lib/tomcat7/webapps/ScadaBR/WEB-INF/classes/env.properties
sed -i "s/^convert.db.url=/#convert.db.url=/g" /var/lib/tomcat7/webapps/ScadaBR/WEB-INF/classes/env.properties
sed -i "s/^convert.db.username=/#convert.db.username=/g" /var/lib/tomcat7/webapps/ScadaBR/WEB-INF/classes/env.properties
sed -i "s/^convert.db.password=/#convert.db.password=/g" /var/lib/tomcat7/webapps/ScadaBR/WEB-INF/classes/env.properties
sed -i "s/type=InnoDB/engine=InnoDB/g" /var/lib/tomcat7/webapps/ScadaBR/WEB-INF/db/createTables-mysql.sql

###########################################################################################################
# Restarting services
###########################################################################################################
service mysql restart
service tomcat7 start

echo "Don't remove this file from /root !" > /root/README

echo "##################################################"
echo "# Finished !!                                    #"
echo "# Scada GUI user: admin                          #"                      
echo "# Scada GUI password: admin                      #"
echo "# Database root user: root                       #"
echo "# Database root password: password               #"
echo "# Database: scadabr                              #"
echo "# Database user: scadabr                         #"
echo "# Database password: scadabr                     #"
echo "##################################################"

exit 0

