#!/bin/bash
#
# Nagios Plugin for checking states of printer server jobs queue and shared printer
#
# Date: 31.08.2009
# License: GNU Public License v2
# Version: 1.0 stable
# Written by: Julien DECULTOT
#
# Contact
# E-Mail: nagios@zazacorp.info
#
# nagios.zazacorp.info
#

set +x

pluginpath="/usr/local/nagios/libexec"
pluginname=`basename $0`

while getopts "H:C:w:c:" options; do
  case $options in
        H)hostname=$OPTARG;;
        C)community=$OPTARG;;
        *)
          echo "$pluginname Help:"
          echo "-----------------"
          echo "-H <Hostname> : Hostname/IP of printer server "
          echo "-C <communty> : SNMP Community. Default: public"
          echo "-w <warning>  : Warning rate"
          echo "-c <critical> : Critical rate"
          echo "-----------------"
          echo "Usage: $pluginname -H <hostadress> -C <community> -w <warning> -
c <critical>"
          exit 3
        ;;
  esac
done

if [ -z $community ]; then
        community=public;
fi;
RESULTTEMPSHARENAME='/tmp/sharefoldername.lst'
RESULTTEMPPRINTNAME='/tmp/sharefolderprinter.lst'

SNMPWALK_BIN='/usr/bin/snmpwalk'
OIDSHARENAME='SNMPv2-SMI::enterprises.77.1.2.27.1.1'    # Name of the share
OIDPRINTNAME='SNMPv2-SMI::enterprises.77.1.2.29.1.1'    # Jobs in Queue

SHARENAME=`${SNMPWALK_BIN} -v 2c -c $community $hostname ${OIDSHARENAME} | gawk -F " = STRING: " '{print $2}' > $RESULTTEMPSHARENAME`
PRINTNAME=`${SNMPWALK_BIN} -v 2c -c $community $hostname ${OIDPRINTNAME} | gawk -F " = STRING: " '{print $2}' > $RESULTTEMPPRINTNAME`

echo "INFO - Liste des dossiers en partage"

while read line
do
        if [ `cat $RESULTTEMPPRINTNAME | grep $line | wc -l` = "0" ];then
                echo $line | sed 's/\"//g'
        fi

done < $RESULTTEMPSHARENAME

rm $RESULTTEMPSHARENAME;
rm $RESULTTEMPPRINTNAME;

exit 0
