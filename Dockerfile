FROM debian:stable-slim

RUN apt-get update && \
    apt-get install -y qbittorrent-nox && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN set -x \
    # Add non-root user
 && useradd -d /home/qbittorrent -u 520  qbittorrent \
    # Create symbolic links to simplify mounting
 && mkdir -p /home/qbittorrent/.config/qBittorrent \
 && mkdir -p /home/qbittorrent/.local/share/qBittorrent \
 && mkdir /downloads \
 && chmod go+rw -R /home/qbittorrent /downloads \
 && ln -s /home/qbittorrent/.config/qBittorrent /config \
 && ln -s /home/qbittorrent/.local/share/qBittorrent /torrents \
    # Check it works
 && su qbittorrent -s /bin/sh -c 'qbittorrent-nox -v'

COPY qBittorrent.conf /default/qBittorrent.conf
COPY entrypoint.sh /

RUN chmod +x entrypoint.sh

VOLUME ["/config", "/torrents", "/downloads"]

ENV HOME=/home/qbittorrent

USER qbittorrent

EXPOSE $QBT_WEB_PORT $TORRENT_PORT

ENTRYPOINT ["/entrypoint.sh"]
CMD qbittorrent-nox --webui-port=$QBT_WEB_PORT

HEALTHCHECK --interval=5s --timeout=2s --retries=20 CMD curl --connect-timeout 15 --silent --show-error --fail http://localhost:$QBT_WEB_PORT/ >/dev/null || exit 1
