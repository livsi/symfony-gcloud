FROM php:7.1.5-alpine

COPY config/php/php.ini /usr/local/etc/php/php.ini
COPY config/php/docker-php-entrypoint /usr/local/bin/docker-php-entrypoint
COPY config/php/install-composer.sh /usr/local/bin/docker-app-install-composer
COPY api /var/www/symfony

# https://getcomposer.org/doc/03-cli.md#composer-allow-superuser
ENV COMPOSER_ALLOW_SUPERUSER 1
ENV SYMFONY_ENV prod
ENV APCU_VERSION 5.1.8

RUN set -xe \
    && apk add --no-cache --virtual .persistent-deps \
		 git \
		 icu-libs \
		 zlib \
	&& chmod +x /usr/local/bin/docker-php-entrypoint \
    && apk add --no-cache --virtual .build-deps \
		 $PHPIZE_DEPS \
		 openssl \
		 icu-dev \
		 zlib-dev \
	&& docker-php-ext-install \
		 intl \
		 pdo_mysql \
		 zip \
	&& pecl install \
         apcu-${APCU_VERSION} \
    && docker-php-ext-enable --ini-name 20-apcu.ini apcu \
	&& docker-php-ext-enable --ini-name 10-opcache.ini opcache \
	&& chmod +x /usr/local/bin/docker-app-install-composer \
	&& docker-app-install-composer \
	&& mv composer.phar /usr/local/bin/composer \
	&& apk del .build-deps \
	&& chown -R 82 /var/www/symfony

RUN composer global require "hirak/prestissimo:^0.3" --prefer-dist --no-progress --no-suggest --optimize-autoloader --classmap-authoritative

EXPOSE 9000

VOLUME /var/www/symfony/web

WORKDIR /var/www/symfony

RUN mkdir -p \
		var/cache \
		var/logs \
		var/sessions \
	&& composer install --prefer-dist --no-dev --optimize-autoloader --no-scripts --no-progress --no-suggest \
	&& composer clear-cache