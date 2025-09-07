#!/bin/bash

# Update system
yum update -y

# Install Java 21 (Amazon Corretto)
yum install java-21-amazon-corretto -y


# Set JAVA_HOME
echo "export JAVA_HOME=/usr/lib/jvm/java-21-amazon-corretto" >> /etc/profile
echo "export PATH=\$JAVA_HOME/bin:\$PATH" >> /etc/profile
source /etc/profile

# Download and install Tomcat 11
cd /opt
wget https://dlcdn.apache.org/tomcat/tomcat-11/v11.0.11/bin/apache-tomcat-11.0.11.tar.gz
tar -xzvf apache-tomcat-11.0.11.tar.gz
mv apache-tomcat-11.0.11 tomcat

# Set permissions
chmod +x /opt/tomcat/bin/startup.sh
chmod +x /opt/tomcat/bin/shutdown.sh

# Create symlinks
ln -s /opt/tomcat/bin/startup.sh /usr/local/bin/tomcatup
ln -s /opt/tomcat/bin/shutdown.sh /usr/local/bin/tomcatdown

# pre-process context and config files
yum install dos2unix -y
dos2unix /opt/tomcat/webapps/manager/META-INF/context.xml
dos2unix /opt/tomcat/webapps/host-manager/META-INF/context.xml
dos2unix /opt/tomcat/conf/tomcat-users.xml

# Use awk to comment out multi-line <Valve> block in manager context.xml
awk '/<Valve className="org.apache.catalina.valves.RemoteAddrValve"/ {
    print "<!--";
    print;
    getline;
    print $0 " -->";
    next;
}
{ print }' /opt/tomcat/webapps/manager/META-INF/context.xml > /opt/tomcat/webapps/manager/META-INF/context.xml.tmp && mv /opt/tomcat/webapps/manager/META-INF/context.xml.tmp /opt/tomcat/webapps/manager/META-INF/context.xml

# Use awk to comment out multi-line <Valve> block in host-manager context.xml
awk '/<Valve className="org.apache.catalina.valves.RemoteAddrValve"/ {
    print "<!--";
    print;
    getline;
    print $0 " -->";
    next;
}
{ print }' /opt/tomcat/webapps/host-manager/META-INF/context.xml > /opt/tomcat/webapps/host-manager/META-INF/context.xml.tmp && mv /opt/tomcat/webapps/host-manager/META-INF/context.xml.tmp /opt/tomcat/webapps/host-manager/META-INF/context.xml


# Update users information in conf/tomcat-users.xml file
sed -i '/<\/tomcat-users>/i \
<role rolename="manager-gui"/>\n\
<role rolename="manager-script"/>\n\
<role rolename="manager-jmx"/>\n\
<role rolename="manager-status"/>\n\
<user username="admin" password="admin" roles="manager-gui, manager-script, manager-jmx, manager-status"/>\n\
<user username="deployer" password="deployer" roles="manager-script"/>\n\
<user username="tomcat" password="tomcat" roles="manager-gui"/>' /opt/tomcat/conf/tomcat-users.xml

# Start Tomcat
tomcatup