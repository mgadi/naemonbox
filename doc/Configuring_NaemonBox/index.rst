======================
Configuring Overview
======================

Introduction
=========

This document describes how to monitor local and Windows machines attributes, such as

• Memory Usage
• CPU load
• Disk Usage

Overview
=========

Monitoring services or attributes of a Windows machine requires the installation of an agent. This agent acts as a proxy between the Nagios plugin and the actual service or attribute of the Windows machine to be monitored . Without installing an agent on the Windows machine, Naemon would be unable to monitor local services or attributes of the Windows machine.

For this example, we will install NSClient ++ on the Windows machine and using the plugin check_nrpe that will communicate with the addon NSClient .

Steps
=========

There are several steps you need to follow in order to monitor a new Windows machine:

+ Install a monitoring agent on the Windows machine
+ Create new host and service definitions for monitoring the Windows machine
+ Restart the Naemon Service

Windows Agent Installation
=========

Naemon recommends using NSClient ++ on http://www.nsclient.org. These instructions allow a NSClient basic installation and  Naemon configuration to monitor the Windows machine.

Configuration
=========

Now it is time to create some configuration object definitions in order to monitor a new Windows machine. We will start by creating a basic host group for all Windows machines for one site.

Add an hostgroup
================
For editing , we will go through the Naemon Setup menu Config Tool > Object settings > Hostgroups.
You can create or clone. Make changes and click on Apply.

Add a command
================
**Configuration**

*check_nt_uptime* 

We will add a "command / plugin " check_nt_uptime that will be used by the system start service we will create for our "host" .

+ Config Tool Menu / Object Configuration / Commands
+ Enter the name of the command check_nt_uptime
+ Enter the following command line $USER1$/check_nt -H $HOSTADDRESS$ -v UPTIME -s NsclientPassword -p 12489
+ Save and click on apply 

The command is now present in Naemon configuration. We can now associate it to a service.

*check_nt_cpu*

We will add a "command / plugin " check_nt_cpu that will be used by the cpu use service we will create for our "host" .

+ Config Tool Menu / Object Configuration / Commands
+ Enter the name of the command check_nt_cpu
+ Enter the following command line $USER1$/check_nt -H $HOSTADDRESS$ -v CPULOAD -s NsclientPassword -p 12489
+ Save and click on apply 

The command is now present in Naemon configuration. We can now associate it to a service.

*check_mysql*

We will add a "command / plugin " check_mysql that will be used by mysql service we will create for our "host" .

+ Config Tool Menu / Object Configuration / Commands
+ Enter the name of the command check_mysql
+ Enter the following command line $USER1$/check_mysql -H $HOSTADDRESS$ -u user -p Password
+ Save and click on apply 

The command is now present in Naemon configuration. We can now associate it to a service.

*check_local_load*

We will add a "command / plugin " check_local_load that will be used by Current Load service we will create for our "host" .

+ Config Tool Menu / Object Configuration / Commands
+ Enter the name of the command check_local_load
+ Enter the following command line $USER1$/check_load -H $HOSTADDRESS$ -w 5.0,4.0,3.0 -c 10.0,6.0,4.0
+ Save and click on apply 

The command is now present in Naemon configuration. We can now associate it to a service.

*check_local_procs*

We will add a "command / plugin " check_local_procs that will be used by Total Processes service we will create for our "host" .

+ Config Tool Menu / Object Configuration / Commands
+ Enter the name of the command check_local_load
+ Enter the following command line $USER1$/check_procs -w 250 -c 400 -s RSZDT
+ Save and click on apply 

The command is now present in Naemon configuration. We can now associate it to a service.

*check_local_users*

We will add a "command / plugin " check_local_users that will be used by Current users service we will create for our "host" .

+ Config Tool Menu / Object Configuration / Commands
+ Enter the name of the command check_local_users
+ Enter the following command line $USER1$/check_users -w 20 -c 50
+ Save and click on apply 

The command is now present in Naemon configuration. We can now associate it to a service.

*check_local_swap*

We will add a "command / plugin " check_local_swap that will be used by swap usage service we will create for our "host" .

+ Config Tool Menu / Object Configuration / Commands
+ Enter the name of the command check_local_swap
+ Enter the following command line $USER1$/check_procs -w 20 -c 10 
+ Save and click on apply 

