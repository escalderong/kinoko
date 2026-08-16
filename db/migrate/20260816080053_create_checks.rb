class CreateChecks < ActiveRecord::Migration[8.0]
  def change
    create_table :checks, id: :uuid do |t|
      t.bigint :subtotal_cents, null: false, default: 0
      t.bigint :tax_cents, null: false, default: 0
      t.bigint :tip_cents, null: false, default: 0
      t.integer :status, null: false, default: 1
      t.references :order, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end
  end
end
