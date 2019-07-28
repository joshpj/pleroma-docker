#!/bin/sh
CMD=$1

cd "$(dirname "$0")"

usage() {
cat <<USAGE
Usage: $0 [command]

	setup		- build, configure, initialize
	build		- build images
	configure	- generate config files
	initialize	- initialize database
	start		- start Pleroma
	stop		- stop Pleroma

USAGE
}

build() {
	echo
	echo Building images
	docker-compose build
}

mk_nginx_config() {
	echo
	echo Building NGINX config
	echo

	# Extract config file
	mkdir -p volumes/config/nginx
	NGINX_CFG_CMD='cp /opt/pleroma/installation/pleroma.nginx /tmp/config/nginx/pleroma.conf'
	docker-compose -f docker-compose.yml -f docker-compose-init.yml run --no-deps --user root --entrypoint '/bin/sh -c' --rm pleroma "$NGINX_CFG_CMD"

	openssl req -subj '/CN=localhost' -x509 -newkey rsa:4096 -nodes -keyout volumes/config/nginx/key.pem -out volumes/config/nginx/cert.pem -days 365

	patch volumes/config/nginx/pleroma.conf -i nginx.conf.patch

}

mk_pleroma_config() {
	echo
	echo Generating Pleroma config
	echo Please set database server hostname to \'db\'
	echo Please set pleroma listen address to 0.0.0.0
	echo
	mkdir -p volumes/config/
	touch volumes/config/config.exs
	PLEROMA_CFG_CMD='/opt/pleroma/bin/pleroma_ctl instance gen --force --output /tmp/config/config.exs --output-psql /tmp/config/setup_db.psql'
	docker-compose -f docker-compose.yml -f docker-compose-init.yml run --no-deps --user root --entrypoint /bin/sh --rm pleroma $PLEROMA_CFG_CMD
}

mk_config() {
	mk_pleroma_config
	mk_nginx_config
}

init_db() {
	echo
	echo Initializing database

	docker-compose -f docker-compose.yml -f docker-compose-init.yml up -d db
	sleep 10
	docker-compose exec --user postgres db psql -f /tmp/config/setup_db.psql
	docker-compose run --rm --entrypoint='/opt/pleroma/bin/pleroma_ctl migrate' pleroma
	docker-compose stop db
	docker-compose rm --force db
}

start() {
	docker-compose up -d
	docker-compose ps
}

stop() {
	docker-compose stop
}

if [ -z "$CMD" ]; then
	usage
	exit 1
fi

case "$CMD" in
	setup)
		build
		mk_config
		init_db
	;;
	build)
		build
	;;
	configure)
		mk_config
	;;
	pleroma-config)
		mk_pleroma_config
	;;
	nginx-config)
		mk_nginx_config
	;;
	initialize)
		init_db
	;;
	start)
		start
	;;
	stop)
		stop
	;;
	*)
		usage
		exit 1
	;;
esac
