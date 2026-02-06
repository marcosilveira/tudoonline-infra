FROM alpine:3.19
LABEL maintainer="Ganex <suporte@ganex.com.br>"

# Arguments
ARG USER_NAME="php"
ARG USER_UID="1000"
ARG GROUP_NAME="php"
ARG GROUP_GID="1000"
ARG USER_HOME="/app/"
ARG PHP_EXTENSIONS="php82 php82-fpm php82-mysqlnd php82-mysqli php82-xml php82-opcache php82-pdo php82-pdo_mysql php82-pdo php82-redis php82-bcmath php82-ctype php82-intl php82-xsl php82-sockets php82-json php82-openssl php82-phar php82-zlib php82-mbstring php82-zip php82-gd php82-tokenizer php82-xmlwriter php82-dom php82-curl php82-fileinfo php82-simplexml php82-iconv php82-pcntl php82-xmlreader php82-posix php82-sodium"
ARG NEW_RELIC_AGENT_VERSION="10.14.0.3"

# Environment variables
ENV LANG="pt_BR.UTF-8" \
    LANGUAGE="pt_BR:br" \
    LC_ALL="pt_BR.UTF-8" \
    TZ="America/Sao_Paulo" \
    PUPPETEER_EXECUTABLE_PATH="/usr/bin/chromium-browser" \
    PUPPETEER_SKIP_DOWNLOAD="1"

# Create a user and group used to launch processes
RUN addgroup -g $GROUP_GID -S $GROUP_NAME && \
    adduser -u $USER_UID -D -S -h $USER_HOME -s /sbin/nologin -G $GROUP_NAME $USER_NAME

RUN mkdir -p /etc/sudoers.d \
    && echo "$USER_NAME ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/$USER_NAME \
    && chmod 0440 /etc/sudoers.d/$USER_NAME

# Install softwares
RUN set -ex \
    apk update -qq && \
    apk add --no-cache tzdata ca-certificates curl $PHP_EXTENSIONS 'chromium~=124' nss freetype harfbuzz ca-certificates ttf-freefont nodejs npm && \
    npm install --global --unsafe-perm puppeteer@22.7.0 && \
    ln -s /etc/php82/ /etc/php && \
    rm -rf /var/lib/{apt,dpkg,cache,log}/ /tmp/* /var/tmp/* 

# Install New Relic Agent
RUN curl -L "https://download.newrelic.com/php_agent/archive/${NEW_RELIC_AGENT_VERSION}/newrelic-php5-${NEW_RELIC_AGENT_VERSION}-linux-musl.tar.gz" | tar -C /tmp -zx \
    && export NR_INSTALL_USE_CP_NOT_LN=1 \
    && export NR_INSTALL_SILENT=1 \
    && /tmp/newrelic-php5-*/newrelic-install install \
    && mkdir -p /var/log/newrelic \
    && touch /var/log/newrelic/newrelic-daemon.log \
    && chown -R $USER_UID:$GROUP_GID /var/log/newrelic/ \
    && ln -sf /dev/stderr /var/log/newrelic/newrelic-daemon.log \
    && rm -rf /tmp/newrelic-php5-* /tmp/nrinstall*

# Forward logs and configure permissions
RUN set -ex && \
    ln -sf /dev/stderr /var/log/php82/error.log && \
    chown -R $USER_UID:$GROUP_GID /etc/php82/ && \
    chown -R $USER_UID:$GROUP_GID /var/log/php82/ && \
    mkdir -p /var/lib/php/session/ && \
    chown -R $USER_UID:$GROUP_GID /var/lib/php/session && \
    chmod 770 /var/lib/php/session/

# Create app diretory and set permissions
RUN set -ex && \
    chown -R $USER_UID:$GROUP_GID $USER_HOME/ && \
    find $USER_HOME/ -type f -exec chmod 664 {} \; && \
    find $USER_HOME/ -type d -exec chmod 775 {} \;

# Add Application
COPY --from=local/build:latest app/ /app/

# Workdir
WORKDIR $USER_HOME

# User
USER $USER_NAME
STOPSIGNAL SIGQUIT

# Start
EXPOSE 9000
CMD ["php-fpm82", "-F"]