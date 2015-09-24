require 'sinatra'
require 'sinatra/activerecord'
require './environments'

require 'json'

class Retort < ActiveRecord::Base
end

class Ngram < ActiveRecord::Base
end

get "/ngram/add" do
	content_type :json

	sanitized_params = params.slice('prior', 'after')
	created_ngram = Ngram.find_or_create_by sanitized_params

	created_ngram.to_json
end

get "/ngram/next" do
	content_type :json

	Ngram.where(prior: params[:prior]).sample.to_json
end