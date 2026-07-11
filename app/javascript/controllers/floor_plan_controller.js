import { Controller } from "@hotwired/stimulus"

// One instance per zone canvas. The controller element IS the canvas.
export default class extends Controller {
  connect() {
    this.cell = parseInt(this.element.dataset.floorPlanCellValue, 10) || 24
    this._down = this.onPointerDown.bind(this)
    this.element.addEventListener("pointerdown", this._down)
  }

  disconnect() {
    this.element.removeEventListener("pointerdown", this._down)
  }

  onPointerDown(event) {
    const tableEl = event.target.closest(".floor-plan-table")
    if (!tableEl || !this.element.contains(tableEl)) return
    if (event.target.closest(".table-controls")) return // let pencil/trash work
    event.preventDefault()
    if (event.target.closest(".resize-handle")) this.startResize(event, tableEl)
    else this.startDrag(event, tableEl)
  }

  startDrag(event, el) {
    const cell = this.cell
    const w = this.gridUnits(el.style.width)
    const h = this.gridUnits(el.style.height)
    const startX = event.clientX, startY = event.clientY
    const gx0 = this.gridUnits(el.style.left)
    const gy0 = this.gridUnits(el.style.top)
    let gx = gx0, gy = gy0

    // Canvas bounds and every other table's rect, all in grid cells (fixed for the drag).
    const cols = Math.floor(this.element.clientWidth / cell)
    const rows = Math.floor(this.element.clientHeight / cell)
    const others = Array.from(this.element.querySelectorAll(".floor-plan-table"))
      .filter((t) => t !== el)
      .map((t) => ({
        x: this.gridUnits(t.style.left), y: this.gridUnits(t.style.top),
        w: this.gridUnits(t.style.width), h: this.gridUnits(t.style.height)
      }))

    const fits = (x, y) => {
      if (x < 0 || y < 0 || x + w > cols || y + h > rows) return false
      return !others.some((o) => x < o.x + o.w && x + w > o.x && y < o.y + o.h && y + h > o.y)
    }

    const move = (e) => {
      // Target cell straight from the cursor, then slide toward it one cell at a
      // time so it stops at the canvas edge or against another table.
      const targetX = gx0 + Math.round((e.clientX - startX) / cell)
      const targetY = gy0 + Math.round((e.clientY - startY) / cell)
      const stepX = Math.sign(targetX - gx)
      while (gx !== targetX && fits(gx + stepX, gy)) gx += stepX
      const stepY = Math.sign(targetY - gy)
      while (gy !== targetY && fits(gx, gy + stepY)) gy += stepY
      el.style.left = gx * cell + "px"
      el.style.top = gy * cell + "px"
    }
    this.trackPointer(move, () => this.persist(el, { pos_x: gx, pos_y: gy }))
  }

  startResize(event, el) {
    const startX = event.clientX, startY = event.clientY
    const w0 = parseInt(el.style.width, 10), h0 = parseInt(el.style.height, 10)
    const move = (e) => {
      el.style.width = Math.max(this.cell, w0 + e.clientX - startX) + "px"
      el.style.height = Math.max(this.cell, h0 + e.clientY - startY) + "px"
    }
    this.trackPointer(move, () => {
      const w = Math.max(1, Math.round(parseInt(el.style.width, 10) / this.cell))
      const h = Math.max(1, Math.round(parseInt(el.style.height, 10) / this.cell))
      el.style.width = w * this.cell + "px"
      el.style.height = h * this.cell + "px"
      this.persist(el, { width: w, height: h })
    })
  }

  // Run `move` on every pointermove, then `onFinish` once on pointerup, cleaning
  // up both listeners.
  trackPointer(move, onFinish) {
    const up = () => {
      window.removeEventListener("pointermove", move)
      window.removeEventListener("pointerup", up)
      onFinish()
    }
    window.addEventListener("pointermove", move)
    window.addEventListener("pointerup", up)
  }

  gridUnits(px) {
    return Math.round((parseInt(px, 10) || 0) / this.cell)
  }

  persist(el, attrs) {
    const token = document.querySelector('meta[name="csrf-token"]')?.content
    fetch(el.dataset.updateUrl, {
      method: "PATCH",
      headers: { "Content-Type": "application/json", "Accept": "application/json", "X-CSRF-Token": token },
      body: JSON.stringify({ table: attrs })
    })
  }
}
