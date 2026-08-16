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
    Rails.cache.fetch(cache_key) { fetch_visible_entries }
  end

  private

  attr_reader :commerce

  def cache_key
    [ "catalog_query/visible_entries", commerce.id, commerce.updated_at.to_i ]
  end

  def fetch_visible_entries
    # .includes here preloads variant_groups/variants and modifier_groups/
    # modifiers in a handful of queries instead of N+1 per product.
    products_by_category = commerce.products.where(is_active: true)
      .includes(variant_groups: :variants, modifier_groups: :modifiers)
      .order(:name).to_a.group_by(&:product_category_id)

    commerce.product_categories.order(:name).to_a
      .map { |category| Entry.new(category: category, products: products_by_category[category.id] || []) }
      .select { |entry| entry.products.present? }
  end
end
