class AddIdentifierFieldsToBigrams < ActiveRecord::Migration
  def change
    add_column :bigrams, :identifier, :string
    add_column :bigrams, :medium, :string
    add_column :bigrams, :channel, :string
  end
end

# dru@facebook
# /u/dru@reddit#/r/subred
# dru@irc.amazdong.com#interns
# identifier@medium#channel