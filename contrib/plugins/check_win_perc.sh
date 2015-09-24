#!/bin/bash
#
# Script to check the Windows Dell-PERC for current status
#
# Original by:  Lewis Getschel
# Modified by:  Ken Nerhood
# Date:         05/11/2005
# Parameters:   1 - the IP address of the system to check
#               2 - snmp community string
#               3 - controller num (from .1.3.6.1.4.1.674.10893.1.1.130.1.1.1)
#
# Version History:
# 12/29/2004    Keeping a temp file seemed the best way to go on this. This
# LG            allows seeing changes. I initially didn't show the number of
#               Global/Dedicated HotSpares, but I realized that since each
#               "at-that-time-purchased" group had different standards for how
#               they were configured I needed to see the actual numbers of spares
#
# Notes:        The "baseline" (the temp file) is never actually replaced
#               anywhere in this code. If a new baseline is desired, then
#               simply delete the appropriate temp file. This routine will
#               create a NEW baseline (/tmp) file, and use that onward.
#
# Additional note:
#               Whenever something changes on the array (ready to offline, etc)
#               2 things happen:
#               1) Nagios goes to critical state
#               2) Nagios will STAY that way until you delete (or rename) the
#                  'baseline' file in /tmp
#                  I just leave it that way until the new drive arrives, then
#                  I delete the file. I let the "new config" be the Warning
#                  state for the 1st check, that way it shows up better in the
#                  event log.
#
#
# 05/11/2005    Added additional parameters to allow for easier configuration.
# KBN           You need to specify which array controller you want to monitor,
#               currently the script will only handle 2 controllers.
#               The script will now return a warning state if the controller
#               reports a severity level differnt than OK. This is to handle
#               the case where the baseline matches, but controller is not yet
#               OK (i.e. when rebuilding)
#
#
# =================================== Script starts below ================================
#
systemdifferences=0
hostnam=$1
communitystring=$2
arraynum=$3
# echo $1 >> /tmp/nagios_event_debug.txt
# echo --- `date` --- >> /tmp/nagios_event_debug.txt

if [ "$#" -lt "3" ]; then
   echo "Useage: check_win_perc host community arraynumber"
   exit 3
fi

# these system status's don't hold after a reboot!
currentsystemstatus=`/usr/bin/snmpget -v1 -c $communitystring $hostnam\:161 1.3.6.1.4.1.674.10893.1.1.130.1.1.5.$arraynum | awk '{print $NF}'`
previoussystemstatus=`/usr/bin/snmpget -v1 -c $communitystring $hostnam\:161 1.3.6.1.4.1.674.10893.1.1.130.1.1.5.$arraynum | awk '{print $NF}'`
system_serial_number=`snmpwalk -v 1 -c $communitystring $hostnam .1.3.6.1.4.1.674.10892.1.300.10.1.11 | awk '{print $NF}' | sed 's/\"//g'`

