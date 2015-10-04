==============
Installation Guide
==============

System requirements
=========

   * An x86-compatible hardware
   * 4 GB free disk space
   * 1 GB of RAM. 
   * 1 processor core - 1 GHz CPU

Recommended system requirements
=========

   * An x86-compatible hardware 
   * 20 GB plus the required disk space recommended essentialy for /var. Disk space needed by mysql and rrd files
   * 2 processors core or hyper-thread for each virtualized CP - 2 GHz+ CPU.
   * 2 GB of RAM.

Client Operating Systems
=========
   • Windows: 2000,XP or later, 2003,2007 or later
   • Linux/Unix: 2.4+ kernel Linux distributions, Solaris 9+ , FreeBSD 6.4+, AIX 5.2/5.3 


openvz VPS installation
=======
To use NaemonBox on openvz VPS, first you need to do as root (according to your timezone, change the third command line below):

::

    cd /etc/
    rm localtime
    ln -s /usr/share/zoneinfo/Europe/Paris ./localtime

GNU/Linux Debian 7 (or later) Installation 
=========

`Naemonbox <https://naemonbox.com/>`_ require for running a machine with Debian GNU/Linux 7 or later ready (or based on Debian) that has network access. A video installation instructions in **expert mode** of Debian GNU / Linux 8 (codename " jessie ") on the 64-bit PC architecture (" amd64 ") is available `here <https://youtu.be/Eq0HP7HJWy0?t=2>`_ for French users.

Once you have access to your server, either directly or by SSH, you can install Naemonbox using the install script.

Get the latest tarball here https://github.com/mgadi/naemonbox/releases/latest

Installing
=========

A video installation instructions of Naemonbox is avalaible `here <https://youtu.be/WG096n-lzvc?t=94>`_. When installing from a released tarball, you need to run as root. 

::

   tar zxvf naemonbox-VerNum.tar.gz
   cd naemon
   ./install

Go to url http://your_ip_adress/

* Login/password : admin/admin
* Wiki Login/password : wikiadmin/admin

Naemonbox is compatible with Nagios configuration.
