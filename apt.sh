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

VERT="\\033[1;32m"
NORMAL="\\033[0;39m"
ROUGE="\\033[1;31m"
ROSE="\\033[1;35m"
BLEU="\\033[1;34m"
BLANC="\\033[0;02m"
BLANCLAIR="\\033[1;08m"
JAUNE="\\033[1;33m"
CYAN="\\033[1;36m"


echo -e "$ROSE======== Adding repositories ========$NORMAL"

CUSTOMAPT=/etc/apt/sources.list
grep -qri "non-free" $CUSTOMAPT
if [[ $? -eq 1 ]]
    then
        echo -e "$ROUGE You need added non-free repository$NORMAL"
        echo   "We add non-free repository for you"
        sed -i "s/wheezy main contrib/wheezy main contrib non-free/g" /etc/apt/sources.list
        sed -i "s/updates main contrib/updates main contrib non-free/g" /etc/apt/sources.list
    fi

if [ $# -gt 0 ]; then
            if [[ "$1" == "debian" ]]; then
                    grep -qri "debian" $CUSTOMAPT
                    if [ $# -eq 1 ]; then
        echo "You have non-free repository"
                    fi
            fi
    fi

