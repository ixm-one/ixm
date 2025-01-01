---
title: Automation
order: 1
---

# Automation

This section discusses the automation tooling that IXM uses to keep itself from
bitrotting too quickly.

## Renovate

Mend Renovate is a powerful tool that is used to keep various dependencies up
to date and pinned in a way to prevent users from accidentally upgrading. IXM
relies on Renovate to keep it's documentation tooling and GitHub Actions
workflows up to date. However, Renovate is known to open PRs at an alarmingly
fast rate, and this can become a nuisance for those opening PRs and for those
who might want to *Live At HEAD* with IXM's repository.

For this reason, Renovate commits are only opened on Sunday's after 12PM in the
`America/Los_Angeles` timezone.

## Husky

> [!TIP]
> Move this section to the developer experience.

To help prevent contributors from having to make small typo fixes or similar,
IXM expects developers to setup the [Husky](https://typicode.github.io/husky/)
tool. This tool is vital in reducing mistakes made before applying a commit.

This tool will be installed the first time you run `npm install`.
