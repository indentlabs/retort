class TokenService
  def self.tokenize(string)
  	string.split ' '
  end

  def self.tokenize_sentences(string)
	string.gsub(/[.?!]/, '\0|').split('|')
  end
end