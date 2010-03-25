class CreateQueries < ActiveRecord::Migration
  def self.up
    create_table :queries do |t|
      t.string :from_user, :limit => 15
      t.string :lang, :limit => 2
      t.string :q, :limit => 140
      t.integer :rpp
      t.date :since

      t.timestamps
    end
  end

  def self.down
    drop_table :queries
  end
end
