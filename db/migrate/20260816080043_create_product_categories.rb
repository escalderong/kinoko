class CreateProductCategories < ActiveRecord::Migration[8.0]
  def change
    create_table :product_categories, id: :uuid do |t|
      t.string :name, null: false
      t.string :icon, null: false
      # index: false — the composite index below already covers commerce_id-only
      # lookups as its leftmost prefix, so a standalone index here would be redundant.
      t.references :commerce, null: false, foreign_key: true, type: :uuid, index: false

      t.timestamps

      t.index [ :commerce_id, :name ], unique: true
    end
  end
end
