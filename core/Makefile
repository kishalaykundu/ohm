.PHONY: all help start test add_to_group init build shell bash update purge stop

# default target. runs help command.
all:
	@echo "Try 'make help'"

# displays callable make targets.
help:
	grep -E "^# target:" [Mm]akefile

# target: make start (initalizes docker daemon if not started)
start:
	sudo systemctl start docker

# target: make add_to_group (this checks if the docker group exists in system and if not, creates it and adds user to docker group)
add_to_group:
	if [ $(getent group docker) ]; then \
		sudo groupadd docker; \
		sudo usermod -aG docker $(USER); \
	else \
		sudo usermod -aG docker $(USER); \
	fi; \
	newgrp docker

# target: make init (starts docker daemon and adds user to docker group, sequentially runs 'make init' & 'make add_to_group')
init: start
	make add_to_group

# target: make build (uses docker,instead of docker compose to build app image)
build:
	docker build -t ohm_core:latest .

# target: DBNAME=<dbname> DBUSER=<admin-name> DBPASS=<password> make devup (creates & runs app/db/cache in dev)
devup:
	DBNAME=$(DB) DBUSER=$(DBUSER) DBPASSWORD=$(DBPASS) docker compose -f dev.yaml up

# target: DB=<dbname> DBUSER=<admin-name> DBPASS=<password> make devdb (creates & runs app/db/cache in dev)
devdb:
	docker compose db psql --dbname=$(DB) --username=$(DBUSER) --password=$(DBPASS)

# target: make up (creates & runs app in production)
up:
	docker compose -f live.yaml up

# target: make shell (enters app shell)
shell:
	docker compose run -rm app  /bin/bash

# target: make bash (enters app shell using docker, not docker compose)
bash:
	docker run -i -t ohm_core:latest /bin/bash

# target: make update (installs & updates pip requirements for app)
update:
	docker-compose run app pip install -r app/requirements/dev.txt

# target: make purge (removes all images in the system including base images) [NOT RECOMMENDED - USE WITH CAUTION]
purge:
	docker rmi -f $(docker images -aq)

# target: make stop (stops docker daemon)
stop:
	sudo systemctl stop docker.socket \
	&& sudo systemctl stop docker
