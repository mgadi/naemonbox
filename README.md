## Welcome to the naemonbox project##

[![Flattr this git repo](http://api.flattr.com/button/flattr-badge-large.png)](https://flattr.com/submit/auto?user_id=mgadi&url=https://github.com/mgadi/naemonbox&title=badges&language=&tags=github&category=software)

Naemonbox - monitoring framework 

## Presentation ##

NAEMONBOX is based on Debian. This software provide a quick and easy installation wich includes the most-used tools in the Nagios/Naemon community.
Having the Nagios/Naemon tools already installed and configured for you, will bring you more than you expect ...

![naemonbox-webui](https://cloud.githubusercontent.com/assets/4088423/8827638/21e5b4da-308e-11e5-817e-47c6001ecf20.PNG)
### Requirements ###
####openvz VPS ONLY####
To use NaemonBox on openvz VPS, first you need to do as root :
```
cd /etc/
rm localtime
ln -s /usr/share/zoneinfo/Europe/Paris ./localtime
```
-------------------------------------------------
####Both openvz VPS and Dedicated Servers####
Naemonbox is only available for x86_64 architecture, at the moment. (Since naemonbox-0.0.6, we enable the non-free repository for you. You can directly jump to Installing section). 
You need to enable the non-free packages to install gettext and SNMP MIBs. Open up ```/etc/apt/sources.list```, and you should see lines like the following (URLs will likely vary). Simply add non-free to the respective URLs you wish to use :
```
deb http://ftp.fr.debian.org/debian/ wheezy main non-free contrib
deb-src http://ftp.fr.debian.org/debian/ wheezy main non-free contrib
 
deb http://security.debian.org/ wheezy/updates main contrib non-free
deb-src http://security.debian.org/ wheezy/updates main contrib non-free
 
# wheezy-updates, previously known as 'volatile'
deb http://ftp.fr.debian.org/debian/ wheezy-updates main contrib non-free
deb-src http://ftp.fr.debian.org/debian/ wheezy-updates main contrib non-free
```
Running ```apt-get update``` will update your local repo with the package listing.

### Installing ###
When installing from a released tarball, all you need to do is run as root
```
# tar zxvf naemonbox-VerNum.tar.gz
# cd naemon 
# ./install
```
Go to url http://your_ip_adress/

    Login/password : admin/admin
    Wiki Login/password : wikiadmin/admin

### License ###

Naemonbox is distributed under GNU GPL v2 license, see LICENSE.

Documentation
=============

For complete documentation see `Naemonbox's Documentation <http://naemonbox.readthedocs.org/en/latest/#welcome-to-naemonbox-s-documentation>`_, visit `Naemonbox Homepage <https://naemonbox.com/>`_.
Thank's for using Naemonbox !
 


