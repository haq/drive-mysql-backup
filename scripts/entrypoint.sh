#!/bin/ash

function check_env() {
  if [[ -z "$1" ]]; then
    echo "($1) environment variable is missing a value"
    exit 1
  fi
}

# rclone command
if [[ "$1" == "rclone" ]]; then
    $*
    exit 0
fi

# check if all environment variables are set
check_env ${TZ}
check_env ${CRON}
check_env ${RCLONE_REMOTE}
check_env ${BACKUP_FOLDER}
check_env ${DATABASE}
check_env ${DB_TYPE}
check_env ${DB_HOST}
check_env ${DB_PORT}
check_env ${DB_USER}
check_env ${DB_PASSWORD}

# check if rclone config exists
rclone config show "${RCLONE_REMOTE}" > /dev/null
if [[ $? != 0 ]]; then
  echo "rclone config does not exist"
  exit 1
else
  echo "rclone config exists"
fi

# check if rclone config is functional
rclone mkdir "${BACKUP_FOLDER}"
if [[ $? != 0 ]]; then
  echo "rclone config is incorrect"
  exit 1
else
  echo "rclone config is correct"
fi

# creating .pgpass file
echo "creating postgres environment variables"
export PGDATABASE="${DATABASE}"
export PGHOST="${DB_HOST}"
export PGPORT="${DB_PORT}"
export PGUSER="${DB_USER}"
export PGPASSWORD="${DB_PASSWORD}"

# configure crontab
crontab -l | grep -q "backup.sh" && echo "cron entry exists" || echo "${CRON} cd /app/scripts && sh backup.sh > /dev/stdout" | crontab - && echo "created cron entry"

echo "starting crond"

# start crond
crond -l 2 -f