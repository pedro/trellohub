require "rubygems"
require "bundler"

Bundler.require

require "trello"

Trello.configure do |config|
  config.developer_public_key = ENV["TRELLO_OAUTH_KEY"]
  config.member_token = ENV["TRELLO_OAUTH_TOKEN"]
end

board = Trello::Board.find ENV["TRELLO_BOARD_ID"]
board.cards.each do |card|
  github_issues = []
  card.checklists.each do |check|
    github_issues += check.items.select do |item|
      item.name.include?("https://github.com/")
    end
  end
  puts "Card #{card.name} has #{github_issues.size} issues on GH"
end

