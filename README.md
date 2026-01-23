# CS 61C: Course Notes

Course notes for CS 61C. A [Jupyter Book 2](https://jupyterbook.org/) project.

## Deployment

This website is currently deployed at <notes.cs61c.org> via Cloudflare pages. If redeployment is needed, follow the below instructions, which assume **a freshly forked copy of this repository, and redeployment to an entirely new Pages project**:

<details>
    
<summary> Redeployment from a fresh repo </summary>

1. GitHub Setup
    1. Go to GitHub organization settings => GitHub Apps => Cloudflare Pages => Configure => Repository Access, and ensure that the app has access to this repository.
2. Create a Pages project in Cloudflare
    1. Login to Cloudflare
        1. If you are doing this for CS61C, please login as the CS61C Cloudflare account and use "CS61C DNS Account" to have access to the DNS records for <cs61c.org>
    2. Go to Workers and Pages => Create Application => Looking to deploy Pages? Get started
    3. Import an existing Git repository => Get Started
    4. Make sure GitHub account is set to whichever organization has this repository
    5. Select a repository => `this repository's name` => Begin Setup
    6. Set the following:
        - Production branch: `main`
        - Framework preset: `None`
        - Build command: `bash build.sh`
        - Build output directory: `_build/html` (see below)
    7. Click Save and Deploy. This should deploy the project. Once it completes, click "Continue to Project".
3. Configure a custom domain in the project
    1. Click "Custom domains" in the top navigation bar of the project
    2. Add a custom domain => enter the desired domain. (e.g. `notes.cs61c.org`
    3. Click "Continue"
    4. Make sure everything looks fine, then click "Activate domain". It may take up to 48 hours to propagate, but based on past experience, it is way faster than that.

</details>

If minor changes are needed, go to the [existing Cloudflare Pages project](https://dash.cloudflare.com/75ae6c7813df14d320647bbf553f2ba0/pages/view/course-notes/settings/production) (must be logged in to the CS61C Cloudflare), select "Settings" and configure as desired.

Cloudflare Pages expects:

- a directory with HTML source to serve as a static site: `_build/html` ([mystmd docs](https://mystmd.org/guide/deployment-github-pages)), and
- a build command that generates that directory: `bash build.sh` wraps `mystmd build` which is installed from the pywrangler config `pyproject.toml`.

## Jupyter Book Setup

* If you have `pip` on your machine, follow the "Install with `pip`" instructions on the [Jupyter Book website](https://jupyterbook.org/stable/get-started/install/).
* Try locally serving the book: `jupyter book start`
* If the above command fails, you may need to try a different installation method---likely because jupyter is incorrectly configured on your machine . If you have `npm`, use that. Otherwise here are the `uv` instructions that work on Mac M1 chips. Create a virtual environment with `uv` and then install via `uv pip`.

```
uv venv
source .venv/bin/activate
uv pip install "jupyter-book>=2.0.0"
uv run --with jupyter jupyter book start # use this syntax for running all jupyter book commands
```