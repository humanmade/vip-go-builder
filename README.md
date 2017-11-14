<table width="100%">
	<tr>
		<td align="left" width="70">
			<strong>VIP Go Builder</strong><br />
			Build JS and CSS on VIP Go projects.
		</td>
		<td align="right" width="20%">
			<a href="https://travis-ci.org/humanmade/vip-go-builder">
				<img src="https://circleci.com/gh/humanmade/vip-go-builder.svg?style=svg" alt="Build status">
			</a>
		</td>
	</tr>
	<tr>
		<td>
			A <strong><a href="https://hmn.md/">Human Made</a></strong> project. Maintained by @rmccue.
		</td>
		<td align="center">
			<img src="https://hmn.md/content/themes/hmnmd/assets/images/hm-logo.svg" width="100" />
		</td>
	</tr>
</table>

This repository handles a build process for WordPress.com VIP Go, wherein the source code for the site lives on the `master` branch (for production), and a built version is committed to `master-built` (ditto for other environments).

Curious as to what the result looks like? This repo builds itself, check out the [master-built branch](https://github.com/humanmade/vip-go-builder/commits/master-built).

**Note:** Before using this tool, confirm the use of this deployment process with VIP.


## Setup

### Adding to your repo

To set up the builder for your repo, copy the `.circleci` directory from this repo into your VIP Go deployment repository.

You'll need to set up the build steps for your repository specifically. Edit the `.circleci/config.yml` file and add lines to the `steps` section as documented in the file.

For example, for a standard React build with production (`master`) and development (`develop`) environments, your steps should look like this:

```yaml
version: 2
jobs:
  build:
    docker:
      - image: circleci/node:6.11-stretch

    branches:
      only:
        # Production
        - master

        # Development
        - develop

    steps:
      - checkout

      # Install dependencies...
      - run: npm install

      # ...and run the React build
      - run: npm run build

      - deploy:
          command: .circleci/deploy.sh
```


### Enabling CircleCI

You'll need a machine user to create builds and deploy:

* **Human Made**: Use the `humanmade-travis` user.

* **Other Organisations**: You'll need your own GitHub machine user. If you don't already have one of these, create a new Github user with an obvious name (e.g. `myagency-buildbot`).

Once you have your machine user and private key ready, set up Circle for your VIP Go repository:

1. Ask the VIP team to add your **machine user** to the repository with **write access**, and **you with admin access** (you'll need this temporarily to enable CircleCI on the repository)
1. Once you have been added, log into CircleCI using your regular user
1. Enable CircleCI for the repository (you will no longer need admin access after this step)
2. Log out, and log into CircleCI using your GitHub machine user
3. "Follow" the relevant repository on CircleCI
4. Go to the Project Settings page for the project on CircleCI (Settings in top-right corner of the repo's page)
5. Go to the "Checkout SSH keys" page
6. Click "Authorize with GitHub" - If prompted, accept raised permissions for CircleCI
7. Click "Create and add {user} user key"
8. Remove the (now redundant) deploy key


### Configuring Builds

You can configure the build commits by setting environment variables for your build (Project Settings > Environment Variables):

* `DEPLOY_SUFFIX`

  Suffix for branch names.

  Defaults to `-built` (i.e. `master` is deployed to `master-built`).

* `DEPLOY_GIT_NAME`

  Git author name.

  Defaults to `CircleCI`.

* `DEPLOY_GIT_EMAIL`

  Git author email.

  Defaults to `ryan+circle-vip-go@hmn.md`.

You can also configure which files to exclude from the built branch using the `deploy-exclude.txt` file.
