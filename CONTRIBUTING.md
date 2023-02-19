# Contributing Guide

Thank you for investing your time in contributing to this project. It's exciting
that so many people are interested in keeping Gitpod self-hosted alive and vibrant.

<!-- toc -->

* [Issues](#issues)
  * [Create a new issue](#create-a-new-issue)
  * [Solve an issue](#solve-an-issue)
* [Making Changes](#making-changes)
* [Commit Your Update](#commit-your-update)
* [Pull Request](#pull-request)
  * [Cloud credentials](#cloud-credentials)

<!-- Regenerate with "pre-commit run -a markdown-toc" -->

<!-- tocstop -->

## Issues

There is an inherent blurring of lines in this project when it comes to issues.
Namely, what is an issue on Gitpod and what is an issue on Self-Hosted?

Please don't submit feature requests or bugs for the Gitpod project itself. Although
I am a [former Gitpodder](https://www.simonemms.com/blog/2023/01/28/i-am-an-ex-podder),
as of January 2023 I am no longer part of the team. Self-hosted used to be an
important part of the Gitpod business model, but was abandoned in December
2022 - the scope of this project is to maintain Gitpod as a self-hosted solution,
not maintaining a fork of Gitpod itself.

Any Gitpod-related issues should be raised on [their GitHub account](https://github.com/gitpod-io/gitpod).

### Create a new issue

If you spot an issue with your Gitpod installation, [search if an issue already exists](https://docs.github.com/en/search-github/searching-on-github/searching-issues-and-pull-requests#search-by-the-title-body-or-comments).
If no issue exists, you can open a new issue via the [form](https://github.com/mrsimonemms/gitpod-self-hosted/issues/new/choose).

### Solve an issue

Look through the [existing issues](https://github.com/mrsimonemms/gitpod-self-hosted/issues)
to find one that interests you. As a general rule, issues won't be assigned to
anyone. Once you're happy with your change, please open a pull request with a
fix.

## Making Changes

It is recommended that all changes are done in [Gitpod](https://www.gitpod.io)
(if you don't use it, why are you here?) as that is the most up-to-date working
environment. A [Devbox](https://www.jetpack.io/devbox) file is also maintained.

## Commit Your Update

Commit the changes once you are happy with them. Please enusre that all commit
messages use the [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0)
format. This makes all messages consistent and will allow for automated
release management in the future (if necessary).

See the [documentation for examples](https://www.conventionalcommits.org/en/v1.0.0/#examples).

## Pull Request

When you're finished with the changes, create a pull request (PR).

As a general rule, it's a good idea to create a draft PR early. This will run
the changes through the CI/CD pipeline (GitHub Actions). It will also flag up
any conflicts so you can fix them early.

Please ensure that an issue exists prior to creating a pull request. This
ensures that the work is desirable to the project and avoids lots of unnecessary
work. Exceptions are made for small, typo-style fixes.

### Cloud credentials

This project is run by an [individual](https://simonemms.com) (not Gitpod) and
I cannot justify the expense in signing up to test multiple cloud providers.

If you're submitting a setup for a new cloud provider, you will need to also submit
credentials for a paid-account for the cloud provider in question (please don't
add your raw keys to the PR).

You can encrypt your keys with my [public GPG key](https://gist.github.com/mrsimonemms/b742ced9016488e84424e5609bbb0e68)
or [contact me](https://simonemms.com/contact) to discuss things further.
