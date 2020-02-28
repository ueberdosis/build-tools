FROM docker/compose:alpine-1.25.4
LABEL maintainer="Patrick Baber <patrick.baber@ueber.io>"

ENV COMPOSE_INTERACTIVE_NO_CLI "true"

# Install essentials
RUN apk add --no-cache \
    bash \
    openssl \
    rsync \
    sshpass

# Install trivy
COPY --from=aquasec/trivy /usr/local/bin/trivy /usr/local/bin/trivy
RUN chmod +x /usr/local/bin/trivy

# Override entrypoint of compose image
ENTRYPOINT []