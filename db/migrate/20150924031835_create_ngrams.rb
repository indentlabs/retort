class CreateBigrams < ActiveRecord::Migration
 def self.up
   create_table :bigrams do |t|
     t.string :prior
     t.string :after
     t.timestamps
   end
 end

 def self.down
   drop_table :bigrams
 end
end