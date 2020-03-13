# 🛠️ Build Tools

Docker image with useful CI/CD tools

## Tools included

- bash
- Docker
- Docker Compose
- git
- openssl
- rsync
- Sonnar Scanner
- sshpass
- trivy

## Dependencies

Docker

## Usage

Use specific tag instead of `latest`. See Docker Hub

```
docker container run ueberdosis/build-tools:latest docker version
docker container run ueberdosis/build-tools:latest docker-compose version
docker container run ueberdosis/build-tools:latest git help
docker container run ueberdosis/build-tools:latest sonar-scanner --version
docker container run ueberdosis/build-tools:latest trivy --version
```