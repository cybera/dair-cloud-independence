#Dockerfile
FROM jenkins/jenkins:lts
MAINTAINER Ben Leavitt <ben.leavitt@cybera.ca>
USER root
RUN apt-get update && apt-get install -y tree nano curl sudo
RUN curl https://get.docker.com/builds/Linux/x86_64/docker-latest.tgz | tar xvz -C /tmp/ && mv /tmp/docker/docker /usr/bin/docker
RUN curl -L "https://github.com/docker/compose/releases/download/1.23.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
RUN chmod 755 /usr/local/bin/docker-compose
RUN usermod -a -G sudo jenkins
RUN echo "jenkins ALL=(ALL:ALL) NOPASSWD:ALL" >> /etc/sudoers
USER jenkins
##Uncomment below for automated setup
#ENV JAVA_OPTS="-Djenkins.install.runSetupWizard=false"
#COPY jenkins-plugins.txt /usr/share/jenkins/ref/jenkins-plugins.txt
#RUN /usr/local/bin/install-plugins.sh < /usr/share/jenkins/ref/jenkins-plugins.txt
