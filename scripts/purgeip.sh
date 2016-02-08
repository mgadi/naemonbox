#!/bin/bash
#
##  @Synopsis   Install Script for Naemonbox project
##  Developped by : Mark GADI aka MG-MONITORING
###################################################################
# Naemonbox is developped with GPL Licence 2.0
#
# GPL License: http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt
# Naemonbox Install Script
# Usage: bash install.sh
#
###################################################################
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
###################################################################
ROUGE="\033[31m"
VERT="\033[32m"
JAUNE="\033[33m"
BLEU="\033[34m"
MAGENTA="\033[35m"
defaut="\033[00m"
task=""
nocolor=""

# ENVIRONNEMENT
export myscripts=$(readlink -f $(dirname $0))
src=$myscripts
. "$myscripts"/naemonbox.cfg

## Script Dir ###############################################################################
# http://stackoverflow.com/questions/59895/can-a-bash-script-tell-what-directory-its-stored-in
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  dir="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done

dir="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
bindir="$dir/bin"
#oldip="grep only_from /etc/xinetd.d/nrpe | cut -f2 -d: | awk '{print $4}'"

###################################
# BEGIN
# Function: changeip
###################################

changeip() {
printf "\n$defaut"
echo -e "$ROUGE We need to update databases$defaut"
dbpass="$1" echo -e "\n--- Type MySQL root password ---\n"
        [ -n "$dbpass" ] || read -s -p "Enter MySQL root password: " dbpass

echo -e "\n--- Type MySQL root password ---\n"

mysqldump -uroot -p"$dbpass" --opt glpi>/tmp/glpi.sql
sed -i 's/$oldip/$ip/g' /tmp/glpi.sql
mysql -u root -p"$dbpass" glpi</tmp/glpi.sql
printf "$VERT"
mysqladmin -u root -p"$dbpass" drop cacti -f -s
mysqladmin -u root -p"$dbpass" create cacti
mysql -u root -p"$dbpass" cacti </var/www/cacti/cacti-backup.sql
printf "$defaut"
echo - Database "cacti" updated  
printf "$VERT"
mysqladmin -u root -p"$dbpass" drop syslog -f -s
mysqladmin -u root -p"$dbpass" create syslog
mysql -u root -p"$dbpass" syslog </var/www/cacti/syslog.sql
printf "$defaut"
echo - Database "syslog" updated 
sed -i 's/only_from       = 127.0.0.1 $oldip/only_from       = 127.0.0.1 $ip/g' /etc/xinetd.d/nrpe
sed -i 's/allowed_hosts=127.0.0.1,$oldip/allowed_hosts=127.0.0.1,$ip/g' /etc/naemon/nrpe.cfg
sed -i 's/server = http:\/\/$oldip\/glpi/server = http:\/\/$ip\/glpi/g' /etc/fusioninventory/agent.cfg
#fusioninventory-agent --debug --debug
sed -i 's/http:\/\/$oldip\/naemon/http:\/\/$ip\/naemon/g' /var/www/glpi/plugins/webservices/scripts/glpi7a.php
sed -i 's/http:\/\/$oldip/http:\/\/$ip/g' /var/www/wiki/LocalSettings.php
sed -i 's/apache@$oldip/apache@$ip/g' /var/www/wiki/LocalSettings.php
systemctl reload apache2
printf "$VERT"
echo "Go to URL: http://$ip/"
}
changeip

