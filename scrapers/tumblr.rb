#!/usr/bin/ruby

require 'tumblr_client'

class Tumblrer
  attr_reader :client

  def initialize
    puts "Initializing Tumblr client"
    Tumblr.configure do |config|
      config.consumer_key       = "R8dfrUYX2HesfwTXZGYNGz2aJcI0aV0VVEkIm25vBmUxxX3Q7R"
      config.consumer_secret    = "zTKtMhMrCbkBTBJJEZPy0RtFJicgUNv84n4UxuTOtpR1DGC8F7"
      config.oauth_token        = "UYWPx7w6DRR5ga7zyVKXKj4ws5wQERTOunutAX9Nq7gpsNAD0j"
      config.oauth_token_secret = "a2ODh44u26v6zf8nOEJpQ5TTEkIx4DkXkamVf8GJoM1GKKPWqE"
    end
    @client = Tumblr::Client.new
    puts "Done"
  end

  def feed_retort!
    loop do
      @client.dashboard["posts"].each do |post|
        text = sanitize(post['body'] || post['caption'])
        puts "Scraping #{post['blog_name']}'s text of length #{text.length}: #{text[0, 140]}"
        parse_ngram(post['blog_name'], text) if text.length > 0
      end

      puts "Sleeping"
      sleep 30
    end
  end

  private

  def parse_ngram channel, text
    uri = URI.parse(URI.escape "http://www.retort.us/bigram/parse?message=#{text}&channel=#{channel}&medium=tumblr")
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Get.new(uri.request_uri)
    response = http.request(request)
  rescue
    puts "Error making request to Retort for blog #{channel}: #{text}"
  end

  def sanitize message
    return '' unless message
    message
      .gsub('&rsquo;', "'")
      .gsub('&lsquo;', "'")
      .gsub('&rdquo;', '"')
      .gsub('&ldquo;', '"')
      .gsub('“', '"')
      .gsub('”', '"')
      .gsub('…', '...')
      .gsub(%r{</?[^>]+?>}, ' ')   # Replace all HTML tags with a space
      .strip                       # Remove leading and ending spaces
  rescue
    puts "SHIT SHIT SHIT #{message} threw exception"
    nil
  end
end

ankov = Tumblrer.new
ankov.feed_retort!
