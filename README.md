# 🛠️ Build Tools

Docker image with useful CI/CD tools optimized for use in GitLab CI pipelines.

## Tools included

- bash
- curl
- [Docker](https://docs.docker.com/engine/reference/commandline/cli/)
- [Docker Buildx](https://docs.docker.com/build/architecture/#buildx)
- [Docker Compose](https://docs.docker.com/get-started/08_using_compose/)
- git
- openssl
- [regctl](https://github.com/regclient/regclient) (for advanced image handling)
- rsync
- [sshpass](https://www.redhat.com/sysadmin/ssh-automation-sshpass) (for SSH servers with password authentication)
- [trivy](https://aquasecurity.github.io/trivy/v0.45/)

## Dependencies

Docker

## Getting started

Include the image via the **default.image** keyword in your `.gitlab-ci.yml`:

```yaml
default:
  image: ueberdosis/build-tools:0.63.0
```

## Usage examples

### Build images with Docker Compose

Specify `COMPOSE_FILE` if different from the default: `docker-compose.yml`. See [Docker Compose documentation](https://docs.docker.com/compose/compose-file/build/) for more details.

```yaml
build_app:
  variables:
    COMPOSE_FILE: docker-compose.build.yml
  stage: build
  script:
    - docker-compose build app
    - docker-compose push app
```

### Run trivy

Adjust the image-name and tag after copying the command to your `.gitlab-ci.yml`. See [trivy documentation](https://aquasecurity.github.io/trivy/v0.45/docs/target/container_image/) for more details.

```yaml
container_scan:
  script:
    - |
      trivy image \
        --severity HIGH,CRITICAL \
        --ignore-unfixed \
        --exit-code 1 \
        registry.gitlab.com/your-repository-path/your-image-name:your-tag
```

## Contributing

To release a new version on Docker Hub run:

```bash
export VERSION="0.63.0"

# Init buildx
docker buildx create --use

# Build, tag and push
docker buildx build \
  --platform linux/amd64,linux/arm64/v8 \
  --tag ueberdosis/build-tools:$VERSION \
  --push \
  .
```

## License

GNU General Public License v3.0
