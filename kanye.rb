require 'httparty'
require 'rhymes'

require 'pry'

rhyme_scheme = 'AABB CCDD EEFF GG'
rhymes = {}
rap_lines = []

def previous_word after
  url = "http://www.retort.us/bigram/prior?after=#{after}&medium=music&identifier=kanyewest"
  json = JSON.parse(HTTParty.get(url).body)

  puts "#{json['prior']} --> #{after}"

  json["prior"]
rescue
  puts "No words found prior to #{after}"
  nil
end

def full_line
  url = "http://www.retort.us/markov/create?medium=music&identifier=kanyewest"
  HTTParty.get(url).body
end

def rhymes_for word
  word = 'land' if word == 'and'
  Rhymes.rhyme(word.gsub /\W+/, '').map(&:downcase)
rescue Rhymes::UnknownWord
  []
end


def generate_next_line_for rhyming_scheme, poem_lines
  # If we've reached the end of the rhyming scheme, we can return the full poem!
  if poem_lines.length == rhyming_scheme.length
    return poem_lines.map { |line| line.force_encoding 'utf-8' }.join("\n")
  end

  if poem_lines.length > 0
    puts "Poem so far:"
    puts poem_lines.map { |line| "\t#{line}" }.join("\n")
  end

  next_rhyme_scheme_indicator = rhyming_scheme.chars[poem_lines.count]

  # If we're on a blank rhyme scheme indicator, add a blank line to the lines and continue on
  if next_rhyme_scheme_indicator == ' '
    return generate_next_line_for rhyming_scheme, poem_lines.concat([' '])
  end

  puts "Generating line for rhyme scheme indicator #{next_rhyme_scheme_indicator}..."

  # If this is the first time we've seen this indicator, we can generate a fully-random line
  if rhyming_scheme.index(next_rhyme_scheme_indicator) == poem_lines.length
    puts "Generating full line from Markov model."
    line = full_line
    puts "Line generated: #{line}"

    while line.split(' ').length < 6
      puts "Full line generated is too short! Regenerating this line..."
      line = full_line
    end

    full_poem = generate_next_line_for rhyming_scheme, poem_lines.concat([line])

    if full_poem == nil
      line_to_backtrack_to = rhyming_scheme.index(next_rhyme_scheme_indicator) - 1
      if line_to_backtrack_to <= 1
        puts "Initial line resulted in failed poem -- trying again from scratch."
        return generate_next_line_for rhyming_scheme, []
      else
        puts "Backtracking and trying again at line #{line_to_backtrack_to - 1}"
        return generate_next_line_for rhyming_scheme, poem_lines[0..(line_to_backtrack_to - 1)]
      end
    else
      return full_poem
    end

  # If we've used this scheme indicator before, we need to rhyme with it
  else
    index_of_first_scheme_indicator = rhyming_scheme.index(next_rhyme_scheme_indicator)
    word_to_rhyme_with = poem_lines[index_of_first_scheme_indicator].split(' ').last
    puts "Rhyming with #{word_to_rhyme_with}"

    rhyming_words = rhymes_for word_to_rhyme_with
    puts "Found #{rhyming_words.length} rhymes."

    if rhyming_words.length == 0
      return nil
    end

    # Then, go through each word and try to find one we can build backwards from
    line = []
    rhyming_words.shuffle.each do |potential_rhyme|
      puts "Looking for usage of #{potential_rhyme}..."
      previous_word_for_this_rhyme = previous_word(potential_rhyme)
      if previous_word_for_this_rhyme
        # If we find a word to use, try to use it and fail if we can't
        line = [previous_word_for_this_rhyme, potential_rhyme]

        # Build the full line backward to the beginning
        while line[0] != nil && line.length < 8
          prior_word = previous_word(line[0])
          line.unshift prior_word

          break if line[0] == line[1] && line[1] == line[2]
        end

        # If the line we generated is too short, jump back a line and try again
        if line.is_a?(Array) && line.length < 6
          puts "Line generated is too short! Retrying this line..."
          return generate_next_line_for rhyming_scheme, poem_lines
        end

        line = line.compact.join(' ') if line.is_a? Array
        puts "Line generated: #{line}"
        full_poem = generate_next_line_for rhyming_scheme, poem_lines.concat([line])

        if full_poem == nil
          puts "Poem generation failed -- trying next potential rhyme for #{word_to_rhyme_with}"
          return nil
        else
          return full_poem
        end
      end
    end

    # If no rhyming words were usable, start over :(
    return nil
  end

end


puts "Generating poem with rhyme scheme #{rhyme_scheme}."
poem = generate_next_line_for(rhyme_scheme, [])

puts "POEM CREATED! (WOOOOOO)"
puts poem


# # First line is random
# first_line = full_line

# rhyme_scheme.chars.each do |rhyme|
#   # Add breaks between verses
#   rap_lines.concat [''] if rhyme == ' '

#   # If we're on a line without a previous rhyme, generate a random line
#   if rhymes.key?(rhyme) == false
#     line = full_line

#     # And set the final word of the line as the word to rhyme with in the future
#     rhymes[rhyme] = line.split(' ').last

#   # If we're on a line WITH a previous rhyme, we want to ask for rhyming words and build back from there
#   else
#     rhyming_words = rhymes_for rhymes[rhyme]
#     puts "Rhyming words for #{rhymes[rhyme]}: #{rhyming_words}"

#     # Then, go through each word and try to find one we can build backwards from
#     line = []
#     rhyming_words.shuffle.each do |potential_rhyme|
#       puts "Looking for rhymes for #{potential_rhyme}..."
#       previous_word_for_this_rhyme = previous_word(potential_rhyme)
#       if previous_word_for_this_rhyme
#         # If we find a word to use, set it and break to ignore the other rhyming words
#         line = [previous_word_for_this_rhyme, potential_rhyme]
#         break
#       end
#     end

#     # Lazily fail if we don't have any workable rhymes (run script again)
#     fail if line.length == 0

#     # Now, work back from the left-most word until we reach a START token (or a good length)
#     while line[0] != nil || line.length < 8
#       prior_word = previous_word(line[0])
#       line.unshift prior_word

#       break if line[0] == line[1] && line[1] == line[2]
#     end
#   end

#   line = line.compact.join(' ') if line.is_a? Array
#   puts "Line generated: #{line}"
#   rap_lines.concat [line]
# end

# puts rap_lines.join "\n"