if [ $arraynum -eq "1" ]; then
   contl1severity=`/usr/bin/snmpwalk -v1 -c $communitystring $hostnam\:161 1.3.6.1.4.1.674.10893.1.1.130.1.1.6.$arraynum | awk '{print $NF}'`
   contl1drives=`/usr/bin/snmpwalk -v1 -c $communitystring $hostnam\:161 1.3.6.1.4.1.674.10893.1.1.130.5.1.7 | awk '{print $NF}' | awk 'BEGIN {x=0} /'$arraynum'/ {++x} END {print x}'`
   contl1name=`/usr/bin/snmpget -v1 -c $communitystring $hostnam\:161 1.3.6.1.4.1.674.10893.1.1.130.1.1.2.$arraynum | awk -F\" '{print $2}'`
   for ((a=1; a < = $contl1drives ; a++))  # Double parentheses, and "total_drives" with no "$".
   do
      current_disks_state[${a}]=`/usr/bin/snmpget -v1 -c $communitystring $hostnam\:161 1.3.6.1.4.1.674.10893.1.1.130.4.1.4.${a} | awk '{print $NF}'`
   done                           # A construct borrowed from 'ksh93'.

   # === if there is a previousdata file for previous run, read it in.
   if [ -e /tmp/${hostnam}_${arraynum}_$system_serial_number.txt ]; then
     for ((a=1; a <= contl1drives ; a++))  # Double parentheses, and "total_drives" with no "$".
      do
         previous_disks_state[${a}]=`/bin/sed -ne ${a}p /tmp/${hostnam}_${arraynum}_$system_serial_number.txt`
      done
      previousdata=1
   else # no previous file data, make it now from current (or should I make it manually as 4 3 3 3 1 ..??)
      currentdrive=1
      previousdata=0
      /bin/touch /tmp/${hostnam}_${arraynum}_$system_serial_number.txt
      while [ $currentdrive -le $contl1drives ]
      do
         echo ${current_disks_state[$currentdrive]} >> /tmp/${hostnam}_${arraynum}_$system_serial_number.txt
         currentdrive=`expr $currentdrive + 1`
      done
      echo "WARNING - PERC array wrote first status file for /tmp/${hostnam}_${arraynum}_$system_serial_number"
      exit 1
   fi

   totalhotspares=`/usr/bin/snmpwalk -c $communitystring -v 1 $hostnam 1.3.6.1.4.1.674.10893.1.1.130.4.1.22 | awk '{print $NF}'| awk 'BEGIN {x=0} /3/ {++x} END {print x}'`
   #totaldedicatedspares=`/usr/bin/snmpwalk -c $communitystring -v 1 $hostnam 1.3.6.1.4.1.674.10893.1.1.130.4.1.22 | awk '{print $NF}'| awk 'BEGIN {x=0} /4/ {++x} END {print x}'`

   # ========= If current status != previous status then it's Broken, figure out where =============
   # except for the FIRST time this script runs, this code only runs because of a mismatch in states
   # it seems safe to assume that I should check each array position for where the problem is.
   currentdrive=1
   while [ $currentdrive -le $contl1drives ]
   do
      if [ ${current_disks_state[$currentdrive]} -ne ${previous_disks_state[$currentdrive]} ]; then
         systemdifferences=1
         echo -n `/usr/bin/snmpget -v1 -c $communitystring $hostnam\:161 1.3.6.1.4.1.674.10893.1.1.130.4.1.2.$currentdrive | awk -F\" '{print $2}'`" "
         case "${current_disks_state[$currentdrive]}" in
            "0" )
               echo -n "Unknown";;
            "1" )
               echo -n "Ready"
               case "`/usr/bin/snmpget -v1 -c $communitystring $hostnam\:161 1.3.6.1.4.1.674.10893.1.1.130.4.1.22.$currentdrive | awk '{print $NF}'`" in
                  "1" )
                     echo -n "-member of virtual disk.";;
                  "2" )
                     echo -n "-member of disk group.";;
                  "3" )
                     echo -n "-global hot spare.";;
                  "4" )
                     echo -n "-dedicated hot spare.";;
                   * )
                     echo -n "Bad_ERROR_Code.";;
               esac;;
            "2" )
               echo -n "Failed";;
            "3" )
               echo -n "Online";;
            "4" )
               echo -n "Offline";;
            "6" )
               echo -n "Degraded";;
            "7" )
               echo -n "Recovering";;
            "11" )
               echo -n "Removed";;
            "15" )
               echo -n "Resyncing";;
            "24" )
               echo -n "Rebuild";;
            "25" )
               echo -n "No Media";;
            "26" )
               echo -n "Formatting";;
            "28" )
               echo -n "Diagnostics";;
            "35" )
               echo -n "Initializing";;
            * )
               echo -n "Bad_ERROR_Code";;
         esac
         echo -n " Was: "
         case "${previous_disks_state[$currentdrive]}" in
            "0" )
               echo -n "Unknown. ";;
            "1" )
               echo -n "Ready. ";;
            "2" )
               echo -n "Failed. ";;
            "3" )
               echo -n "Online. ";;
            "4" )
               echo -n "Offline. ";;
            "6" )
               echo -n "Degraded. ";;
            "7" )
               echo -n "Recovering. ";;
            "11" )
               echo -n "Removed. ";;
            "15" )
               echo -n "Resyncing. ";;
            "24" )
               echo -n "Rebuild. ";;
            "25" )
               echo -n "No Media. ";;
            "26" )
               echo -n "Formatting. ";;
            "28" )
               echo -n "Diagnostics. ";;
            "35" )
               echo -n "Initializing. ";;
            * )
               echo -n "Bad_ERROR_Code. ";;
         esac
      fi
      currentdrive=`expr $currentdrive + 1`
   done
   if [ $systemdifferences -eq 0 ];
   then
      case $contl1severity in
         "0" )
            echo "OK - $contl1name Drives=$contl1drives, Global HotSpares=$totalhotspares"; exit 0;;
         "1" )
            echo "Warning - $contl1name Controller"; exit 1;;
         "2" )
            echo "Error  - $contl1name Controller"; exit 2;;
         "3" )
            echo "Failure - $contl1name Controller"; exit 2;;
         esac
   else
      echo ""
      exit 2
   fi

