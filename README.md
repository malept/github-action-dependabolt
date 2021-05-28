# GitHub Action: Dependabolt

A GitHub Action to make sure all packages in a [`bolt`](http://boltpkg.com/)-managed monorepo are
updated in a Dependabot-generated pull request.

## Inputs

* `gitCommitEmail`: The email to use when committing to the repository, defaults to the repository
  owner's fake GitHub email.
* `gitCommitFlags`: Any extra `git commit` flags to pass, such as `--no-verify`.
* `gitCommitUser`: The value to set `git config user.name`, defaults to the repository owner.

## Secrets used

This action uses an SSH deploy key with write permissions to push the commit back up to the repository.
Specify `DEPENDABOLT_SSH_DEPLOY_KEY` in the repository secrets (the private key).

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
    - name: Install Node.js
    - uses: actions/setup-node@v2
      with:
        node-version: 14.x
    - name: Run dependabolt
      uses: malept/github-action-dependabolt@main
      with:
        gitCommitUser: Dependabolt Bot
      env:
        DEPENDABOLT_SSH_DEPLOY_KEY: ${{ secrets.DEPENDABOLT_SSH_DEPLOY_KEY }}
```

In a production setting, `main` should be a tagged version (e.g., `v1.0.0`).

## Debugging

If you need to debug the action, you can set the `DEPENDABOLT_DEBUG` environment
variable, which sets `-x` in the shell script.
