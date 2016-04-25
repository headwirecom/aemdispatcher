About AEM Dispatcher
==================

AEM Dispatcher is a set of general solution regarding Adobe AEM's Dispatcher. It discusses the setup and configuration of the Dispatcher as well as certain use cases like language selection based on browser settings etc.

The GitHub contains several example configurations packaged into a VirtualBox / CentOS 7 installation provided by Vagrant.

For specific documentation on the examples read the Readme.md files inside their configuration folder (every folder except the **artifacts** and **scripts** folder).

# Requirements

* VirtualBox - https://www.virtualbox.org/wiki/Downloads
* Vagrant - https://www.vagrantup.com/downloads.html
* AEM 6.1 JAR and License file

# Installation

After installing Virtualbox and Vagrant onto your computer you need to place your **AEM 6.1** JAR file as well as the **license** file into the **/artifacts** folder. Make sure the JAR file pattern is name **aem\*.jar** and the license file is named **license.properties**.

Now we can start Vagrant with:

	vagrant up

which will install the **plain, no rewrite** configuration. If you want to install another configuration then you have to provide the module name (any folder inside the project beside **artifacts** and **scripts**:

	MODULE=browser-language-redirect vagrant up

In case you made some local changes or want to test your own module then you need to provide the following:

	MODULE=my-own-project LOCAL=local vagrant up

By default the scripts will clone the **aemdispatcher** git repo from **Github** and install the dispatcher configuration from there. With the local switch the configuration will be installed from your local copy.

## Publish Access

You can access your publish instance by: http://localhost:4503/ on your computer as there is a link towards the AEM instance running in your VM. If the page is coming up you can access it through the Dispatcher: http://localhost:8080/ as Apache in the VM is mapped to 8080 on your computer.

# Clean Up

If you want to delete your virtual machine then you can do this from the project folder:

	vagrant -f destroy

If will ask you if you want to remove it and if you enter y[es] then it will remove you instance from your computer.

# Project Notes

This project is setting up a Virtualbox instance with Centos 7, Apache 2.4, AEM 6.1 and its Dispatcher. These are the various locations:

**/home/aem**: AEM home directory and the place where AEM is installed
**/var/www/dispatcher**: Dispatcher Document Root
**/etc/httpd/conf.d/disaptcher**: Dispatcher HTTP and Dispatcher Configuration (/conf) and Dispatcher Module (/modules)
**/var/log/httpd/dispatcher.log**: Dispatcher Log Files

**Attention**: the reason why AEM is placed into **/home** is that we did not wanted it in a common place like **/opt** etc. This way you are free to place your installation(s) as you wish.

**SELINUX** is disabled in order to ensure that the Dispatcher can access AEM by creating a socket connection. With SELINUX enabled the Dispatcher will fail to create a socket and therefore cannot work with AEM.

In order to keep configuration properties centralized configuration files (HTTP, Dispatcher, Init Scripts etc) contain tokens (enclosed into @) which are replaced during the installation which the values from the **bootstrap.sh** file. This way shared properties can be managed there.
Properties are replaced using **sed**:

	sed -i 's/\@APACHE_DOCUMENT_ROOT_FOLDER\@/'$ENCODED'/g' dispatcher.any

**Attention**: ENCODED is a variable and therefore cannot be placed inside '' otherwise it is not replaced with its value. As you can see the string is stop before and started again afterwards.

**Attention**: anything with special characters need to be encoded (/, $, @ etc) to ensure proper handling:

	ENCODED=$( echo "$APACHE_DOCUMENT_ROOT_FOLDER" | sed 's/\//\\\//g' )


## AEM Startup Scripts

As the AEM bin scripts are not very well configurable so this project provides its own version that will work for publish on 4053. It will override the AEM startup scripts in /home/aem/crx-quickstart/bin.

The System V service scripts is named **aem61publish** and placed inside /etc/init.d and then activated with **chkconfig**. In addition **httpd** is activated as well to make sure Apache starts up when the VM starts up.

# Own Configuration

The examples are written in a way to allow you do develop your very own Dispatcher configuration, install and test it. Vagrant by default does share the root of the Vagrant file folder in the guest OS under /home/vagrant/sync but it is a **push-once** copy and anything in there is not updated anymore.

In order to enabled custom development on your computer the **configurations** folder is mapped to **/home/vagrant/configurations** folder on the VM which is synced both ways. This ways you can edit the configurations files on your computer and then update the configuration in the VM. These are the step to do that:

1. Edit the configurations files or copy and edit a pre-existing configuration
2. Login to Vagrant: "vagrant ssh" from anywhere in the project
3. Become root with "sudo -s"
4. Go to the scripts folder: "cd /home/vagrant/sync/scripts"
5. Run the script with the configuration folder name as first parameter and "local" as second parameter: "./update-dispatcher-conf.sh <configuration folder name> local"
6. Check that the HTTP service did restart successfully

**Attention**: in order to deploy your own configuration you need to do a **local** update otherwise the configuration is taken from the cloned GIT repository under /home/git/aemdispatcher.

**Note**: the update **not** only lets you **update** a configuration but also **switch** a configuration as it will clean an existing configuration before installing the new one.

**Attention**: only configurations are synced dynamically between the Host and the VM meaning that Vagrant bootstrap, service installation and environment variable setup is static. You can, though, reload that using "vagrant reload". It will update the folder /home/vagrant/sync but it will not reinstall or update anything. That said if you make changes to anything else than the configuration files you probably need to destroy and re-install the VM.

## Environment Variable Setup

The **scripts** folder contains a scripted called **setenv.sh** which will set all environment variable. If you need to change any properties it might be best to do that in there if possible.