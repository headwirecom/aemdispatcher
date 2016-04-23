#!/bin/bash

echo Installing Module: $1

pwd
echo "Load Settings"
. /home/vagrant/sync/scripts/setenv.sh
echo "AEM Home Folder: $AEM_HOME_FOLDER"

# Disable SELINUX
setenforce 0

# Update Configuation to keep SELINUX disabled
sed -i 's/enforcing/disadbled/g' /etc/selinux/config

# Create Home Folder and make it Root readable
mkdir -p $AEM_HOME_FOLDER
chown root $AEM_HOME_FOLDER

# Create Apache Document Root Folder
mkdir -p $APACHE_DOCUMENT_ROOT_FOLDER

# Create Dispatcher / Modules Folder
mkdir -p $PROJECT_MODULE
cd $PROJECT_MODULE

# Extract Dispatcher Module
echo ls $ARTIFACTS_FOLDER/$DISPATCHER_NAME
DISPATCHER_FILE=`ls $ARTIFACTS_FOLDER/$DISPATCHER_NAME`
echo Dispatcher File: $DISPATCHER_FILE
tar -xzf $DISPATCHER_FILE

# Create Symbolic Link for Dispatcher Module
ln -s `ls dispatcher*.so` mod_dispatcher.so

# Install 1.8 JDK
yum -y install curl lsof net-tools java-1.8.0-openjdk-devel 

# Install Apache Web Server
yum -y install httpd

# Install Git to clone Project later
yum -y install git

mkdir -p $GIT_HOME_FOLDER
cd $GIT_HOME_FOLDER
git clone $GIT_REPO_URL

PUBLISH_DOMAIN=publish

echo "Updating /etc/hosts..."
echo "127.0.0.1 $PUBLISH_DOMAIN" >> /etc/hosts
#echo "127.0.0.1 $PUBLISH_DOMAIN" >> /etc/hosts

# Create Dispatcher Document Root and set permissions
echo "Create and Set Permission for Document Root: $APACHE_DOCUMENT_ROOT_FOLDER"
mkdir $APACHE_DOCUMENT_ROOT_FOLDER
chmod -R 777 $APACHE_DOCUMENT_ROOT_FOLDER

# Copy AEM into project
mkdir -p $AEM_HOME_FOLDER
cd $AEM_HOME_FOLDER
cp $ARTIFACTS_FOLDER/aem* $AEM_HOME_FOLDER/
cp $ARTIFACTS_FOLDER/license* $AEM_HOME_FOLDER/

# Extract the AEM Installation
java -jar aem*.jar -unpack

# Create Runlevel Scripts
cp -R  $ARTIFACTS_FOLDER/bin $AEM_HOME_FOLDER/crx-quickstart/

# Install System V scripts
$SCRIPTS_FOLDER/install-aem-services.sh $ARTIFACTS_FOLDER $AEM_HOME_FOLDER

# No need to start the AEM Publish isntance as we just did beforehand
echo "Starting AEM Publish"
service aem61publish start

# Run the Dispather Conf Update Script
if [ "$2" == "local" ]
then
	cd $SCRIPTS_FOLDER
else
	cd $GIT_HOME_FOLDER/aemdispatcher/scripts
fi
pwd
. ./update-dispatcher-conf.sh $1

cat << EOF

*****************************************************************************************
* Your AEM Publish and Dispatcher is setup and running
* 
* 127.0.0.1 publish
*****************************************************************************************
EOF
