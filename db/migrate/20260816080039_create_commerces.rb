class CreateCommerces < ActiveRecord::Migration[8.0]
  def change
    create_table :commerces, id: :uuid do |t|
      t.string :name, null: false
      t.string :theme, null: false, default: "light"

      t.timestamps
    end
  end
end
