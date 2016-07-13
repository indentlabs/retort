require './app'
require 'sinatra/activerecord/rake'
require 'rake/testtask'

task default: :test

Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = FileList['test/*.rb']
  t.verbose = true
end

namespace :db do
  desc "Create database based on a DATABASE_URL"
  task :create do
    config = uri_to_config ENV['DATABASE_URL']
    begin
      case config['adapter']
      when /sqlite/
        if File.exist?(config['database'])
          $stderr.puts "#{config['database']} already exists"
        else
          # Create the SQLite database; just connecting is enough to create it.
          ActiveRecord::Base.establish_connection config
          ActiveRecord::Base.connection
        end

      when /mysql/
        create_options = nil
        ActiveRecord::Base.establish_connection config.merge('database' => nil)
        ActiveRecord::Base.connection.create_database config['database'], create_options
        ActiveRecord::Base.establish_connection config

      when /postgresql/
        encoding = config['encoding'] || ENV['CHARSET'] || 'utf8'
        ActiveRecord::Base.establish_connection config.merge('database' => 'postgres', 'schema_search_path' => 'public')
        ActiveRecord::Base.connection.create_database config['database'], config.merge('encoding' => encoding)
        ActiveRecord::Base.establish_connection config
      end
    rescue Exception => e
      $stderr.puts e, *(e.backtrace)
      $stderr.puts "Couldn't create database for #{config.inspect}."
    end
  end

  def uri_to_config(uri)
    begin
      uri = URI.parse(uri)
    rescue URI::InvalidURIError
      raise "Invalid DATABASE_URL"
    end
    {
      'adapter'  => (uri.scheme == 'postgres' ? 'postgresql' : uri.scheme),
      'database' => (uri.scheme.match(/sqlite/) ? uri.path : uri.path[1..-1]),
      'username' => uri.user,
      'password' => uri.password,
      'host'     => uri.host,
      'port'     => uri.port,
    }
  end
end
