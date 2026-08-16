class CreateOrderItems < ActiveRecord::Migration[8.0]
  def change
    create_table :order_items, id: :uuid do |t|
      t.bigint :base_price_cents, null: false
      t.datetime :fired_at
      t.string :product_name, null: false
      t.integer :quantity, null: false
      t.text :notes
      t.references :order, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end
  end
end
