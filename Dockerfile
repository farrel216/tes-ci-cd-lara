FROM php:8.2-fpm
WORKDIR /var/www

# Install dependencies
RUN apt update && apt install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip -y

RUN apt clean && rm -rf /var/lib/apt/lists/*

RUN docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd

COPY . .
COPY .env .env

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

RUN useradd -G www-data,root -u 1000 -d /home/developer developer
RUN mkdir -p /home/developer/.composer && \
    chown -R developer:developer /home/developer

RUN chown -R developer:developer /var/www && chmod -R 777 /var/www

RUN cp /usr/local/etc/php/php.ini-development /usr/local/etc/php/php

USER developer
RUN composer install

USER root

CMD php artisan serve --host=0.0.0.0 --port 80