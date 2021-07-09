#!/bin/bash


#######################################################
# Release Notes:
#
# Powerwall stats dumper for openhab
# Created by Vince Loschiavo - 2021-02-21
# As of Tesla Powerwall version 20.49.0, the powerwall gateway requires you authenticate for every stat.
#
# This script will login to the powerwall once per day to refresh the cookie, grab the JSON output from the powerwall and
#  send it to STDOUT for parsing by your tool of choice.
#
# Example URLs:
# /api/meters/aggregates
# /api/system_status/soe
# /api/system_status/grid_status
# /api/sitemaster
# /api/powerwalls
# /api/status
#
#
#######################################################
# Usage:
# ./powerwallstats.sh /URL/YOU/WANT/TO/COLLECT
#
# eg:
# ./powerwallstats.sh /api/meters/aggregates
#######################################################



#######################################################
# User Modified Variables
#######################################################
# You'll want to change these to match your environment
POWERWALLIP="${POWERWALL_IP:-powerwall}"
PASSWORD='${POWERWALL_PASSWORD}'


#######################################################
# Static Definitions
#######################################################
# You probably won't need to change these

USERNAME="customer"
# EMAIL="mnestor79@gmail.com"             # Set this to whatever you want, it's not actually used in the login process; I suspect Tesla will collect this eventually
COOKIE="${COOKIE_FILE:-/var/tmp/PWcookie.txt}"          # Feel free to change this location as you see fit.
# URL=$1
# TELEGRAF_CONF="/etc/telegraf/telegraf.d/powerwall.conf"




#######################################################
# Subroutines
#######################################################

# Create a valid Cookie
create_cookie () {
        # Delete the old cookie if it exists
        if [ -f $COOKIE ]; then
                rm -f $COOKIE
        fi

        # Login and Create new cookie
        curl -s -k -i -c $COOKIE -X POST -H "Content-Type: application/json" -d "{\"username\":\"$USERNAME\",\"password\":\"$PASSWORD\", \"email\":\"$EMAIL\",\"force_sm_off\":false}" "https://$POWERWALLIP/api/login/Basic"

        # If Login fails, then throw error and exit
        if [ $? -eq 200 ]; then
                echo "Login failed"
                exit;
        fi
}

update_cookie () {
    if [ -f $COOKIE ]; then
        # Cookie is present. Insert into configuration.
        AuthCookie=$(grep 'AuthCookie' /var/tmp/PWcookie.txt | awk '{print($7)}')
        if [ $? -ne 0 ]; then
            echo "Unable to match AuthCookie in /var/tmp/PWCookie.txt."
            exit;
        fi
        UserRecord=$(grep 'UserRecord' /var/tmp/PWcookie.txt | awk '{print($7)}')
        if [ $? -ne 0 ]; then
            echo "Unable to match UserRecord in /var/tmp/PWCookie.txt."
            exit;
        fi
        cp /etc/telegraf/telegraf.conf.tmpl /etc/telegraf/telegraf.conf
        echo "   headers = {\"Cookie\" = \"AuthCookie=${AuthCookie}; UserRecord=${UserRecord}\"}" >> /etc/telegraf/telegraf.conf
        if [ $? -eq 0 ]; then
            echo "Updated Cookies to:"
            echo $AuthCookie
            echo $UserRecord
        fi
        echo "Reloading Telegraf config"
        pkill -1 telegraf
    fi
}


# Check for a valid cookie
valid_cookie () {

        # if cookie doesnt exist, then login and create the cookie
        if [ ! -f $COOKIE ]; then
                # Cookie not present. Creating cookie.
                create_cookie
                update_cookie
        fi

        # If the cookie is older than one day old, refresh the cookie
        # Collect both times in seconds-since-the-epoch
        ONE_DAY_AGO=$(date -d 'now - 1 days' +%s)
        FILE_TIME=$(date -r "$COOKIE" +%s)

        if [ "$FILE_TIME" -le "$ONE_DAY_AGO" ]; then
                #The cookie is older than 1 days; get a new cookie
                create_cookie
                update_cookie
        fi
}


getstat () {
        curl -s -k -b $COOKIE https://$POWERWALLIP$URL > /dev/null
}

#######################################################
# Main
#######################################################

# Check for a valid cookie or login and create one
valid_cookie

# Get URL like /api/meters/aggregates
getstat

#Done