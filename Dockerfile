FROM php:5.6-apache

RUN curl -sL https://deb.nodesource.com/setup_4.x | bash - \
  && apt-get update && apt-get install -y \
      libfreetype6-dev \
      libjpeg62-turbo-dev \
      libpng12-dev \
      git \
      nodejs \
  && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
  && docker-php-ext-install pdo pdo_mysql gd

RUN npm install -g gulp@3.8.11

RUN mkdir -p /usr/src/mibew
WORKDIR /usr/src/mibew

ADD src/package.json ./
RUN npm install

ADD src/gulpfile.js ./
ADD src/bower.json ./
ADD src/composer.json ./
ADD src/tools ./tools
RUN gulp bower-install && gulp composer-install

ADD src/* ./
ADD src/mibew ./mibew
RUN gulp js && gulp chat-styles && gulp page-styles && gulp pack-sources

RUN rm -rf /var/www/html && mv /usr/src/mibew/mibew /var/www/html

WORKDIR /var/www/html

RUN chown www-data:www-data cache files/avatar

CMD ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]
