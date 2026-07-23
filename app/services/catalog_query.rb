# Fetches a commerce's orderable catalog: every active product, grouped by
# category, with categories that have no visible products dropped. A plain
# Ruby object (not a controller) because this is query/business logic, not
# view logic — it's called once from App::TablesController#show and the
# result is threaded down through the modal partials as an explicit local,
# the same way OrderCartBuilder keeps cart-building logic out of the view.
class CatalogQuery
  Entry = Struct.new(:category, :products, keyword_init: true)

  def initialize(commerce)
    @commerce = commerce
  end

  def visible_entries
    # .includes batches each association into one `$in` query instead of one
    # query per product per group — MongoDB has no SQL-style join, this is
    # the Mongoid-idiomatic way to avoid N+1 across referenced (non-embedded)
    # collections.
    products_by_category = commerce.products.where(is_active: true)
      .includes(variant_groups: :variants, modifier_groups: :modifiers)
      .asc(:name).to_a.group_by(&:product_category_id)

    commerce.product_categories.asc(:name).to_a
      .map { |category| Entry.new(category: category, products: products_by_category[category.id] || []) }
      .select { |entry| entry.products.present? }
  end

  private

  attr_reader :commerce
end
