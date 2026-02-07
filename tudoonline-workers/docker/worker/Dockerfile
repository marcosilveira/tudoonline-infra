FROM alpine:3.15
LABEL maintainer="Ganex <suporte@ganex.com.br>"

# Arguments
ARG USER_NAME="php"
ARG USER_UID="1000"
ARG GROUP_NAME="php"
ARG GROUP_GID="1000"
ARG USER_HOME="/app/"
ARG PHP_EXTENSIONS="php7 php7-mysqlnd php7-mysqli php7-xml php7-opcache php7-pdo php7-pdo_mysql php7-pdo php7-redis php7-bcmath php7-ctype php7-intl php7-xsl php7-sockets php7-json php7-openssl php7-phar php7-zlib php7-mbstring php7-zip php7-gd php7-tokenizer php7-xmlwriter php7-dom php7-curl php7-fileinfo php7-simplexml php7-iconv php7-pcntl php7-xmlreader php7-posix php7-amqp"
ARG WORKERS_ADD="imagemagick ghostscript nano"
ARG NEW_RELIC_AGENT_VERSION="10.10.0.1"

# Environment variables
ENV LANG="pt_BR.UTF-8" \
    LANGUAGE="pt_BR:br" \
    LC_ALL="pt_BR.UTF-8" \
    TZ="America/Sao_Paulo"

# Create a user and group used to launch processes
RUN addgroup -g $GROUP_GID -S $GROUP_NAME && \
    adduser -u $USER_UID -D -S -h $USER_HOME -s /sbin/nologin -G $GROUP_NAME $USER_NAME

# Install softwares
RUN set -ex \
    apk update -qq && \
    # Install curl specific version to application support uri with white spaces
    apk add 'libcurl<7.68' 'curl<7.68' --repository=https://dl-cdn.alpinelinux.org/alpine/v3.10/main && \
    apk add tzdata ca-certificates $WORKERS_ADD $PHP_EXTENSIONS && \
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
    chown -R $USER_UID:$GROUP_GID /etc/php7/ && \
    mkdir -p /var/lib/php/session/ && \
    chown -R $USER_UID:$GROUP_GID /var/lib/php/session && \
    chmod 770 /var/lib/php/session/

# Add Application
COPY app/ $USER_HOME

# Create app diretory and set permissions
RUN set -ex && \
    chown -R 1000:1000 $USER_HOME && \
    find $USER_HOME -type f -exec chmod 664 {} \; && \
    find $USER_HOME -type d -exec chmod 775 {} \; && \
    mkdir -p /var/www/html && \
    ln -s $USER_HOME /var/www/html/

# Workdir
WORKDIR $USER_HOME

# User
# Install SSH Server for VPS Access
# Install SSH Server for VPS Access
# Install SSH Server for VPS Access
RUN sed -i 's/dl-cdn.alpinelinux.org/dl-4.alpinelinux.org/g' /etc/apk/repositories && \
    apk update && apk add --no-cache openssh \
    && mkdir /root/.ssh \
    && chmod 700 /root/.ssh \
    && ssh-keygen -A \
    && sed -i 's/#PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config \
    && echo "PermitRootLogin yes" >> /etc/ssh/sshd_config \
    && echo "root:tudoonline" | chpasswd

# User (Commented out to allow running as root for SSHD)
# USER $USER_NAME
STOPSIGNAL SIGQUIT

# Start
ENTRYPOINT ["/bin/sh", "-c"]