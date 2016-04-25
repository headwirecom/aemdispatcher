About AEM Dispatcher
==================

AEM Dispatcher is a set of general solution regarding Adobe AEM's Dispatcher. It discusses the setup and configuration of the Dispatcher as well as certain use cases like language selection based on browser settings etc.

It also contains Vagrant projects setting up various Dispatcher solutions in a Virtualbox to test, evaluate and develop an AEM site with Dispatcher.

**Attention**: the following text is generic to all solutions provided. Each solution has its own Readme.md file that has further instructions or changes made to this document.

# Requirements

* VirtualBox - https://www.virtualbox.org/wiki/Downloads
* Vagrant - https://www.vagrantup.com/downloads.html
* AEM 6.1 JAR and License file

# Installation

After installing Virtualbox and Vagrant onto your computer you need to place your **AEM 6.1** JAR file as well as the **license** file into the **/artifacts** folder. Make sure the JAR file is name **aem\*.jar** and the license file is named **license.properties**.

Now we can start Vagrant with:

	vagrant up

which will install the **plain, no rewrite** configuration. If you want to install another configuration then you have to provide the module name (any folder inside the project beside **artifacts** and **scripts**:

	MODULE=browser-language-redirect vagrant up

In case you made some local changes or want to test your own module then you need to provide the following:

	MODULE=my-own-project LOCAL=local vagrant up

By default the scripts will clone the **aemdispatcher** git repo from **Github** and install the dispatcher configuration from there. With the local switch you can change settings locally and install them.

You can access your publish instance by: http://localhost:4503/ on your computer as there is a link towards the AEM instance running in your VM. If the page is coming up you can access it through the Dispatcher: http://localhost:8080/ as Apache in the VM is mapped to 8080 on your computer.

# Clean Up

If you want to delete your virtual machine then you can do this from the project folder:

	vagrant -f destroy

If will ask you if you want to remove it and if you enter y[es] then it will remove you instance from your computer.

# Project Notes

This project is setting up a Virtualbox instance with Centos 7, Apache 2.4, AEM 6.1 and its Dispatcher. These are the various locations:

**/home/aem**: AEM home directory and the place where AEM is installed
**/var/www/dispatcher**: Dispatcher Document Root
**/etc/httpd/conf.d/disaptcher**: Dispatcher HTTP and Dispatcher Configuration
**/var/log/httpd/dispatcher.log**: Dispatcher Log Files

**Attention**: the reason why AEM is placed into **/home** is that we did not wanted it in a common place like **/opt** etc. This way you are free to place your installation(s) as you wish.

**Selinux** is disabled in order to ensure that the Dispatcher can access AEM by creating a socket connection. With Selinux enabled the Dispatcher will fail to create a socket and therefore cannot work with AEM.

In order to keep configuration properties centralized configuration files (HTTP, Dispatcher, Init Scripts etc) contain tokens (enclosed into @) which are replaced during the installation which the values from the **bootstrap.sh** file. This way shared properties can be managed there.
Properties are replaced using **sed**:

	sed -i 's/\@APACHE_DOCUMENT_ROOT_FOLDER\@/'$ENCODED'/g' dispatcher.any

**Attention**: ENCODED is a variable and therefore cannot be placed inside '' otherwise it is not replaced with its value. As you can see the string is stop before and started again afterwards.

**Attention**: anything with special characters need to be encoded (/, $, @ etc) to ensure proper handling:

	ENCODED=$( echo "$APACHE_DOCUMENT_ROOT_FOLDER" | sed 's/\//\\\//g' )


## AEM Startup Scripts

As the AEM bin scripts are not very well configurable so this project provides its own version that will work for publish on 4053. It will override the AEM startup scripts in /home/aem/crx-quickstart/bin.

The System V service scripts is named **aem61publish** and placed inside /etc/init.d and then activated with **chkconfig**. In addition **httpd** is activated as well to make sure Apache starts up when the VM starts up.

