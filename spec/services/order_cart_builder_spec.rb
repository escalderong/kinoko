require "rails_helper"

RSpec.describe OrderCartBuilder do
  let(:commerce) { create(:commerce) }
  let(:category) { create(:product_category, commerce: commerce) }
  let(:product) { create(:product, commerce: commerce, product_category: category, base_price: Money.new(10_000, "COP")) }

  def build_cart(cart_params)
    described_class.new(commerce: commerce, cart_params: cart_params).build
  end

  describe "#build" do
    it "builds one order item for a single cart line" do
      result = build_cart([ { product_id: product.id, variant_ids: [], modifier_ids: [], quantity: 2 } ])

      expect(result.size).to eq(1)
      expect(result.first).to include(product_name: product.name, base_price: product.base_price, quantity: 2)
    end

    it "sums quantities for identical product + variant + modifier selections into one order item" do
      group = create(:variant_group, product: product)
      variant = create(:variant, variant_group: group)

      result = build_cart([
        { product_id: product.id, variant_ids: [ variant.id ], modifier_ids: [], quantity: 2 },
        { product_id: product.id, variant_ids: [ variant.id ], modifier_ids: [], quantity: 3 }
      ])

      expect(result.size).to eq(1)
      expect(result.first[:quantity]).to eq(5)
    end

    it "keeps separate order items when the variant selection differs" do
      group = create(:variant_group, product: product)
      small = create(:variant, variant_group: group, name: "Small")
      large = create(:variant, variant_group: group, name: "Large")

      result = build_cart([
        { product_id: product.id, variant_ids: [ small.id ], modifier_ids: [], quantity: 1 },
        { product_id: product.id, variant_ids: [ large.id ], modifier_ids: [], quantity: 1 }
      ])

      expect(result.size).to eq(2)
      expect(result.map { |item| item[:quantity] }).to contain_exactly(1, 1)
    end

    it "keeps separate order items when the modifier selection differs" do
      group = create(:modifier_group, product: product)
      cheese = create(:modifier, modifier_group: group, name: "Cheese")
      bacon = create(:modifier, modifier_group: group, name: "Bacon")

      result = build_cart([
        { product_id: product.id, variant_ids: [], modifier_ids: [ cheese.id ], quantity: 1 },
        { product_id: product.id, variant_ids: [], modifier_ids: [ bacon.id ], quantity: 1 }
      ])

      expect(result.size).to eq(2)
    end

    it "treats the same set of modifiers selected in a different order as identical" do
      group = create(:modifier_group, product: product)
      cheese = create(:modifier, modifier_group: group, name: "Cheese")
      bacon = create(:modifier, modifier_group: group, name: "Bacon")

      result = build_cart([
        { product_id: product.id, variant_ids: [], modifier_ids: [ cheese.id, bacon.id ], quantity: 1 },
        { product_id: product.id, variant_ids: [], modifier_ids: [ bacon.id, cheese.id ], quantity: 1 }
      ])

      expect(result.size).to eq(1)
      expect(result.first[:quantity]).to eq(2)
    end

    it "snapshots variant and modifier names and price deltas at build time" do
      group = create(:variant_group, product: product, name: "Size")
      variant = create(:variant, variant_group: group, name: "Large", price_delta: Money.new(2_000, "COP"))
      modifier_group = create(:modifier_group, product: product, name: "Extras")
      modifier = create(:modifier, modifier_group: modifier_group, name: "Cheese", price_delta: Money.new(1_000, "COP"))

      result = build_cart([ { product_id: product.id, variant_ids: [ variant.id ], modifier_ids: [ modifier.id ], quantity: 1 } ])

      expect(result.first[:variants]).to eq(
        [ { variant_group_name: "Size", variant_name: "Large", price_delta: Money.new(2_000, "COP") } ]
      )
      expect(result.first[:modifiers]).to eq(
        [ { modifier_group_name: "Extras", modifier_name: "Cheese", price_delta: Money.new(1_000, "COP") } ]
      )
    end

    it "raises when a required variant group has an active variant but none is selected" do
      group = create(:variant_group, product: product, is_required: true)
      create(:variant, variant_group: group)

      expect do
        build_cart([ { product_id: product.id, variant_ids: [], modifier_ids: [], quantity: 1 } ])
      end.to raise_error(described_class::InvalidCartError)
    end

    it "raises when a required modifier group has an active modifier but none is selected" do
      group = create(:modifier_group, product: product, is_required: true)
      create(:modifier, modifier_group: group)

      expect do
        build_cart([ { product_id: product.id, variant_ids: [], modifier_ids: [], quantity: 1 } ])
      end.to raise_error(described_class::InvalidCartError)
    end

    it "does not raise for a required variant group that has no variants at all" do
      create(:variant_group, product: product, is_required: true)

      result = build_cart([ { product_id: product.id, variant_ids: [], modifier_ids: [], quantity: 1 } ])

      expect(result.size).to eq(1)
    end

    it "does not raise for a required variant group whose only variant is inactive" do
      group = create(:variant_group, product: product, is_required: true)
      create(:variant, variant_group: group, is_active: false)

      result = build_cart([ { product_id: product.id, variant_ids: [], modifier_ids: [], quantity: 1 } ])

      expect(result.size).to eq(1)
    end

    it "does not raise for a required modifier group that has no modifiers at all" do
      create(:modifier_group, product: product, is_required: true)

      result = build_cart([ { product_id: product.id, variant_ids: [], modifier_ids: [], quantity: 1 } ])

      expect(result.size).to eq(1)
    end

    it "does not raise for a required modifier group whose only modifier is inactive" do
      group = create(:modifier_group, product: product, is_required: true)
      create(:modifier, modifier_group: group, is_active: false)

      result = build_cart([ { product_id: product.id, variant_ids: [], modifier_ids: [], quantity: 1 } ])

      expect(result.size).to eq(1)
    end

    it "raises when fewer than min_selected modifiers are chosen" do
      group = create(:modifier_group, product: product, min_selected: 2)
      modifier = create(:modifier, modifier_group: group)

      expect do
        build_cart([ { product_id: product.id, variant_ids: [], modifier_ids: [ modifier.id ], quantity: 1 } ])
      end.to raise_error(described_class::InvalidCartError)
    end

    it "raises when more than max_selected modifiers are chosen" do
      group = create(:modifier_group, product: product, max_selected: 1)
      first_modifier = create(:modifier, modifier_group: group)
      second_modifier = create(:modifier, modifier_group: group)

      expect do
        build_cart([
          { product_id: product.id, variant_ids: [], modifier_ids: [ first_modifier.id, second_modifier.id ], quantity: 1 }
        ])
      end.to raise_error(described_class::InvalidCartError)
    end

    it "does not raise when exactly min_selected modifiers are chosen" do
      group = create(:modifier_group, product: product, min_selected: 2)
      first_modifier = create(:modifier, modifier_group: group)
      second_modifier = create(:modifier, modifier_group: group)

      result = build_cart([
        { product_id: product.id, variant_ids: [], modifier_ids: [ first_modifier.id, second_modifier.id ], quantity: 1 }
      ])

      expect(result.size).to eq(1)
    end

    it "does not raise when exactly max_selected modifiers are chosen" do
      group = create(:modifier_group, product: product, max_selected: 2)
      first_modifier = create(:modifier, modifier_group: group)
      second_modifier = create(:modifier, modifier_group: group)

      result = build_cart([
        { product_id: product.id, variant_ids: [], modifier_ids: [ first_modifier.id, second_modifier.id ], quantity: 1 }
      ])

      expect(result.size).to eq(1)
    end

    it "raises when more than one variant is selected from the same group" do
      group = create(:variant_group, product: product)
      small = create(:variant, variant_group: group, name: "Small")
      large = create(:variant, variant_group: group, name: "Large")

      expect do
        build_cart([ { product_id: product.id, variant_ids: [ small.id, large.id ], modifier_ids: [], quantity: 1 } ])
      end.to raise_error(described_class::InvalidCartError)
    end

    it "raises when a variant does not belong to the given product" do
      other_product = create(:product, commerce: commerce, product_category: category)
      other_group = create(:variant_group, product: other_product)
      foreign_variant = create(:variant, variant_group: other_group)

      expect do
        build_cart([ { product_id: product.id, variant_ids: [ foreign_variant.id ], modifier_ids: [], quantity: 1 } ])
      end.to raise_error(described_class::InvalidCartError)
    end

    it "raises when a modifier does not belong to the given product" do
      other_product = create(:product, commerce: commerce, product_category: category)
      other_group = create(:modifier_group, product: other_product)
      foreign_modifier = create(:modifier, modifier_group: other_group)

      expect do
        build_cart([ { product_id: product.id, variant_ids: [], modifier_ids: [ foreign_modifier.id ], quantity: 1 } ])
      end.to raise_error(described_class::InvalidCartError)
    end

    it "raises when the product belongs to a different commerce" do
      foreign_product = create(:product, commerce: create(:commerce))

      expect do
        build_cart([ { product_id: foreign_product.id, variant_ids: [], modifier_ids: [], quantity: 1 } ])
      end.to raise_error(described_class::InvalidCartError)
    end

    it "raises when an inactive variant is selected" do
      group = create(:variant_group, product: product)
      variant = create(:variant, variant_group: group, is_active: false)

      expect do
        build_cart([ { product_id: product.id, variant_ids: [ variant.id ], modifier_ids: [], quantity: 1 } ])
      end.to raise_error(described_class::InvalidCartError)
    end

    it "raises when an inactive modifier is selected" do
      group = create(:modifier_group, product: product)
      modifier = create(:modifier, modifier_group: group, is_active: false)

      expect do
        build_cart([ { product_id: product.id, variant_ids: [], modifier_ids: [ modifier.id ], quantity: 1 } ])
      end.to raise_error(described_class::InvalidCartError)
    end

    it "raises when quantity is zero" do
      expect do
        build_cart([ { product_id: product.id, variant_ids: [], modifier_ids: [], quantity: 0 } ])
      end.to raise_error(described_class::InvalidCartError)
    end

    it "raises when quantity is negative" do
      expect do
        build_cart([ { product_id: product.id, variant_ids: [], modifier_ids: [], quantity: -1 } ])
      end.to raise_error(described_class::InvalidCartError)
    end

    it "raises when the product does not exist" do
      expect do
        build_cart([ { product_id: SecureRandom.uuid, variant_ids: [], modifier_ids: [], quantity: 1 } ])
      end.to raise_error(described_class::InvalidCartError)
    end
  end
end
