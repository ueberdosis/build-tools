FROM docker/compose:alpine-1.26.2
LABEL maintainer="Patrick Baber <patrick.baber@ueber.io>"

ENV COMPOSE_INTERACTIVE_NO_CLI "true"
ENV SONAR_SCANNER_VERSION "4.3.0.2102"

# Install essentials
RUN apk add --no-cache \
    bash \
    git \
    openssl \
    openssh-client \
    rsync \
    sshpass \
    unzip \
    wget

# Install Trivy
COPY --from=aquasec/trivy:0.10.1 /usr/local/bin/trivy /usr/local/bin/trivy
RUN chmod +x /usr/local/bin/trivy

# Install SonarScanner
ADD https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-${SONAR_SCANNER_VERSION}.zip /usr/src/sonar-scanner.zip
RUN apk add --no-cache \
    bash \
    nodejs \
    openjdk8-jre \
    && \
    cd /usr/src && unzip sonar-scanner.zip && \
    mv -fv /usr/src/sonar-scanner-${SONAR_SCANNER_VERSION}/bin/sonar-scanner /usr/bin && \
    chmod a+x /usr/bin/sonar-scanner && \
    mv -fv /usr/src/sonar-scanner-${SONAR_SCANNER_VERSION}/lib/* /usr/lib && \
    rm -rf /usr/src/*

ENTRYPOINT []