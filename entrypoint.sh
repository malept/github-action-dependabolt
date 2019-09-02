#!/bin/sh

set +e
set +x

if test -z "$GIT_COMMIT_EMAIL"; then
    GIT_COMMIT_EMAIL="$GITHUB_ACTOR@noreply.users.github.com"
fi

if test -z "$GIT_COMMIT_USER"; then
    GIT_COMMIT_USER="$GITHUB_ACTOR"
fi

packageandversion=$(git show --pretty=format: --unified=0 HEAD package.json | grep '^+ ' | sed --regexp-extended --expression 's#^\+ +"(.*)": "(.*)",?#\1@\2#g')

npx bolt upgrade "$packageandversion"

echo "machine github.com login $GITHUB_ACTOR password $GITHUB_TOKEN" > ~/.netrc
chmod 600 ~/.netrc

git add .
git config user.name "$GITHUB_ACTOR"
git config user.email "$GIT_COMMIT_EMAIL"
git commit $GIT_COMMIT_FLAGS -m "Finish upgrading via bolt"
git push
