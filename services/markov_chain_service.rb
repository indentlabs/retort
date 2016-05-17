class MarkovChainService
    def self.create_random_chain(maximum_chain_length: 20, identifier: {})
        # TODO: minimum_chain_length for ipsum
        # TODO: benchmark tests
        # TODO: support Trigrams
        gram = Bigram.where(identifier.merge({prior: nil})).order('random()').take(1).first
        return '' if gram.nil?
        puts "STARTING WITH ORIGIN: #{gram[:after]}"
        chain = [nil, gram[:after]]

        # TODO: forward and backward expansion
        # TODO: better cyclic detection
        loop do
            id_conditions = identifier.merge({prior: chain.last})

            count = Bigram.where(id_conditions).where.not(after: chain.last).count
            gram = Bigram.where(id_conditions).where.not(after: chain.last).offset(rand count).take(1).first

            #gram = Bigram.where(id_conditions).where.not(after: chain.last).sample

            break unless gram
            break if chain.length > maximum_chain_length
            break if gram[:after].nil?
            next if gram[:after].empty?

            #puts "NEXT WORD: #{gram[:after]}"

            chain << gram[:after]
        end
        puts "FINISHED CHAIN: #{chain.compact}"

        chain.compact.join ' '
    end

    def self.create_chain_from_start_word(start_word:)
        throw NotImplemented
    end

    def self.create_chain_from_end_word(end_word:)
        throw NotImplemented
    end

    def self.create_chain_from_middle_word(middle_word:)
        throw NotImplemented
    end
end
