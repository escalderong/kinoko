class CreateVariantGroups < ActiveRecord::Migration[8.0]
  def change
    create_table :variant_groups, id: :uuid do |t|
      t.string :name, null: false
      t.boolean :is_required, null: false, default: false
      t.references :product, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end
  end
end
