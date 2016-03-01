class SanitizationService
	def self.standard_sanitization(message)
		message = remove_links message
		message = trim_whitespace message
		message = capitalize_properly message
		message = punctuate_properly message

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
		#todo other punctuations based on sentence
		TokenService.tokenize_sentences(message).collect do |sentence|
			sentence += '.' unless sentence.ends_in_terminal_point?
			sentence
		end.join ' '
	end

	def self.remove_links(message)
		TokenService.tokenize(message).reject(&:is_a_link?).join ' '
	end

	def self.match_parentheses(message)
		message #todo
	end

	def self.match_quotes(message)
		message #todo
	end

	def self.remove_symbols(message)
		message.tr('^A-Za-z0-9\.\$!\? ', '')
	end
end