class BigramService
	def self.find_or_create_by_string(tokenizable_string:)
		created = []

		tokens = TokenService.tokenize tokenizable_string

		created << Bigram.find_or_create_by(prior: nil, after: tokens[0])
		created << (0..(tokens.length - 2)).map do |i|
			Bigram.find_or_create_by(prior: tokens[i], after: tokens[i + 1])
		end
		created << Bigram.find_or_create_by(prior: tokens[-1], after: nil)

		created
	end

	def self.find_or_create_by_hash(bigram_hash:)
		Bigram.find_or_create_by(prior: bigram_hash[:prior], after: bigram_hash[:after])
	end

	def self.random_word_after(word:)
		Bigram.where(prior: word).sample
	end

	def self.all_possible_words_before(word:)
		Bigram.where(after: word).pluck(:prior)
	end

	def self.all_possible_words_after(word:)
		Bigram.where(prior: word).pluck(:after)
	end
end