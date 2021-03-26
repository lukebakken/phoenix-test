#!/usr/bin/env bash

set -o errexit

# globals
declare -r script_dir="$(cd "$(dirname "$0")" && pwd -P)"

if [[ -z $POSTGRES_BIN ]]
then
    readonly POSTGRES_BIN='/usr/local/opt/postgresql/bin'
fi

if [[ -z $DB_DIR ]]
then
    export DB_DIR="$script_dir/db"
    mkdir -p "$DB_DIR"
fi

set -o nounset

if "$POSTGRES_BIN/pg_ctl" -D "$DB_DIR" status
then
    echo '[INFO] stopping PostgreSQL...'
    "$POSTGRES_BIN/pg_ctl" -D "$DB_DIR" stop
fi

export POSTGRES_DB="$DB_NAME" POSTGRES_USER="$DB_USERNAME" POSTGRES_PASSWORD="$DB_PASSWORD"
set | grep -F 'POSTGRES'

rm -rf "$DB_DIR"/* "$DB_DIR"/.??*

"$POSTGRES_BIN/initdb" --username="$DB_USERNAME" --pwfile=<(echo "$POSTGRES_PASSWORD") -D"$DB_DIR"

touch "$DB_DIR/.gitkeep"

sleep 2

"$POSTGRES_BIN/pg_ctl" -D "$DB_DIR" -l "$script_dir/log/pg_logfile" start

sleep 2

"$POSTGRES_BIN/psql" -U "$DB_USERNAME" -c "create database $DB_NAME" postgres

tail -f "$script_dir/log/pg_logfile"
