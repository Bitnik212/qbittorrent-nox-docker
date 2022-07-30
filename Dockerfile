FROM debian:stable-slim

RUN apt-get update && \
    apt-get install -y qbittorrent-nox && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY qBittorrent.conf /build/qBittorrent.conf

VOLUME /root/.config/qBittorrent
VOLUME /root/.local/share/data/qBittorrent
VOLUME /root/Downloads

EXPOSE $QBT_WEB_PORT

COPY start.sh /
RUN chmod +x /start.sh
CMD ["/start.sh"]
