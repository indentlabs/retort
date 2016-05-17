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
        while (gram = Bigram.where(identifier.merge({prior: chain.last})).where.not(after: chain.last).take(1).first)
            puts "NEXT WORD: #{gram[:after]}"
            break if chain.length > maximum_chain_length
            break if gram[:after].nil?
            next if gram[:after].empty?

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
