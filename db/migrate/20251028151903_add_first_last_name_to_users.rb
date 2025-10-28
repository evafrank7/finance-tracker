class AddFirstLastNameToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :first, :string
    add_column :users, :last, :string
  end
end
