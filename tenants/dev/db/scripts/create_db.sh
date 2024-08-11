#!/bin/bash
set -e

function echo_usage() {
    echo "Usage: ./create_tenant_db [options]"
    echo ""
    echo "OPTIONS:"
    echo "--dbname=<dbname>     : Explicit name of database"
    echo "--digits=<number>     : Number of digits in the randomly generated database name"
    echo "--dbuser=<login name>   : User name to login to database"
    echo "--password=<password> : Password for user login"
    echo ""
    echo "[CRITICAL]: One and only one of --dbname or --digits must be specified"
    echo ""
}

# Parse arguments
for i in "$@"
do
    case $i in
        --dbname=*)
        DBNAME="${i#*=}"
        shift # past argument=value
        ;;
        --digits=*)
        NUMDIGITS="${i#*=}"
        shift # past argument=value
        ;;
        --dbuser=*)
        DBUSER="${i#*=}"
        shift # past argument=value
        ;;
        --password=*)
        PASSWORD="${i#*=}"
        shift # past argument=value
        ;;
        --default)
        DEFAULT=YES
        shift # past argument with no value
        ;;
        *)
            # unknown option
        ;;
    esac
done

if [[ ! -z "$DBNAME" && ! -z "$NUMDIGITS" ]]; then
    echo_usage
    exit
fi

if [[ -z "$DBNAME" && -z "$NUMDIGITS" ]]; then
    echo_usage
    exit
fi

if [[ -z "$DBUSER" || -z "$PASSWORD" ]]; then
    echo_usage
    exit
fi

if [ ! -z "$NUMDIGITS" ]; then
    exponent=$(( $NUMDIGITS - 1 ))
    lower=$(( 10**$exponent ))
    upper=$(( 9*$lower))
    DBNAME="\"$(shuf -i ${lower}-${upper} -n 1)\""
fi

# Create the first super user and corresponding master db
# POSTGRES="psql -U ${POSTGRES_USER} -d ${POSTGRES_DB}"
# $POSTGRES <<EOSQL
# IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname="${DBUSER}") THEN
#     CREATE USER "${DBUSER}" WITH ENCRYPTED PASSWORD '${PASSWORD}';
# ELSE
#     \echo User "${DBUSER}" already exists
# END IF
# IF NOT EXISTS (SELECT FROM pg_database WHERE datname="${DBNAME}") THEN
#     CREATE DATABASE "${DBNAME}" OWNER "${DBUSER}";
# ELSE
#     \echo Database "${DBNAME}" already exists. Please delete DB before running command again.
# END IF
# EOSQL
echo "SELECT 'CREATE USER \"${DBUSER}\" WITH ENCRYPTED PASSWORD \"${PASSWORD}\";' WHERE NOT EXISTS (SELECT FROM pg_roles WHERE rolname=\"${DBUSER}\") \gexec" | psql
echo "SELECT 'CREATE DATABASE \"${DBNAME}\"' WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = \"${DBNAME}\")\gexec" | psql
echo "Done"