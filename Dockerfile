FROM alpine:3.21
LABEL Maintainer="Stanislav Khromov <stanislav+github@khromov.se>" \
      Description="Lightweight container with Nginx 1.26 & PHP-FPM 8.4 based on Alpine Linux."

ARG PHP_VERSION="8.4.5-r0"

# https://github.com/wp-cli/wp-cli/issues/3840
ENV PAGER="more"

# Install packages and remove default server definition
RUN apk --no-cache add php84=${PHP_VERSION} \
    php84-ctype \
    php84-curl \
    php84-dom \
    php84-exif \
    php84-fileinfo \
    php84-fpm \
    php84-gd \
    php84-iconv \
    php84-intl \
    php84-mbstring \
    php84-mysqli \
    php84-opcache \
    php84-openssl \
    php84-pecl-imagick \
    php84-pecl-redis \
    php84-phar \
    php84-session \
    php84-simplexml \
    php84-soap \
    php84-xml \
    php84-xmlreader \
    php84-zip \
    php84-zlib \
    php84-pdo \
    php84-xmlwriter \
    php84-tokenizer \
    php84-pdo_mysql \
    php84-pdo_sqlite \
    nginx supervisor curl tzdata htop mysql-client dcron

# Symlink php8 => php
RUN ln -s /usr/bin/php84 /usr/bin/php

RUN ls /usr/bin

# Install PHP tools
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && chmod +x wp-cli.phar && mv wp-cli.phar /usr/local/bin/wp
RUN php84 -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && php84 composer-setup.php --install-dir=/usr/local/bin --filename=composer

# Configure nginx
COPY config/nginx.conf /etc/nginx/nginx.conf

# Configure PHP-FPM
COPY config/fpm-pool.conf /etc/php84/php-fpm.d/www.conf
COPY config/php.ini /etc/php84/conf.d/custom.ini

# Configure supervisord
COPY config/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Setup document root
RUN mkdir -p /var/www/html

# Make sure files/folders needed by the processes are accessable when they run under the nobody user
RUN chown -R nobody:nobody /var/www/html && \
  chown -R nobody:nobody /run && \
  chown -R nobody:nobody /var/lib/nginx && \
  chown -R nobody:nobody /var/log/nginx

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
