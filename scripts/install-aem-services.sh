#!/bin/bash

echo
echo "Copying System V start up scripts..."
echo
cp $1/aem61publish /etc/init.d

ENCODED=$( echo "$2" | sed 's/\//\\\//g' )
echo Encoded AEM Folder: $ENCODED
sed -i 's/\@AEM_HOME_FOLDER\@/'$ENCODED'/g' /etc/init.d/aem61publish

chmod 755 /etc/init.d/aem*

# echo "Copying environment settings..."
# cp $1/solr*.in.sh /etc/default

echo
echo "Enabling AEM services..."
echo
chkconfig aem61publish on
echo
echo "Enabling HTTPD services..."
echo
chkconfig httpd on
