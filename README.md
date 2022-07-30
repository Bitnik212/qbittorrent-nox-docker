# QBittorrent Docker Image

[Docker](https://www.docker.com/) image for [qBittorrent](http://www.qbittorrent.org/).

Run using this command

	docker run -d \
		-p 8081:8081 \
		-e QBT_WEB_PORT=8081
		-e TORRENT_PORT=8082
		-v $PWD/config:/config \
		-v $PWD/torrents:/torrents \
		-v $PWD/downloads:/downloads \
		bitnik212/qbittorrent-nox

To have webUI running on [http://localhost:8080](http://localhost:8080) (username: admin, password: adminadmin) with config in the following locations mounted:

* `/config`: QBittorrent configuration files
* `/torrents`: Torrent files
* `/downloads`: Download location

It is probably a good idea to add `--restart=always` so the container restarts if it goes down.

_Note: For the container to run, the legal notice had to be automatically accepted. By running the container, you are accepting its terms. Toggle the flag in `qBittorrent.conf` to display the notice again._