The command is now present in Naemon configuration. We can now associate it to a service.

Add a service
================

We will add a service "system start" to find out how long the system is started, to oversee our "host ".

**System Start**

We will go through the Naemon Setup menu Config Tool > Object settings > Services.

+ Completing the "system start" Service Description
+ Enter the host name S34XXXXXXX
+ Choose Systeme_Start service model
+ Add a contact group Supervisors
+ Save and click apply

The service is now present in Naemon configuration.

**CPU Use**
To know the CPU load

We will go through the Naemon Setup menu Config Tool > Object settings > Services.

+ Completing the "cpu_use" Service Description
+ Enter the host name S34XXXXXXX
+ Choose Win-Cpu_Use service model
+ Add a contact group Supervisors
+ Save and click apply

The service is now present in Naemon configuration.

**CURRENT Load**
To know the local load

We will go through the Naemon Setup menu Config Tool > Object settings > Services.

+ Completing the "local_load" Service Description
+ Enter the host name S34XXXXXXX
+ Choose generic-service service model
+ Add a contact group Supervisors
+ Save and click apply

The service is now present in Naemon configuration.

**CURRENT Users**
To know the numbers of users connected

We will go through the Naemon Setup menu Config Tool > Object settings > Services.

+ Completing the "Current_Users" Service Description
+ Enter the host name S34XXXXXXX
+ Choose generic-service service model
+ Add a contact group Supervisors
+ Save and click apply

The service is now present in Naemon configuration.


Network status
================

Each monitored server consists of several services ( DHCP - WINS - SQL - TINA etc ...). Each monitored service uses a command.
To check a service on the server, take control of the server and start a NET START command line or open the Services management method

To monitor the McAfee status services , we create a template *TMP-McAfee_Services* that each host will be associated to McAfee_Service
Setting the Service Template : *TMP-McAfee_Services*

+ Name: *TMP-McAfee_Services*
+ Service Description : McAfee_Services
+ Service Model used : generic Service
+ Command verification : check_nt_services
+ Arguments: 'McAfee Framework Service!McShield McAfee!McAfee Task Manager!McAfee Validation Trust Protection Service'

*McAfee_Service* Definition

This service uses the command check_nt_services

+ Command name : check_nt_services
+ Command line: $USER1$/check_nt -H $HOSTADDRESS$ -v SERVICESTATE -s NsclientPassword -p 12489 -d SHOWALL -l $ARG1$,$ARG2$,$ARG3$,$ARG4$

Macro $ARG1$ , $ARG2$ , $ARG3$ ... match the arguments placed in the command. eg: "McAfee Framework Service!McShield McAfee!McAfee Task Manager!McAfee Validation Trust Protection Service'

Service : traffic ( naemon )
To know the traffic up and down from the NIC

+ In the Config Tool / Services menu.
+ Completing the description (eg traffic )
+ Choose a service model (eg generice-Service )
+ Select the check command : check_traffic
+ Arguments : eth0!80!90!1
+ Save and click on apply

The service is now present in Naemon configuration, we need to export it to apply config changes

Export Naemon Configuration Files
Menu Config Tool/Object settings and then click Apply to save your change to disk, check your configuration changes, reload your monitoring core

Add a host
=========

We will add a Windows server-based host in our Naemon configuration.
We will go to the Setup menu Tool/Object settings/Hosts . Clone an existing host or creat a new one. Then, fill the fields :

+ Host name ( "host name") : S34XXXXXXX
+ Host Description ( "Alias" ) : Web Server
+ IP address / DNS : 10.xx.xxx.xxx
+ Add a template (template) associated with this host . A Template is the centralization of characteristics common to a machine.
+ Then select the template : Servers-Win2k3
+ Fill the Control Period : 24x7
+ Add a contact group : Supervisors
+ Save and click on apply

At this point, the host www is in the Naemon configuration 

We will now export the new configuration changes to Naemon by clicking on Apply.
View diff of changed files compares files 

+ Save changes to disk dumps the configuration .
+ Check your configuration checks changes if there is no error
+ Reload your monitoring core recover Naemon .

access management , authentication and authorization
=========
