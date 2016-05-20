class String
	def capitalize_first
		(slice(0) || '').upcase + (slice(1..-1) || '')
	end

	def capitalize_first!
		replace(capitalize_first)
	end

	def ends_in_terminal_point?
		#todo handle "quote?"
		['!', '?', '.'].include? (slice(-1) || '')
	end

	def ends_in_unterminated_punctuation?
		[',', ';', '~'].include? (slice(-1) || '')
	end

	def is_a_link?
		self.start_with?('http://') || self.start_with?('https://') || self.start_with?('www.')
		#todo regex?
	end
end