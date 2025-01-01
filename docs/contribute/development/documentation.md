---
title: Documentation
order: 2
---

# Documentation

IXM's documentation is written using the [vitepress](https://vitepress.dev)
static site generator. While other generators (such as `hugo`) might be faster,
or produce smaller output, vitepress happens to have the most complete set of
features (including a default theme) out of the box, with the easiest ability
to customize output.

Vitepress is installable via `npm` and other NodeJS tooling, which allows us to
keep the actual files necessary to build the documentation located within the
IXM repository. Additionally, markdown files are kept fairly readable, allowing
for offline viewing if NodeJS cannot be used in a local environment.

## Building Locally

Build the documentation locally requires a recent NodeJS LTS release.
Additionally, the `node` and `npm` commands should be on your system `PATH`
environment variables.

To build the documentation:

1. Navigate your terminal to the root of the IXM repository
2. Run `npm ci` to install `vitepress` and other tools that will help you work
   locally. The `ci` command will pull packages based on the
   `package-lock.json` file.
3. Start the development server by running `npm run docs:dev`.

This set of commands will be enough to get any user up and running quickly.
Additional steps are needed before opening a [Pull Request](./pull-requests).
