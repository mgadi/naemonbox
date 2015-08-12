======================
Centralize logs in Windows with CACTI
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
