FROM docker:25.0-cli
LABEL maintainer="Patrick Baber <patrick.baber@ueber.io>"

ENV REGCLIENT_VERSION "0.6.0"

ARG TARGETARCH

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

# Install regctl
RUN if [ "$TARGETARCH" = "arm64" ]; then ARCHITECTURE="linux-arm64"; else ARCHITECTURE="linux-amd64"; fi && \
    wget https://github.com/regclient/regclient/releases/download/v${REGCLIENT_VERSION}/regctl-${ARCHITECTURE} && \
    mv regctl-${ARCHITECTURE} /usr/local/bin/regctl && \
    chmod +x /usr/local/bin/regctl

# Install Trivy
COPY --from=aquasec/trivy:0.50.1 /usr/local/bin/trivy /usr/local/bin/trivy
RUN chmod +x /usr/local/bin/trivy

# copy ci script
ADD ./ci.sh /usr/local/bin/ci
RUN chmod a+x /usr/local/bin/ci

ENTRYPOINT []
