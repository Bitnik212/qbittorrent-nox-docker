#!/bin/sh -e

# Default configuration file
if [ ! -f /config/qBittorrent.conf ]
then
	cp /default/qBittorrent.conf /config/qBittorrent.conf
fi

# Allow groups to change files.
umask 002

# echo "MailNotification\enabled=$EMAIL_ENABLE" >> /config/qBittorrent.conf
# echo "MailNotification\email=$EMAIL_TO" >> /config/qBittorrent.conf
# echo "MailNotification\password=$EMAIL_PASSWORD" >> /config/qBittorrent.conf
# echo "MailNotification\req_auth=$EMAIL_NEED_AUTH" >> /config/qBittorrent.conf
# echo "MailNotification\req_ssl=$EMAIL_NEED_SSL" >> /config/qBittorrent.conf
# echo "MailNotification\sender=$EMAIL_FROM" >> /config/qBittorrent.conf
# echo "MailNotification\smtp_server=$EMAIL_SMTP" >> /config/qBittorrent.conf
# echo "MailNotification\username=$EMAIL_LOGIN" >> /config/qBittorrent.conf

exec "$@"
