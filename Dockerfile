FROM docker/compose:alpine-1.25.4
LABEL maintainer="Patrick Baber <patrick.baber@ueber.io>"

ENV COMPOSE_INTERACTIVE_NO_CLI "true"

# Install essentials
RUN apk add --no-cache \
    bash \
    openssl \
    openssh-client \
    rsync \
    sshpass \
    unzip \
    wget

ENTRYPOINT []