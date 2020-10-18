# Docker PHP-FPM 8.0.0RC2 & Nginx 1.18 on Alpine Linux

* Built on the lightweight and secure Alpine Linux distribution
* Very small Docker image size (+/-35MB)
* Uses PHP 8 for better performance, lower CPU usage & memory footprint
* Optimized for 100 concurrent users
* Optimized to only use resources when there's traffic (by using PHP-FPM's on-demand PM)
* The servers Nginx, PHP-FPM and supervisord run under a non-privileged user (nobody) to make it more secure
* The logs of all the services are redirected to the output of the Docker container (visible with `docker logs -f <container name>`)
* Follows the KISS principle (Keep It Simple, Stupid) to make it easy to understand and adjust the image to your needs

![nginx 1.18.0](https://img.shields.io/badge/nginx-1.18-brightgreen.svg)
![php 8](https://img.shields.io/badge/php-8-brightgreen.svg)
![License MIT](https://img.shields.io/badge/license-MIT-blue.svg)

### Includes

* Composer
* WP-CLI
* GD2
* Various other extensions (like SimpleXML)
* MySQL CLI

This image is built on GitHub actions and hosted on the GitHub Docker images repo. It is also available under `khromov/alpine-nginx-php8` on Docker Hub.

### Usage

Fetch the prebuilt image in `docker-compose.yml` 
```
FROM docker.pkg.github.com/khromov/alpine-nginx-php8/alpine-nginx-php8
```

Or just fetch it:

```
docker pull docker.pkg.github.com/khromov/alpine-nginx-php8/alpine-nginx-php8
```

If you get "no basic auth credentials", see [this page](https://docs.github.com/en/free-pro-team@latest/packages/using-github-packages-with-your-projects-ecosystem/configuring-docker-for-use-with-github-packages).

#### Start Nginx, PHP and MySQL via Docker-compose

This is convenient for developing Laravel, WordPress or Drupal sites.

```
docker-compose up
```

Now you can access your site at http://localhost:8080 and the MySQL database at `db:3306`.

The folder `./src-compose` will be created and you can put your project files there.

#### Quick build / run

```
docker build . -t php 
docker run -p 8080:8080 -t php
```

Go to:  
http://localhost:8080/

## Configuration
In [config/](config/) you'll find the default configuration files for Nginx, PHP and PHP-FPM.
If you want to extend or customize that you can do so by mounting a configuration file in the correct folder.

## Acknowledgements

This image was inspired by [TrafeX/docker-php-nginx](https://github.com/TrafeX/docker-php-nginx) and [this subsequent fork](https://github.com/khromov/docker-php-nginx).