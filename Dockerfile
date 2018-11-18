FROM ubuntu:16.04
RUN apt-get update && apt-get install apache2 php7.0 php7.0-mysql libapache2-mod-php7.0 php7.0-gd php7.0-xml php7.0-mbstring vim mysql-client-5.7 -y

COPY drupal-8.6.3.tar.gz / 
RUN tar -xf /drupal-8.6.3.tar.gz --strip-components 1 -C /var/www/html/ && rm -f /var/www/html/index.html && chown -R www-data:www-data /var/www/html/


COPY run.sh /usr/local/bin/entrypoint
RUN chmod 755 /usr/local/bin/entrypoint


WORKDIR /var/www/html/

EXPOSE 80 443

ENTRYPOINT ["entrypoint"]
