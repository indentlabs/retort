class CreateNgrams < ActiveRecord::Migration
 def self.up
   create_table :ngrams do |t|
     t.string :prior
     t.string :after
     t.timestamps
   end
 end

 def self.down
   drop_table :ngrams
 end
end