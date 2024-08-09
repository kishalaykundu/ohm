SHELL=/bin/bash
.PHONY: init package clean

# this checks if the docker group exists in system
check_and_add_to_docker_group:
	if [ $(getent group docker) ]; then \
		sudo groupadd docker; \
		sudo usermod -aG docker $(USER); \
	else \
		sudo usermod -aG docker $(USER); \
	fi; \
	newgrp docker

init:
	sudo systemctl start docker

start: init
	make check_and_add_to_docker_group

build:
	docker build -t ohm-core:latest .

check:
	docker run -i -t ohm-core:latest /bin/bash

purge: # removes all images in the system including base images
	docker rmi -f $(docker images -aq)

stop:
	sudo systemctl stop docker.socket \
	&& sudo systemctl stop docker
