# GitHub Action: Dependabolt

A GitHub Action to make sure all packages in a [`bolt`](http://boltpkg.com/)-managed monorepo are
updated in a Dependabot-generated pull request.

## Environment variables

* `GIT_COMMIT_EMAIL` the email to use when committing to the repository, defaults to the repository
  owner's fake GitHub email.
* `GIT_COMMIT_USER` - `git config user.name`, defaults to the repository owner.
* `GIT_COMMIT_FLAGS` - any extra `git commit` flags to pass, such as `--no-verify`.

## Example workflow

```yaml
name: Dependabolt

on: [create]

jobs:
  dependabolt:
    runs-on: ubuntu-latest
    steps:
    - id: checkout_action
      if: github.event.ref_type == 'branch' && startsWith(github.event.ref, 'dependabot/')
      uses: actions/checkout@v1
    - name: Run dependabolt
      if: success()
      uses: malept/github-action-dependabolt@master
      env:
        GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```
