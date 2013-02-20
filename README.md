# TrelloHub

A script to sync checklists in Trello with Github issues.


## Usage

After setup, you can refer to GitHub issues from any checklist item in a Trello card by simply pasting the issue URL (eg `https://github.com/heroku/heroku-buildpack-ruby/issues/62`).

The script will periodically poll the status of that issue, and mark the item as completed once the issue is closed (or incomplete if the issue is ever reopened).


## Deployment

Sorry, this is not yet a service! For now:

  - Push to a Heroku app
  - Add config vars
  - Configure scheduler to run daily, running `bundle exec ruby trellohub.rb`
