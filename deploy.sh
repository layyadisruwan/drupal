#!/bin/bash

set -e


read -p 'Please enter sql root user passsword: ' SQLROOTPWD
read -p 'Please enter sql user: ' SQLUSER
read -p 'Please enter sql user passsword: ' SQLUSERPWD
read -p 'Please enter database name: ' DRUPALDB

SQLVERSION='5.7'
SQLDATADIR='/tmp/sql'
SQLCONTAINER='drupaldb'
WEBCONTAINER='drupalapp'
DRUPALIMG='drupalweb'

docker stop "${WEBCONTAINER}"
docker rm "${WEBCONTAINER}"
docker stop "${SQLCONTAINER}"
docker rm "${SQLCONTAINER}"
rm -fr "${SQLDATADIR}"


mkdir -p "${SQLDATADIR}"

docker pull mysql:"${SQLVERSION}"

docker run --name "${SQLCONTAINER}" -e MYSQL_ROOT_PASSWORD="${SQLROOTPWD}" -e MYSQL_DATABASE="${DRUPALDB}" -e MYSQL_USER="${SQLUSER}" -e MYSQL_PASSWORD="${SQLUSERPWD}" -v "${SQLDATADIR}":/var/lib/mysql -d mysql:"${SQLVERSION}"


docker build -t "${DRUPALIMG}" $(pwd)

docker run --name "${WEBCONTAINER}" \
  --link "${SQLCONTAINER}":drupaldb \
  -e DRUPAL_SQL_DB="${DRUPALDB}" \
  -e DRUPAL_SQL_USER="${SQLUSER}" \
  -e DRUPAL_SQL_PASS="${SQLUSERPWD}" \
  -e DRUPAL_SQL_HOST='drupaldb' \
  -p 8080:80 -d "${DRUPALIMG}"

