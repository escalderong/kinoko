class CreateProducts < ActiveRecord::Migration[8.0]
  def change
    create_table :products, id: :uuid do |t|
      t.string :name, null: false
      t.boolean :is_active, null: false, default: true
      t.bigint :base_price_cents, null: false
      # index: false — the composite index below already covers commerce_id-only
      # lookups as its leftmost prefix, so a standalone index here would be redundant.
      t.references :commerce, null: false, foreign_key: true, type: :uuid, index: false
      t.references :product_category, null: false, foreign_key: true, type: :uuid

      t.timestamps

      t.index [ :commerce_id, :is_active ]
    end
  end
end
