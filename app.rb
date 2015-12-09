require 'sinatra'
require 'sinatra/activerecord'
require './environments'

require 'json'

class Bigram < ActiveRecord::Base; end
class Retort < ActiveRecord::Base; end

get "/" do
	erb :"apidocs"
end

get "/markov/create" do
	content_type :json

	maximum_chain_length = begin
		Integer params[:maximum_chain_length]
	rescue
		20
	end

	#todo start word
	gram  = Bigram.where(prior: nil).sample
	chain = gram.slice(:prior, :after).values

	#todo forward and backward expansion
	#todo better cyclic detection
	while (gram = Bigram.where(prior: chain.last).where.not(after: chain.last).sample) && chain.length <= maximum_chain_length
		#todo customizable chain length limits
		break if gram[:after].nil?
		chain << gram[:after]
	end

	chain.compact.join ' '
end

get "/bigram/list" do
	content_type :json

	Bigram.order(:prior).pluck(:prior, :after).to_json
end

get "/bigram/add" do
	content_type :json

	sanitized_params = params.slice('prior', 'after')
	created_bigram = Bigram.find_or_create_by sanitized_params
	#todo increase weight if found (not created)

	created_bigram.to_json
end

get "/bigram/next" do
	content_type :json

	Bigram.where(prior: params[:prior]).sample.to_json
end

get "/bigram/parse" do
	content_type :json

	created = []

	tokens = params[:message].split(' ') #todo TokenService.tokenize
	created << Bigram.find_or_create_by(prior: nil, after: tokens[0])
	created << (0..(tokens.length - 2)).map do |i|
		Bigram.find_or_create_by(prior: tokens[i], after: tokens[i + 1]) #todo BigramService.add_or_create_by for adding weights/reuse?
	end
	created << Bigram.find_or_create_by(prior: tokens[-1], after: nil)

	created.to_json
end

get "/retort/list" do
	content_type :json

	Retort.order(:stimulus).pluck(:stimulus, :response).to_json
end

get "/retort/add" do
	content_type :json

	sanitized_params = params.slice('stimulus', 'response')
	created_retort = Retort.find_or_create_by sanitized_params

	created_retort.to_json
end

get "/retort/get" do
	content_type :json

	Retort.where(stimulus: params[:stimulus]).sample.to_json
end