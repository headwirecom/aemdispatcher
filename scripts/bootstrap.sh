#!/bin/bash

echo "************************************************"
echo Installing Module: $1
echo "************************************************"

echo "************************************************"
echo "Load Settings"
echo "************************************************"
. /home/vagrant/sync/scripts/setenv.sh

# Disable SELINUX
echo "************************************************"
echo "Disable SELINUX"
echo "************************************************"
setenforce 0

# Update Configuation to keep SELINUX disabled
echo "************************************************"
echo "Permanently disable SELINUX"
echo "************************************************"
sed -i 's/enforcing/disadbled/g' /etc/selinux/config

# Create Home Folder and make it Root readable
echo "************************************************"
echo "Create AEM Home Folder: $AEM_HOME_FOLDER"
echo "************************************************"
mkdir -p $AEM_HOME_FOLDER
chown root $AEM_HOME_FOLDER

# Create Apache Document Root Folder
echo "************************************************"
echo "Create Apache Document Root $APACHE_DOCUMENT_ROOT_FOLDER"
echo "************************************************"
mkdir -p $APACHE_DOCUMENT_ROOT_FOLDER
chmod -R 777 $APACHE_DOCUMENT_ROOT_FOLDER

# Create Dispatcher / Modules Folder
echo "************************************************"
echo "Create Project Module: $PROJECT_MODULE"
echo "************************************************"
mkdir -p $PROJECT_MODULE
cd $PROJECT_MODULE

# Extract Dispatcher Module
DISPATCHER_FILE=`ls $ARTIFACTS_FOLDER/$DISPATCHER_NAME`
echo "************************************************"
echo "Expand Dispatcher Archive: $DISPATCHER_FILE"
echo "************************************************"
tar -xzf $DISPATCHER_FILE

# Create Symbolic Link for Dispatcher Module
echo "************************************************"
echo "Create Symbolic Link to Dispatcher Module"
echo "************************************************"
ln -s `ls dispatcher*.so` mod_dispatcher.so

# Install 1.8 JDK
echo "************************************************"
echo "Install the JDK"
echo "************************************************"
yum -y install curl lsof net-tools java-1.8.0-openjdk-devel 

# Install Apache Web Server
echo "************************************************"
echo "Install Apache HTTPD Service"
echo "************************************************"
yum -y install httpd

# Install Git to clone Project later
echo "************************************************"
echo "Install GIT"
echo "************************************************"
yum -y install git

echo "************************************************"
echo "Create Git Homme Folder: $GIT_HOME_FOLDER"
echo "************************************************"
mkdir -p $GIT_HOME_FOLDER
cd $GIT_HOME_FOLDER
echo "************************************************"
echo "Clone AEM Dispatcher GIT Repo: $GIT_REPO_URL"
echo "************************************************"
git clone $GIT_REPO_URL

PUBLISH_DOMAIN=publish

echo "************************************************"
echo "Updating /etc/hosts..."
echo "************************************************"
echo "127.0.0.1 $PUBLISH_DOMAIN" >> /etc/hosts
#echo "127.0.0.1 $PUBLISH_DOMAIN" >> /etc/hosts

# Copy AEM into project
echo "************************************************"
echo "Create AEM Home folder: $AEM_HOME_FOLDER and copy AEM Jar and License file"
echo "************************************************"
mkdir -p $AEM_HOME_FOLDER
cd $AEM_HOME_FOLDER
cp $ARTIFACTS_FOLDER/aem* $AEM_HOME_FOLDER/
cp $ARTIFACTS_FOLDER/license* $AEM_HOME_FOLDER/

# Extract the AEM Installation
echo "************************************************"
echo "Extract AEM JAR file"
echo "************************************************"
java -jar aem*.jar -unpack

# Copy Runlevel Scripts
echo "************************************************"
echo "Install our own AEM Start / Stop scripts"
echo "************************************************"
cp -R  $ARTIFACTS_FOLDER/bin $AEM_HOME_FOLDER/crx-quickstart/

# Install System V scripts
echo "************************************************"
echo "INstall Sytem V runlevel scripts for AEM"
echo "************************************************"
cd $SCRIPTS_FOLDER
. ./install-aem-services.sh

# No need to start the AEM Publish isntance as we just did beforehand
echo "************************************************"
echo "Starting AEM Publish and HTTPD Services"
echo "************************************************"
service aem61publish start
service httpd start

# Run the Dispather Conf Update Script
if [ "$2" == "local" ]
then
	cd $SCRIPTS_FOLDER
else
	cd $GIT_HOME_FOLDER/aemdispatcher/scripts
fi
. ./update-dispatcher-conf.sh $1

cat << EOF

*****************************************************************************************
* Your AEM Publish and Dispatcher is setup and running
*
* You need to wait until AEM is fully started up before hitting the Server through
* the dispatcher on:
*
* http://localhost:8080/
*
* You can check here:
*
* http://localhost:4503/
* 
* The Dispatcher GIT Repo is available under $GIT_HOME_FOLDER/aemdispatcher. It is a clone
* of the GIT Repo on Github. If there are updates then you can go to the GIT Repo and
* update with:
*
* git pull origin
*
* and then run the udpate scripts in the $GIT_HOME_FOLDER/aemdispatcher/sctipts folder
* using this syntax:
*
* ./update-dispatcher-conf.sh <sub projet name>
*
* Sub Project are any folders other than scripts and artifacts like plain-no-rewrites or
* browser-language-redirect.
*
*****************************************************************************************
EOF
