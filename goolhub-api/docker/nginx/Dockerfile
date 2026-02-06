FROM alpine:3.19
LABEL maintainer="Ganex <suporte@ganex.com.br>"

# Arguments
ARG USER_NAME="nginx"
ARG USER_UID="1000"
ARG GROUP_NAME="nginx"
ARG GROUP_GID="1000"
ARG USER_HOME="/var/lib/nginx/"

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
    apk add tzdata nginx && \
    rm -rf /var/lib/{apt,dpkg,cache,log}/ /tmp/*

# Create app diretory and set permissions
RUN set -ex && \
    chown -R $USER_UID:$GROUP_GID $USER_HOME/ && \
    find $USER_HOME/ -type f -exec chmod 664 {} \; && \
    find $USER_HOME/ -type d -exec chmod 775 {} \;

# Add Application
COPY --from=local/build:latest app/ /app/

# Forward logs to docker
RUN set -ex && \
    ln -sf /dev/stdout /var/log/nginx/access.log && \
    ln -sf /dev/stderr /var/log/nginx/error.log

# Configure correct permissions to user
RUN set -ex && \
    chown -R $USER_NAME:$GROUP_NAME /var/lib/nginx/ && \
    chown -R $USER_NAME:$GROUP_NAME /var/log/nginx

# Workdir
WORKDIR $USER_HOME

# User
USER $USER_NAME

# Expose ports
EXPOSE 8080
STOPSIGNAL SIGQUIT

# Set the default command to run on boot
CMD ["nginx", "-g", "daemon off;"]