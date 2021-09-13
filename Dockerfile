FROM node:13.8 AS node

FROM php:8.0-apache AS production

# Copy nodejs from node image
COPY --from=node /usr/local/bin/node /usr/local/bin/node
COPY --from=node /opt /opt
COPY --from=node /usr/local/lib/node_modules /usr/local/lib/node_modules
COPY --from=node /usr/local/bin /usr/local/bin

# Custom Vhost
ADD 000-default.conf /etc/apache2/sites-available/000-default.conf
ADD docker-php-dev-environment.sh /usr/local/bin/

ENV PHP_BUILD_DEPS="autoconf gcc g++ libpq-dev linux-headers-amd64 make libmcrypt-dev libicu-dev libpq-dev libxml2-dev build-essential libpng-dev libjpeg-dev libonig-dev libzip-dev libfreetype6-dev libmagickwand-dev"

RUN set -xe \
    #
    # Install tools and PHP dependencies
    #
    && apt-get update \
    && apt-get install -y git subversion openssh-client coreutils unzip libpq-dev nano binutils-gold libgcc1 python libc-dev sqlite3-pcre libtool supervisor rsyslog \
    && apt-get install -y ${PHP_BUILD_DEPS} \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    #
    # Install Xdebug and Imagick
    #
    && pecl install xdebug \
    && pecl list-files xdebug |grep src |cut -d ' ' -f 3 > /usr/local/etc/php/conf.d/xdebug.ini \
    #
    # PHP Configuration
    #
    && docker-php-ext-install -j$(nproc) iconv mbstring intl pdo_pgsql pdo_mysql gd zip bcmath soap sockets opcache \
    # Cleanup
    && docker-php-source delete \
    && echo "Installing composer" \
    #
    # Install latest composer 1
    #
    && curl https://getcomposer.org/composer-1.phar > /usr/local/bin/composer1 \
    && chmod +x /usr/local/bin/composer1 \
    #
    # Install latest composer 2
    #
    && curl https://getcomposer.org/composer-2.phar > /usr/local/bin/composer \
    && chmod +x /usr/local/bin/composer \
    #
    # Install webpack-encore
    #
    && npm install -g @symfony/webpack-encore \
    #
    # Enable httpd mod_rewrite, mod_headers, mod_expires
    #
    && a2enmod rewrite headers expires\
    #
    # Build dependencies cleanup
    #
    && apt-get remove -y ${PHP_BUILD_DEPS} \
    && apt-get clean

EXPOSE 80

# Labelling strategy on child containers build
ONBUILD ARG FORLABS_IMAGE_CONTEXT='production'
ONBUILD LABEL fr.forlabs.image_context="${FORLABS_IMAGE_CONTEXT}"

# PHP sessions are stored in /tmp
VOLUME /tmp

# Final step to create symfony development image
FROM production AS development

# Disable opcache by default
RUN bash /usr/local/bin/docker-php-dev-environment.sh
