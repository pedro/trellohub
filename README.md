# TrelloHub

A script to sync checklists in Trello with Github issues.

Also, a serious runner for the Lack of Creativity Naming Rubygems Award, together with baconmocha, file-tail and todo.


## Usage

After setup, you can refer to GitHub issues from any checklist item in a Trello card by simply pasting the issue URL (eg `https://github.com/heroku/heroku-buildpack-ruby/issues/62`).

The script will periodically poll the status of that issue, and mark the item as completed once the issue is closed (or incomplete if the issue is ever reopened).


## Deployment

Sorry, this is not yet a service! For now:

  - Push to a Heroku app
  - Fill in config-vars according to `.env.sample`. You'll need a [Github OAuth token](https://help.github.com/articles/creating-an-oauth-token-for-command-line-use) and a [Trello account key](https://trello.com/1/appKey/generate) with write access to private data (change the scope to `read,write`, consider making it long-lived by setting `expiration=never`.)
  - Configure scheduler to run daily, running `bundle exec ruby trellohub.rb`
