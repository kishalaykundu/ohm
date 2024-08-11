FROM postgres:16

COPY ./compose/dev/db/tenants/t2/maintenance /usr/local/bin/maintenance
COPY ./dev/db/tenants/t2/init.sql /docker-entrypoint-initdb.d/
RUN chmod +x /usr/local/bin/maintenance/* &&\
    mv /usr/local/bin/maintenance/* /usr/local/bin && rmdir /usr/local/bin/maintenance
