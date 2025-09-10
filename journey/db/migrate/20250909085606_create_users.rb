class CreateUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :users do |t|
      t.string  :email,              null: false
      t.string  :encrypted_password, null: false
      t.string  :confirmation_token
      t.string  :remember_token,     null: false

      t.string  :name,               null: false
      t.integer :role,               null: false, default: 1

      t.timestamps
    end

    add_index :users, :email,              unique: true
    add_index :users, :confirmation_token, unique: true
    add_index :users, :remember_token,     unique: true
    add_index :users, :role
  end
end
