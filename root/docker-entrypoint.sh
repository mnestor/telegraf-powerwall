#!/bin/bash

# get a cookie for the powerwall authentication
/etc/periodic/hourly/powerwallstats.sh

# start cron in the background to refresh the cookie
crond -f &

# start pulling stats
telegraf --config-directory /etc/telegraf/telegraf.d 