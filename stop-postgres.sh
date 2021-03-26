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
else
    echo '[INFO] PostgreSQL not running!'
fi
