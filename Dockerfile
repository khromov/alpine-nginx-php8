FROM alpine:3.24
LABEL Maintainer="Stanislav Khromov <stanislav+github@khromov.se>" \
      Description="Lightweight container with Nginx & PHP-FPM 8.5 based on Alpine Linux."

ARG PHP_VERSION="8.5.12-r0"

# https://github.com/wp-cli/wp-cli/issues/3840
ENV PAGER="more"

# Install packages and remove default server definition
RUN apk --no-cache add php85=${PHP_VERSION} \
    php85-ctype \
    php85-curl \
    php85-dom \
    php85-exif \
    php85-fileinfo \
    php85-fpm \
    php85-gd \
    php85-iconv \
    php85-intl \
    php85-mbstring \
    php85-mysqli \
    php85-openssl \
    php85-pecl-imagick \
    php85-pecl-redis \
    php85-phar \
    php85-session \
    php85-simplexml \
    php85-soap \
    php85-xml \
    php85-xmlreader \
    php85-zip \
    php85-zlib \
    php85-pdo \
    php85-xmlwriter \
    php85-tokenizer \
    php85-pdo_mysql \
    php85-pdo_sqlite \
    nginx supervisor curl tzdata htop mysql-client dcron

# Symlink php8 => php
RUN ln -sf /usr/bin/php85 /usr/bin/php

RUN ls /usr/bin

# Install PHP tools
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && chmod +x wp-cli.phar && mv wp-cli.phar /usr/local/bin/wp
RUN php85 -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && php85 composer-setup.php --install-dir=/usr/local/bin --filename=composer

# Configure nginx
COPY config/nginx.conf /etc/nginx/nginx.conf

# Configure PHP-FPM
COPY config/fpm-pool.conf /etc/php85/php-fpm.d/www.conf
COPY config/php.ini /etc/php85/conf.d/custom.ini

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
