#
# VERSION 0.1.0
#

FROM debian:stretch
MAINTAINER Guillaume CONNAN "guillaume.connan44@gmail.com"

ENV DEBIAN_FRONTEND noninteractive

# Setting repositories, updating and installing softwares

RUN echo "deb http://deb.debian.org/debian stretch main contrib non-free"         >  /etc/apt/sources.list    && \
    echo "deb http://deb.debian.org/debian stretch-updates main contrib non-free" >> /etc/apt/sources.list    && \
    echo "deb http://security.debian.org stretch/updates main contrib non-free"   >> /etc/apt/sources.list

RUN apt-get update                && \
    apt-get upgrade -y -q         && \
    apt-get dist-upgrade -y -q    && \
    apt-get -y -q autoclean       && \
    apt-get -y -q autoremove

RUN apt-get install -y -q build-essential    \
                          procps             \
                          supervisor         \
                          wget               \
                          python-pip         \
                          libcairo2          \
                          python-cairo       \
                          libffi-dev         \
                          memcached

RUN pip install uwsgi                                                             \
                Flask-Cache                                                       \
                python-memcached                                                  \
                https://github.com/graphite-project/whisper/archive/master.zip    \
                https://github.com/graphite-project/carbon/archive/master.zip     \
                https://github.com/brutasse/graphite-api/archive/master.zip

# Carbon

RUN mkdir -p /opt/graphite/conf-back                                                                 && \
    rm -fr /opt/graphite/conf/*                                                                      && \
    sed -i 's/HOSTNAME = .*/HOSTNAME = \"internal\"/' /opt/graphite/lib/carbon/instrumentation.py    && \
    rm -f /opt/graphite/lib/carbon/instrumentation.pyc                                               && \
    python -m compileall /opt/graphite/lib/carbon/instrumentation.py

ADD conf/carbon/carbon.conf              /opt/graphite/conf-back/carbon.conf
ADD conf/carbon/storage-aggregation.conf /opt/graphite/conf-back/storage-aggregation.conf
ADD conf/carbon/storage-schemas.conf     /opt/graphite/conf-back/storage-schemas.conf

# Graphite-API

RUN mkdir -p /opt/graphite-api

ADD conf/graphite-api/config.yaml /opt/graphite-api/config.yaml
ADD conf/graphite-api/uwsgi.ini   /opt/graphite-api/uwsgi.ini

# Grafana

ENV GRAFANA_RELEASE 4.2.0
RUN wget "https://s3-us-west-2.amazonaws.com/grafana-releases/release/grafana-$GRAFANA_RELEASE.linux-x64.tar.gz"       \
         -O /opt/grafana-$GRAFANA_RELEASE.linux-x64.tar.gz                                                          && \
    tar -xf /opt/grafana-$GRAFANA_RELEASE.linux-x64.tar.gz -C /opt/                                                 && \
    mv /opt/grafana-$GRAFANA_RELEASE /opt/grafana                                                                   && \
    rm -f /opt/grafana/conf/*                                                                                       && \
    mkdir -p /opt/grafana/data/plugins                                                                              && \
    mkdir -p /opt/grafana/conf-back

ADD conf/grafana/defaults.ini /opt/grafana/conf-back/defaults.ini

# Collectd

ENV COLLECTD_RELEASE 5.7.1
RUN wget "https://storage.googleapis.com/collectd-tarballs/collectd-$COLLECTD_RELEASE.tar.bz2"       \
         -O /opt/collectd-$COLLECTD_RELEASE.tar.bz2                                               && \
    tar -xf /opt/collectd-$COLLECTD_RELEASE.tar.bz2 -C /opt/

RUN (                                                                           \
        cd /opt/collectd-$COLLECTD_RELEASE/                                  && \
        /opt/collectd-$COLLECTD_RELEASE/configure --prefix=/opt/collectd        \
                                                  --disable-all-plugins         \
                                                  --enable-aggregation          \
                                                  --enable-cpu                  \
                                                  --enable-df                   \
                                                  --enable-disk                 \
                                                  --enable-interface            \
                                                  --enable-load                 \
                                                  --enable-logfile              \
                                                  --enable-memcached            \
                                                  --enable-memory               \
                                                  --enable-processes            \
                                                  --enable-swap                 \
                                                  --enable-write_graphite       \
    )                                                                        && \
    (                                                                           \
        cd /opt/collectd-$COLLECTD_RELEASE/                                  && \
        make -j2 install                                                        \
    )                                                                        && \
    rm -fr /opt/collectd/etc/*

ADD conf/collectd/collectd.conf /opt/collectd/etc/collectd.conf

# Cleaning

RUN apt-get clean                   && \
    rm -fr /tmp/*                   && \
    rm -fr /var/tmp/*               && \
    rm -fr /var/lib/apt/lists/*     && \
    rm -fr /root/.cache             && \
    rm -f  /opt/grafana-*.tar.gz    && \
    rm -fr /opt/collectd-*

# Adding services

RUN mkdir -p /var/log/supervisor

ADD conf/supervisor/supervisor.conf /etc/supervisor/conf.d/supervisor.conf
ADD scripts/init.sh                 /init.sh

# Expose ports and volumes

EXPOSE 2003 2004 3000

VOLUME ["/var/log/supervisor/", "/opt/graphite/storage/whisper/", "/opt/graphite/conf/", "/opt/grafana/conf/", "/opt/grafana/data/"]

# Init

CMD ["/bin/bash", "-e", "/init.sh"]
