import { Controller } from "@hotwired/stimulus"

// Native details works without JavaScript; these are desktop dropdown conveniences.
export default class extends Controller {
  fit() {
    const menu = this.element.querySelector(".app-notebook-filter-menu")
    if (!menu) return

    menu.classList.remove("app-notebook-filter-menu--constrained")
    menu.style.removeProperty("--notebook-filter-max-height")
    if (!this.element.open || window.matchMedia("(max-width: 991.98px)").matches) return

    const viewport = window.visualViewport
    const bottom = viewport ? viewport.offsetTop + viewport.height : window.innerHeight
    const bounds = menu.getBoundingClientRect()
    const available = Math.max(0, bottom - bounds.top - 16)
    if (bounds.height > available) {
      menu.style.setProperty("--notebook-filter-max-height", `${available}px`)
      menu.classList.add("app-notebook-filter-menu--constrained")
    }
  }

  close(event) {
    if (!this.element.open) return
    event.preventDefault()
    event.stopPropagation()
    this.element.open = false
    this.element.querySelector("summary").focus()
  }

  dismiss(event) {
    if (window.matchMedia("(max-width: 991.98px)").matches) return
    if (!this.element.contains(event.target)) this.element.open = false
  }
}
