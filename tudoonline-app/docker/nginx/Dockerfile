FROM alpine:3.17

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

# Install softwares and Configure Logs/Permissions
RUN set -ex && \
    apk update -qq && \
    apk add tzdata nginx && \
    rm -rf /var/lib/{apt,dpkg,cache,log}/ /tmp/* && \
    mkdir -p /app/ && \
    mkdir -p /var/www/html && \
    ln -s /app/ /var/www/html/ && \
    ln -sf /dev/stdout /var/log/nginx/access.log && \
    ln -sf /dev/stderr /var/log/nginx/error.log && \
    chown -R $USER_NAME:$GROUP_NAME /var/lib/nginx/ && \
    chown -R $USER_NAME:$GROUP_NAME /var/log/nginx

# Add Application (Last step to maximize cache of previous layers)
# COPY --chmod is supported by Kaniko >= 1.0.0
COPY --chown=1000:1000 --chmod=775 app/ /app/

# Workdir
WORKDIR $USER_HOME

# User
USER $USER_NAME

# Expose ports
EXPOSE 8080
STOPSIGNAL SIGQUIT

# Set the default command to run on boot
CMD ["nginx", "-g", "daemon off;"]
