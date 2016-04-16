==============
About Naemonbox
==============

 .. image /images/Logo-250x50.png ::
 :scale: 90 %
 
`Naemonbox <https://naemonbox.com/>`_ is an extansive Software Package for monitoring devices. Monitoring requires some clarification of the concepts used and how they are defined in NaemonBox. This means to observe, record, collect and display different aspects of hardware and software from activities point of view. This monitored aspects could be close to hardware like CPU Temperature, CPU Voltage, FAN Spin from NET devices but also close to services running on monitored Operating System like SSH daemons, POSTFIX daemons, HTTP services or checks the availability of devices via ping. It notifies users of outages, generates performance data for reporting, creates automated ticket with GLPI in the release of an alarm from Naemon.  It allows you to centralize, and analyze log messages with cacti and rsyslog, and many other possibilities …

A whole new way to share IT content with the various actors of an information system (Governance, Administrators, Technicians, Operators, …). And exciting new connections between apps and devices. All that and more make NaemonBox better than ever.

`Official site <https://naemonbox.com/>`_ 


.. image:: /images/naemonbox-thumb.png
 :scale: 90 %
Naemonbox Project
================
NAEMONBOX is a tool that allows you to install and easy to use your own Monitoring server. Having the Nagios/Naemon tools already installed and configured for you, will bring you more than you expect …

NAEMONBOX comes with a PHP based web-tool to ease configuration and administration on One central storage. It manage groups, users and corresponding permissions and notifications. It provide Flexible preselection by device and monitoring categories with beautiful graphing of your performance data. It run distributed monitoring instances as master/worker instances to increase performance and availability in complex networks. It gives customizable map with Nagvis, well integrated with Thruk. You won’t need to install another web interface. 

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
