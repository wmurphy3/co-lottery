class CreateUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :users do |t|
      t.string :name, null: false
      t.text :address
      t.string :phone
      t.string :email, null: false
      
      t.timestamps null: false
    end
  end
end
