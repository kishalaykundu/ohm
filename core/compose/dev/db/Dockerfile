FROM postgres:15

ARG HOME_FOLDER=./compose/dev/db

COPY /maintenance /usr/local/bin/maintenance
COPY ./postgres/scripts/create_om_db /app/scripts/
RUN chmod +x /usr/local/bin/maintenance/* &&\
    chmod +x /app/scripts/create_om_db &&\
    mv /usr/local/bin/maintenance/* /usr/local/bin && rmdir /usr/local/bin/maintenance
