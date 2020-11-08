class CreateUserPrizes < ActiveRecord::Migration[5.2]
  def change
    create_table :user_prizes do |t|
      t.integer :user_id
      t.integer :prize_id
      t.timestamps null: false
    end
  end
end
