class AddLocaleAndThemeToUsers < ActiveRecord::Migration[8.0]
  def change
    change_table :users, bulk: true do |t|
      t.string :locale, null: false, default: 'en'
      t.string :theme, null: false, default: 'light'
      t.index :locale
      t.index :theme
    end
  end
end
