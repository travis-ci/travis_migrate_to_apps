Migrate your GitHub organizations to use the Travis CI GitHub App integration

Travis CI will now be a unified platform with only one site: https://travis-ci.com.

This change uses a new GitHub integration mechanism underneath: GitHub Apps instead of GitHub Services. The main difference is that you will now give Travis CI access to your repositories on a repository basis instead of giving it access to all of them.

Hence, we have developped this gem to help you migrate your currently active repositories in one sweep rather than having to add them manually one by one in the GitHub UI.

Here are the steps:

1) Install the gem
```
gem install ravis_migrate_to_apps
```

2) Generate a GitHub personal access token with repo scope

Goto https://github.com/settings/tokens
Generate new token
https://github.com/settings/tokens/new
FIXME: add screenshot
Click the "Generate token" button at the bottom

Note: if you are migrating an organization, the token must be generated by an owner of the organization. https://help.github.com/articles/permission-levels-for-an-organization/

3) Activate the Travis CI GitHub Apps integration with 1 repo

Goto https://travis-ci.com/profile
Click the "Activate GitHub Apps Integration"
FIXME: add screenshot from GitHub
You'll be redirected to your profile page on Travis CI
FIXME: add screenshot from Travis CI

4) Fetch your Travis CI api token

2 ways:

a. On your profile page: https://travis-ci.com/profile

b. Via the Travis CI CLI: travis token --pro

5) Run the gem

travis_migrate_to_apps [owner_name] [travis_access_token] [github_access_token]

where 

[owner_name] is the GitHub account (user or organization) where the repositories are located
[travis_access_token] is the Travis CI token obtained in step #4 above
[github_access_token] is the GitHub token obtained in step #2 above

Happy migration!
