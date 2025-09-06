#!/bin/bash
# install Jenkins
yum update
yum install java-21-amazon-corretto -y
wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
yum install jenkins -y
sed -i '/### Anything between here and the comment below will become the new contents of the file/a [Service]\nEnvironment="JAVA_OPTS=-Djava.awt.headless=true -Djava.net.preferIPv4Stack=true -Djava.io.tmpdir=/var/cache/jenkins/tmp/ -Dorg.apache.commons.jelly.tags.fmt.timeZone=America/Edmonton -Duser.timezone=America/Edmonton"\nEnvironment="JENKINS_OPTS=--pluginroot=/var/cache/jenkins/plugins"' /etc/systemd/system/jenkins.service.d/override.conf
systemctl enable jenkins
systemctl start jenkins

# then install git
yum install git -y

# then Install Maven
MAVEN_VERSION=3.9.11
wget https://dlcdn.apache.org/maven/maven-3/$MAVEN_VERSION/binaries/apache-maven-$MAVEN_VERSION-bin.tar.gz -P /tmp
tar -xzf /tmp/apache-maven-$MAVEN_VERSION-bin.tar.gz -C  /opt/
mv /opt/apache-maven-$MAVEN_VERSION /opt/maven
ln -s /opt/maven/bin/mvn /usr/local/bin/mvn
echo "M2_HOME=/opt/maven" | tee -a /etc/environment
rm -rf /tmp/apache-maven-$MAVEN_VERSION-bin.tar.gz

# then install terraform
yum install -y yum-utils
yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
yum -y install terraform

# finally install kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x ./kubectl
mkdir -p $HOME/bin && cp ./kubectl $HOME/bin/kubectl && export PATH=$PATH:$HOME/bin