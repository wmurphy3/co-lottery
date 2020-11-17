class UpdatePrizes < ActiveRecord::Migration[5.2]
  def change
    add_column :prizes, :class_name, :string
  end
end
