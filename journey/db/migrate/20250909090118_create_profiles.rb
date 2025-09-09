class CreateProfiles < ActiveRecord::Migration[8.0]
  def change
    create_table :profiles do |t|
      t.references :user, null: false, foreign_key: true
      t.string :phone_country_code
      t.string :phone_local
      t.string :phone
      t.date :bday
      t.string :country
      t.string :hq

      t.timestamps
    end
  end
end
