import { Controller } from "@hotwired/stimulus"
import { Turbo } from "@hotwired/turbo-rails"

// Match the server page size to the space between the heading and the folio.
export default class extends Controller {
  static targets = ["rows"]
  static values = { perPage: Number, page: Number }

  connect() {
    this.observer = new ResizeObserver(() => {
      clearTimeout(this.resizeTimer)
      this.resizeTimer = setTimeout(() => this.fitPage(), 150)
    })
    this.observer.observe(this.rowsTarget)
  }

  disconnect() {
    this.observer.disconnect()
    clearTimeout(this.resizeTimer)
  }

  fitPage() {
    if (window.matchMedia("(max-height: 539px)").matches) return

    const rowHeight = parseFloat(getComputedStyle(this.rowsTarget).getPropertyValue("--notebook-row-height"))
    if (!rowHeight || !this.rowsTarget.clientHeight) return

    const perPage = Math.max(1, Math.min(20, Math.floor(this.rowsTarget.clientHeight / rowHeight)))
    if (perPage === this.perPageValue) return

    const url = new URL(window.location.href)
    // Keep the first visible record on the page when the viewport changes.
    const firstItem = (this.pageValue - 1) * this.perPageValue
    url.searchParams.set("page", Math.floor(firstItem / perPage) + 1)
    url.searchParams.set("per_page", perPage)
    Turbo.visit(url.toString(), { action: "replace" })
  }
}
