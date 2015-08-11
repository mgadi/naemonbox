==============
Introduction
==============

This document describes how to monitor local and Windows machines attributes, such as

• Memory Usage
• CPU load
• Disk Usage

==============
Overview
==============

Monitoring services or attributes of a Windows machine requires the installation of an agent. This agent acts as a proxy between the Nagios plugin and the actual service or attribute of the Windows machine to be monitored . Without installing an agent on the Windows machine, Naemon would be unable to monitor local services or attributes of the Windows machine.

For this example, we will install NSClient ++ on the Windows machine and using the plugin check_nrpe that will communicate with the addon NSClient .

==============
Steps
==============

There are several steps you need to follow in order to monitor a new Windows machine:

• Install a monitoring agent on the Windows machine
• Create new host and service definitions for monitoring the Windows machine
• Restart the Naemon Service

==============
Windows Agent Installation
==============

Naemon recommends using NSClient ++ on http://www.nsclient.org. These instructions allow a NSClient basic installation and  Naemon configuration to monitor the Windows machine.

==============
Configuration
==============

Now it is time to create some configuration object definitions in order to monitor a new Windows machine. We will start by creating a basic host group for all Windows machines for one site.
