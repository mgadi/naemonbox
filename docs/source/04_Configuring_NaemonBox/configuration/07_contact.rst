.. _contactconfiguration:

========
Contacts
========

**********
Definition
**********

The contacts in Naemon are used to:

* Log in to the Naemon web interface: each contact has its own rights of authentication to the web interface.
* Be warned in the event of a problem on your network (notification).

To add a contact, simply go to the menu: **Config Tool ==> Object Configuration ==> Contacts ==> Create a new contact**.
 
To display a contact, click on the **Object Configuration** field under **Contacts**, then click on the **Show** button.

.. image:: /images/contacts.png
 :scale: 90 %

According to your needs, add more attributes by clicking on **add new attributes**, fill the field you just selected and **click on finish**.

.. image:: /images/contacts-2.png
 :scale: 90 %
 
*******************
General information
*******************

* The **contact_name** field defined the login to access the web interface.
* The **alias** field is used to define a longer name or description for the contact.
* The **use** field allows us to link the contact to a Model of contact.
* The **can_submit_commands** directive is used to determine whether or not the contact can submit external commands to Naemon from the CGIs. Values: 0 = don't allow contact to submit commands, 1 = allow contact to submit commands. 
* The **email** field contain the e-mail address of the contact (to send out an alert email to the contact).
* The **contactgroups** is used to associated the contact to one or more groups of contacts.
* The **host_notification_commands** field serves to choose the notification command to a host.
* The **host_notification_options** field serves to define states for which notifications can be sent out to this contact..
* The **host_notification_period** field serves to choose the time period for which notifications can be sent.
* The **host_notification_enable** directive allows us to enable the sending of notifications to the user.
* The **service_notification_commands** field serves to choose the notification command to a service.
* The **service_notification_options** field serves to define states for which notifications can be sent out to this contact..
* **minimum_value**: 	This directive is used as the value that the host or service hourly value must equal before notification is sent to this contact.
* **pager**: 	This directive is used to define a pager number for the contact.
* **addressx**: 	Address directives are used to define additional "addresses" for the contact.
* **retain_status_information**: 	This directive is used to determine whether or not status-related information about the contact is retained across program restarts.
* **retain_nonstatus_information**: 	This directive is used to determine whether or not non-status information about the contact is retained across program restarts.


***********************
User Configuration
***********************
You can either edit or create, simply go to the menu: **Config Tool ==> User settings**. 

* The **Usernamed** field serves to select an existing user to change or to create a new user (just type his name) to access the Naemon web interface. 
* The **Contact Exists**  field let us edit the user settings
* The **Password** and **Confirm Password** fields contain the user password.
You can now set to yes or no the global authorization functionality when determining what the users have access to. 
More information on how to setup authentication and configure authorization for the CGIs can be found `here <http://www.naemon.org/documentation/usersguide/cgiauth.html>`_.



  ::

      http://[IP_DU_SERVER_CENTRAL]/index.php?autologin=1&useralias=[login_user]&token=[value_autologin]

.. tip:: 

    A sample CGI configuration file (*/etc/naemon/cgi.cfg*) is installed for you.

* The **Authentication Source** field specifies if the connection information comes from an LDAP directory or information stored locally on the server.
* The **Access list groups** field serves to define an access group to a user (group use for access control (ACL)).

.. note::

     The defaut Admin user has all authorisations set to **yes**.
