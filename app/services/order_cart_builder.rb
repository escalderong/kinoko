# Builds the OrderItem data for a new order from raw cart params submitted by
# the new-order modal. Not a model, not a controller concern — a plain Ruby
# object so the grouping/validation logic (the highest-risk part of this
# feature) can be unit tested in isolation from Rails/Mongoid persistence.
#
# Input shape (cart_params): an array of hashes, each
#   { product_id:, variant_ids: [...], modifier_ids: [...], quantity: }
#
# Output shape (#build): an array of plain hashes ready to persist as
# OrderItem + OrderItemVariant/OrderItemModifier snapshots:
#   { product_name:, base_price:, quantity:,
#     variants: [{ variant_group_name:, variant_name:, price_delta: }],
#     modifiers: [{ modifier_group_name:, modifier_name:, price_delta: }] }
#
# Cart lines are grouped by product + the exact set of selected variants and
# modifiers: identical groups are summed into a single OrderItem, any
# difference in the variant/modifier set produces a separate OrderItem.
class OrderCartBuilder
  class InvalidCartError < StandardError; end

  Line = Struct.new(:product, :variants, :modifiers, :quantity, keyword_init: true)

  def initialize(commerce:, cart_params:)
    @commerce = commerce
    @cart_params = Array(cart_params)
  end

  def build
    products_by_id = load_products
    lines = cart_params.map { |params| build_line(params, products_by_id) }
    lines.group_by { |line| grouping_key(line) }.map { |_key, group| build_order_item_data(group) }
  end

  private

  attr_reader :commerce, :cart_params

  # One batched query for every distinct product in the cart (plus their
  # variant/modifier groups) instead of one query per cart line — the same
  # product commonly appears in several lines with different selections.
  def load_products
    ids = cart_params.filter_map { |params| params[:product_id] }.map(&:to_s).uniq
    commerce.products.where(:id.in => ids)
      .includes(variant_groups: :variants, modifier_groups: :modifiers)
      .index_by { |product| product.id.to_s }
  end

  def build_line(params, products_by_id)
    product = products_by_id[params[:product_id].to_s]
    raise InvalidCartError, I18n.t("app.tables.orders.errors.product_unavailable") unless product

    quantity = params[:quantity].to_i
    raise InvalidCartError, I18n.t("app.tables.orders.errors.quantity_invalid") unless quantity.positive?

    variants = resolve_and_validate_variants(product, normalize_ids(params[:variant_ids]))
    modifiers = resolve_and_validate_modifiers(product, normalize_ids(params[:modifier_ids]))

    validate_variant_selection!(product, variants)
    validate_modifier_selection!(product, modifiers)

    Line.new(product: product, variants: variants, modifiers: modifiers, quantity: quantity)
  end

  def normalize_ids(ids)
    Array(ids).map(&:to_s).reject(&:blank?).uniq
  end

  # Fetches the selected variants AND rejects any that are inactive or belong
  # to a different product (same-commerce cross-product references, not just
  # cross-commerce ones) — resolving and validating are done together here so
  # a caller can't accidentally use the result without both checks applied.
  def resolve_and_validate_variants(product, variant_ids)
    return [] if variant_ids.empty?

    variants = Variant.where(:id.in => variant_ids).to_a
    raise InvalidCartError, I18n.t("app.tables.orders.errors.variant_unavailable") if variants.size != variant_ids.size

    variants.each do |variant|
      next if variant.is_active && variant.variant_group.product_id == product.id

      raise InvalidCartError, I18n.t("app.tables.orders.errors.variant_unavailable")
    end

    variants
  end

  # See resolve_and_validate_variants — same shape, for modifiers.
  def resolve_and_validate_modifiers(product, modifier_ids)
    return [] if modifier_ids.empty?

    modifiers = Modifier.where(:id.in => modifier_ids).to_a
    raise InvalidCartError, I18n.t("app.tables.orders.errors.modifier_unavailable") if modifiers.size != modifier_ids.size

    modifiers.each do |modifier|
      next if modifier.is_active && modifier.modifier_group.product_id == product.id

      raise InvalidCartError, I18n.t("app.tables.orders.errors.modifier_unavailable")
    end

    modifiers
  end

  def validate_variant_selection!(product, variants)
    by_group = variants.group_by(&:variant_group_id)

    by_group.each_value do |selected|
      raise InvalidCartError, I18n.t("app.tables.orders.errors.single_selection") if selected.size > 1
    end

    # A required group with no active variants to choose from has nothing a
    # waiter could ever select — treat it as trivially satisfied rather than
    # permanently blocking the product from being ordered (catalog authoring
    # gap, not a cart error).
    product.variant_groups.select { |group| group.is_required && group.variants.any?(&:is_active) }.each do |group|
      next if by_group[group.id]&.size == 1

      raise InvalidCartError, I18n.t("app.tables.orders.errors.group_required", group: group.name)
    end
  end

  def validate_modifier_selection!(product, modifiers)
    by_group = modifiers.group_by(&:modifier_group_id)

    product.modifier_groups.each do |group|
      next if group.modifiers.none?(&:is_active)

      count = by_group[group.id]&.size || 0
      min = group.min_selected.to_i

      if group.is_required && count < 1
        raise InvalidCartError, I18n.t("app.tables.orders.errors.group_required", group: group.name)
      end

      raise InvalidCartError, I18n.t("app.tables.orders.errors.min_selected", group: group.name, min: min) if count < min

      if group.max_selected.present? && count > group.max_selected
        raise InvalidCartError, I18n.t("app.tables.orders.errors.max_selected", group: group.name, max: group.max_selected)
      end
    end
  end

  def grouping_key(line)
    [
      line.product.id.to_s,
      line.variants.map { |variant| variant.id.to_s }.sort,
      line.modifiers.map { |modifier| modifier.id.to_s }.sort
    ]
  end

  def build_order_item_data(lines)
    representative = lines.first

    {
      product_name: representative.product.name,
      base_price: representative.product.base_price,
      quantity: lines.sum(&:quantity),
      variants: representative.variants.map do |variant|
        { variant_group_name: variant.variant_group.name, variant_name: variant.name, price_delta: variant.price_delta }
      end,
      modifiers: representative.modifiers.map do |modifier|
        { modifier_group_name: modifier.modifier_group.name, modifier_name: modifier.name, price_delta: modifier.price_delta }
      end
    }
  end
end
