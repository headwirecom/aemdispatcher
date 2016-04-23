#!/bin/bash

SUB_PROJECT=$1

. ./setenv.sh

if [ "$2" == "local" ]
then
	# Copy Project Fiels to project folder
	echo "cp -R $SYNC_FOLDER/$SUB_PROJECT/httpd/dispatcher/* $APACHE_CONF_HOME""
	cp -R $SYNC_FOLDER/$SUB_PROJECT/httpd/dispatcher/* $APACHE_CONF_HOME
else
	# Copy Project Fiels to project folder
	echo "cp -R $GIT_HOME_FOLDER/aemdispatcher/$SUB_PROJECT/httpd/dispatcher/* $APACHE_CONF_HOME"
	cp -R $GIT_HOME_FOLDER/aemdispatcher/$SUB_PROJECT/httpd/dispatcher/* $APACHE_CONF_HOME
fi

# Filter Dispatcher HTTP Conf and Dispatcher Any file
cd $APACHE_CONF_HOME
echo Filter HTTP Configuration and Dispatcher.any files

for file in *
do
	if [ -f $file ]
	then
		echo "Filter File: $file"
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
	fi
	if [ ! -f $file ]
	then
		echo "Not a File (Ignored): $file"
	fi
done

# Link the Dispqtcher HTTP Conf file into the Apache
echo Link HTTP Conf File: ln -s `ls $APACHE_CONF_HOME/*.httpd.conf` /etc/httpd/conf.d/dispatcher.httpd.conf
ln -s `ls $APACHE_CONF_HOME/*.httpd.conf` /etc/httpd/conf.d/dispatcher.httpd.conf

# Restart Apache
apachectl configtest
apachectl restart
