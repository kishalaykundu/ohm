#!/bin/bash
set -e

function echo_usage() {
    echo "Usage: ./create_db [options]"
    echo ""
    echo "OPTIONS:"
    echo "  MANDATORY:"
    echo "      --dbname=<dbname>     : Name of admin database"
    echo "      --dbuser=<user name>  : User name of superuser to login to database"
    echo "  OPTIONAL:"
    echo "      --dbport=<dbport>     : Port of connection to admin database (default 5432)"
    echo "NOTE: A randomized password will be generated for user. Please store this for future logins"
    echo ""
}

# Parse arguments
DBPORT="5432"
for i in "$@"
do
    case $i in
        --dbname=*)
        DBNAME="${i#*=}"
        shift # past argument=value
        ;;
    esac
    case $i in
        --dbuser=*)
        DBUSER="${i#*=}"
        shift # past argument=value
        ;;
    esac
    case $i in
        --dbport=*)
        DBPORT="${i#*=}"
        shift # past argument=value
        ;;
    esac
done
PASSWORD=$(uuidgen)

# exit if mandatory options are not present
if [ ! [ -z "$DBNAME" || -z "$DBUSER" ]]; then
    echo_usage
    exit
fi

# Create the first super user and corresponding master db
POSTGRES="psql -d ${POSTGRES_DB} -U ${POSTGRES_USER}"
$POSTGRES <<EOSQL
IF NOT EXISTS (SELECT FROM pg_database WHERE datname="${DBNAME}") THEN
    CREATE DATABASE "${DBNAME}" OWNER "${DBUSER}";
ELSE
    \echo DB "${DBNAME}" already exists. Delete DB before running command again.
END IF
IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname="${DBUSER}") THEN
    CREATE USER "${DBUSER}" WITH ENCRYPTED PASSWORD '${PASSWORD}';
ELSE
    \echo User "${DBUSER}" already exists
END IF
CREATE EXTENSION IF NOT EXISTS pgcrypto;
CREATE SCHEMA IF NOT EXISTS ohm;
EOSQL
echo "SELECT 'CREATE USER \"${DBUSER}\" WITH ENCRYPTED PASSWORD \"${PASSWORD}\";' WHERE NOT EXISTS (SELECT FROM pg_roles WHERE rolname=\"${DBUSER}\") \gexec" | psql
echo "SELECT 'CREATE DATABASE \"${DBNAME}\"' WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = \"${DBNAME}\")\gexec" | psql
echo "Done"
