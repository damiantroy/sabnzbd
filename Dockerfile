# Base
FROM docker.io/rockylinux/rockylinux:8
LABEL maintainer="Damian Troy <github@black.hole.com.au>"
RUN dnf -y update && dnf clean all

# Commaon
ENV PUID=1001
ENV PGID=1001
RUN groupadd -g "$PGID" videos && \
    useradd --no-log-init -u "$PUID" -g videos -d /config -M videos && \
    install -d -m 0755 -o videos -g videos /config /videos
ENV TZ=Australia/Melbourne
ENV LANG=C.UTF-8
COPY test.sh /usr/local/bin/

# App
RUN dnf -y install epel-release && \
    dnf -y localinstall --nogpgcheck https://mirrors.rpmfusion.org/free/el/rpmfusion-free-release-8.noarch.rpm https://mirrors.rpmfusion.org/nonfree/el/rpmfusion-nonfree-release-8.noarch.rpm && \
    dnf -y install nmap-ncat git unzip p7zip par2cmdline python39-pip unrar && \
    dnf clean all
RUN git clone --branch master https://github.com/sabnzbd/sabnzbd.git /opt/sabnzbd && \
    chown -R "$PUID:$PGID" /opt/sabnzbd && \
    python3 -m pip install --upgrade pip setuptools wheel && \
    python3 -m pip install -r /opt/sabnzbd/requirements.txt && \
    su - videos -c 'cd /opt/sabnzbd && /opt/sabnzbd/tools/make_mo.py'

# Runtime
VOLUME /config /videos
EXPOSE 8080
USER videos
CMD ["/opt/sabnzbd/SABnzbd.py","--logging","1","--browser","0"]
