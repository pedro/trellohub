require "rubygems"
require "bundler"

Bundler.require

require "trello"

module Trello
  class Item < BasicData
    register_attributes :id, :name, :state, :type, :readonly => [ :id, :name, :state, :type ]
    validates_presence_of :id, :type

    # Updates the fields of an item.
    #
    # Supply a hash of string keyed data retrieved from the Trello API representing
    # an item.
    def update_fields(fields)
      attributes[:id]    = fields['id']
      attributes[:name]  = fields['name']
      attributes[:state] = fields['state']
      attributes[:type]  = fields['type']
      self
    end

    def closed?
      attributes[:state] == "complete"
    end
  end

  class Card
    def update_checklist_item_state(list_id, item_id, state)
      client.put("/cards/#{id}/checklist/#{list_id}/checkItem/#{item_id}/state", { :value => state })
    end
  end
end

Trello.configure do |config|
  config.developer_public_key = ENV["TRELLO_OAUTH_KEY"]
  config.member_token = ENV["TRELLO_OAUTH_TOKEN"]
end

class GithubIssue
  def self.from_trello(card, list, item)
    return unless item.name.include?("https://github.com/")
    new(card, list, item)
  end

  def self.github
    @@github ||= Github.new oauth_token: ENV["GITHUB_TOKEN"]
  end

  attr_accessor :card, :list, :item

  def initialize(card, list, item)
    @card = card
    @list = list
    @item = item
    parse_project
  end

  def parse_project
    match = item.name.match(/github.com\/(.*)\/(.*)\/issues\/(\d+)/)
    return unless match
    @github_user, @github_repo, @github_issue = match[1..4]
  end

  def closed?
    issue = self.class.github.issues.find(@github_user, @github_repo, @github_issue)
    issue.state != "open"
  end
end

board = Trello::Board.find ENV["TRELLO_BOARD_ID"]
board.cards.each do |card|
  github_issues = []
  card.checklists.each do |list|
    github_issues += list.items.map do |item|
      GithubIssue.from_trello(card, list, item)
    end.compact
  end

  puts "Card #{card.name} has #{github_issues.size} issues on GH"
  github_issues.each do |issue|
    if issue.closed? && !issue.item.closed?
      puts "issue closed on github - closing in trello"
      issue.card.update_checklist_item_state(issue.list.id, issue.item.id, "complete")
    elsif !issue.closed? && issue.item.closed?
      puts "issue open in github - reopening in trello"
      issue.card.update_checklist_item_state(issue.list.id, issue.item.id, "incomplete")
    end
  end
end

