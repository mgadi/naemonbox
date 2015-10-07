==============
Getting Started
==============
This is a quick guide to the basics of `Naemonbox <https://naemonbox.com/>`_, written from a new user’s perspective. We don’t talk about advanced concepts for all apps. Visit the project website that provide complete documentation.

Step one
=========

Before using Naemonbox, you’ll need to know the fundamentals and Linux commands. 
I recommend you read the product documents: 
    * `Naemon documentation available <http://www.naemon.org/documentation/usersguide/toc.html>`_.
    * `Cacti documentation available <http://docs.cacti.net/>`_.
    * `Pnp4Nagios <http://docs.pnp4nagios.org/>`_.
    * `Weathermaps <http://network-weathermap.com/docs>`_.
    * `Nagvis <http://www.nagvis.org/doc>`_.
    * `Glpi <http://www.glpi-project.org/spip.php?rubrique18>`_.
    * `Fusion Inventory <http://fusioninventory.org/documentation/documentation.html>`_.
    * `SNMPTT <http://snmptt.sourceforge.net/docs/snmptt.shtml>`_.
    * `Mediawiki <http://www.mediawiki.org/wiki/Documentation>`_.
    * `Psdash <https://github.com/Jahaja/psdash>`_.
    * `NRPE <http://nagios.sourceforge.net/docs/nrpe/NRPE.pdf>`_.
    * `NSCA <http://nagios.sourceforge.net/download/contrib/documentation/misc/NSCA_Setup.pdf>`_.
    * `Webmin <http://www.webmin.com/docs.html>`_.

Step two
=========
.. image:: /images/naemonbox-naemon-login-1.png
 :scale: 50 %
 
Connect to applications

    * Use root and your password to connect by ssh or TTY
    * Use admin / admin for web application (naemon, nagvis, cacti, glpi, phpmyadmin, webmin)
    * Use wikiadmin / admin for the wiki.

You are strongly suggested to change credentials of the admin default user. Ready? Let’s go!

Configure the monitoring

there are 2 ways :

1. Manualy, you can edit nagios/naemon config files. Not recommanded because you need to use an editor in text mode (vi, nano…).

2. Use Naemon web config tool to configure and manage naemon. That is what we will detail in the next  step 

Step three 
=========

**The Basics** workings are all the elements that are involved in the monitoring and notification logic. There are described in  :ref:`Configuring Naemon <04_Configuring_NaemonBox/index>` section. 

Step four
=========

How to monitor remote devices or services ? Several ways are possibles according to the host type’s.

 * Linux host (debian like, Centos…) : install SNMP agent and/or NRPE
 * Windows Host : install snmp and/or nsclient++ or via WMI (Naemonbox is ready for WMI)
 * Network Host (switch, router, firewall) : enable SNMP
 * Network services (http, ftp, smtp, pop…) : Many plugins are availables in /usr/lib/nagios/plugins
