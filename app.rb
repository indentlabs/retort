require 'sinatra'
require 'sinatra/activerecord'
require './environments'

require 'json'

set :public_folder, Proc.new { File.join(root, "views", "assets") }

get "/" do
	erb :"apidocs"
end

class Ngram < ActiveRecord::Base
end

get "/ngram/list" do
	content_type :json

	Ngram.order(:prior).pluck(:prior, :after).to_json
end


get "/ngram/add" do
	content_type :json

	sanitized_params = params.slice('prior', 'after')
	created_ngram = Ngram.find_or_create_by sanitized_params
	#todo increase weight if found (not created)

	created_ngram.to_json
end

get "/ngram/next" do
	content_type :json

	Ngram.where(prior: params[:prior]).sample.to_json
end


class Retort < ActiveRecord::Base
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