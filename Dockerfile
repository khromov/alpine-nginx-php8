FROM alpine:edge
LABEL Maintainer="Stanislav Khromov <stanislav+github@khromov.se>" \
      Description="Lightweight container with Nginx 1.18 & PHP-FPM 8 based on Alpine Linux."

ARG PHP_VERSION="8.1.0-r0"

# https://github.com/wp-cli/wp-cli/issues/3840
ENV PAGER="more"

# T
RUN apk add --no-cache 

# Install packages and remove default server definition
RUN apk add --no-cache -X http://dl-cdn.alpinelinux.org/alpine/edge/testing php81=${PHP_VERSION} \
    php81-ctype \
    php81-curl \
    php81-dom \
    php81-exif \
    php81-fileinfo \
    php81-fpm \
    php81-gd \
    php81-iconv \
    php81-intl \
    php81-mbstring \
    php81-mysqli \
    php81-opcache \
    php81-openssl \
    php81-pecl-imagick \
    php81-pecl-redis \
    php81-phar \
    php81-session \
    php81-simplexml \
    php81-soap \
    php81-xml \
    php81-xmlreader \
    php81-zip \
    php81-zlib \
    php81-pdo \
    php81-xmlwriter \
    php81-tokenizer \
    php81-pdo_mysql \
    nginx supervisor curl tzdata htop mysql-client dcron

# Symlink php8 => php
RUN ln -s /usr/bin/php81 /usr/bin/php

# Install PHP tools
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && chmod +x wp-cli.phar && mv wp-cli.phar /usr/local/bin/wp
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && php composer-setup.php --install-dir=/usr/local/bin --filename=composer

# Configure nginx
COPY config/nginx.conf /etc/nginx/nginx.conf

# Configure PHP-FPM
COPY config/fpm-pool.conf /etc/php81/php-fpm.d/www.conf
COPY config/php.ini /etc/php81/conf.d/custom.ini

# Configure supervisord
COPY config/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Setup document root
RUN mkdir -p /var/www/html

# Make sure files/folders needed by the processes are accessable when they run under the nobody user
RUN chown -R nobody.nobody /var/www/html && \
  chown -R nobody.nobody /run && \
  chown -R nobody.nobody /var/lib/nginx && \
  chown -R nobody.nobody /var/log/nginx && \ 
  chown -R nobody.nobody /var/log/php81

# Switch to use a non-root user from here on
USER nobody

# Add application
WORKDIR /var/www/html
COPY --chown=nobody src/ /var/www/html/

# Expose the port nginx is reachable on
EXPOSE 8080

# Let supervisord start nginx & php-fpm
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]

# Configure a healthcheck to validate that everything is up&running
HEALTHCHECK --timeout=10s CMD curl --silent --fail http://127.0.0.1:8080/fpm-ping
