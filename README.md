## Welcome to the naemonbox project##

Naemonbox - monitoring framework 

## Presentation ##

NAEMONBOX is based on Debian. This software provide a quick and easy installation wich includes the most-used tools in the Nagios/Naemon community.
Having the Nagios/Naemon tools already installed and configured for you, will bring you more than you expect ...

### Requirements ###
For x86_64 architecture only. You need to enable the non-free packages to install gettext. Edit with vi or nano /etc/apt/sources.list and ad the non-free repository as
```
deb http://ftp.fr.debian.org/debian/ wheezy main non-free contrib
deb-src http://ftp.fr.debian.org/debian/ wheezy main non-free contrib
 
deb http://security.debian.org/ wheezy/updates main contrib non-free
deb-src http://security.debian.org/ wheezy/updates main contrib non-free
 
# wheezy-updates, previously known as 'volatile'
deb http://ftp.fr.debian.org/debian/ wheezy-updates main contrib non-free
deb-src http://ftp.fr.debian.org/debian/ wheezy-updates main contrib non-free
```

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

### More info ###

Visit the MG Monitoring homepage at https://blog.mg-monitoring.com/

Thank's for using Naemonbox !
