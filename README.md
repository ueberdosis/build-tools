# Build Tools

Docker image with useful CI/CD tools

## Tools included

- bash
- Docker
- Docker Compose
- git
- openssl
- rsync
- sshpass

## Dependencies

Docker

## Usage

```
docker image build -t ueberdosis/build-tools .
docker container run ueberdosis/build-tools docker version
docker container run ueberdosis/build-tools docker-compose version
docker container run ueberdosis/build-tools git help
```