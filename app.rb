require 'sinatra'
require 'sinatra/activerecord'
require './environments'

require_relative 'services/bigram_service'
require_relative 'services/markov_chain_service'
require_relative 'services/sanitization_service'
require_relative 'services/token_service'

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

	MarkovChainService.create_random_chain(
		maximum_chain_length: maximum_chain_length
	)
end

get "/bigram/list" do
	content_type :json

	Bigram.order(:prior).pluck(:prior, :after).to_json
end

get "/bigram/add" do
	content_type :json

	sliced_params = params.slice('prior', 'after')
	BigramService.find_or_create_by_hash(bigram_hash: sliced_params).to_json
end

get "/bigram/next" do
	content_type :json

	Bigram.where(prior: params[:prior]).sample.to_json
end

get "/bigram/parse" do
	content_type :json

	BigramService.find_or_create_by_string(tokenizable_string: params[:message]).to_json
end

get "/retort/list" do
	content_type :json

	Retort.order(:stimulus).pluck(:stimulus, :response).to_json
end

get "/retort/add" do
	content_type :json

	sliced_params = params.slice('stimulus', 'response')
	Retort.find_or_create_by(sliced_params).to_json
end

get "/retort/get" do
	content_type :json

	Retort.where(stimulus: params[:stimulus]).sample.to_json
end