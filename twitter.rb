#!/usr/bin/ruby

require 'twitter'

class Twitterer
  attr_reader :client

  def initialize
    puts "Initializing Twitter client"
    @client = Twitter::REST::Client.new do |config|
      # @AnthonyKovloski
      config.consumer_key        = ENV['TWITTER_CONSUMER_KEY']
      config.consumer_secret     = ENV['TWITTER_CONSUMER_SECRET']
      config.access_token        = ENV['TWITTER_ACCESS_TOKEN']
      config.access_token_secret = ENV['TWITTER_ACCESS_TOKEN_SECRET']
    end
    puts "Done"
  end

  def feed_retort!
    loop do
      tweets = @client.home_timeline
      tweets.each do |tweet|
        puts "Feeding #{tweet.user.screen_name}'s message: #{tweet.text}"
        parse_ngram(tweet.user.screen_name, tweet.text)
      end
      puts "Resting"
      sleep 60
    end
  end

  private

  def parse_ngram user, text
    uri = URI.parse(URI.escape "http://www.retort.us/bigram/parse?message=#{text}&identifier=#{user}&medium=twitter")
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Get.new(uri.request_uri)
    response = http.request(request)
  rescue
    puts "Error making request to Retort for #{user}: #{text}"
  end
end

ankov = Twitterer.new
ankov.feed_retort!
