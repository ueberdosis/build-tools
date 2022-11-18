FROM docker/compose:alpine-1.29.2
LABEL maintainer="Patrick Baber <patrick.baber@ueber.io>"

ENV COMPOSE_INTERACTIVE_NO_CLI "true"
ENV BUILDX_VERSION "0.9.1"

# Install essentials
RUN apk add --no-cache \
    bash \
    curl \
    gettext \
    git \
    jq \
    openssh-client \
    openssl \
    rsync \
    sshpass \
    unzip \
    wget

# Install Docker Buildx
RUN mkdir -p /usr/local/libexec/docker/cli-plugins && \
    wget -O /usr/local/libexec/docker/cli-plugins/docker-buildx \
    https://github.com/docker/buildx/releases/download/v${BUILDX_VERSION}/buildx-v${BUILDX_VERSION}.linux-amd64 && \
    chmod +x /usr/local/libexec/docker/cli-plugins/docker-buildx

# Install Trivy
COPY --from=aquasec/trivy:0.29.0 /usr/local/bin/trivy /usr/local/bin/trivy
RUN chmod +x /usr/local/bin/trivy

# copy ci script
ADD ./ci.sh /usr/local/bin/ci
RUN chmod a+x /usr/local/bin/ci

ENTRYPOINT []
