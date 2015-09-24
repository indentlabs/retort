class CreateRetorts < ActiveRecord::Migration
 def self.up
   create_table :retorts do |t|
     t.string :stimulus
     t.string :response
     t.timestamps
   end
 end

 def self.down
   drop_table :retorts
 end
end