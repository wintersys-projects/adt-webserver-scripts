##### [MAIN REPOSITORY](https://github.com/wintersys-projects/adt-build-machine-scripts)

##### This repository is the code which implements the webserver functions of the Agile Deployment Toolkit

The webserver layer is able to install **Apache**, **Nginx** or **Lighttpd** with customisable configuration options and sensible defaults without having to do any manual installation or coding. 

The default implementation works to exploit the round-robin loadbalancing of DNS systems so each webserver has its public ip address added to the DNS provider and called in a round robin fashion. This toolkit could be enhanced to support provider specific loadbalancers  but I chose not to implement those in the "core" because of added complexity with little functional enhancement and also because when I first started building this loadbalancers weren't available with the providers I was building for so I had to go down the route that I have. 

I am in no way and NGINX, APACHE or LIGHTTPD configuration expert and so to make it clear this is structured to make it easy for you to make your own configuration choices (possibly or even certainly) preferrable to the configurations that I have provided by default. Its the same with PHP it should be easy enough for you to be able to see how to configure the PHP system for yourself using the buildstyles.dat file. 

You can configure Apache, Nginx or Lighttpd to your own liking in the following files:

**adt-webserver-scripts/providerscripts/webserver/configuration/\***  

The webservers have their webroot as **/var/www/html**

There are cron jobs which maintain the functioning and updating of the webserver and which you can modify using **crontab -e**

You have a choice to use no firewall (not recommended) the UFW firewall, the cloud provider's native firewall, or the UFW firewall and the cloud provider's native firewall (recommended). You also have the choice of swapping out UFW for iptables. 

The firewalling I set by default is as tight as it can reasonably be and you most likely want to keep it that way. 



