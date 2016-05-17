#!/usr/bin/ruby

require 'simple-fourchan'

class Scraper
  attr_reader :client

  BOARDS_TO_SCRAPE = %w(
    3 a aco adv an asp b biz c cgl ck co d diy e fa fit g gd
    h his i ic int jp k lgbt lit m mlp mu n news o out p po
    pol qst r r9k s s4s sci soc sp tg toy trv tv u v vp vg vr
    wsg wsr x y
  )

  def feed_retort!
    loop do
      BOARDS_TO_SCRAPE.shuffle.each do |board|
        puts "Scraping board /#{board}/"
        threads_for_board(board).each do |thread|
          puts "\tFetching thread #{thread.thread}"
          comments_for_thread(board, thread.thread).each do |comment|
            puts "\t\tParsing comment #{sanitize comment.com}"
            parse_ngram(board, sanitize(comment.com))
          end
          sleep 5
        end
      end
    end
  end

  private

  def threads_for_board board
    Fourchan::Board.new(board).threads
  end

  def comments_for_thread board, threadid
    Fourchan::Post.new(board, threadid).all
  end

  def sanitize message
    message
      .gsub(/<br[ ]?[\/]?>/, "\n") # Replace <br /> with \n
      .gsub(/&quot;/, '"')         # Replace &quot; with "
      .gsub(/&#44;/, ',')          # Replace &#44; with ,
      .gsub(/&#039;/, "'")         # Replace &#039; with '
      .gsub(/&gt;/, '>')           # Replace &gt; with >
      .gsub(/&lt;/, '<')           # Replace &lt; with <
      .gsub(/<\/?[^>]*>/, ' ')     # Replace all <*> with ' '
  rescue
    puts "SHIT SHIT SHIT #{message} threw exception"
    nil
  end

  def parse_ngram board, text
    return if text.nil?

    uri = URI.parse(URI.escape "http://www.retort.us/bigram/parse?message=#{text}&medium=4chan&channel=#{board}")
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Get.new(uri.request_uri)
    response = http.request(request)
  rescue
    puts "Error making request to Retort for #{user}: #{text}"
  end
end

ankov = Scraper.new
ankov.feed_retort!
