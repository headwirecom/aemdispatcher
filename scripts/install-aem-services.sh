#!/bin/bash

echo "************************************************"
echo "Load Environment Variables"
echo "************************************************"
. ./setenv.sh

echo "************************************************"
echo "Copying System V start up scripts..."
echo "************************************************"
cp $ARTIFACTS_FOLDER/$AEM_INIT_SCRIPT /etc/init.d

ENCODED=$( echo "$AEM_HOME_FOLDER" | sed 's/\//\\\//g' )
echo "************************************************"
echo Encoded AEM Folder: $ENCODED
echo "************************************************"
sed -i 's/\@AEM_HOME_FOLDER\@/'$ENCODED'/g' /etc/init.d/$AEM_INIT_SCRIPT

chmod 755 /etc/init.d/aem*

# echo "Copying environment settings..."
# cp $1/solr*.in.sh /etc/default

echo "************************************************"
echo "Enabling AEM services..."
echo "************************************************"
chkconfig $AEM_INIT_SCRIPT on
echo "************************************************"
echo "Enabling HTTPD services..."
echo "************************************************"
chkconfig httpd on
