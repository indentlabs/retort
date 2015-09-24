require 'sinatra'
require 'sinatra/activerecord'
require './environments'

class Retort < ActiveRecord::Base
end

class Ngram < ActiveRecord::Base
end
