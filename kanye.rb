require 'httparty'
require 'rhymes'

require 'pry'

rhyme_scheme = 'ABAB CDCD EFEF GG'
rhymes = {}
rap_lines = []

def previous_word after
  url = "http://www.retort.us/bigram/prior?after=#{after}&channel=music&identity=kanyewest&channel=lyrics"
  json = JSON.parse(HTTParty.get(url).body)

  puts "#{json['prior']} --> #{after}"

  json["prior"]
rescue
  puts "No words found prior to #{after}"
  nil
end

def full_line
  url = "http://www.retort.us/markov/create?channel=music&identity=kanyewest&channel=lyrics"
  HTTParty.get(url).body
end

def rhymes_for word
  Rhymes.rhyme(word.gsub /\W+/, '').map(&:downcase)
rescue Rhymes::UnknownWord
  []
end

# First line is random
first_line = full_line

rhyme_scheme.chars.each do |rhyme|
  # Add breaks between verses
  rap_lines.concat [''] if rhyme == ' '

  # If we're on a line without a previous rhyme, generate a random line
  if rhymes.key?(rhyme) == false
    line = full_line

    # And set the final word of the line as the word to rhyme with in the future
    rhymes[rhyme] = line.split(' ').last

  # If we're on a line WITH a previous rhyme, we want to ask for rhyming words and build back from there
  else
    rhyming_words = rhymes_for rhymes[rhyme]
    puts "Rhyming words for #{rhymes[rhyme]}: #{rhyming_words}"

    # Then, go through each word and try to find one we can build backwards from
    line = []
    rhyming_words.shuffle.each do |potential_rhyme|
      puts "Looking for rhymes for #{potential_rhyme}..."
      previous_word_for_this_rhyme = previous_word(potential_rhyme)
      if previous_word_for_this_rhyme
        # If we find a word to use, set it and break to ignore the other rhyming words
        line = [previous_word_for_this_rhyme, potential_rhyme]
        break
      end
    end

    # Lazily fail if we don't have any workable rhymes (run script again)
    fail if line.length == 0

    # Now, work back from the left-most word until we reach a START token (or a good length)
    while line[0] != nil || line.length < 8
      prior_word = previous_word(line[0])
      line.unshift prior_word

      break if line[0] == line[1] && line[1] == line[2]
    end
  end

  line = line.compact.join(' ') if line.is_a? Array
  puts "Line generated: #{line}"
  rap_lines.concat [line]
end

puts rap_lines.join "\n"
