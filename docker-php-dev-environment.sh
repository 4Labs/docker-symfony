#!/bin/bash

# Disable opcache
sed -r 's/^(.{1,})/#\1/' < /usr/local/etc/php/conf.d/docker-php-ext-opcache.ini > /usr/local/etc/php/conf.d/docker-php-ext-opcache.ini.new
mv /usr/local/etc/php/conf.d/docker-php-ext-opcache.ini.new /usr/local/etc/php/conf.d/docker-php-ext-opcache.ini

# Enable xdebug
docker-php-ext-enable xdebug

# Disable httpd cache mods
a2dismod expires headers