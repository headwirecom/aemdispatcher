#!/bin/bash

SUB_PROJECT=$1
LOCAL=$2
echo "************************************************"
echo "Install Sub Module: $SUB_PROJECT"
echo "************************************************"

echo "************************************************"
echo "Load Environment Variables"
echo "************************************************"
. ./setenv.sh

echo "************************************************"
echo "Shut down Apache Web Server"
echo "************************************************"
service httpd stop

echo "************************************************"
echo "Delete current Apache Dispatcher Configuration"
echo "************************************************"
rm -rf $APACHE_CONF_HOME
mkdir -p $APACHE_CONF_HOME

if [ "$LOCAL" == "local" ]
then
	# Copy Project Fiels to project folder
	echo "************************************************"
	echo "Copy Dispatcher Configuration from local env"
	echo "************************************************"
	cp -R $SYNC_FOLDER/$SUB_PROJECT/$HTTP_CONF_SUB_FOLDER/* $APACHE_CONF_HOME
else
	# Copy Project Fiels to project folder
	echo "************************************************"
	echo "Copy Dispatcher Configuration from GIT folder"
	echo "************************************************"
	cp -R $GIT_HOME_FOLDER/aemdispatcher/$SUB_PROJECT/$HTTP_CONF_SUB_FOLDER/* $APACHE_CONF_HOME
fi

# Filter Dispatcher HTTP Conf and Dispatcher Any file
cd $APACHE_CONF_HOME
echo "************************************************"
echo Filter HTTP Configuration and Dispatcher.any files
echo "************************************************"

for file in *
do
	if [ -f $file ]
	then
		echo "************************************************"
		echo "Filter File: $file"
		echo "************************************************"
		ENCODED=$( echo "$PROJECT_MODULE" | sed 's/\//\\\//g' )
		echo Encoded Project Module: $ENCODED
		sed -i 's/\@PROJECT_MODULE\@/'$ENCODED'/g' $file
		ENCODED=$( echo "$APACHE_CONF_HOME" | sed 's/\//\\\//g' )
		echo Encoded Conf Folder: $ENCODED
		sed -i 's/\@APACHE_CONF_FOLDER\@/'$ENCODED'/g' $file
		ENCODED=$( echo "$APACHE_LOG_FOLDER" | sed 's/\//\\\//g' )
		echo Encoded Log Folder: $ENCODED
		sed -i 's/\@APACHE_LOG_FOLDER\@/'$ENCODED'/g' $file
		ENCODED=$( echo "$APACHE_DOCUMENT_ROOT_FOLDER" | sed 's/\//\\\//g' )
		echo Encoded Document Root Folder: $ENCODED
		sed -i 's/\@APACHE_DOCUMENT_ROOT_FOLDER\@/'$ENCODED'/g' $file
	else
		echo "************************************************"
		echo "Not a File (Ignored): $file"
		echo "************************************************"
	fi
done

# Link the Dispqtcher HTTP Conf file into the Apache
echo "************************************************"
echo Link HTTP Conf File: `ls $APACHE_CONF_HOME/*.httpd.conf` to /etc/httpd/conf.d/$APACEH_CONF_NAME
echo "************************************************"
ln -s `ls $APACHE_CONF_HOME/*.httpd.conf` /etc/httpd/conf.d/$APACEH_CONF_NAME

# Restart Apache
echo
echo "Restart Apache Service"
echo
service httpd start
