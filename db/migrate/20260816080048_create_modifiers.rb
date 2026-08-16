class CreateModifiers < ActiveRecord::Migration[8.0]
  def change
    create_table :modifiers, id: :uuid do |t|
      t.string :name, null: false
      t.bigint :price_delta_cents, null: false, default: 0
      t.boolean :is_active, null: false, default: true
      t.references :modifier_group, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end
  end
end
