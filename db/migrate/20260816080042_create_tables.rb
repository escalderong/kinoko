class CreateTables < ActiveRecord::Migration[8.0]
  def change
    create_table :tables, id: :uuid do |t|
      t.integer :capacity, null: false
      t.integer :number, null: false
      t.integer :pos_x, null: false, default: 0
      t.integer :pos_y, null: false, default: 0
      t.integer :width, null: false, default: 2
      t.integer :height, null: false, default: 2
      t.integer :status, null: false, default: 1
      # index: false — the composite index below already covers commerce_id-only
      # lookups as its leftmost prefix, so a standalone index here would be redundant.
      t.references :commerce, null: false, foreign_key: true, type: :uuid, index: false
      t.references :floor_zone, null: false, foreign_key: true, type: :uuid

      t.timestamps

      # Race-safe counterpart to Table's validates_uniqueness_of :number, scope: :commerce
      t.index [ :commerce_id, :number ], unique: true
    end
  end
end
