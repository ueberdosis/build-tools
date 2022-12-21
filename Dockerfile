FROM docker:20.10-cli
LABEL maintainer="Patrick Baber <patrick.baber@ueber.io>"

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

# Install Trivy
COPY --from=aquasec/trivy:0.35.0 /usr/local/bin/trivy /usr/local/bin/trivy
RUN chmod +x /usr/local/bin/trivy

# copy ci script
ADD ./ci.sh /usr/local/bin/ci
RUN chmod a+x /usr/local/bin/ci

ENTRYPOINT []
