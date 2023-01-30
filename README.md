# 🛠️ Build Tools

Docker image with useful CI/CD tools

## Tools included

- bash
- curl
- Docker
- Docker Buildx
- Docker Compose
- git
- openssl
- rsync
- sshpass
- trivy

## Dependencies

Docker

## Getting started

Include the image via the **image** keyword in your `.gitlab-ci.yml`:

```yaml
image: ueberdosis/build-tools
```

## Usage examples

### Run trivy

Adjust the image-name and tag after copying the command to your `.gitlab-ci.yml`.

```yaml
container_scan:
  stage: test
  cache:
    paths:
      - $HOME/.cache/trivy
  except:
    - schedule
  script:
    - |
      trivy --quiet image \
        --severity CRITICAL \
        --ignore-unfixed \
        --exit-code 1 \
        registry.gitlab.com/your-repository-path/your-image-name:your-tag
```

## Contributing

To release a new version on Docker Hub run:

```bash
export VERSION="0.59.0"

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
