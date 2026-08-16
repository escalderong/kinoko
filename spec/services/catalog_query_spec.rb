require "rails_helper"

RSpec.describe CatalogQuery do
  let(:commerce) { create(:commerce) }

  def entries_for(commerce)
    described_class.new(commerce).visible_entries
  end

  describe "#visible_entries" do
    it "returns each category paired with its products" do
      category = create(:product_category, commerce: commerce, name: "Drinks")
      product = create(:product, commerce: commerce, product_category: category, name: "Latte")

      entries = entries_for(commerce)

      expect(entries.size).to eq(1)
      expect(entries.first.category).to eq(category)
      expect(entries.first.products).to eq([ product ])
    end

    it "excludes categories that have no products at all" do
      create(:product_category, commerce: commerce, name: "Empty Category")

      expect(entries_for(commerce)).to be_empty
    end

    it "excludes categories whose only products are inactive" do
      category = create(:product_category, commerce: commerce)
      create(:product, commerce: commerce, product_category: category, is_active: false)

      expect(entries_for(commerce)).to be_empty
    end

    it "excludes inactive products from an otherwise visible category" do
      category = create(:product_category, commerce: commerce)
      active = create(:product, commerce: commerce, product_category: category, name: "Active", is_active: true)
      create(:product, commerce: commerce, product_category: category, name: "Inactive", is_active: false)

      expect(entries_for(commerce).first.products).to eq([ active ])
    end

    it "orders categories and their products by name" do
      category_b = create(:product_category, commerce: commerce, name: "B Category")
      category_a = create(:product_category, commerce: commerce, name: "A Category")
      create(:product, commerce: commerce, product_category: category_a, name: "Zebra")
      create(:product, commerce: commerce, product_category: category_a, name: "Apple")
      create(:product, commerce: commerce, product_category: category_b, name: "Anything")

      entries = entries_for(commerce)

      expect(entries.map { |entry| entry.category.name }).to eq([ "A Category", "B Category" ])
      expect(entries.first.products.map(&:name)).to eq([ "Apple", "Zebra" ])
    end

    it "does not leak another commerce's categories or products" do
      other_commerce = create(:commerce)
      other_category = create(:product_category, commerce: other_commerce)
      create(:product, commerce: other_commerce, product_category: other_category)
      create(:product_category, commerce: commerce) # this commerce's own empty category

      expect(entries_for(commerce)).to be_empty
      expect(entries_for(other_commerce).size).to eq(1)
    end
  end

  describe "caching" do
    include ActiveSupport::Testing::TimeHelpers

    # Test env runs Rails.cache as :null_store (see config/environments/test.rb),
    # which never actually caches — swap in a real in-process store for this
    # block only, so the caching behavior under test is exercised for real.
    around do |example|
      original_cache = Rails.cache
      Rails.cache = ActiveSupport::Cache::MemoryStore.new
      example.run
      Rails.cache = original_cache
    end

    it "only builds the catalog once across consecutive calls" do
      category = create(:product_category, commerce: commerce)
      create(:product, commerce: commerce, product_category: category)
      query = described_class.new(commerce)

      expect(query).to receive(:fetch_visible_entries).once.and_call_original

      2.times { query.visible_entries }
    end

    it "reflects catalog changes after the commerce touch chain invalidates the cache" do
      category = create(:product_category, commerce: commerce)
      product = create(:product, commerce: commerce, product_category: category, name: "Original")

      expect(entries_for(commerce).first.products.map(&:name)).to eq([ "Original" ])

      # The cache key is keyed on commerce.updated_at.to_i (second precision),
      # so travel forward a second to guarantee the touch below lands on a
      # different cache key instead of racing the clock in a fast test.
      travel(1.second) { product.update!(name: "Renamed") }

      expect(entries_for(commerce).first.products.map(&:name)).to eq([ "Renamed" ])
    end
  end
end
