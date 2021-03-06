#!/bin/bash

set -o errexit
set -o pipefail
set -o nounset

#Clear terminal screen so the about text can be read
clear

RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
RESET='\033[0m'

# Check Docker is running
SERVICE='docker'
if ps ax | grep -v grep | grep -v /Library/PrivilegedHelperTools/com.docker.vmnetd | grep $SERVICE > /dev/null
then
    printf "${GREEN}$SERVICE service running, continuing.\n${RESET}"
else
    printf "${RED}Docker is not running and is required for this script, exiting.\n${RESET}"
    exit 1
fi

printf "
${GREEN}
####
# This simple script starts a Drupal 8 checked out from head
# running in ddev with a fresh database.
#
# Make sure you've uploaded any patches from last issue
# you worked on before continuing, as this blow away
# local changes.
#
# Press y to continue, or any other key to exit the script.
# !!You don't need to hit enter!!.
#
####
${RESET}"
read -n1 INSTALL
if [[ ! $INSTALL =~ ^[Yy]$ ]]
then
	printf "${RED}You didn't hit y or Y, exiting script${RESET}"
    exit 1
else
	printf "${GREEN}# Continuing
####${RESET}"
fi

printf "\n"
ddev remove || echo "No existing project to remove"
wait
ddev start
wait
ddev exec git fetch
ddev exec git reset --hard origin/8.6.x
ddev exec composer install
ddev exec drush si standard --account-pass=admin --db-url=mysql://db:db@db:3306/db
ddev exec drush cr
ddev describe

printf "
${GREEN}
####
# Use the following URL's to access your site:
#
# Website:   ${YELLOW}http://sprint-[ts].ddev.local/
#            (U:admin  P:admin)
# ${GREEN}IDE:       ${YELLOW}http://sprint-[ts].ddev.local:8000/
#            (U:username  P:password)
# ${GREEN}Mailhog:   ${YELLOW}http://sprint-[ts].ddev.local:8025/${GREEN}
# DB Admin:  ${YELLOW}http://sprint-[ts].ddev.local:8036/${GREEN}
# IRC:       ${YELLOW}http://sprint-[ts].ddev.local:9000/${GREEN}
# 
# See ${YELLOW}Readme.txt${GREEN} for more information.
####
${RESET}
"
