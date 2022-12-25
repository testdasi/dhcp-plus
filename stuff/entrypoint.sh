#!/bin/bash

if [[ -f "/etc/webmin/installed.flag" ]]
then
    echo '[info] webmin has been initialised, continue... '
else
    echo '[info] webmin not initialised. Initialising... '
    mkdir -p /etc/webmin
    cp -rf /etc/webmin-orig/* /etc/webmin/
fi

if [[ -f "/etc/dhcp/dhcpd.conf" ]]
then
    echo '[info] dhcpd.conf found, continue... '
else
    echo '[info] dhcpd.conf not found. Attempting to create default config... '
    mkdir -p /etc/dhcp
    cp /dhcp-plus/dhcpd.conf /etc/dhcp/
    sed -i "s|_DEFAULT_SUBNET_|$DEFAULT_SUBNET|g" '/etc/dhcp/dhcpd.conf'
    sed -i "s|_DEFAULT_NETMASK_|$DEFAULT_NETMASK|g" '/etc/dhcp/dhcpd.conf'
fi

## Only run process if ovpn config found ##
if [[ -f "/etc/webmin/installed.flag" ]] && [[ -f "/etc/dhcp/dhcpd.conf" ]]
then
    echo '[info] Changing webmin password...'
    echo root:$WEBMIN_PASSWORD | chpasswd
    echo '[info] Password is set for user root. (default is password)'
    
    # Disable health check #
    echo ''
    echo '[info] Disabling healthcheck while openvpn is connecting...'
    #touch /config/healthcheck-disable
    echo '[info] Healthcheck disabled'
    
    # Initilise apps #
    echo ''
    echo '[info] Initialisation started...'
    #source /static-ubuntu/openvpn-client/initialise.sh
    echo '[info] Initialisation complete'

    # DHCP Server #
    echo ''
    echo "[info] Starting ISC DHCP SERVER in background..."
    /bin/sh -ec 'CONFIG_FILE=/etc/dhcp/dhcpd.conf; if [ -f /etc/ltsp/dhcpd.conf ]; then CONFIG_FILE=/etc/ltsp/dhcpd.conf; fi; [ -e /var/lib/dhcp/dhcpd.leases ] || touch /var/lib/dhcp/dhcpd.leases; chown root:dhcpd /var/lib/dhcp /var/lib/dhcp/dhcpd.leases; chmod 775 /var/lib/dhcp ; chmod 664 /var/lib/dhcp/dhcpd.leases; if test -n "$INTERFACES" -a -z "$INTERFACESv4"; then INTERFACESv4="$INTERFACES"; fi; exec dhcpd -user dhcpd -group dhcpd -4 -pf /run/dhcp-server/dhcpd.pid -cf $CONFIG_FILE $INTERFACESv4'
    echo '[info] Server started'

    # Webmin #
    echo ''
    echo "[info] Running Webmin"
    PERLLIB=/usr/share/webmin
    /usr/share/webmin/miniserv.pl /etc/webmin/miniserv.conf
    echo "[info] All done"
    
    # Enable health check #
    echo ''
    echo '[info] Enabling healthcheck...'
    #rm -f /config/healthcheck-disable
    echo '[info] Healthcheck enabled'

    ### Periodically checking IP ###
    sleep_time=3600
    echo ''
    while true
    do
        echo "All your base are belong to us"
        sleep $sleep_time
    done
else
    echo '[CRITICAL] Initialisation failed. Exiting.'
fi
