 Forlabs Base Symfony image
===============================================================================

Image source on Github: https://github.com/4Labs/docker-symfony

Base symfony 4+ engine including composer and common php modules.

The dockerfile contains 2 useful stages:
 - production
 - development (default)

The development image is built on top of the production.
For more information about stages: https://docs.docker.com/develop/develop-images/multistage-build/

## Build production image

To build production image, stop at production stage:

```shell script
docker build --target production .
```

## Build development image

```shell script
docker build .
```

The development image adds xdebug and disables opcache.

All dev modifications are done in the `/usr/local/bin/docker-php-dev-environment.sh script`.

## Tag management

Docker builds all git tags in prod and dev mode.

Prod images use the git tag, dev image adds the "-dev" suffix:

##### example:
* forlabs/symfony:5.0.0
* forlabs/symfony:5.0.0-dev

As it is useful to keep projects images up to date but fixed to a major version, 
tags are added with only major version (ie: `forlabs/symfony:5` and `forlabs/symfony:5-dev`)