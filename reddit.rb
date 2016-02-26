#!/usr/bin/ruby

require 'net/http'
require 'uri'
require 'json'
require 'redd'

class Redditor
  attr_reader :reddit

  def initialize
    puts "Initializing reddit client"
    @reddit = Redd.it(:script, "H3o8S_X6B0WYzg", "VKhDeFb95MNkusqz539h9XcoNfk", "not_gabe_2", "not_gabe_2", user_agent: "Abe Newman v1.0.0 by /u/ghost_of_drusepth")
    reddit.authorize!
    puts "Done"
  end

  def spread_hope!
    begin
      puts "Spreading hope!"
      stream_all!
    rescue Redd::Error::RateLimited => error
      sleep(error.time)
      retry
    rescue Redd::Error => error
      # 5-something errors are usually errors on reddit's end.
      raise error unless (500...600).include?(error.code)
      retry
    end
  end

  private

  def stream_all!
    reddit.stream :get_comments, "all" do |comment|
      puts "nom nom nom ~"

      # FEED RETORT
      begin
        uri = URI.parse("http://indent-retort.herokuapp.com/bigram/parse?message=#{comment.body}")
        http = Net::HTTP.new(uri.host, uri.port)
        request = Net::HTTP::Get.new(uri.request_uri)
        response = http.request(request)
        puts "Fed Retort"
      rescue
        puts "some retort error, dunno lol"
        # eh
      end
    end
  end
end

gabe = Redditor.new
gabe.spread_hope!
