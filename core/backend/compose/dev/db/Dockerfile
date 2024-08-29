FROM postgres:16
ARG PG_FOLDER=./compose/dev/db

COPY ${PG_FOLDER}/maintenance /usr/local/bin/maintenance
COPY ${PG_FOLDER}/init.sql /docker-entrypoint-initdb.d/
RUN chmod +x /usr/local/bin/maintenance/* &&\
    mv /usr/local/bin/maintenance/* /usr/local/bin && rmdir /usr/local/bin/maintenance
