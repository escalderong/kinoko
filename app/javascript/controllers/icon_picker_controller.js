import { Controller } from "@hotwired/stimulus"

// Drives the compact icon picker. Positions the native popover under its
// trigger (getBoundingClientRect + fixed positioning, so it works without CSS
// anchor positioning), reflects the chosen icon in the trigger, and closes the
// popover on select. The grid highlight itself is pure CSS (:has checked).
export default class extends Controller {
  static targets = ["preview", "menu", "trigger"]

  reposition(event) {
    if (event && event.newState !== "open") return
    const rect = this.triggerTarget.getBoundingClientRect()
    Object.assign(this.menuTarget.style, {
      position: "fixed",
      margin: "0",
      inset: "auto",
      top: `${rect.bottom + 4}px`,
      left: `${rect.left}px`,
    })
  }

  select(event) {
    const value = event.target.value
    this.previewTarget.className = `${this.previewTarget.dataset.baseClass} fa-${value}`
    if (this.hasMenuTarget && this.menuTarget.hidePopover) this.menuTarget.hidePopover()
  }
}
