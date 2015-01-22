===================================
Welcome to Naemonbox's documentation!
===================================


==============
About Naemonbox
==============

NaemonBox is a monitoring framework. It comes with a set of applications that meet the differents needs for a complete monitoring resource from an IT and business point of view.

A whole new way to share IT content with the various actors of an information system (Governance, Administrators, Technicians, Operators, …). And exciting new connections between apps and devices. All that and more make NaemonBox better than ever.

Naemon checks the availability of your network resources, notifies users of outages, and generates performance data for reporting. It creates automated ticket with GLPI in the release of an alarm from Naemon.  It allows you to centralize, and analyze log messages with cacti and rsyslog, and many other possibilities …



Naemonbox Project
================
The purpose of NAEMONBOX is to provide a quick and easy installation wich includes the most-used tools in the Nagios/Naemon community.
NAEMONBOX avoid the tedious work of manually compiling and integrating Nagios addons avoiding outdated pre-packaged installations with no regular updates. NAEMONBOX bundles Naemon together with many important addons into a Gnu/Linux operating systems Debian 7. Having the Nagios/Naemon tools already installed and configured for you, will bring you more than you expect …

Naemon comes with a PHP based web-tool for configuring the monitoring software, provide graph for your performance data with PNP4Nagios, and customizable map with Nagvis, well integrated with Thruk. You won’t need to install another web interface. 

   * Easy to install : install is mainly done with the install script of the release tarball.
   * Easy for new users : once installed, Naemonbox provide a single WebUI to interface with all modules and packs.
   * Easy to migrate from Nagios : we want Nagios configuration and plugins to work in with Naemon.
     Plugins provide great flexibility and are a big legacy codebase to use. It would be a shame not to use all this community work
   * Debian-platform : Naemonbox is only available for Debian OS. 
 
This is basically what Naemonbox is made of. Maybe add the "keep it simple" Linux principle and it's perfect. There is nothing we don't want, we consider every features / ideas.


Features
=========


Naemonbox has a lot of features, we started to list some of them in the last paragraph. Let's go into details :

    * NAEMON: core monitoring application. Role separated daemons : we want a daemon to do one thing but doing it good. Naemon have at least 4 daemon called worker.
    * CACTI and PNP4NAGIOS : Perfomance Management, Rsyslog.
    * WEATHERMAP : Mapping bandwith.
    * NAGVIS : Customizable mapping.
    * GLPI/FUSION : Management and inventory.
    * SNMPTT : SNMP Trap translation.
    * BACKUP MANAGER : Command line backup tool to make daily archives.
    * MEDIAWIKI : the wiki software that powers Wikipédia.
    * PSDASH: A linux system information web dashboard using psutils and flask.
    * NRPE : allows you to remotely execute Nagios plugins on other Linux/Unix machines. This allows you to monitor remote machine metrics (disk usage, CPU load,  etc). NRPE can also communicate with Windows agent addons like NSClient++, so you can check metrics on remote Windows machines as well.
    * NSCA : allows you to integrate passive alerts and checks from remote machines and applications with Naemon. Useful for processing security alerts, as well as redundant and distributed Naemon setups.
    * WEBMIN : a web-based interface for system administration.

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
