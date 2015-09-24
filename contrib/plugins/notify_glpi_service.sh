#! /bin/sh

# O. SPY

# $1 = $NOTIFICATIONTYPE$
# $2 = $HOSTNAME$
# $3 = $SERVICEDESC$
# $4 = $SERVICESTATE$
# $5 = $SERVICEOUTPUT$

# LOG=/tmp/glpi_$$.log

echo "----------------------------------------------------------------------------------" >> $LOG
echo notification: $1 >> $LOG
echo hostname: $2 >> $LOG
echo title: "$3" >> $LOG
echo status: $4 >> $LOG
echo content: "$5" >> $LOG
echo "----------------------------------------------------------------------------------" >> $LOG

/usr/bin/php /var/www/glpi/plugins/webservices/scripts/create_ticket.php --source=alarmservice --notification=$1 --hostname=$2 --title="$3" --content="$5" --state=$4 --debug=true

