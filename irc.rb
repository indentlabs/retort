#!/usr/bin/ruby

require 'cinch'
require 'net/http'
require 'uri'

retort_url = 'http://ea107dce.ngrok.io'

bot = Cinch::Bot.new do
  configure do |c|
    c.nick = "TK"
    c.realname = "TK"
    c.server = "irc.amazdong.com"
    c.channels = [ "#interns" ]
  end

  # Learn from all messages
  on :message, /(.*)/ do |m, message|
    return if message.include? '#noquo'
    puts "[Bigram] Logging: #{message}"

    uri = URI.parse("#{retort_url}/bigram/parse?message=#{message}")
    http = Net::HTTP.new(uri.host, uri.port)

    request = Net::HTTP::Get.new(uri.request_uri)
    response = http.request(request)

    puts "[Bigram] Response #{response.code}: #{response.body}"
  end

  # Respond to messages when mentioned
  on :message, /TK/ do |m, message|
    uri = URI.parse("#{retort_url}/markov/create")
    http = Net::HTTP.new(uri.host, uri.port)

    request = Net::HTTP::Get.new(uri.request_uri)
    response = http.request(request)

    m.reply response.body
  end
end

# Start bot
bot.start
