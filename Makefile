install:
	install -m 755 -g root -o root nsupdate.sh /usr/bin/nsupdate.sh
install-service: install
	cp nsupdate.sh.service /etc/systemd/system
	test -e /etc/nsupdate.sh || echo -e "$(shell cat config.sample.sh)\nLOOP=2h # update interval" | tee /etc/nsupdate.sh
	systemctl enable nsupdate.sh
	systemctl start nsupdate.sh
