#!/bin/bash

echo "Copying System V start up scripts..."
echo "Copy from Artifacts Folder: " $1
cp $1/aem61publish /etc/init.d

ENCODED=$( echo "$2" | sed 's/\//\\\//g' )
echo Encoded AEM Folder: $ENCODED
sed -i 's/\@AEM_HOME_FOLDER\@/'$ENCODED'/g' /etc/init.d/aem61publish

chmod 755 /etc/init.d/aem*

# echo "Copying environment settings..."
# cp $1/solr*.in.sh /etc/default

echo "Enabling AEM services..."
chkconfig aem61publish on
echo "Enabling HTTPD services..."
chkconfig httpd on
