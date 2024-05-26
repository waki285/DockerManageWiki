FROM php:8.1.18-fpm

RUN apt update
RUN apt install -y \
	git \
	curl \
	zip \
	unzip \
    libicu-dev \
    imagemagick \
	wget \
	vim
RUN docker-php-ext-install pdo_mysql mysqli 
RUN docker-php-ext-install intl 
RUN pecl install apcu && docker-php-ext-enable apcu

COPY php.ini /usr/local/etc/php/
COPY ./src /var/www/html
COPY ./mysql /var/www/mysql
COPY MirahezeFunctions.php /var/www/html/MirahezeFunctions.php
COPY wgConf.php /var/www/html/wgConf.php
COPY ManageWikiExtensions.php /var/www/html/ManageWikiExtensions.php
COPY ManageWikiNamespaces.php /var/www/html/ManageWikiNamespaces.php
COPY ManageWikiSettings.php /var/www/html/ManageWikiSettings.php

COPY ./wait-for-it/wait-for-it.sh /usr/local/bin/wait-for-it.sh
RUN chmod +x /usr/local/bin/wait-for-it.sh

COPY ./install.sh /usr/local/bin/install.sh
RUN chmod +x /usr/local/bin/install.sh

WORKDIR /var/www/html
