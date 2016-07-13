require 'sinatra'
require 'sinatra/activerecord'
require './environments'

require_relative 'lib/string'

require_relative 'services/bigram_service'
require_relative 'services/markov_chain_service'
require_relative 'services/sanitization_service'
require_relative 'services/token_service'
require_relative 'services/identity_service'

require 'json'

class Bigram < ActiveRecord::Base; end
class Retort < ActiveRecord::Base; end

get "/" do
    erb :"apidocs"
end

get "/stats" do
    erb :"stats"
end

get "/identities" do
    @mediums = Bigram.distinct(:medium).pluck(:medium)

    erb :"identities"
end

# API

# TODO: scope everything here under /api/v1/

get "/identities/mediums" do
    content_type :json

    mediums = Bigram.distinct(:medium)
    mediums = mediums.where(channel: params[:channel]) if params[:channel]
    mediums = mediums.where(identifier: params[:identifier]) if params[:identifier]
    mediums = mediums.pluck(:medium)

    mediums.to_json
end

get "/identities/channels" do
    content_type :json

    channels = Bigram.distinct(:channel)
    channels = channels.where(medium: params[:medium]) if params[:medium] && params[:medium] != 'All mediums'
    channels = channels.where(identifier: params[:identifier]) if params[:identifier]
    channels = channels.pluck(:channel)

    channels.to_json
end

get "/identities/identifiers" do
    content_type :json

    identifiers = Bigram.distinct(:identifier)
    identifiers = identifiers.where(medium: params[:medium]) if params[:medium] && params[:medium] != 'All mediums'
    identifiers = identifiers.where(channel: params[:channel]) if params[:channel] && params[:channel] != 'All channels'
    identifiers = identifiers.pluck(:identifier)

    identifiers.to_json
end

get "/ngrams/count" do
    content_type :json

    ngrams = Bigram.distinct
    ngrams = ngrams.where(medium: params[:medium]) if params[:medium]
    ngrams = ngrams.where(channel: params[:channel]) if params[:channel]
    ngrams = ngrams.where(identifier: params[:identifier]) if params[:identifier]

    ngrams.to_json
end

get "/markov/create" do
    content_type :json

    maximum_chain_length = begin
        Integer params[:maximum_chain_length]
    rescue
        20
    end

    chain = MarkovChainService.create_random_chain(
        maximum_chain_length: maximum_chain_length,
        identifier: IdentityService.query_parameters(params[:identifier], params[:medium], params[:channel])
    )

    SanitizationService.standard_sanitization(chain)
end

get "/markov/ipsum" do
    content_type :json

    result = 4.times.map {
        4.times.map {
            chain = MarkovChainService.create_random_chain
        }.join ' '
    }.join("\n\n")

    SanitizationService.ipsum_sanitization(result)
end

get "/bigram/list" do
    content_type :json

    Bigram.order(:prior).pluck(:prior, :after).to_json
end

get "/bigram/add" do
    content_type :json

    sliced_params = params.slice('prior', 'after')
    BigramService.find_or_create_by_hash(
        bigram_hash: sliced_params,
        identifier: IdentityService.query_parameters(params[:identifier], params[:medium], params[:channel])
    ).to_json
end

get "/bigram/next" do
    content_type :json

    BigramService.random_word_after(word: params[:prior]).to_json
end

get "/bigram/antecedents" do
    content_type :json

    BigramService.all_possible_words_before(
        word: params[:prior],
        identifier: IdentityService.query_parameters(params[:identifier], params[:medium], params[:channel])
    ).to_json
end

get "/bigram/consequents" do
    content_type :json

    BigramService.all_possible_words_after(
        word: params[:prior],
        identifier: IdentityService.query_parameters(params[:identifier], params[:medium], params[:channel])
    ).to_json
end

get "/bigram/parse" do
    content_type :json

    BigramService.find_or_create_by_string(
        tokenizable_string: params[:message],
        identifier: IdentityService.query_parameters(params[:identifier], params[:medium], params[:channel])
    ).to_json
end

get "/retort/list" do
    content_type :json

    Retort.order(:stimulus).pluck(:stimulus, :response).to_json
end

get "/retort/add" do
    content_type :json

    sliced_params = params.slice('stimulus', 'response')
    Retort.find_or_create_by(sliced_params).to_json #todo RetortService.find_or_create_by
end

get "/retort/get" do
    content_type :json

    Retort.where(stimulus: params[:stimulus]).sample.to_json
end

get "/retort/random/opening" do
    content_type :json

    Retort.where(stimulus: nil).sample.to_json
end
