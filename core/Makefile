.PHONY: all help start test add_to_group init build shell bash update purge stop

# default target. runs help command.
all:
	@echo "Try 'make help'"

# displays callable make targets.
help:
	grep -E "^# target:" [Mm]akefile

# called by start
start_docker:
	sudo systemctl start docker

# called by start
add_to_group:
	if [ $(getent group docker) ]; then \
		sudo groupadd docker; \
		sudo usermod -aG docker ${USER}; \
	else \
		sudo usermod -aG docker ${USER}; \
	fi; \
	newgrp docker

# called by init
start: start_docker
	make add_to_group

# called by init
docker_login:
	docker login

# target: make init
# target: (starts docker daemon , adds user to docker group & login to docker, sequentially runs 'make start' & 'make docker_login')
init:
	make start && make docker_login

# target: make build (uses docker,instead of docker compose to build app image)
build:
	docker build -t ohm_core:latest .

# target: DB=<admindb-name> DBUSER=<admindb-user> DBPASS=<admindb-password> USERDB=<userdb-name> USERDBUSER=<userdb-user>
# target: USERDBPASS=<userdb-password> make local (creates & runs app/db/cache in local)
local:
	DB=${DB} DBUSER=${DBUSER} DBPASS=${DBPASS} USERDB=${USERDB} USERDBUSER=${USERDBUSER} USERDBPASS=${USERDBPASS} \
		docker compose -f docker-compose.local.yaml up

# target: DB=<dbname> DBUSER=<admin-name> DBPASS=<password> make localdb (creates & runs app/db/cache in dev)
localdb:
	docker compose db psql --dbname=${DB} --username=${DBUSER} --password=${DBPASS}

# target: DB=${DB} DBUSER=${DBUSER} DBPASS=${DBPASS} make runsql FILE=<sql-file-with-relative-pathname> DBCONTAINER=<db-container-name>
runsql:
	docker cp ${FILE} {DBCONTAINER}:/file.sql \
	&& docker exec -u ${DBUSER} ${DBCONTAINER}  psql ${DB} ${DBUSER} /file.sql

# target: make up (creates & runs app in production)
up:
	docker compose -f docker-compose.yaml up

# target: make shell (enters app shell)
shell:
	docker compose run -rm app  /bin/bash

# target: make bash (enters app shell using docker, not docker compose)
bash:
	docker run -i -t ohm_core:latest /bin/bash

# target: make update (installs & updates pip requirements for app)
update:
	docker-compose run app pip install -r app/requirements/dev.txt

# target: make clean (stops and removes all containers)
clean:
	docker ps -aq | xargs docker stop | xargs docker rm

# target: make purge (removes all images in the system including base images) [NOT RECOMMENDED - USE WITH CAUTION]
purge:
	docker rmi -f $(docker images -aq)

# target: make stop (stops docker daemon)
stop:
	sudo systemctl stop docker.socket \
	&& sudo systemctl stop docker
