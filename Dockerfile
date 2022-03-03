FROM docker/compose:alpine-1.29.2
LABEL maintainer="Patrick Baber <patrick.baber@ueber.io>"

ENV COMPOSE_INTERACTIVE_NO_CLI "true"
ENV SONAR_SCANNER_VERSION "4.6.2.2472"

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
COPY --from=aquasec/trivy:0.24.2 /usr/local/bin/trivy /usr/local/bin/trivy
RUN chmod +x /usr/local/bin/trivy

# Install SonarScanner
ADD https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-${SONAR_SCANNER_VERSION}.zip /usr/src/sonar-scanner.zip
RUN apk add --no-cache \
    bash \
    nodejs \
    openjdk11-jre \
    && \
    cd /usr/src && unzip sonar-scanner.zip && \
    mv -fv /usr/src/sonar-scanner-${SONAR_SCANNER_VERSION}/bin/sonar-scanner /usr/bin && \
    chmod a+x /usr/bin/sonar-scanner && \
    mv -fv /usr/src/sonar-scanner-${SONAR_SCANNER_VERSION}/lib/* /usr/lib && \
    rm -rf /usr/src/*

# copy ci script
ADD ./ci.sh /usr/local/bin/ci
RUN chmod a+x /usr/local/bin/ci

ENTRYPOINT []
