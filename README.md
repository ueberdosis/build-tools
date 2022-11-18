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
- Sonnar Scanner
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
      trivy \
        --quiet \
        --severity CRITICAL \
        --auto-refresh \
        --ignore-unfixed \
        --exit-code 1 \
        registry.gitlab.com/your-repository-path/your-image-name:your-tag
```

### Run Sonar Scanner

Make sure to add an `analysis` stage to your `stages`. Add a scheduled pipeline with the variable `SCHEDULE_ANALYSE` so it will be run on a regular basis. Store your credentials in the environment variables `SONAR_PROJECT_KEY`, `SONAR_HOST` and `SONAR_LOGIN` (**Settings → CI/CD → Variables**).

```yaml
sonarqube:
  stage: analysis
  only:
    variables:
      - $SCHEDULE_ANALYSE
    refs:
      - schedules
  script:
    - |
      sonar-scanner \
        -Dsonar.projectKey=$SONAR_PROJECT_KEY \
        -Dsonar.host.url=$SONAR_HOST \
        -Dsonar.login=$SONAR_LOGIN
```

## Contributing

To release a new version on Docker Hub run:

```bash
export VERSION="0.42.0"
docker-compose build --pull
docker-compose push
```

## License

GNU General Public License v3.0