else
   contl2severity=`/usr/bin/snmpwalk -v1 -c $communitystring $hostnam\:161 1.3.6.1.4.1.674.10893.1.1.130.1.1.6.$arraynum | awk '{print $NF}'`
   contl2name=`/usr/bin/snmpget -v1 -c $communitystring $hostnam\:161 1.3.6.1.4.1.674.10893.1.1.130.1.1.2.$arraynum | awk -F\" '{print $2}'`
   contl1drives=`/usr/bin/snmpwalk -v1 -c $communitystring $hostnam\:161 1.3.6.1.4.1.674.10893.1.1.130.5.1.7 | awk '{print $NF}' | awk 'BEGIN {x=0} /1/ {++x} END {print x}'`
   contl2drives=`/usr/bin/snmpwalk -v1 -c $communitystring $hostnam\:161 1.3.6.1.4.1.674.10893.1.1.130.5.1.7 | awk '{print $NF}' | awk 'BEGIN {x=0} /'$arraynum'/ {++x} END {print x}'`
   d=$contl1drives
   for ((a=1; a < = $contl2drives ; a++))  # Double parentheses, and "total_drives" with no "$".
   do
      let d=$contl1drives+$a
      current_disks_state[${a}]=`/usr/bin/snmpget -v1 -c $communitystring $hostnam\:161 1.3.6.1.4.1.674.10893.1.1.130.4.1.4.$d | awk '{print $NF}'`
   done                           # A construct borrowed from 'ksh93'.

   # === if there is a previousdata file for previous run, read it in.
   if [ -e /tmp/${hostnam}_${arraynum}_$system_serial_number.txt ]; then
      for ((a=1; a <= contl2drives ; a++))  # Double parentheses, and "total_drives" with no "$".
      do
         previous_disks_state[${a}]=`/bin/sed -ne ${a}p /tmp/${hostnam}_${arraynum}_$system_serial_number.txt`
      done
      previousdata=1
   else # no previous file data, make it now from current (or should I make it manually as 4 3 3 3 1 ..??)
      currentdrive=1
      previousdata=0
      /bin/touch /tmp/${hostnam}_${arraynum}_$system_serial_number.txt
      while [ $currentdrive -le $contl2drives ]
      do
         echo ${current_disks_state[$currentdrive]} >> /tmp/${hostnam}_${arraynum}_$system_serial_number.txt
         currentdrive=`expr $currentdrive + 1`
      done
      echo "WARNING - PERC array wrote first status file for /tmp/${hostnam}_${arraynum}_$system_serial_number"
      exit 1
   fi

   totalhotspares=`/usr/bin/snmpwalk -c $communitystring -v 1 $hostnam 1.3.6.1.4.1.674.10893.1.1.130.4.1.22 | awk '{print $NF}'| awk 'BEGIN {x=0} /3/ {++x} END {print x}'`
   #totaldedicatedspares=`/usr/bin/snmpwalk -c $communitystring -v 1 $hostnam 1.3.6.1.4.1.674.10893.1.1.130.4.1.22 | awk '{print $NF}'| awk 'BEGIN {x=0} /4/ {++x} END {print x}'`

   currentdrive=1
   while [ $currentdrive -le $contl2drives ]
   do
      if [ ${current_disks_state[$currentdrive]} -ne ${previous_disks_state[$currentdrive]} ]; then
         systemdifferences=1
         let c2currentdrive=$contl1drives+$currentdrive
         echo -n `/usr/bin/snmpget -v1 -c $communitystring $hostnam\:161 1.3.6.1.4.1.674.10893.1.1.130.4.1.2.$c2currentdrive | awk -F\" '{print $2}'`" "
         case "${current_disks_state[$currentdrive]}" in
            "0" )
               echo -n "Unknown";;
            "1" )
               echo -n "Ready"
               case "`/usr/bin/snmpget -v1 -c $communitystring $hostnam\:161 1.3.6.1.4.1.674.10893.1.1.130.4.1.22.$c2currentdrive | awk '{print $NF}'`" in
                  "1" )
                     echo -n "-member of virtual disk.";;
                  "2" )
                     echo -n "-member of disk group.";;
                  "3" )
                     echo -n "-global hot spare.";;
                  "4" )
                     echo -n "-dedicated hot spare.";;
                   * )
                     echo -n "Bad_ERROR_Code.";;
               esac;;
            "2" )
               echo -n "Failed";;
            "3" )
               echo -n "Online";;
            "4" )
               echo -n "Offline";;
            "6" )
               echo -n "Degraded";;
            "7" )
               echo -n "Recovering";;
            "11" )
               echo -n "Removed";;
            "15" )
               echo -n "Resyncing";;
            "24" )
               echo -n "Rebuild";;
            "25" )
               echo -n "No Media";;
            "26" )
               echo -n "Formatting";;
            "28" )
               echo -n "Diagnostics";;
            "35" )
               echo -n "Initializing";;
            * )
               echo -n "Bad_ERROR_Code";;
         esac
         echo -n " Was: "
         case "${previous_disks_state[$currentdrive]}" in
            "0" )
               echo -n "Unknown. ";;
            "1" )
               echo -n "Ready. ";;
            "2" )
               echo -n "Failed. ";;
            "3" )
               echo -n "Online. ";;
            "4" )
               echo -n "Offline. ";;
            "6" )
               echo -n "Degraded. ";;
            "7" )
               echo -n "Recovering. ";;
            "11" )
               echo -n "Removed. ";;
            "15" )
               echo -n "Resyncing. ";;
            "24" )
               echo -n "Rebuild. ";;
            "25" )
               echo -n "No Media. ";;
            "26" )
               echo -n "Formatting. ";;
            "28" )
               echo -n "Diagnostics. ";;
            "35" )
               echo -n "Initializing. ";;
            * )
               echo -n "Bad_ERROR_Code. ";;
         esac
      fi
      currentdrive=`expr $currentdrive + 1`
   done
   if [ $systemdifferences -eq 0 ];
   then
      case $contl2severity in
         "0" )
            echo "OK - $contl2name Drives=$contl2drives, Global HotSpares=$totalhotspares"; exit 0;;
         "1" )
            echo "Warning - $contl2name Controller"; exit 1;;
         "2" )
            echo "Error  - $contl2name Controller"; exit 2;;
         "3" )
            echo "Failure - $contl2name Controller"; exit 2;;
         esac
   else
      echo ""
      exit 2
   fi
fi
