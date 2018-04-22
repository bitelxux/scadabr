docker run --privileged -p8080:8080 -itd bitelxux/scadabr

or something like

docker run --privileged --name scada -h openstack --name scada --net internal --ip 10.1.1.50 -v /home/cnn/work/scada/database:/root/database -p8080:8080 -itd bitelxux/scadabr

# Quick start. Mysql datasource

Create a new MySQL datasource:

* Name               ScadaBR 
* Export ID (XID)    ScadaBR
* Update period      5
* Driver class name  com.mysql.jdbc.Driver
* Connection string  jdbc:mysql://localhost:3306/scadabr
* Username           scadabr
* Password           scadabr
* Select statement   select name from dataSources;

https://hub.docker.com/r/bitelxux/scadabr/
