class UPdateIndexes < ActiveRecord::Migration[5.2]
  def change
    add_index :users, :email, unique: true
    add_index :user_prizes, :user_id
    add_index :user_prizes, :prize_id
  end
end
