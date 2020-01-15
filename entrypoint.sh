#!/bin/sh

set -e
set -x

if ! echo "$GITHUB_REF" | grep -q ^refs/heads/dependabot/; then
    echo 'Not a dependabot PR, skipping'
    exit 0 # Exit with success because the red X looks bad
fi

if test -z "$INPUT_GITCOMMITEMAIL"; then
    INPUT_GITCOMMITEMAIL="$GITHUB_ACTOR@users.noreply.github.com"
fi

if test -z "$INPUT_GITCOMMITUSER"; then
    INPUT_GITCOMMITUSER="$GITHUB_ACTOR"
fi

packageandversion=$(git show --pretty=format: --unified=0 HEAD package.json | grep '^+ ' | sed --regexp-extended --expression 's#^\+ +"(.*)": "(.*)",?#\1@\2#g')

if test -z "$packageandversion"; then
    echo "No upgraded packages found" 1>&2
    exit 0
fi
npx bolt upgrade "$packageandversion"

git add .
git config user.name "$GITHUB_ACTOR"
git config user.email "$INPUT_GITCOMMITEMAIL"
git commit $INPUT_GITCOMMITFLAGS -m "Finish upgrading via bolt"

if test -n "$DEPENDABOLT_SSH_DEPLOY_KEY"; then
    mkdir ~/.ssh
    echo "$DEPENDABOLT_SSH_DEPLOY_KEY" > ~/.ssh/deploy_key
    chmod 400 ~/.ssh/deploy_key

    git remote rm origin
    git remote add origin "git@github.com:$GITHUB_REPOSITORY.git"
else
    echo "machine github.com login $GITHUB_ACTOR password $GITHUB_TOKEN" > ~/.netrc
    chmod 600 ~/.netrc
fi

GIT_SSH_COMMAND="ssh -i ~/.ssh/deploy_key" git push origin HEAD:$GITHUB_REF
