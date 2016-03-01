class TokenService
  def self.tokenize(string)
  	string.split ' '
  end

  def self.tokenize_sentences(string)
	string.gsub(/([.?!]\s)/, '\0|').split('|').map(&:strip)
  end
end
