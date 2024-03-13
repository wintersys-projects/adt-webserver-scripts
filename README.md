##### [MAIN REPOSITORY](https://github.com/wintersys-projects/adt-build-machine-scripts)

##### This repository is the code which implements the webserver functions of the Agile Deployment Toolkit

This is the sourcecode for the webserver layer of the Agile Deployment Toolkit. 

The webserver layer is able to install **Apache**, **Nginx** or **Lighttpd** with customisable configuration options and sensible defaults without having to do any manual installation. These webservers can be installed through the autoscaling mechanism of the Agile Deployment Toolkit meaning that when it is considered that a scaling event needs to take place by the autoscaler a VPS will be spun up and the scripts from this repository installed and executed in order to build a webserver. 

These webserver machines are called in a "round robin" fashion either using the DNS system of the provider they are running on or using cloudflare (or perhaps in the furture other proxying services). This means that you can use the DNS system of your VPS provider or you can go for added security and whatnot by using cloudflre for your DNS service. Cloudflare might also have various performance benefits as well. 

You can fork the repository and configure Apache, Nginx or Lighttpd to your own liking in the following files:

**adt-webserver-scripts/providerscripts/webserver/configuration/\***  

The webservers have their webroot as **/var/www/html**

There are cron jobs which maintain the functioning and updating of the webserver and which you can modify using **crontab -e**

A machine level firewall is installed (ufw) allows connections to ports :443 and :80



