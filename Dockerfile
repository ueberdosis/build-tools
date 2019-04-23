FROM docker/compose:1.24.0

# Install essentials
RUN apk add --no-cache \
    git \
    openssh-client \
    openssl \
    rsync \
    sshpass

ENTRYPOINT []
