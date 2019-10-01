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
echo "Initial Admin Password below"
INITPASS=`sudo cat /var/lib/docker/volumes/jenkins_home/_data/secrets/initialAdminPassword`
echo $INITPASS
echo "Please visit your servers public IP to continue Jenkins setup"
while :
do
	TESTPASS=`sudo cat /var/lib/docker/volumes/jenkins_home/_data/secrets/initialAdminPassword`
	if [ "$TESTPASS" != "$INITPASS" ]; then
		echo $TESTPASS
		break
	fi
done
echo "Done setup! Waiting 10 seconds to restart jenkins"
sleep 10
sudo docker restart jenkins
sudo ln -s /var/lib/docker/volumes/jenkins_home/_data /var/jenkins_home
echo "Jenkins restarted, please check the servers local IP to verify everything is up and running"
