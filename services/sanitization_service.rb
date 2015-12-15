class SanitizationService
	def self.standard_sanitization(message)
		message = trim_whitespace message
		message = capitalize_properly message
		message = punctuate_properly message

		message
	end

	def self.trim_whitespace(message)
		#todo s/  / /
		message.strip
	end

	def self.capitalize_properly(message)
		TokenService.tokenize_sentences(message).map(&:capitalize_first).join ' '
	end

	def self.punctuate_properly(message)
		#todo other punctuations based on sentence
		TokenService.tokenize_sentences(message).map do |sentence|
			sentence += '.' unless sentence.ends_in_terminal_point?
		end.join ' '
	end

	def self.remove_links(message)
		throw NotImplemented
	end

	def self.match_parentheses(message)
	end

	def self.match_quotes(message)
	end
end