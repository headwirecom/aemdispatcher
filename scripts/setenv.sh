#!/bin/bash

export SYNC_FOLDER=/home/vagrant/sync
export ARTIFACTS_FOLDER=$SYNC_FOLDER/artifacts
export SCRIPTS_FOLDER=$SYNC_FOLDER/scripts
export DISPATCHER_NAME="dispatcher-*.tar.gz"

export GIT_REPO_URL=https://github.com/headwirecom/aemdispatcher.git

# Setup a local setup inside /etc/httpd to keep the files seperate from Apache
export APACHE_CONF_HOME=/etc/httpd/conf.d/dispatcher
export APACHE_LOG_FOLDER=/var/log/httpd
export APACHE_DOCUMENT_ROOT_FOLDER=/var/www/dispatcher
export PROJECT_MODULE=$APACHE_CONF_HOME/modules
export AEM_HOME_FOLDER=/home/aem
export GIT_HOME_FOLDER=/home/git
