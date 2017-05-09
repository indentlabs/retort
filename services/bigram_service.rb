class BigramService
    def self.find_or_create_by_string(tokenizable_string:, identifier: {})
        created = []

        tokens = TokenService.tokenize tokenizable_string

        #todo clean this up
        created << Bigram.find_or_create_by(identifier.merge({prior: nil, after: tokens[0]}))
        created << (0..(tokens.length - 2)).map do |i|
            Bigram.find_or_create_by(identifier.merge({prior: tokens[i], after: tokens[i + 1]}))
        end
        created << Bigram.find_or_create_by(identifier.merge({prior: tokens[-1], after: nil}))

        created
    end

    def self.find_or_create_by_hash(bigram_hash:, identifier: {})
        Bigram.find_or_create_by(identifier.merge({prior: bigram_hash[:prior], after: bigram_hash[:after]}))
    end

    def self.random_word_before(word:, identifier: {})
        bigram = Bigram.where(identifier).where("lower(after) = ?", word).sample
    end

    def self.random_word_after(word:, identifier: {})
        bigram = Bigram.where(identifier).where("lower(prior) = ?", word).sample
    end

    def self.all_possible_words_before(word:, identifier: {})
        Bigram.where(identifier.merge({after: word})).pluck(:prior)
    end

    def self.all_possible_words_after(word:, identifier: {})
        Bigram.where(identifier.merge({prior: word})).pluck(:after)
    end
end