# GitHub Action: Dependabolt

A GitHub Action to make sure all packages in a [`bolt`](http://boltpkg.com/)-managed monorepo are
updated in a Dependabot-generated pull request.

## Inputs

* `gitCommitEmail`: The email to use when committing to the repository, defaults to the repository
  owner's fake GitHub email.
* `gitCommitFlags`: Any extra `git commit` flags to pass, such as `--no-verify`.
* `gitCommitUser`: The value to set `git config user.name`, defaults to the repository owner.

## Secrets used

This action uses one of two methods to push the commit back up to the repository:

* If `DEPENDABOLT_SSH_DEPLOY_KEY` is specified in the repository secrets, it is used to push the
  commit back to the repository's SSH endpoint.
* Otherwise, `GITHUB_TOKEN` is used to push the commit back to the repository's HTTPS endpoint. This
  currently only works with private repositories. See the [GitHub Actions forum post](https://github.community/t5/GitHub-Actions/Github-action-not-triggering-gh-pages-upon-push/td-p/26869) for details.

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
      uses: malept/github-action-dependabolt@master
      with:
        gitCommitUser: Dependabolt Bot
      env:
        GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

In a production setting, `master` should be a tagged version (e.g., `v1.0.0`).

## Docker Hub

Alternatively, `uses` can be `docker://malept/gha-dependabolt:VERSION` where VERSION is `latest`
(same as `master`) or a tagged version, minus the leading `v` (example:
`docker://malept/gha-dependabolt:1.0.0`). This can speed up your workflow.
