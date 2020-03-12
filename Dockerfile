FROM docker/compose:debian-1.25.4
LABEL maintainer="Patrick Baber <patrick.baber@ueber.io>"

ENV COMPOSE_INTERACTIVE_NO_CLI "true"
ENV SONAR_SCANNER_VERSION "4.3.0.2102"

# Install essentials
RUN apt-get update && \
    apt-get install -y \
    bash \
    openssl \
    openssh-client \
    rsync \
    sshpass \
    unzip \
    wget

COPY --from=aquasec/trivy:0.5.2 /usr/local/bin/trivy /usr/local/bin/trivy
RUN chmod +x /usr/local/bin/trivy

WORKDIR /opt
RUN wget -q -O /opt/sonar-scanner-cli.zip https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-${SONAR_SCANNER_VERSION}-linux.zip \
    && unzip sonar-scanner-cli.zip \
    && rm sonar-scanner-cli.zip \
    && mv sonar-scanner-${SONAR_SCANNER_VERSION}-linux /usr/local/bin

ENTRYPOINT []