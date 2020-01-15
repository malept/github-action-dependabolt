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

npx bolt upgrade "$packageandversion"

echo "machine github.com login $GITHUB_ACTOR password $GITHUB_TOKEN" > ~/.netrc
chmod 600 ~/.netrc

git add .
git config user.name "$GITHUB_ACTOR"
git config user.email "$INPUT_GITCOMMITEMAIL"
git commit $INPUT_GITCOMMITFLAGS -m "Finish upgrading via bolt"
git push origin HEAD:$GITHUB_REF
