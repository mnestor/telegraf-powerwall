# Telegraf docker image modified for polling stats from Tesla Powerwall

## Overview ##

I had been doing this with a multiline command on the main telegraf image but wanted to clean up my setup so created this.

## Credits ##

This uses a modified version of a script from [@Vince Loschiavo](https://github.com/vloschiavo): [powerwallstats.sh](https://github.com/vloschiavo/powerwall2/blob/master/samples/powerwallstats.sh)

At this point I've forgotten where I got the telegraf config, if/when I remember I'll update this.

## Configurables

### Required:

```
POWERWALL_PASSWORD=
INFLUX_DB=
```

### Optional (with defaults):

```
POWERWALL_IP=powerwall
COOKIE_FILE=/var/tmp/PWcookie.txt
```

