======================
Windows Agent Installation
======================

Naemon recommends using NSClient ++. These instructions allow a NSClient basic installation and Naemon configuration to monitor the Windows machine.


1.  Download the latest stable version from http://www.nsclient.org
2. Install NSClient++ and use the "Complete" setup type to make sure you got all features. On the next page use the default path for nsclient.ini and make sure "Install sample configuration" are checked
3. Enter all hosts that are allowed to connect to NSClient++, separate multiple IP's with ",". Make sure to check the following:
 *  Check **Enable common check plugins**
 *  Check **Enable nsclient server (check_nt)**
 *  Check **Enable NRPE server (check_nrpe)**
 *  Check **Enable NSCA client**
 *  Check  **Enable WMI checks**

.. image:: /images/nsclient-install1.png

NSClient++ should be installed and set up to start automatically. This should be enough to start with some basic Windows monitoring.
