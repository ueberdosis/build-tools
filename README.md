# 🛠️ Build Tools

Docker image with useful CI/CD tools

## Tools included

- bash
- curl
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

## Usage of the CI helper script

This images comes with a CI helper script which can do a lot to clean up your `.gitlab-ci.yml` and make it more readable.

### ci init

> The init command logs in to the docker registry and defines which compose file will be used for future docker-compose commands in the current pipeline. It also sets the IMAGE and TAG environment variables if not already set.

**Default usage**:

```yaml
before_script:
  - eval $(ci init)
```

**Using a different compose file**:

By default the script uses the `docker-compose.build.yml` throughout the pipeline. To use another compose file (e.g. `docker-compose.awesome.yml`) pass the name (in this example `awesome`) as an argument: 

```yaml
before_script:
  - eval $(ci init awesome) 
```

To use a different compose file for certain jobs (e.g. testing stages), just run the init command again for this job:

```yaml
unit_tests:
  stage: tests
  before_script:
    - eval $(ci init testing)
  script:
    - echo "Test something!"
```

**Using a different registry**:

By default the script uses the GitLab container registry of the current project. You can specify your own registry with environment variables. Make sure to store secrets in **Settings → CI/CD → Variables**:

```yaml
variables:
  REGISTRY: registry.example.com
  REGISTRY_USER: $PROD_REGISTRY_USER
  REGISTRY_PASSWORD: $PROD_REGISTRY_PASSWORD
```

### ci run

> The run command starts all services from the previously selected compose file and executes the code from stdin.

It also prefixes the service names so concurrent jobs on the same Docker host are not interfering with each other and it can copy files and folders from a running container after the given script is finished. Of course it takes care of automatically stopping and removing containers, networks and volumes as well after your script finished.

**Default usage**:

```yaml
unit_tests:
  stage: tests
  script:
    - |
      ci run << CODE
        docker-compose exec -T php ./vendor/bin/phpunit
      CODE
```

**Concurrency**:

If you want to run multiple instances in the same pipeline, pass a name as argument to the `run` command. This will prefix the resulting container names and allows concurrency:

```yaml
unit_tests:
  stage: tests
  script:
    - |
      ci run unit_tests << CODE
        docker-compose exec -T php ./vendor/bin/phpunit
      CODE
    
browser_tests:
  stage: tests
  script:
    - |
      ci run browser_tests << CODE
        docker-compose exec -T php php artisan dusk
      CODE
```

**Copying files and folder:**

To copy files and folders from a running container to the host machine you can use the `--copy` option by specifying the service name followed by a colon and the path in the container:

```yaml
browser_tests:
  stage: tests
  artifacts:
    when: on_failure
    paths:
      - screenshots
  script:
    - |
      ci run --copy php:/var/www/tests/Browser/screenshots << CODE
        docker-compose exec -T php php artisan:dusk
      CODE
```

The example above will create a new folder named `screenshots` in the current working directory with the contents of `var/www/tests/Browser/screenshots` from inside the `php` container. The copying is done after your script finished, so it can be used for artifacts storage or caching purposes.

### ci down

> The down command stops and deletes running containers, networks and volumes.

If you use the `run` command, invoking this command manually is not required. But it comes in handy for regular cleaning jobs in case someone terminated the pipeline prematurely.

**Default usage:**

```yaml
clean:
  stage: clean
  only:
    - schedules
  script:
   - ci down unit_tests
   - ci down browser_tests
```

### ci ssh

> The ssh command adds the private ssh key stored in SSH_KEY to the ssh-agent and adds the fingerprint from SSH_FINGERPRINT to known_hosts.

Another common task in a pipeline is connecting to a remote host to deploy changes. The ssh command simplifies this process. Put the contents of your private ssh key in **Settings → CI/CD → Variables** as `SSH_KEY` as well as the fingerprint of your host machine as `SSH_FINGERPRINT` and run the ssh command before the rest of your script:

**Default usage:**

```yaml
deploy:
  stage: deploy
  script:
    - ci ssh
    - # deploy your application, e.g.
    - rsync -arz --progress src/ remote-host:/var/www/
```

> The SSH_FINGERPRINT can be retrieved with `ssh-keyscan example.com`.

### ci secrets

> The secrets command writes secrets stored in environment variables to text files and provides a checksum to use it with docker secrets.

Another common task in deployments is to pass secrets from environment variables to docker. A convenient way is to write them to actual text files and use a checksum in the secrets name to keep it up to date. Use the `SECRET_ENV_VARS` variable to define a list of those environment variables. The script will write them to text files: `MYSQL_DATABASE` will be written to `MYSQL_DATABASE.txt`. And it sets those checksum variables for each secret: The checksum of `MYSQL_DATABASE` will be available as `MYSQL_DATABASE_HASH`.

**Default usage:**

```yaml
deploy:
  stage: deploy
  variables:
    SECRET_ENV_VARS: ( "MYSQL_DATABASE" "MYSQL_USER" "MYSQL_PASSWORD" )
  script:
    - ci secrets
    - # deploy your application, e.g.
    - docker stack deploy production
```

A typical compose file can look like this to actually use those secrets:

```yaml
version: "3.7"
services:
  
  database:
    image: mariadb
  environment:
    MYSQL_DATABASE_FILE: /run/secrets/mysql_database
    MYSQL_USER_FILE: /run/secrets/mysql_user
    MYSQL_PASSWORD_FILE: /run/secrets/mysql_password
  secrets:
    - mysql_database
    - mysql_user
    - mysql_password

secrets:
  mysql_database:
    name: mysql_database_${MYSQL_DATABASE_HASH}
    file: MYSQL_DATABASE.txt
  mysql_user:
    name: mysql_user_${MYSQL_USER_HASH}
    file: MYSQL_USER.txt
  mysql_password:
    name: mysql_password_${MYSQL_PASSWORD_HASH}
    file: MYSQL_PASSWORD.txt
```

### customize

By default the container names will be prefixed with project and pipeline id. You can customize this via an environment variable:

```yaml
variables:
  COMPOSE_PROJECT_NAME: your-desired-prefix 
```

If you want to use a compose file with a completely different name, you can specify this via an environment variable too:

```yaml
variables:
  COMPOSE_FILE: awesome-compose-file.yml
```

## License

GNU General Public License v3.0
