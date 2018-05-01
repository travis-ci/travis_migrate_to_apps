# Migrate your GitHub organizations to use the Travis CI GitHub App integration

This gem will help you migrate the repositories you have on [https://travis-ci.com](travis-ci.com) from legacy [GitHub Services](https://developer.github.com/v3/guides/replacing-github-services/) integration to the new [GitHub Apps](https://developer.github.com/apps/) integration.

The main difference is that you will now give Travis CI access to your repositories on a repository basis instead of giving it access to all of them.

Hence, we have developped this gem to help you migrate your repositories that are currently active on Travis CI in one sweep rather than having to add them manually one by one in the GitHub UI.

Here are the steps:

## 1. Install the gem
```
gem install travis_migrate_to_apps
```

## 2. Generate a GitHub personal access token with repo scope

You can generate new GitHub token [here](https://github.com/settings/tokens/new).

Choose the name of your liking and ensure to select the whole `repo` scope as shown below:

![GitHub new token page](https://github.com/travis-ci/travis_migrate_to_apps/blob/assets/github-token-new.png)

Then click the "Generate token" button at the bottom to generate the token.

You'll then be back on the GitHub token page:

![GitHub token page](https://github.com/travis-ci/travis_migrate_to_apps/blob/assets/github-token-added.png)

Take care of copying the newly generated token and save it for later usage.

**Note: if you are migrating an organization, the token must be generated by [an owner of the GitHub organization](https://help.github.com/articles/permission-levels-for-an-organization/).**

## 3. Activate the Travis CI GitHub Apps integration with 1 repo

Go to your profile page on Travis CI: https://travis-ci.com/profile

Click the "Activate GitHub Apps Integration" button highlighted below:

![Activate GitHub Apps Integration button](https://github.com/travis-ci/travis_migrate_to_apps/blob/assets/github-apps-button-on-profile-page.png)

You'll directed to the GitHub Apps page for the Travis CI app:

![GitHub Apps page](https://github.com/travis-ci/travis_migrate_to_apps/blob/assets/travis-ci-github-app.png)

Choose at least one repository and click the "Approve & Install" button.

You'll then be redirected to your profile page on Travis CI and the newly added repository should appear under "GitHub Apps Integration":

![Travis CI profile page](https://github.com/travis-ci/travis_migrate_to_apps/blob/assets/travis-ci-profile-with-github-apps-integration.png)

## 4. Get your Travis CI API token

There's two ways you can get this token:

1. On your profile page: https://travis-ci.com/profile

![Travis CI token on profile page](https://github.com/travis-ci/travis_migrate_to_apps/blob/assets/travis-ci-token-profile-page.png)

1. Via the [Travis CI client](https://github.com/travis-ci/travis.rb) by running: `travis token --pro`

## 5. Run the gem

```
travis_migrate_to_apps [owner_name] [travis_access_token] [github_access_token]
```

where 

- `[owner_name]` is the GitHub account (user or organization) where the repositories you want to migrate are located
- `[travis_access_token]` is the Travis CI token obtained in step #4 above
- `[github_access_token]` is the GitHub token obtained in step #2 above

Happy migration!
