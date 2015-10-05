=====
Hosts Definition
=====


A host definition is used to define a physical server, workstation, device, etc. that resides on your network.

All additions of hosts are done in the menu: **Config Tool ==> Object Configuration ==> Hosts ==> Create a
new host**.

.. image:: /images/hosts-definition.png
 :scale: 90 %

Create a host
=========

Directive Descriptions

**host_name:**	This directive is used to define a short name used to identify the host. It is used in host group and service definitions to reference this particular host. Hosts can have multiple services (which are monitored) associated with them. When used properly, the $HOSTNAME$ macro will contain this short name.

**alias:**	This directive is used to define a longer name or description used to identify the host. It is provided in order to allow you to more easily identify a particular host. When used properly, the $HOSTALIAS$ macro will contain this alias/description.

**address:**	This directive is used to define the address of the host. Normally, this is an IP address, although it could really be anything you want (so long as it can be used to check the status of the host). You can use a FQDN to identify the host instead of an IP address, but if DNS services are not available this could cause problems. When used properly, the $HOSTADDRESS$ macro will contain this address.

**use:** Link to the the template you use

**contact_groups:** This is a list of the short names of the contact groups that should be notified whenever there are problems (or recoveries) with this host. Multiple contact groups should be separated by commas. You must specify at least one contact or contact group in each host definition.

**new attribute:** A field used to add a new directive wich is filled with the **add new attribute** button.

A descrition of all directives is located `here`_. 

.. _here: http://www.naemon.org/documentation/usersguide/objectdefinitions.html#host

**apply** Click on apply to save.
