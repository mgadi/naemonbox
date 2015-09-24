#! /bin/sh

# S. SANCHEZ

# $1 = $NOTIFICATIONTYPE$
# $2 = $HOSTNAME$
# $3 = $HOSTSTATE$
# $4 = $HOSTOUTPUT$

#LOG=/tmp/glpi_host_$$.log

echo "----------------------------------------------------------------------------------" >> $LOG
echo notification : $1 >> $LOG
echo hostname     : $2 >> $LOG
echo hoststate    : "$3" >> $LOG
echo hostoutput   : "$4" >> $LOG
echo "----------------------------------------------------------------------------------" >> $LOG

/usr/bin/php /var/www/glpi/plugins/webservices/scripts/create_ticket.php --source=alarmhost --notification=$1 --hostname=$2 --title="host problem - $3" --content="$4" --state=$3 --debug=true

