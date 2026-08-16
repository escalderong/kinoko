class CreateOrderItemModifiers < ActiveRecord::Migration[8.0]
  def change
    create_table :order_item_modifiers, id: :uuid do |t|
      t.string :modifier_group_name, null: false
      t.string :modifier_name, null: false
      t.bigint :price_delta_cents, null: false, default: 0
      t.references :order_item, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end
  end
end
