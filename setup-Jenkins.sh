#!/bin/bash
INITPASS='nananaa'
TESTPASS='goodbye'
sudo apt-get update
sudo apt-get install docker.io
sudo docker build --tag=jenkins .
sudo docker run -d \
	-v jenkins_home:/var/jenkins_home \
	-v /var/run/docker.sock:/var/run/docker.sock \
	-v $(which docker):/usr/bin/docker \
	--name jenkins \
	-p 8180:8080 \
	-p 50000:50000 \
	-u root \
	--privileged \
	jenkins:latest
echo "Building containers"
sleep 15
echo ""
echo "Initial Admin Password below"
TEST=`sudo ls /var/lib/docker/volumes/jenkins_home/_data/secrets/ | grep initialAdminPassword`
while [[ "$TEST" != "initialAdminPassword" ]]
do
	sleep 2
	TEST=`sudo ls /var/lib/docker/volumes/jenkins_home/_data/secrets/ | grep initialAdminPassword`
done
INITPASS=`sudo cat /var/lib/docker/volumes/jenkins_home/_data/secrets/initialAdminPassword`
echo $INITPASS
echo ""
echo ""
echo "Please visit your servers public IP to continue Jenkins setup"
IP4=`curl -s4 ifconfig.co`
IP6=`curl -s6 ifconfig.co`
echo "IPv4: http://$IP4:8180"
echo "IPv6: http://[$IP6]:8180"
TEST=`sudo ls /var/lib/docker/volumes/jenkins_home/_data/secrets/ | grep initialAdminPassword`
while [[ "$TEST" != "" ]]
do
        sleep 2
        TEST=`sudo ls /var/lib/docker/volumes/jenkins_home/_data/secrets/ | grep initialAdminPassword`
done
echo "Done setup! Restarting Jenkins"
sleep 5
sudo docker restart jenkins
sudo ln -s /var/lib/docker/volumes/jenkins_home/_data /var/jenkins_home
echo "Jenkins restarted, please check the servers local IP to verify everything is up and running"
