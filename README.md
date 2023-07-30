# gh-publicize

A `gh` extension to publish content from source repository into multiple target repositories.

Built on top of [`gruntwork-io/git-xargs`](https://github.com/gruntwork-io/git-xargs/), `gh-publicize` is more
opinionated on how to publish content from a centralized location with specific default behaviors:

1. Use of a centralized source repository to publish content from, whether used
   as a template repository or not
1. Provide helper library for shell scripts to simplify managing content
1. Avoid making changes unless explicitly indicated _(`-r,--run` flag)_
1. Avoid archived repositories unless explicitly indicated _(`-a,--include-archived-repos` flag)_

![High-level overview of gruntwork-io/git-xargs tool for creating pull requests for repositories containing new or updated content](https://github.com/gruntwork-io/git-xargs/raw/master/docs/git-xargs-banner.png)

## Quickstart

1. Download and install [git-xargs](https://github.com/gruntwork-io/git-xargs/)
1. `gh extension install andyfeller/gh-publicize`
1. `gh publicize --repo=<owner>/<repo> <cmd>`
1. `gh publicize --repo=<owner>/<repo> --run <cmd>`
1. Profit! :moneybag: :money_with_wings: :money_mouth_face: :money_with_wings: :moneybag:

## Usage

> **Note**
> `gh-publicize` requires the use of coarse-grained v1 PAT token with `repo` scope.

```shell
Publish content in target repositories from source repository.

USAGE
  gh publicize [flags] --repo=<owner>/<repo> [...] <cmd>
  gh publicize [flags] --repos=<file> <cmd>
  gh publicize [flags] --org=<org> <cmd>

FLAGS
  -a, --include-archived-repos         Whether to include archived repositories
  -c, --cache-dir=<cache-dir>          Name of directory containing preserved data to reuse
  -d, --debug                          Enable debug logging
  -h, --help                           Displays help usage
  -m, --repo=<owner>/<repo>            Target a specific repo, can be passed multiple times to target several repos
  -n, --repos=<file>                   Target multiple repos, file contains <owner>/<repo> entry per line
  -o, --org=<org>                      Target all repos in GitHub organization
  -p, --preserve                       Preserve temporary directory containing data
  -R, --reviewers=<csv-usernames>      Comma-separated list of usernames to review pull request
  -r, --run                            Apply changes; defaults to dryrun
  -s, --source-repo=<owner>/<repo>     Name of source repository to clone
  -t, --source-repo-revision=<rev>     Revision of source repository to checkout; default 'main'

ENVIRONMENT VARIABLES
  PUBLICIZE_HOME                       Path to gh-publicize
  PUBLICIZE_LIB                        Path to gh-publicize/lib
  PUBLICIZE_SOURCE_DIR                 Path to source repository cloned for use
```

### Example of source repository and shell script to use with gh-publicize

When creating a new GitHub repository, there are several common needs that may go overlooked:

1. Adding a [code owners][github-codeowners] file
1. Adding a [code of conduct][github-code of conduct] such as [Contributor Covenant][contributor covenant]
1. Adding a [license][github-license] from [choosealicense.com][choosealicense]
1. Adding a [`.gitignore`][github-gitignore] based upon [gitignore.io][gitignore.io]

One option would be using a [template repository][github-template repository],
except it relies upon people to use it and only supports static content.  This
is where `gh-publicize` can offer a reactive approach using a source repository
and a simple shell script.

- **Source Repository**

  ```shell
  .
  ├── .gitignore
  ├── CODEOWNERS
  ├── CODE_OF_CONDUCT.md
  ├── LICENSE.txt
  └── README.md
  ```

- **Shell Script**

  ```shell
  #! /usr/bin/env bash
  
  # Invoke command(s) and/or script(s) doing work, assuming environment including PWD will be preserved for invoked scripts
  source $PUBLICIZE_LIB/helpers.sh
  
  # Ensure base files every repository needs are there if missing; do not override
  copyMissingFile $PUBLICIZE_SOURCE_DIR ".gitignore"
  copyMissingFile $PUBLICIZE_SOURCE_DIR "CODEOWNERS"
  copyMissingFile $PUBLICIZE_SOURCE_DIR "CODE_OF_CONDUCT.md"
  copyMissingFile $PUBLICIZE_SOURCE_DIR "LICENSE.txt"
  
  # Update repository labels as appropriate
  updateLabels
  ```

In the example above, the source repository contains the base files and it may
be a template repository in fact while the shell script leverages 
[helper functions](lib/helpers.sh) to copy missing files only and update labels.

<details>
  <summary>
    <b>Example of <code>gh publicize</code> output</b>
  </summary>
  <p>
    Running the shell script in dryrun mode:

    ```shell
    $ gh publicize --source-repo=andyfeller/template \
                  --repo=tinyfists/test-1 \
                  --repo=tinyfists/test-2 \
                  /Users/andyfeller/Documents/workspace/andyfeller/template/bin/00-base.sh 
    ```

    resulting in:

    ```shell
    Created temporary directory for caching data:  /var/folders/xb/svzskj1x77x3qsmwx1d84nqc0000gn/T/gh-publicizeXXX.1Po09C0v
    Cloning andyfeller/template, checking out main
    Cloning into '/var/folders/xb/svzskj1x77x3qsmwx1d84nqc0000gn/T/gh-publicizeXXX.1Po09C0v/_source-repo'...
    remote: Enumerating objects: 17, done.
    remote: Counting objects: 100% (17/17), done.
    remote: Compressing objects: 100% (12/12), done.
    Receiving objects: 100% (17/17), 5.64 KiB | 5.64 MiB/s, done.
    Resolving deltas: 100% (3/3), done.
    remote: Total 17 (delta 3), reused 13 (delta 2), pack-reused 0
    Already on 'main'
    Your branch is up to date with 'origin/main'.
    Executing git-xargs command
    [git-xargs] INFO[2023-07-29T01:37:48-04:00] git-xargs running...                         
    [git-xargs] INFO[2023-07-29T01:37:48-04:00] Dry run setting enabled. No local branches will be pushed and no PRs will be opened in Github 
    Processing repos [2/2] ███████████████████████████████████████████████ 100% | 2s

    Git-xargs run summary @ 2023-07-29 05:37:50.471082 +0000 UTC

    • Runtime in seconds: 2
    • Command supplied: [/Users/andyfeller/Documents/workspace/andyfeller/template/bin/00-base.sh]
    • Repo selection method: repo-flag


    All repos that were targeted for processing after filtering missing / malformed repos

    ┌─────────────────────────────────────────────────┐
    | Repo name | Repo URL                            |
    | test-1    | https://github.com/tinyfists/test-1 |
    | ----------------------------------------------- |
    | test-2    | https://github.com/tinyfists/test-2 |
    └─────────────────────────────────────────────────┘

    Repos that were successfully cloned to the local filesystem

    ┌─────────────────────────────────────────────────┐
    | Repo name | Repo URL                            |
    | test-2    | https://github.com/tinyfists/test-2 |
    | ----------------------------------------------- |
    | test-1    | https://github.com/tinyfists/test-1 |
    └─────────────────────────────────────────────────┘

    Repos that showed file changes to their working directory following command execution

    ┌─────────────────────────────────────────────────┐
    | Repo name | Repo URL                            |
    | test-2    | https://github.com/tinyfists/test-2 |
    | ----------------------------------------------- |
    | test-1    | https://github.com/tinyfists/test-1 |
    └─────────────────────────────────────────────────┘

    Repos whose local branch was not pushed because the --dry-run flag was set

    ┌─────────────────────────────────────────────────┐
    | Repo name | Repo URL                            |
    | test-2    | https://github.com/tinyfists/test-2 |
    | ----------------------------------------------- |
    | test-1    | https://github.com/tinyfists/test-1 |
    └─────────────────────────────────────────────────┘

    Repos whose specified branches did not exist on the remote, and so were first created locally

    ┌─────────────────────────────────────────────────┐
    | Repo name | Repo URL                            |
    | test-2    | https://github.com/tinyfists/test-2 |
    | ----------------------------------------------- |
    | test-1    | https://github.com/tinyfists/test-1 |
    └─────────────────────────────────────────────────┘
    ```
  </p>
</details>

<details>
  <summary>
    <b>Example of <code>gh publicize --run</code> output</b>
  </summary>
  <p>
    Running the shell script in run mode:

    ```shell
    $ ./gh publicize --run \
                    --source-repo=andyfeller/template \
                    --repo=tinyfists/test-1 \
                    --repo=tinyfists/test-2 \
                    /Users/andyfeller/Documents/workspace/andyfeller/template/bin/00-base.sh
    ```

    resulting in:

    ```shell
    Created temporary directory for caching data:  /var/folders/xb/svzskj1x77x3qsmwx1d84nqc0000gn/T/gh-publicizeXXX.Uspv6dG3
    Cloning andyfeller/template, checking out main
    Cloning into '/var/folders/xb/svzskj1x77x3qsmwx1d84nqc0000gn/T/gh-publicizeXXX.Uspv6dG3/_source-repo'...
    remote: Enumerating objects: 17, done.
    remote: Counting objects: 100% (17/17), done.
    remote: Compressing objects: 100% (12/12), done.
    remote: Total 17 (delta 3), reused 13 (delta 2), pack-reused 0
    Receiving objects: 100% (17/17), 5.64 KiB | 2.82 MiB/s, done.
    Resolving deltas: 100% (3/3), done.
    Already on 'main'
    Your branch is up to date with 'origin/main'.
    Executing git-xargs command
    [git-xargs] INFO[2023-07-29T01:38:07-04:00] git-xargs running...                         
    Processing repos [2/2] ███████████████████████████████████████████████ 100% | 4s

    Git-xargs run summary @ 2023-07-29 05:38:11.716495 +0000 UTC

    • Runtime in seconds: 4
    • Command supplied: [/Users/andyfeller/Documents/workspace/andyfeller/template/bin/00-base.sh]
    • Repo selection method: repo-flag


    All repos that were targeted for processing after filtering missing / malformed repos

    ┌─────────────────────────────────────────────────┐
    | Repo name | Repo URL                            |
    | test-1    | https://github.com/tinyfists/test-1 |
    | ----------------------------------------------- |
    | test-2    | https://github.com/tinyfists/test-2 |
    └─────────────────────────────────────────────────┘

    Repos that were successfully cloned to the local filesystem

    ┌─────────────────────────────────────────────────┐
    | Repo name | Repo URL                            |
    | test-2    | https://github.com/tinyfists/test-2 |
    | ----------------------------------------------- |
    | test-1    | https://github.com/tinyfists/test-1 |
    └─────────────────────────────────────────────────┘

    Repos that showed file changes to their working directory following command execution

    ┌─────────────────────────────────────────────────┐
    | Repo name | Repo URL                            |
    | test-2    | https://github.com/tinyfists/test-2 |
    | ----------------------------------------------- |
    | test-1    | https://github.com/tinyfists/test-1 |
    └─────────────────────────────────────────────────┘

    Repos whose specified branches did not exist on the remote, and so were first created locally

    ┌─────────────────────────────────────────────────┐
    | Repo name | Repo URL                            |
    | test-2    | https://github.com/tinyfists/test-2 |
    | ----------------------------------------------- |
    | test-1    | https://github.com/tinyfists/test-1 |
    └─────────────────────────────────────────────────┘

    Pull requests opened

    ┌────────────────────────────────────────────────────────┐
    | Repo name | Pull request URL                           |
    | test-2    | https://github.com/tinyfists/test-2/pull/1 |
    | ------------------------------------------------------ |
    | test-1    | https://github.com/tinyfists/test-1/pull/1 |
    └────────────────────────────────────────────────────────┘
    ```
  </p>
</details>

## Setup

Like any other `gh` CLI extension, `gh-publicize` is trivial to install or upgrade and works on most operating systems:

- **Installation**

  ```shell
  gh extension install andyfeller/gh-publicize
  ```
  
  _For more information: [`gh extension install`](https://cli.github.com/manual/gh_extension_install)_

- **Upgrade**

  ```shell
  gh extension upgrade gh-publicize
  ```

  _For more information: [`gh extension upgrade`](https://cli.github.com/manual/gh_extension_upgrade)_

[github-codeowners]: https://docs.github.com/en/github/creating-cloning-and-archiving-repositories/about-code-owners
[github-code of conduct]: https://docs.github.com/en/communities/setting-up-your-project-for-healthy-contributions/adding-a-code-of-conduct-to-your-project
[github-gitignore]: https://docs.github.com/en/get-started/getting-started-with-git/ignoring-files
[gitignore.io]: https://gitignore.io
[github-license]: https://docs.github.com/en/communities/setting-up-your-project-for-healthy-contributions/adding-a-license-to-a-repository
[github-template repository]: https://docs.github.com/en/repositories/creating-and-managing-repositories/creating-a-template-repository
[contributor covenant]: https://www.contributor-covenant.org/
[choosealicense]: https://choosealicense.com/