======================
Configuration Naemon  
======================

.. image:: /images/naemonbox-naemon-login.png


Introduction
=========

This document describes how to monitor local and Windows machines attributes, such as:
 
• Memory Usage
• CPU load
• Disk Usage

Overview
=========

.. image:: /images/monitoring-windows.png
Monitoring services or attributes of a Windows machine requires the installation of an agent. This agent acts as a proxy between the Nagios plugin and the actual service or attribute of the Windows machine to be monitored . Without installing an agent on the Windows machine, Naemon would be unable to monitor local services or attributes of the Windows machine.

For this example, we will install NSClient ++ on the Windows machine and using the plugin check_nrpe that will communicate with the addon NSClient .

Steps
=========

There are several steps you need to follow in order to monitor a new Windows machine:


• Install a monitoring agent on the Windows machine
• Create new host and service definitions for monitoring the Windows machine
• Restart the Naemon Service
