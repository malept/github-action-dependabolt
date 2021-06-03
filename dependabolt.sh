#!/bin/sh

set -e

if test -n "$DEPENDABOLT_DEBUG"; then
    set -x
fi

if ! echo "$GITHUB_REF" | grep -q ^refs/heads/dependabot/; then
    if ! echo "$GITHUB_HEAD_REF" | grep -q ^dependabot/; then
        echo 'Not a dependabot branch or PR, skipping'
        exit 0 # Exit with success because the red X looks bad
    fi
fi

if test -z "$DEPENDABOLT_SSH_DEPLOY_KEY"; then
  echo "ERROR: Please set the DEPENDABOLT_SSH_DEPLOY_KEY environment variable." 1>&2
  exit 1
fi

if test -z "$GIT_COMMIT_EMAIL"; then
    GIT_COMMIT_EMAIL="$GITHUB_ACTOR@users.noreply.github.com"
fi

if test -z "$GIT_COMMIT_USER"; then
    GIT_COMMIT_USER="$GITHUB_ACTOR"
fi

if test -n "$GITHUB_HEAD_REF"; then
    git fetch origin "$GITHUB_HEAD_REF"
    git checkout "$GITHUB_HEAD_REF"
    UPSTREAM_BRANCH="$GITHUB_HEAD_REF"
else
    UPSTREAM_BRANCH="$GITHUB_REF"
fi

packageandversion=$(git show --pretty=format: --unified=0 HEAD package.json | grep '^+ ' | sed --regexp-extended --expression 's#^\+ +"(.*)": "(.*)",?#\1@\2#g')

if test -z "$packageandversion"; then
    echo "No upgraded packages found" 1>&2
    exit 0
fi
npx bolt upgrade "$packageandversion"

git add .

if test -n "$(git status -s)"; then
    git config user.name "$GITHUB_ACTOR"
    git config user.email "$GIT_COMMIT_EMAIL"
    git commit $GIT_COMMIT_FLAGS -m "Finish upgrading via bolt"

      mkdir ~/.ssh
      echo "$DEPENDABOLT_SSH_DEPLOY_KEY" > ~/.ssh/deploy_key
      chmod 400 ~/.ssh/deploy_key

      git remote rm origin
      git remote add origin "git@github.com:$GITHUB_REPOSITORY.git"

    GIT_SSH_COMMAND="ssh -i ~/.ssh/deploy_key" git push origin HEAD:$UPSTREAM_BRANCH
else
    echo 'No updates to packages necessary!'
fi
