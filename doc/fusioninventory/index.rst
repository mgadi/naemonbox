======================
Fusioninventory Client Installation
======================

Windows Client
=========

+ Select the version to install for the following architecture :
+ The installer detects the system language installed . Leave blank and click OK.
+ Click Next 
+ Agree with the license terms and click Next
+ Click Next
+ Click Next
+ In the field Servers Mode, enter the IP @ of GLPI server : http://your_ip_address/glpi/plugins/fusioninventory/
+ Click Install , Next, and Close.

ESX Client
=========
Do the following commands :

* fusioninventory-esx --user root --password 'n-26sus1' --host @IP --directory /tmp
* fusioninventory-injector -v --file /tmp/HSOTNAME-2013-11-04-07-13-32.ocs -u http://your_ip_address/glpi/plugins/fusioninventory/
