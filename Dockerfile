FROM php:7.1-apache
MAINTAINER sinkcup <sinkcup@gmail.com>

RUN apt-get update
RUN apt-get upgrade -y
RUN apt-get install -y gnupg2 icu-devtools libicu-dev libssl-dev unzip vim zlib1g-dev
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
RUN curl -sL https://deb.nodesource.com/setup_8.x | bash -
RUN apt-get install -y nasm nodejs
RUN docker-php-ext-install intl mbstring pdo_mysql zip opcache
RUN apt-get install -y libjpeg62-turbo-dev libpng-dev libwebp-dev libxpm-dev libfreetype6-dev libsasl2-dev libssl-dev zlib1g-dev
RUN docker-php-ext-configure gd --with-gd --with-webp-dir --with-jpeg-dir --with-png-dir --with-zlib-dir --with-xpm-dir --with-freetype-dir
RUN apt-get install -y cron
RUN docker-php-ext-install gd
RUN apt-get clean \
    && apt-get autoclean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
RUN a2enmod rewrite headers
RUN touch /usr/local/etc/php/php.ini

WORKDIR /var/www/laravel

COPY composer.json /var/www/laravel/
COPY composer.lock /var/www/laravel/
RUN composer install --no-autoloader --no-scripts --no-dev

COPY package.json /var/www/laravel/
COPY package-lock.json /var/www/laravel/
RUN npm install

COPY resources/js /var/www/laravel/resources/js
COPY resources/sass /var/www/laravel/resources/sass
COPY webpack.mix.js /var/www/laravel/
RUN npm run production

COPY app /var/www/laravel/app
COPY artisan /var/www/laravel/artisan
COPY bootstrap /var/www/laravel/bootstrap
COPY config /var/www/laravel/config
COPY database /var/www/laravel/database
COPY public /var/www/laravel/public
COPY resources /var/www/laravel/resources
COPY routes /var/www/laravel/routes
COPY server.php /var/www/laravel/server.php
COPY storage /var/www/laravel/storage
RUN composer install --optimize-autoloader --no-dev

RUN rm /etc/apache2/sites-enabled/*
COPY config/apache2 /etc/apache2/
RUN sed -i 's/\/var\/www\/.*\/public/\/var\/www\/laravel\/public/g' /etc/apache2/sites-available/laravel.conf
RUN a2ensite laravel

COPY crontab /var/spool/cron/crontabs/root
RUN chmod 0644 /var/spool/cron/crontabs/root

COPY . /var/www/laravel/
RUN chown www-data:www-data bootstrap/cache \
    && chown -R www-data:www-data storage/
RUN for i in patches/*.patch; do patch -N -p0 -i $i || true; done

COPY docker/start.sh /usr/local/bin/start
RUN chmod +x /usr/local/bin/start
CMD ["/usr/local/bin/start"]
