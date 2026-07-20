require "rails_helper"

# Both controllers that include this concern only ever call it with
# machine-built line items from OrderCartBuilder, which snapshots names from
# already-validated Variant/Modifier records — so the persistence-failure
# branch (a snapshot failing OrderItemVariant/OrderItemModifier's own
# validation) can never actually be reached through a real HTTP request.
# Testing the concern directly, with a deliberately invalid snapshot, is the
# only way to exercise the rollback-vs-preserve contract this concern's own
# comment calls "the highest-risk part of this feature."
RSpec.describe OrderItemPersistence do
  let(:host_class) do
    Class.new do
      include OrderItemPersistence
      public :persist_order_items, :rollback_created_items
    end
  end
  let(:host) { host_class.new }

  describe "#persist_order_items" do
    it "creates every item and its variant/modifier snapshots on success" do
      order = create(:order)
      line_items = [
        {
          product_name: "Latte", base_price: Money.new(700_000, "COP"), quantity: 1,
          variants: [ { variant_group_name: "Size", variant_name: "Large", price_delta: Money.new(0, "COP") } ],
          modifiers: [ { modifier_group_name: "Extras", modifier_name: "Cheese", price_delta: Money.new(0, "COP") } ]
        }
      ]

      expect(host.persist_order_items(order, line_items)).to be true

      order.reload
      expect(order.order_items.count).to eq(1)
      expect(order.order_items.first.order_item_variants.count).to eq(1)
      expect(order.order_items.first.order_item_modifiers.count).to eq(1)
    end

    it "rolls back only what it created when a later snapshot is invalid, preserving pre-existing items" do
      order = create(:order)
      existing_item = create(:order_item, order: order, product_name: "Pre-existing")

      line_items = [
        { product_name: "Latte", base_price: Money.new(700_000, "COP"), quantity: 1, variants: [], modifiers: [] },
        {
          product_name: "Broken", base_price: Money.new(100_000, "COP"), quantity: 1,
          # blank names violate OrderItemVariant's own validates_presence_of —
          # this can't happen via a real cart (snapshots always come from an
          # already-validated Variant), but it's exactly the failure shape
          # persist_order_items must survive without corrupting the order.
          variants: [ { variant_group_name: nil, variant_name: nil, price_delta: Money.new(0, "COP") } ],
          modifiers: []
        }
      ]

      result = host.persist_order_items(order, line_items)

      expect(result).to be false
      order.reload
      expect(order.order_items.to_a).to eq([ existing_item ])
    end
  end
end
