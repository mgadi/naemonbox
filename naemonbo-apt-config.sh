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
# init variables
rouge="\033[31m"
vert="\033[32m"
jaune="\033[33m"
bleu="\033[34m"
magenta="\033[35m"
defaut="\033[00m"
task=""
nocolor=""


line="$magenta------------------------------------------------------------------------\n$defaut"
export line

version="0.0.5"
echo "
####################################################################
#                                                                  #
#                                                                  #
#                                                                  #
#                    Thanks for using Naemonbox                    #
#                       by MG-MONITORING                           #
#                                                                  #
#                        v:$version                                   #
####################################################################
"

###################################
# Create log file
###################################
eval `date "+day=%d; month=%m; year=%Y"`
log_file=/tmp/naemonbox-install-`date +%d%m%Y`.log
###################################
# Variables
###################################

function_apt () {

echo 'deb http://ftp.fr.debian.org/debian/ wheezy non-free
	deb-src http://ftp.fr.debian.org/debian/ wheezy non-free' > /etc/apt/sources.list.d/wheezy_nonfree.list
cat << EOF > /etc/apt/sources.list	
# deb http://ftp.fr.debian.org/debian wheezy main

deb http://ftp.fr.debian.org/debian wheezy main non-free contrib
deb-src http://ftp.fr.debian.org/debian wheezy main non-free contrib

deb http://security.debian.org/ wheezy/updates main contrib non-free
deb-src http://security.debian.org/ wheezy/updates main contrib non-free

# wheezy-updates, previously known as 'volatile'
deb http://ftp.fr.debian.org/debian wheezy-updates main contrib non-free
deb-src http://ftp.fr.debian.org/debian wheezy-updates main contrib non-free
EOF
apt-get update
}
function_apt
