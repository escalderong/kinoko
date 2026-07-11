import { Controller } from "@hotwired/stimulus"

// Client-side zone switching: all zones are rendered once on page load, and
// switching between them just toggles visibility — no server round-trip.
export default class extends Controller {
  static targets = ["tab", "panel", "floorZoneField"]

  switch(event) {
    const zoneId = event.currentTarget.dataset.zoneId
    this.tabTargets.forEach((tab) => tab.classList.toggle("menu-active", tab.dataset.zoneId === zoneId))
    this.panelTargets.forEach((panel) => panel.classList.toggle("hidden", panel.dataset.zoneId !== zoneId))
    if (this.hasFloorZoneFieldTarget) this.floorZoneFieldTarget.value = zoneId
  }
}
