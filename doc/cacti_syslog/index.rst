======================
Centralize Windows logs with CACTI
======================

When it comes to management, monitoring , one of the major commandments is based on the importance and attention that must be given to the logs. This is a unique source of information to have on hand in order to exploit and thus back to the source of the problem. To support its analysis and its exploitation, we will centralize event logs. This requires that all messages are transmitted to a central server Cacti with syslog plugin, an rsyslog server. " Rsyslog " centralizes the various event logs on the monitoring server . We can quickly and efficiently locate these failures on a network.

Windows client installation
=========

We will use a "syslog" agent which will allow us to send traps compatible with RFC 3164 standard syslog format.

Prerequisites
=========

Must be installed

+	Microsoft.Net framework 2. 
+	El2esl

Go to All Programs and launch el2sl Configurator. This window opens :

+ **gate** , enter the monitoring server address. Leave the default port
+ You can change for each log , record types that will be sent to the server according to their order of importance ( critical [2] Warning [ 4] ... )
+ Click "close" .

Create a rule deletion
=========

To create rules deletion, click on the red cross to the right of the log and then enter a name for your rule .

For example, to delete all events from the **naemon** server,  just click on the red cross and complete the following steps.
Here we remove all UDP connection messages from the monitoring server .
There it's finished. Well logs !

Management of authentication and access permissions
=========

Now you want to configure Cacti to provide authentication and additional permissions . This configuration is done from the web console cacti .
We want to restrict viewing an account on the [ Console ] and [ syslog ] tab .
In the Utilities / User Management menu, click add to create our first account. 

+ Then fill in the [ User Name ], [ Full Name ] . 
+ Add a password (X2) . Enabled Check the box to activate the account . 
+ In the [ Realm permissions ] check the boxes [ Console Access ] and [ Plugin - > Syslog User] .
