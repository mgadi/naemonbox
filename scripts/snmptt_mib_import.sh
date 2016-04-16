#!/bin/bash
File="snmptt-Dell.conf"
cd /usr/share/snmp/mibs/Dell
rm -rf /etc/snmp/snmptt.conf.bak
mv /etc/snmp/$File /etc/snmp/"$File".bak
#import MIBs, changing trap severity from Normal to critical for all traps
find . -type f | cut -d '/' -f 2 | xargs -I {} snmpttconvertmib --severity=Critical --in={} --out=/etc/snmp/$File --exec='/usr/lib/nagios/plugins/eventhandlers/submit_check_result $A "snmptrap-service" 2 '
#change certain trap's severity from Critical to Normal
#  Changing linkUp trap to be Normal:
sed "/^EVENT.*linkUp.*Critical$/ s/Critical/Normal/" -i /etc/snmp/$File
#  Changing linkUp trap to send an OK, the string 'A linkUp trap' is located in the EXEC line of the snmptt definition:
sed "/^EXEC.*A\ linkUp\ trap.*/ s/\ 2/\ 0/" -i /etc/snmp/$File

