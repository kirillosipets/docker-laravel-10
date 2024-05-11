FROM php:8.2-fpm as app

ARG UID
ARG GID

ENV UID=${UID}
ENV GID=${GID}

RUN apt-get update && apt-get install -y \
    libfreetype-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    zlib1g-dev \
    libzip-dev \
    unzip \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd \
    && docker-php-ext-install zip \
    && docker-php-ext-install mysqli pdo pdo_mysql

COPY . /var/www
WORKDIR /var/www

RUN chown -R www-data:www-data /var/www \
    && chmod -R 775 /var/www/storage

COPY --from=composer:2.6.5 /usr/bin/composer /usr/local/bin/composer

COPY composer.json ./
RUN composer install

CMD ["php-fpm", "-y", "/usr/local/etc/php-fpm.conf", "-R"]
