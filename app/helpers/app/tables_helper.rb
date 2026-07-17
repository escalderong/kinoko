module App::TablesHelper
  GRID_CELL_PX = 24

  def table_rect_style(table)
    cell = GRID_CELL_PX
    "left:#{table.pos_x * cell}px; top:#{table.pos_y * cell}px; width:#{table.width * cell}px; height:#{table.height * cell}px"
  end
end
