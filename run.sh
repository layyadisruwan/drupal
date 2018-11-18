#!/bin/sh
set -e

# Avoid Apache complaining about existing PID files
rm -f /var/run/apache2/apache2.pid

# Define Drupal home file path
DRUPAL_HOME="/var/www/html"


# Define Drupal settings file path
DRUPAL_DEFAULT_SETTINGS_FILE="${DRUPAL_HOME}/sites/default/default.settings.php"
DRUPAL_SETTINGS_FILE="${DRUPAL_HOME}/sites/default/settings.php"


if [ ! -f "${DRUPAL_SETTINGS_FILE}" ]; then

# Create Drupal settings file
cp "${DRUPAL_DEFAULT_SETTINGS_FILE}" "${DRUPAL_SETTINGS_FILE}"
chown www-data:www-data "${DRUPAL_SETTINGS_FILE}"


# Check the avilability of environment variables

if [ -n "$DRUPAL_SQL_DB" ] && [ -n "$DRUPAL_SQL_USER" ] && [ -n "$DRUPAL_SQL_PASS" ] && [ -n "$DRUPAL_SQL_HOST" ] ; then

cat >> "${DRUPAL_SETTINGS_FILE}" <<'EOF'
$databases['default']['default'] = array (
EOF
cat >> "${DRUPAL_SETTINGS_FILE}" <<EOF
   'database' => '${DRUPAL_SQL_DB}',
   'username' => '${DRUPAL_SQL_USER}',
   'password' => '${DRUPAL_SQL_PASS}',
   'prefix' => '',
   'host' => '${DRUPAL_SQL_HOST}',
   'port' => '3306',
EOF
cat >> "${DRUPAL_SETTINGS_FILE}" <<'EOF'
   'namespace' => 'Drupal\\Core\\Database\\Driver\\mysql',
   'driver' => 'mysql',
);
EOF

sed -i '/<\/VirtualHost>/i <Directory \/var\/www\/html\/>\n        AllowOverride All\n<\/Directory>' /etc/apache2/sites-available/000-default.conf
a2enmod rewrite proxy proxy_http
fi
fi


# Start Apache
tail -F /var/log/apache2/* &
exec /usr/sbin/apache2ctl -D FOREGROUND
