class AddIndexToBigramsPriorAndAfter < ActiveRecord::Migration
  def change
  	add_index :bigrams, :prior
  	add_index :bigrams, :after
  end
end
