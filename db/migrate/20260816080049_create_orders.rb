class CreateOrders < ActiveRecord::Migration[8.0]
  def change
    create_table :orders, id: :uuid do |t|
      t.datetime :opened_at, null: false
      t.datetime :closed_at
      t.integer :status, null: false, default: 1
      t.references :table, null: false, foreign_key: true, type: :uuid

      t.timestamps

      # Enforces "at most one open order per table" atomically at the database
      # level (replaces a Mongo partial_filter_expression index this app used to
      # have). The app-level guard (Order.open_for(table).exists? in
      # OrdersController#create) is a TOCTOU race on its own; this partial unique
      # index is what actually closes it — the losing INSERT fails with SQLSTATE
      # 23505, which ActiveRecord raises as RecordNotUnique.
      #
      # The literal 1 must stay in sync with Order.statuses[:open]. A model spec
      # asserts that mapping so a future renumbering fails loudly instead of
      # silently disabling this constraint.
      t.index :table_id, unique: true, where: "status = 1", name: "index_orders_on_table_id_when_open"
    end
  end
end
