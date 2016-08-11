FROM php:7.0-apache

RUN pecl install redis \
 && docker-php-ext-enable redis

COPY index.php /var/www/html/
