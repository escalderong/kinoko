class CreateCheckItems < ActiveRecord::Migration[8.0]
  def change
    create_table :check_items, id: :uuid do |t|
      t.integer :quantity, null: false
      t.references :check, null: false, foreign_key: true, type: :uuid
      t.references :order_item, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end
  end
end
