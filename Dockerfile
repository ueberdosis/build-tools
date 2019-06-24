FROM docker:git

ENV DOCKER_COMPOSE_VERSION "1.24.1"
ENV COMPOSE_INTERACTIVE_NO_CLI "true"

# Install essentials
RUN apk add --no-cache \
    bash \
    openssl \
    rsync \
    sshpass

# Install Docker Compose
RUN apk add --no-cache \
    gcc \
    libc-dev \
    make \
    openssl-dev \
    py-pip \
    python-dev \
    libffi-dev \
    && \
    pip install --no-cache-dir docker-compose==${DOCKER_COMPOSE_VERSION}

ENTRYPOINT []