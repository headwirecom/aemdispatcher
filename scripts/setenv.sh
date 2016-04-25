#!/bin/bash

#
# This script contains most of the folders and URLs needed for setting up Vagrant
# and to update the configuraton. Please make any adjustments here
#
export SYNC_FOLDER=/home/vagrant/sync
export ARTIFACTS_FOLDER=$SYNC_FOLDER/artifacts
export SCRIPTS_FOLDER=$SYNC_FOLDER/scripts
export DISPATCHER_NAME="dispatcher-*.tar.gz"

export GIT_REPO_URL=https://github.com/headwirecom/aemdispatcher.git

# Setup a local setup inside /etc/httpd to keep the files seperate from Apache
export APACHE_CONF_HOME=/etc/httpd/conf.d/dispatcher
export APACHE_LOG_FOLDER=/var/log/httpd
export APACHE_DOCUMENT_ROOT_FOLDER=/var/www/dispatcher
export APACEH_CONF_NAME=dispatcher.httpd.conf
export PROJECT_MODULE=$APACHE_CONF_HOME/modules
export PROJECT_CONF=$APACHE_CONF_HOME/conf
export AEM_HOME_FOLDER=/home/aem
export GIT_HOME_FOLDER=/home/git
export SCRIPTS_IN_GIT=$GIT_HOME_FOLDER/aemdispatcher/scripts
export HTTP_CONF_SUB_FOLDER=httpd/dispatcher

export SELINUX_CONFIG=/etc/selinux/config
export OPEN_JDK_INSTALLATION=java-1.8.0-openjdk-devel

export INSTALL_AEM_SERVICES_SCRIPT=install-aem-services.sh
export AEM_INIT_SCRIPT=aem61publish
export UPDATE_SCRIPT=update-dispatcher-conf.sh