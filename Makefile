install:
	install -m 755 -g root -o root nsupdate.sh /usr/bin/nsupdate.sh
install-service: install
	cp nsupdate.sh.service /etc/systemd/system
	test -e /etc/nsupdate.sh || cp config.sample.sh /etc/nsupdate.sh
	systemctl enable nsupdate.sh
	systemctl start nsupdate.sh
