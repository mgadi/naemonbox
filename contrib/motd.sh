#!/bin/bash
#
# MOTD Script 
# Version 1.0
# Updated: 20/11/2012
# Script location /etc/profile.d/
# Developped by : Mark GADI aka MG-MONITORING

figlet naemonbox
let upSeconds="$(/usr/bin/cut -d. -f1 /proc/uptime)"
let secs=$((${upSeconds}%60))
let mins=$((${upSeconds}/60%60))
let hours=$((${upSeconds}/3600%24))
let days=$((${upSeconds}/86400))
UPTIME=`printf "%d days, %02dh%02dm%02ds" "$days" "$hours" "$mins" "$secs"`
# get the load averages
read one five fifteen rest < /proc/loadavg

CPUTIME=$(ps -eo pcpu | awk 'NR>1' | awk '{tot=tot+$1} END {print tot}')
CPUCORES=$(cat /proc/cpuinfo | grep -c processor)
UP=$(echo `uptime` | awk '{ print $1 }')
PRIVATEIP=`/sbin/ifconfig | /bin/grep "Bcast:" | /usr/bin/cut -d ":" -f 2 | /usr/bin/cut -d " " -f 1`
VERT="\\033[1;32m"
NORMAL="\\033[0;39m"
ROUGE="\\033[1;31m"
ROSE="\\033[1;35m"
BLEU="\\033[1;34m"
BLANC="\\033[0;02m"
BLANCLAIR="\\033[1;08m"
JAUNE="\\033[1;33m"
CYAN="\\033[1;36m"

NaemonBox_NETWORK_MODE=`grep dhcp /etc/network/interfaces | grep eth0 | wc -l`
NETWORK=`if [ "${NaemonBox_NETWORK_MODE}" = "1" ]; then
                    printf " DHCP\n"
                  else
                    printf " STATIC\n"
                  fi`
 
echo -e "
$JAUNE `hostname -s` $NORMAL `lsb_release -ds`

$VERT System Information as `date +"%A %d %B %Y, %T"` $NORMAL 

  IP: $JAUNE `echo $PRIVATEIP`$NORMAL              Mode: $JAUNE $NETWORK $NORMAL
  System Load: ${one} ${five} ${fifteen}   CPU Use: `echo $CPUTIME / $CPUCORES | bc`%
  Memory use: `free -m | head -n 2 | tail -n 1 | awk {'print $4'}` Mb (Free) / `free -m | head -n 2 | tail -n 1 | awk {'print $2'}` Mb (Total)  
  Uptime: ${UPTIME}
  Kernel: `uname -or`

$VERT Services: $NORMAL"
printf "\n"
if [ $? -eq 0 ]; then
  printf "  MYSQL      Status :$VERT OK (`pgrep mysqld -x -d " "`)\n$NORMAL"
else
  printf "  MYSQL      Status :$ROUGE KO\n$NORMAL"
fi
if [ $? -eq 0 ]; then
  printf "  APACHE     Status :$VERT OK (`pgrep apache2 -x -d " "`)\n$NORMAL"
else
  printf "  APACHE     Status :$ROUGE KO\n$NORMAL"
fi
NAEMON_PID=`pgrep naemon -x -d " "`
if [ "1${NAEMON_PID}" != "1" ]; then
 printf "  NAEMON     Status :$VERT OK (`pgrep naemon -x -d " "`)\n$NORMAL"
else
 printf "  NAEMON     Status :$ROUGE KO\n$NORMAL"
fi
PNP4NAGIOS_PID=`pgrep npcd -x -d " "`
if [ "1${PNP4NAGIOS_PID}" != "1" ]; then
 printf "  PNP4NAGIOS Status :$VERT OK (`pgrep npcd -x -d " "`)\n$NORMAL"
else
 printf "  PNP4NAGIOS Status :$ROUGE KO\n$NORMAL"
fi
SYSLOG_PID=`pgrep rsyslogd -x -d " "`
if [ "1${SYSLOG_PID}" != "1" ]; then
 printf "  RSYSLOG    Status :$VERT OK (`pgrep rsyslogd -x -d " "`)\n$NORMAL"
else
 printf "  RSYSLOG    Status :$ROUGE KO\n$NORMAL"
fi
SNMPD_PID=`pgrep snmpd -x -d " "`
if [ "1${SNMPD_PID}" != "1" ]; then
 printf "  SNMPD      Status :$VERT OK (`pgrep snmpd -x -d " "`)\n$NORMAL"
else
 printf "  SNMPD      Status :$ROUGE KO\n$NORMAL"
fi
SNMPTRAPD_PID=`pgrep snmptrapd -x -d " "`
if [ "1${SNMPTRAPD_PID}" != "1" ]; then
 printf "  SNMPTRAPD  Status :$VERT OK (`pgrep snmptrapd -x -d " "`)\n$NORMAL"
else
 printf "  SNMPTRAPD  Status :$ROUGE KO\n$NORMAL"
fi 
#sudo /etc/init.d/nrpe status >/dev/null 2>&1
NRPE_PID=`pgrep nrpe -x -d " "`
 if [ "1${NRPE_PID}" != "1" ]; then
 printf "  NRPE       Status :$VERT OK ($NRPE_PID)\n$NORMAL"
else
 printf "  NRPE       Status :$ROUGE KO\n$NORMAL"
fi
NSCA_PID=`pgrep nsca -x -d " "`
if [ "1${NSCA_PID}" != "1" ]; then
 printf "  NSCA       Status :$VERT OK ($NSCA_PID)\n$NORMAL"
else
 printf "  NSCA       Status :$ROUGE KO\n$NORMAL"
fi
echo -e " 
"

# End of script
                                                                                                                     


