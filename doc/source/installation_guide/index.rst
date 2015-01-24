==============
Installation Guide
==============

System requirements
=========

   * An x86-compatible hardware
   * 4 GB free disk space
   * 1 GB of RAM. 
   * 1 processor core

Recommended system requirements
=========

   * 20 GB plus the required disk space recommended essentialy for /var. Disk space needed by mysql and rrd files
   * 2 processors core or hyper-thread for each virtualized CPU.
   * 2 GB of RAM.

openvz VPS ONLY
=======
To use NaemonBox on openvz VPS, first you need to do as root (according to your timezone, change the third command line below):

::

    cd /etc/
    rm localtime
    ln -s /usr/share/zoneinfo/Europe/Paris ./localtime

GNU/Linux Debian 7 Installation Only
=========

Naemonbox require for running a machine with Debian GNU/Linux 7 ready (or based on Debian) that has network access.

Once you have access to your server, either directly or by SSH, you can install Naemonbox using the install script.

Get the latest tarball here https://github.com/mgadi/naemonbox/releases/latest

Installing
=========

When installing from a released tarball, you need to run as root

::

   tar zxvf naemonbox-VerNum.tar.gz
   cd naemon
   ./install

Go to url http://your_ip_adress/

* Login/password : admin/admin
* Wiki Login/password : wikiadmin/admin

Naemonbox is compatible with Nagios configuration.
