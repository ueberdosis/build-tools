# 🛠️ Build Tools

Docker image with useful CI/CD tools optimized for use in GitLab CI pipelines.

## Tools included

- bash
- curl
- Docker
- Docker Buildx
- Docker Compose
- git
- openssl
- regctl
- rsync
- sshpass
- trivy

## Dependencies

Docker

## Getting started

Include the image via the **default.image** keyword in your `.gitlab-ci.yml`:

```yaml
default:
  image: ueberdosis/build-tools:0.63.0
```

## Usage examples

### Run trivy

Adjust the image-name and tag after copying the command to your `.gitlab-ci.yml`.

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
