FROM alpine:3.19

# Arguments
ARG PHP_EXTENSIONS="php82 php82-fpm php82-mysqlnd php82-mysqli php82-xml php82-opcache php82-pdo php82-pdo_mysql php82-pdo php82-redis php82-bcmath php82-ctype php82-intl php82-xsl php82-sockets php82-json php82-openssl php82-phar php82-zlib php82-mbstring php82-zip php82-gd php82-tokenizer php82-xmlwriter php82-dom php82-curl php82-fileinfo php82-simplexml php82-iconv php82-pcntl php82-xmlreader php82-posix php82-sodium"
ENV COMPOSER_MEMORY_LIMIT="3G"

# Install softwares
RUN set -ex \
    apk update -qq && \
    apk add tzdata ca-certificates curl $PHP_EXTENSIONS && \
    ln -s /etc/php82/ /etc/php && \
    rm -rf /var/lib/{apt,dpkg,cache,log}/ /tmp/* /var/tmp/*  && \
    curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer

# Workdir
WORKDIR /app/

# Copy Application files
COPY app/ /app/

# Run composer
RUN composer install --no-interaction --prefer-dist --no-progress

# Configure permissions
RUN set -ex && \
    chown -R 1000:1000 /app/ && \
    find /app/ -type f -exec chmod 664 {} \; && \
    find /app/ -type d -exec chmod 775 {} \;