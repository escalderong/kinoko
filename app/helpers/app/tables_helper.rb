module App::TablesHelper
  GRID_CELL_PX = 24

  def table_rect_style(table)
    "#{table_position_style(table)}; #{table_size_style(table)}"
  end

  # Position only, no width/height — used to anchor the aura wrapper on the
  # grid without constraining its box, since aura's own padding needs room to
  # bleed outward around the (fixed-size) table div nested inside it.
  def table_position_style(table)
    cell = GRID_CELL_PX
    "left:#{table.pos_x * cell}px; top:#{table.pos_y * cell}px"
  end

  def table_size_style(table)
    cell = GRID_CELL_PX
    "width:#{table.width * cell}px; height:#{table.height * cell}px"
  end

  # Shared by the variant and modifier lines in an order item's current-items
  # display — both are "group: name" plus an optional "(+price)" suffix.
  def order_item_option_label(group_name, name, price_delta)
    label = "#{group_name}: #{name}"
    price_delta.zero? ? label : "#{label} (+#{price_delta.format})"
  end
end
