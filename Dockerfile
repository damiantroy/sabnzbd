# Base
FROM centos:7
LABEL maintainer="Damian Troy <github@black.hole.com.au>"
RUN yum -y update && yum clean all

# Commaon
VOLUME /config
ENV PUID=1001
ENV PGID=1001
RUN groupadd -g ${PGID} videos && \
    useradd --no-log-init -u ${PUID} -g videos -d /config -M videos && \
    install -d -m 0755 -o videos -g videos /config /videos
ENV TZ=Australia/Melbourne
COPY test.sh /usr/local/bin/

# App
VOLUME /videos
EXPOSE 8080
RUN yum -y install epel-release http://repository.it4i.cz/mirrors/repoforge/redhat/el7/en/x86_64/rpmforge/RPMS/rpmforge-release-0.5.3-1.el7.rf.x86_64.rpm && \
    yum -y install nmap-ncat git unzip p7zip par2cmdline python3-pip && \
    yum clean all
RUN git clone --branch master https://github.com/sabnzbd/sabnzbd.git /opt/sabnzbd && \
    chown -R $PUID:$PGID /opt/sabnzbd
RUN python3 -m pip install --upgrade pip setuptools wheel
RUN python3 -m pip install -r /opt/sabnzbd/requirements.txt
RUN su - videos -c 'cd /opt/sabnzbd && /opt/sabnzbd/tools/make_mo.py'

# Runtime
USER videos
ENV LANG=en_US.UTF-8
CMD ["/opt/sabnzbd/SABnzbd.py","--logging","1","--browser","0"]
