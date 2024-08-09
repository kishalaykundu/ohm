.PHONY: all help translate test clean update compass collect rebuild

# target: all - Default target. Does nothing.
all:
	@echo "Hello $(LOGNAME), nothing to do by default"
	@echo "Try 'make help'"

# target: help - Display callable targets.
help:
	@egrep "^# target:" [Mm]akefile

# target: test - calls the "test" django command
test:
	docker-compose run app python3.12 manage.py test

# target: bash
bash:
	docker-compose exec app bash

# target: test - calls the "test" django command
shell:
	docker-compose run app python3.12 manage.py shell_plus

# target: clean - remove all ".pyc" files
clean:
	docker-compose run app python3.12 manage.py clean_pyc

# target: update - install (and update) pip requirements
update:
	docker-compose run app pip install -r app/requirements/dev.txt -r app/requirements/psycobuild.txt

# target: collect - calls the "collectstatic" django command
collect:
	docker-compose run app python3.12 manage.py collectstatic --noinput

# target: collect - calls the "makemigrations" django command
migrations:
	docker-compose run app python3.12 manage.py makemigrations

# target: collect - calls the "migrate" django command
migrate:
	docker-compose run app python3.12 manage.py migrate

# target: rebuild - clean, update, collect, then rebuild all data
rebuild: clean update collect
	docker-compose run app python3.12 manage.py reset_db --noinput
	docker-compose run app python3.12 manage.py makemigrations
	docker-compose run app python3.12 manage.py migrate

# Builds the frontend
build:
	rm -rf frontend/dist/*
	docker-compose run frontend yarn build
