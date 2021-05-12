require 'active_record'

set :public_folder, Proc.new { File.join(root, "views", "assets") }

configure :development do
  set :database, 'sqlite3:dev.db'
  set :show_exceptions, true
end

configure :production do
  db = URI.parse(ENV['RDS_URL'] || 'postgres:///localhost/mydb')

  ActiveRecord::Base.establish_connection(
    :adapter  => db.scheme == 'postgres' ? 'postgresql' : db.scheme,
    :host     => db.host,
    :username => db.user,
    :password => db.password,
    :database => db.path[1..-1],
    :encoding => 'utf8'
  )
end
