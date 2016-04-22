#!/bin/bash

SYNC_FOLDER=/home/vagrant/sync
ARTIFACTS_FOLDER=$SYNC_FOLDER/artifacts
SCRIPTS_FOLER=$SYNC_FOLDER/scripts
DISPATCHER_NAME=dispatcher-module.tar.gz

DISPATHER_FILE=ARTIFACTS_FOLDER/$DISPATCHER_NAME

# Setup a local setup inside /etc/httpd to keep the files seperate from Apache
APACHE_CONF_HOME=/etc/httpd/conf.d/dispatcher
APACHE_LOG_FOLDER=/var/log/httpd
APACHE_DOCUMENT_ROOT_FOLDER=/var/www/dispatcher
PROJECT_MODULE=$APACHE_CONF_HOME/modules
AEM_HOME_FOLDER=/home/aem

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
# echo DISPATCHER FILE: $ARTIFACTS_FOLDER/$DISPATCHER_NAME
# ls -lt $ARTIFACTS_FOLDER/
tar -xzf $ARTIFACTS_FOLDER/$DISPATCHER_NAME

# Create Symbolic Link for Dispatcher Module
pwd
echo Link Dispatcher Module: ln -s `ls dispatcher*.so` mod_dispatcher.so
ln -s `ls dispatcher*.so` mod_dispatcher.so

# Install 1.8 JDK
yum -y install curl lsof net-tools java-1.8.0-openjdk-devel 

# Install Apache Web Server
yum -y install httpd

PUBLISH_DOMAIN=publish

echo "Updating /etc/hosts..."
echo "127.0.0.1 $PUBLISH_DOMAIN" >> /etc/hosts
#echo "127.0.0.1 $PUBLISH_DOMAIN" >> /etc/hosts

# Copy Project Fiels to project folder
cp -R $SYNC_FOLDER/httpd/dispatcher/* $APACHE_CONF_HOME

# Filter Dispatcher HTTP Conf and Dispatcher Any file
cd $APACHE_CONF_HOME
echo Filter HTTP Configuration and Dispatcher.any files

ENCODED=$( echo "$PROJECT_MODULE" | sed 's/\//\\\//g' )
echo Encoded Project Module: $ENCODED
sed -i 's/\@PROJECT_MODULE\@/'$ENCODED'/g' dispatcher*.httpd.conf
ENCODED=$( echo "$APACHE_CONF_HOME" | sed 's/\//\\\//g' )
echo Encoded Conf Folder: $ENCODED
sed -i 's/\@APACHE_CONF_FOLDER\@/'$ENCODED'/g' dispatcher*.httpd.conf
ENCODED=$( echo "$APACHE_LOG_FOLDER" | sed 's/\//\\\//g' )
echo Encoded Log Folder: $ENCODED
sed -i 's/\@APACHE_LOG_FOLDER\@/'$ENCODED'/g' dispatcher*.httpd.conf
ENCODED=$( echo "$APACHE_DOCUMENT_ROOT_FOLDER" | sed 's/\//\\\//g' )
echo Encoded Document Root Folder: $ENCODED
sed -i 's/\@APACHE_DOCUMENT_ROOT_FOLDER\@/'$ENCODED'/g' dispatcher*.httpd.conf
sed -i 's/\@APACHE_DOCUMENT_ROOT_FOLDER\@/'$ENCODED'/g' dispatcher.any

# Link the Dispqtcher HTTP Conf file into the Apache
echo Link HTTP Conf File: ln -s `ls $APACHE_CONF_HOME/*.httpd.conf` /etc/httpd/conf.d/dispatcher.httpd.conf
ln -s `ls $APACHE_CONF_HOME/*.httpd.conf` /etc/httpd/conf.d/dispatcher.httpd.conf

# Restart Apache
sudo apachectl restart

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
$SCRIPTS_FOLER/install-aem-services.sh $ARTIFACTS_FOLDER $AEM_HOME_FOLDER

# echo "Starting AEM Author"
# service aem61author start

# No need to start the AEM Publish isntance as we just did beforehand
echo "Starting AEM Publish"
service aem61publish start

cat << EOF

*****************************************************************************************
* Your AEM Publish and Dispatcher is setup and running
* 
* 127.0.0.1 publish
*****************************************************************************************
EOF
