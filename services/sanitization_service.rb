# encoding: utf-8

require_relative 'token_service'

class SanitizationService
	def self.standard_sanitization(message)
		message = remove_links message
		message = trim_whitespace message
		message = capitalize_properly message
		message = punctuate_properly message
		message = remove_biblical_chapters message
		message = swap_special_characters message

		message
	end

	def self.ipsum_sanitization(message)
		message = standard_sanitization message
		message = remove_symbols message

		message
	end

	def self.trim_whitespace(message)
		message.strip.squeeze(' ')
	end

	def self.capitalize_properly(message)
		TokenService.tokenize_sentences(message).map(&:capitalize_first).join ' '
	end

	def self.punctuate_properly(message)
		message = match_parentheses message

		TokenService.tokenize_sentences(message).collect do |sentence|
			sentence = sentence.chop if sentence.ends_in_unterminated_punctuation?
			sentence += '.' unless sentence.ends_in_terminal_point?
			sentence
		end.join ' '
	end

	def self.remove_links(message)
		TokenService.tokenize(message).reject(&:is_a_link?).join ' '
	end

	def self.remove_biblical_chapters(message)
		# Many biblical passages begin with ^5Text/etc, this removes the ^digit.
		message.gsub(/^\^\d+/, '')
	end

	def self.swap_special_characters(message)
		message.gsub('“', '"') # left smart quote
			.gsub('’', "'")    # smart '
			.gsub('”', '"')	 # right smart quote
	end


	def self.match_parentheses(message)
		opening_parentheses = message.count "("
		closing_parentheses = message.count ")"

		return message if opening_parentheses == closing_parentheses
		# todo make sure parentheses are opened before closed

		if opening_parentheses > closing_parentheses
			parentheses_to_add = opening_parentheses - closing_parentheses
			message = ([message] + [")"] * parentheses_to_add).join
		else
			parentheses_to_add = closing_parentheses - opening_parentheses
			message = (["("] * parentheses_to_add + [message]).join
		end
	end

	def self.match_quotes(message)
		#['"', "'"].each do |quote|
		#	words_with_left_quote  = message.scan Regexp.new("(#{quote}\w+[^#{quote}]?")
		#	words_with_right_quote = message.scan Regexp.new("[^ #{quote}]?\w+#{quote})
		#
		#	replacements_to_make = words_with_left_quote.length - words_with_right_quote.length
		#
		#	TokenService.tokenize(message).map do |word|
		#		break if replacements_to_make.zero?
		#		next if words_with_left_quote.include?(word) || words_with_right_quote.include?(word)
		#
		#		if replacements_to_make > 0
		#			word = "#{word}#{quote}"
		#			replacements_to_make -= 1
		#		elsif replacements_to_make < 0
		#			word = "#{quote}#{word}"
		#			replacements_to_make += 1
		#		end
		#		word
		#	end.join ' '
		#end
		message
	end

	def self.remove_symbols(message)
		message.tr('^A-Za-z0-9\.\$!\? ', '')
	end
end
