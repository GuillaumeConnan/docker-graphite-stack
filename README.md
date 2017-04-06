# docker-graphite-stack

AIO and ready for use metrology stack container based on Carbon, Graphite-API and Grafana

Graphite-API 1.1.3, Carbon 1.0.0-rc1, Whisper 1.0.0-rc1 and Grafana 4.2.0 running on Debian 9.0 Stretch

## Installation

```sh
docker pull silenthunter44/docker-graphite-stack:latest
```

## Run

Run with default configuration with the following:

```sh
docker run --detach --name graphite-stack -p 2003 -p 3000 silenthunter44/docker-graphite-stack:latest
```

Alternatively, you can use external volumes for configuration, storage and log data with the following:

```sh
docker run --detach --name graphite-stack  \
  -v /local-path-to-log:/var/log/supervisor \
  -v /local-path-to-whisper:/opt/graphite/storage/whisper \
  -v /local-path-to-graphite-conf:/opt/graphite/conf \
  -v /local-path-to-grafana-conf:/opt/grafana/conf \
  -v /local-path-to-grafana-data:/opt/grafana/data \
  -p 2003 -p 3000 silenthunter44/docker-graphite-stack:latest
```

## Ports

- `2003` : Carbon line receiver TCP port
- `2004` : Carbon pickle receiver port
- `3000` : Grafana HTTP listen port

## Volumes

- `/var/log/supervisor` : logfiles of all services
- `/opt/graphite/storage/whisper` : Whisper database
- `/opt/graphite/conf` : Carbon configuration
  - carbon.conf
  - storage-aggregation.conf
  - storage-schemas.conf
- `/opt/grafana/conf` : Grafana configuration
  - defaults.ini
- `/opt/grafana/data` : Grafana data
  - grafana.db
  - plugins/

## Credentials

Default credentials for Grafana are `admin` / `admin`

## Configuration

Datasource must be added to Grafana after first login. A Graphite datasource is ready to be used in proxy access mode and available at URL http://127.0.0.1:8080

## Included services

- `carbon-cache` : recieve and write incomming metrics into Whisper files
- `graphite-api` : queries Whisper database & expose an HTTP API to Grafana
- `grafana` : sublimates the data returned by Graphite-API
- `memcached` : cache Graphite-API data and Grafana sessions
- `collectd` : gather and report internal metrology to carbon-cache
