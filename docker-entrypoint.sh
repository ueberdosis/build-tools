#!/bin/bash

# if [ -z ${BRANCH+x} ] && [ ! -z ${CI_COMMIT_REF_SLUG+x} ]
# then
#     export BRANCH="$CI_COMMIT_REF_SLUG";
# fi

# if [ -z ${REGISTRY+x} ] && [ ! -z ${CI_REGISTRY+x} ] && [ ! -z ${CI_PROJECT_PATH+x} ]
# then
#     export REGISTRY="$CI_REGISTRY/$CI_PROJECT_PATH";
# fi

# if [ -z ${COMMIT+x} ] && [ ! -z ${CI_COMMIT_SHA+x} ]
# then
#     export COMMIT="$CI_COMMIT_SHA";
# fi

$@