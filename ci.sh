 #!/usr/bin/env bash
set -e

# set default compose file and a namespace for the compose project, can be overridden
COMPOSE_FILE_BASE=${COMPOSE_FILE:-"docker-compose.build.yml"}
COMPOSE_PROJECT_NAME_BASE=${COMPOSE_PROJECT_NAME:-"ci-$CI_PROJECT_ID-$CI_PIPELINE_ID"}

# parse command line options
POSITIONAL=()
while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
        -c|--copy)
        COPY="$2"
        shift
        shift
        ;;
        *)
        POSITIONAL+=("$1")
        shift
        ;;
    esac
done
set -- "${POSITIONAL[@]}"

# copy stuff from a container
function copy_from_container() {
    if [ ! -z "$1" ]; then
        CONTAINER_NAME=$(echo $1 | cut -d':' -f 1)
        CONTAINER_PATH=$(echo $1 | cut -d':' -f 2)
        CONTAINER_ID=$(docker-compose ps -q $CONTAINER_NAME)
        docker cp $CONTAINER_ID:$CONTAINER_PATH .
    fi
}

if [ $# -gt 0 ]; then

    # ci init
    # --------------------------------------------------------------------
    # initializes the current job
    # you can overwrite the default compose file by providing an argument.
    if [ "$1" == "init" ]; then
        shift

        # set compose file based on the argument
        if [ ! -z "$1" ]; then
            COMPOSE_FILE_BASE="docker-compose.$1.yml"
            shift
        fi

        # set the compose project name to allow concurrent jobs
        echo "export COMPOSE_FILE=$COMPOSE_FILE_BASE"
        echo "export COMPOSE_PROJECT_NAME=$COMPOSE_PROJECT_NAME_BASE"

        # set default image and tag names
        if [ -z "$IMAGE" ]; then
            echo "export IMAGE=$CI_REGISTRY/$CI_PROJECT_PATH"
        fi
        if [ -z "$TAG" ]; then
            echo "export TAG=build-$CI_COMMIT_REF_SLUG-$CI_COMMIT_SHA"
        fi

        if [ ! -z "$REGISTRY_USER" ]; then
            # if a user specifies a dedicated docker registry, log into it
            docker login -u $REGISTRY_USER -p $REGISTRY_PASSWORD $REGISTRY  &>/dev/null

        elif [ ! -z "$CI_BUILD_TOKEN" ]; then
            # or fall back to gitlabs own registry
            docker login -u gitlab-ci-token -p $CI_BUILD_TOKEN $CI_REGISTRY &>/dev/null
        fi

    # ci run
    # --------------------------------------------------------------------
    # spins up containers and executes the code piped in from stdin.
    # makes sure the containers will be shut down even something fails.
    # to allow concurrency, pass a unique identifier as argument.
    # to copy something from a running container use the copy option
    elif [ "$1" == "run" ]; then
        shift

        # prefix the compose project name with the given argument
        if [ ! -z "$1" ]; then
            export COMPOSE_PROJECT_NAME=$COMPOSE_PROJECT_NAME_BASE-$1
            shift
        fi

        # start containers
        docker-compose up -d --no-build --remove-orphans --quiet-pull
        sleep 5

        # run the code from stdin
        # catch errors, stop containers and copy files from containers
        {
            bash -c "$(cat)"
        } || {
            copy_from_container "$COPY"
            docker-compose down
            exit 1
        }

        # stop containers and copy files from containers
        copy_from_container "$COPY"
        docker-compose down

    # ci down
    # --------------------------------------------------------------------
    # stop containers, pass a unique identifier as argument to stop specific
    # containers
    elif [ "$1" == "down" ]; then
       shift

       if [ ! -z "$1" ]; then
           export COMPOSE_PROJECT_NAME=$COMPOSE_PROJECT_NAME_BASE-$1
           shift
       fi

       docker-compose down

    # ci ssh
    # --------------------------------------------------------------------
    # set ssh key stored in SSH_KEY and add SSH_FINGERPRINT to known_hosts
    elif [ "$1" == "ssh" ]; then
        shift

        if [ -z "$SSH_KEY" ] || [ -z "$SSH_FINGERPRINT" ]; then
            echo "ERROR! SSH_KEY or SSH_FINGERPRINT not set!"
            exit 1
        fi

        mkdir -p ~/.ssh
        chmod 700 ~/.ssh
        echo "$SSH_FINGERPRINT" > ~/.ssh/known_hosts
        chmod 644 ~/.ssh/known_hosts
        echo "$SSH_KEY" > ~/.ssh/id_rsa
        chmod 600 ~/.ssh/id_rsa

    # ci secrets
    # --------------------------------------------------------------------
    # loop through the environment variables given by SECRET_ENV_VARS and save
    # them to files, in order to used them with docker secrets
    elif [ "$1" == "secrets" ]; then

        # define secret env vars that will be hashed and saved to files in order
        # to be used with docker secrets
        SECRET_ENV_VARS=${SECRET_ENV_VARS:-"LARAVEL_ENV,MYSQL_ROOT_PASSWORD,MYSQL_DATABASE,MYSQL_USER,MYSQL_PASSWORD"}

        IFS=',' ; for SECRET_ENV_VAR in `echo "$SECRET_ENV_VARS"`; do
            # save to file
            echo "${!SECRET_ENV_VAR}" > "$SECRET_ENV_VAR.txt"

            # generate hash
            SECRET_ENV_VAR_HASH=$(sha512sum "$SECRET_ENV_VAR.txt" | cut -c1-16)

            # export hash of saved file as env variable
            echo "export ${SECRET_ENV_VAR}_HASH=${SECRET_ENV_VAR_HASH}"
        done

    # ci wait-for
    # --------------------------------------------------------------------
    # wait until the given service is ready
    elif [ "$1" == "wait-for" ]; then
        shift

        COUNTER=0
        CONTAINER=$(docker-compose ps -q $1)
        STATUS="starting"

        while [ "$STATUS" != "healthy" ]; do
            STATUS=$(docker inspect -f {{.State.Health.Status}} $CONTAINER)
            STATE=$(docker inspect -f {{.State.Status}} $CONTAINER)
            sleep 1

            if [ "$STATE" == "exited" ]; then
                docker start $CONTAINER
            fi

            ((COUNTER=COUNTER+1))
            if [ $COUNTER -gt 300 ]; then
                echo "Timeout after waiting for 5 minutes…"
                exit 1
            fi
        done

    # ci git-user
    # --------------------------------------------------------------------
    # get the git user of the last commit
    elif [ "$1" == "git-user" ]; then
        shift

        echo "$(git --no-pager show -s --format='%an' $(git log --format="%H" -n 1))"
    fi
fi
