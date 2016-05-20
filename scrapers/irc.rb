#!/usr/bin/ruby

require 'cinch'
require 'net/http'
require 'uri'

retort_url = 'http://www.retort.us'

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

    uri = URI.parse("#{retort_url}/bigram/parse?message=#{message}&identifier=#{m.user.nick}&medium=irc.amazdong.com&channel=interns")
    http = Net::HTTP.new(uri.host, uri.port)

    request = Net::HTTP::Get.new(uri.request_uri)
    response = http.request(request)

    puts "[Bigram] Response #{response.code}: #{response.body}"
  end

  on :message, /TK: be ([^ ]+)/ do |m, person|
    puts "Imitating #{person}"

    src = "#{retort_url}/markov/create?identifier=#{person}&medium=irc.amazdong.com&channel=interns"
    puts src
    uri = URI.parse(src)
    http = Net::HTTP.new(uri.host, uri.port)

    request = Net::HTTP::Get.new(uri.request_uri)
    response = http.request(request)

    m.reply response.body
  end

  on :message, /TK: be someone from ([^ ]+)/ do |m, medium|
    puts "Imitating someone from #{medium}"

    src = "#{retort_url}/markov/create?medium=#{medium}"
    puts src
    uri = URI.parse(src)
    http = Net::HTTP.new(uri.host, uri.port)

    request = Net::HTTP::Get.new(uri.request_uri)
    response = http.request(request)

    m.reply response.body
  end

  on :message, /TK: preach to ([^ ]+)/ do |m, recipient|
    puts "Preaching to #{recipient}"

    gospel = "#{retort_url}/markov/create?medium=bible"
    uri = URI.parse(gospel)
    http = Net::HTTP.new(uri.host, uri.port)

    request = Net::HTTP::Get.new(uri.request_uri)
    response = http.request(request)

    m.reply "#{recipient}: #{response.body}"
  end

  # Respond to messages when mentioned
  #on :message, /TK/ do |m, message|
  #  puts "Responding in general"

  #  uri = URI.parse("#{retort_url}/markov/create")
  #  http = Net::HTTP.new(uri.host, uri.port)

  #  request = Net::HTTP::Get.new(uri.request_uri)
  #  response = http.request(request)

  #  m.reply response.body
  #end
end

# Start bot
bot.start
