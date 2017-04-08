#!/bin/bash

# Carbon
if [ ! -f "/opt/graphite/conf/carbon.conf" ]; then
    /bin/cp -ru /opt/graphite/conf-back/carbon.conf /opt/graphite/conf/carbon.conf
fi
if [ ! -f "/opt/graphite/conf/storage-aggregation.conf" ]; then
    /bin/cp -ru /opt/graphite/conf-back/storage-aggregation.conf /opt/graphite/conf/storage-aggregation.conf
fi
if [ ! -f "/opt/graphite/conf/storage-schemas.conf" ]; then
    /bin/cp -ru /opt/graphite/conf-back/storage-schemas.conf /opt/graphite/conf/storage-schemas.conf
fi

# Grafana
if [ ! -f "/opt/grafana/conf/defaults.ini" ]; then
    /bin/cp -ru /opt/grafana/conf-back/defaults.ini /opt/grafana/conf/defaults.ini
fi

# Remove old PID files
/bin/rm -f /run/supervisord.pid
/bin/rm -f /opt/graphite/storage/carbon-cache-a.pid

# Init
/usr/bin/python /usr/bin/supervisord
