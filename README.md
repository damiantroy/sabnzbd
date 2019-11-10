# SABnzbd newsreader CentOS container

## Configuration

| Command | Config   | Description
| ------- | -------- | -----
| ENV     | PUID     | UID of the runtime user (Default: 1001)
| ENV     | PGID     | GID of the runtime group (Default: 1001)
| ENV     | TZ       | Timezone (Default: Australia/Melbourne)
| VOLUME  | /videos  | Videos directory, including 'downloads/'
| VOLUME  | /config  | Configuration directory
| EXPOSE  | 8080/tcp | HTTP port for web interface

## Instructions

Build and run:
```shell script
PUID=1001
PGID=1001
TZ=Australia/Melbourne
VIDEOS_DIR=/videos
SABNZBD_CONFIG_DIR=/etc/config/sabnzbd
SABNZBD_IMAGE=localhost/sabnzbd # Or damiantroy/sabnzbd if deploying from docker.io

sudo mkdir -p ${VIDEOS_DIR} ${SABNZBD_CONFIG_DIR}
sudo chown -R ${PUID}:${PGID} ${VIDEOS_DIR} ${SABNZBD_CONFIG_DIR}

# You can skip the 'build' step if deploying from docker.io
sudo podman build -t sabnzbd .

sudo podman run -d \
    --pod video \
    --name=sabnzbd \
    -e PUID=${PUID} \
    -e PGID=${PGID} \
    -e TZ=${TZ} \
    -v ${SABNZBD_CONFIG_DIR}:/config:Z \
    -v ${VIDEOS_DIR}:/videos:z \
    ${SABNZBD_IMAGE}
```