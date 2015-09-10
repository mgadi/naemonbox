
======================
Naemon Configuring Overview
======================

.. image:: /images/naemonbox-naemon-login.png


Introduction
=========

This document describes how to monitor local and Windows machines attributes, such as

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

Windows Agent Installation
=========

Naemon recommends using NSClient ++. These instructions allow a NSClient basic installation and Naemon configuration to monitor the Windows machine.


1.  Download the latest stable version of the NSClient++ addon from http://www.nsclient.org
2. Install NSClient++ and use the "Complete" setup type to make sure you got all features. On the next page use the default path for nsclient.ini and make sure "Install sample configuration" are checked
3. Enter all hosts that are allowed to connect to NSClient++, separate multiple IP's with ",". Make sure to check the following:
 * "Check "Enable common check plugins"
 * "Check "Enable nsclient server (check_nt"
 *  "Enable NSCA client (check_nrpe)"
 *  "Enable Web server".

.. image:: /images/nsclient-installation.png

NSClient++ should be installed and set up to start automatically. This should be enough to start with some basic Windows monitoring.

Configuration
=========

Now it is time to create some configuration object definitions in order to monitor a new Windows machine. We will start by creating a basic host group for all Windows machines for one site.

=======

===========
Host Group Definition
===========

A host group definition is used to group one or more hosts together for simplifying configuration.

Add an hostgroup
================
For editing , go through 

1. Naemon Setup menu **Config Tool** ==> **Object settings** ==> **Hostgroups.**

2. **Create** or **Clone.** 

3. Make changes and click on **Apply.**

===========
Command Definition
===========

A command define the command line that uses a script or an application to perform an action . You can run this command by specifying arguments. 

There are three types of commands:

*   Audit controls are used by the schedulers to check the status of a host or service .

*   Notification commands are used by the schedulers to alert contacts (via mail, SMS ... ) .

*   Various commands are used by add-ons ( to perform certain actions ) by the scheduler for data processing ...


Add a command
================
**Configuration**

**check_nt_uptime**

We will add a "command / plugin " check_nt_uptime that will be used by the system start service we will create for our "host" .
For editing , go through

1. **Config Tool Menu** ==> **Object Configuration** ==> **Commands**

2. Enter the command name **check_nt_uptime**. Enter the following command line $USER1$/check_nt -H $HOSTADDRESS$ -v UPTIME -s NsclientPassword -p 12489

4. **Save** and click on **Apply**.

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

access , authentication and authorization management
=========


Create a host
=========

+ Click on the Config Tool menu/Object Configuration/Contact
+ Click Create a new Contact

Fill the fields according to your criteria (full name , Alias ​​/ Login , generic contact, Email, Allow can_submit _commands )

User Configuration
=========

+ Click on the Setup menu Tool/User Configuration
+ Select the account in the username field
+ Create a password and confirm, then click "SAVE"

 Editing the cgi.cfg file
By default, a contact will be entitled to access objects which it is associated , make change according to your needs :

+ show_context_help=0
+ use_authentication=1
+ use_ssl_authentication=0
+ default_user_name=nagiosadmin
+ authorized_for_system_information=nagiosadmin,hotline,
+ authorized_contactgroup_for_system_information=
+ authorized_for_configuration_information=nagiosadmin
+ authorized_contactgroup_for_configuration_information=
+ authorized_for_system_commands=nagiosadmin
+ authorized_contactgroup_for_system_commands=
+ authorized_for_all_services=nagiosadmin,hotline
+ authorized_contactgroup_for_all_services=
+ authorized_for_all_hosts=nagiosadmin,hotline
+ authorized_contactgroup_for_all_hosts=
+ authorized_for_all_service_commands=nagiosadmin
+ authorized_contactgroup_for_all_service_commands=
+ authorized_for_all_host_commands=nagiosadmin
+ authorized_contactgroup_for_all_host_commands=
+ authorized_for_read_only=
+ authorized_contactgroup_for_read_only=
+ refresh_rate=90
+ escape_html_tags=1
+ action_url_target=_blank
+ notes_url_target=_blank
+ lock_author_names=1
+ host_unreachable_sound=../media/critical.wav
+ host_down_sound=../media/critical.wav
+ service_critical_sound=../media/critical.wav
+ service_warning_sound=../media/warning.wav
+ service_unknown_sound=../media/unknown.wav
