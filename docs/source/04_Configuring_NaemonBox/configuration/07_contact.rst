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
* The **contactgroups** is used to associated the contact to one or more groups of contacts.
* The **email** field contain the e-mail address of the contact (to send out an alert email to the contact).
* The **host_notification_commands** field serves to choose the notification command to a host.
* The **host_notification_options** field serves to define states for which notifications can be sent out to this contact..
* The **host_notification_period** field serves to choose the time period for which notifications can be sent.
* The **host_notification_enable** directive allows us to enable the sending of notifications to the user.
* The **service_notification_commands** field serves to choose the notification command to a service.
* The **service_notification_options** field serves to define states for which notifications can be sent out to this contact..



***********************
Naemon authentication
***********************
 
* The **Reach Naemon Front-end** field serves to authorize the user to access the Naemon web interface.
* The **Password** and **Confirm Password** fields contain the user password.
* The **Default Language** field serves to define the language of the Naemon interface for this user.
* The **Admin** field defined if this user is the administrator of the supervision platform or not.
* The **Autologin key** serves to define a connection key for the user. The user will no longer need to enter his / her login and password but will use this key to log in directly. Connection syntax:

  ::

      http://[IP_DU_SERVER_CENTRAL]/index.php?autologin=1&useralias=[login_user]&token=[value_autologin]

.. note:: 
    The Possibility of automatic connection (auto login) should be enabled in the menu: **Administration ==> Options**.

* The **Authentication Source** field specifies if the connection information comes from an LDAP directory or information stored locally on the server.
* The **Access list groups** field serves to define an access group to a user (group use for access control (ACL)).

.. note::

     A Administrative user is never concerned by access control even linked to an access group.

**********************
Additional information
**********************

* The **Address** fields allow us to specify the data of additional contacts (other e-mails, other telephone numbers, etc.).
* The **Status** and **Comment** fields serve to enable or disable the contact and to make comments on it.

