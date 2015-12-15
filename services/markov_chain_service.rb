class MarkovChainService
	def self.create_random_chain(maximum_chain_length: 20)
		#todo minimum_chain_length for ipsum
		gram = Bigram.where(prior: nil).sample
		chain = [nil, gram[:after]]

		#todo forward and backward expansion
		#todo better cyclic detection
		while (gram = Bigram.where(prior: chain.last).where.not(after: chain.last).sample)
			break if chain.length > maximum_chain_length
			break if gram[:after].nil?

			chain << gram[:after]
		end

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