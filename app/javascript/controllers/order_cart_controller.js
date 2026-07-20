import { Controller } from "@hotwired/stimulus"

// Client-side cart for a product picker (new order, or later reused for
// adding items to an existing order — see the form's submit URL, not this
// controller, for that distinction). Every product's variant/modifier panel
// renders hidden up front; selecting a product row toggles visibility, same
// "render everything, toggle with JS" idiom as zones_controller. Adding a
// line pushes it into an in-memory cart array, rendered as a summary list and
// serialized into a hidden JSON field submitted with the real form.
//
// Required-group / min-max validation here is UX only (enables/disables the
// per-product "Add to cart" button). The server (OrderCartBuilder) always
// re-validates independently — never trust the client alone.
export default class extends Controller {
  static targets = ["panel", "cartList", "cartEmpty", "cartField", "itemTemplate", "submitButton"]

  connect() {
    this.cart = []
  }

  selectProduct(event) {
    const productId = event.currentTarget.dataset.productId

    this.panelTargets.forEach((panel) => {
      panel.classList.toggle("hidden", panel.dataset.productId !== productId)
    })

    const panel = this.panelTargets.find((candidate) => candidate.dataset.productId === productId)
    if (panel) this.validatePanel(panel)
  }

  validate(event) {
    const panel = event.target.closest('[data-order-cart-target="panel"]')
    if (panel) this.validatePanel(panel)
  }

  addToCart(event) {
    const panel = event.target.closest('[data-order-cart-target="panel"]')
    if (!panel || !this.panelValid(panel)) return

    const variantInputs = [...panel.querySelectorAll('input[type="radio"]:checked')]
    const modifierInputs = [...panel.querySelectorAll('input[type="checkbox"]:checked')]
    const quantityInput = panel.querySelector('[data-order-cart-target="quantityInput"]')
    const quantity = parseInt(quantityInput?.value, 10) || 1

    this.cart.push({
      product_id: panel.dataset.productId,
      variant_ids: variantInputs.map((input) => input.value),
      modifier_ids: modifierInputs.map((input) => input.value),
      quantity,
      label: this.describeLine(panel.dataset.productName, variantInputs, modifierInputs, quantity)
    })

    variantInputs.forEach((input) => { input.checked = false })
    modifierInputs.forEach((input) => { input.checked = false })
    if (quantityInput) quantityInput.value = 1

    this.validatePanel(panel)
    this.renderCart()
  }

  removeFromCart(event) {
    const index = parseInt(event.currentTarget.dataset.index, 10)
    this.cart.splice(index, 1)
    this.renderCart()
  }

  validatePanel(panel) {
    const valid = this.panelValid(panel)
    const addButton = panel.querySelector('[data-order-cart-target="addButton"]')
    const hint = panel.querySelector('[data-order-cart-target="hint"]')

    if (addButton) addButton.disabled = !valid
    if (hint) hint.classList.toggle("hidden", valid)
  }

  panelValid(panel) {
    const variantGroups = panel.querySelectorAll('[data-order-cart-target="variantGroup"]')
    for (const group of variantGroups) {
      const checked = group.querySelectorAll('input[type="radio"]:checked').length
      if (checked > 1) return false
      if (group.dataset.groupRequired === "true" && checked !== 1) return false
    }

    const modifierGroups = panel.querySelectorAll('[data-order-cart-target="modifierGroup"]')
    for (const group of modifierGroups) {
      const checked = group.querySelectorAll('input[type="checkbox"]:checked').length
      const min = parseInt(group.dataset.groupMin, 10) || 0
      const max = group.dataset.groupMax ? parseInt(group.dataset.groupMax, 10) : null
      const required = group.dataset.groupRequired === "true"

      if (required && checked < 1) return false
      if (checked < min) return false
      if (max !== null && checked > max) return false
    }

    return true
  }

  describeLine(productName, variantInputs, modifierInputs, quantity) {
    const names = [...variantInputs, ...modifierInputs].map((input) => input.dataset.optionName)
    const suffix = names.length ? ` (${names.join(", ")})` : ""
    return `${quantity}x ${productName}${suffix}`
  }

  renderCart() {
    this.cartListTarget.innerHTML = ""

    this.cart.forEach((line, index) => {
      const node = this.itemTemplateTarget.content.firstElementChild.cloneNode(true)
      node.querySelector('[data-order-cart-target="itemLabel"]').textContent = line.label
      node.querySelector('[data-order-cart-target="removeButton"]').dataset.index = index
      this.cartListTarget.appendChild(node)
    })

    if (this.hasCartEmptyTarget) this.cartEmptyTarget.classList.toggle("hidden", this.cart.length > 0)
    if (this.hasSubmitButtonTarget) this.submitButtonTarget.disabled = this.cart.length === 0

    this.cartFieldTarget.value = JSON.stringify(
      this.cart.map(({ product_id, variant_ids, modifier_ids, quantity }) => ({ product_id, variant_ids, modifier_ids, quantity }))
    )
  }
}
