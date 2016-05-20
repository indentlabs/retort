#!/usr/bin/ruby

require 'net/http'

class Scraper
  attr_reader :client

  def scrape url
    puts "Scraping url: #{url}"

    contents = get(url)
    puts "Scraped #{contents.length} characters."

    chunks = contents.split("\n")
    puts "Chunks: #{chunks.count} (of ~#{contents.length / chunks.count} chars)"

    chunks.each do |chunk|
      puts "Parsing: #{chunk[0, 140]}..."
      parse_ngram(chunk)
    end
  end

  private

  def parse_ngram text
    return if text.nil?

    identifier = ENV['IDENTIFIER']
    channel = ENV['CHANNEL']
    medium = ENV['MEDIUM']

    params = []
    params << "identifier=#{identifier}" if identifier
    params << "channel=#{channel}"       if channel
    params << "medium=#{medium}"         if medium

    uri = URI.parse(URI.escape "http://www.retort.us/bigram/parse?message=#{text}&#{params.join('&')}")
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Get.new(uri.request_uri)
    response = http.request(request)
  rescue
    puts "Error making request to Retort for #{user}: #{text}"
  end

  def get url
    uri = URI.parse(URI.escape url)
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Get.new(uri.request_uri)
    response = http.request(request)
    response.body
#  rescue
#    puts "FAIL getting #{url}"
  end
end

url = ARGV.shift
unless url
  puts "Usage: #{$0} <URL TO .TXT FILE>"
  exit 1
end

ankov = Scraper.new
ankov.scrape url
