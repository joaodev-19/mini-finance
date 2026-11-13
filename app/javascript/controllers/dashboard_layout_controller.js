import { Controller } from "@hotwired/stimulus"

// Lay out existing annotations; financial values always come from the server.
export default class extends Controller {
  static targets = ["content", "viewport", "position", "controls", "previous", "next"]

  connect() {
    this.page = 0
    this.pages = 1
    this.mobile = window.matchMedia("(max-width: 991.98px)")
    this.observer = new ResizeObserver(() => {
      cancelAnimationFrame(this.frame)
      this.frame = requestAnimationFrame(() => this.layout())
    })
    this.onBreakpointChange = () => {
      this.observer.disconnect()
      if (!this.mobile.matches) this.observer.observe(this.contentTarget)
      this.layout()
    }
    this.mobile.addEventListener("change", this.onBreakpointChange)
    this.onBreakpointChange()
    this.onFontsReady = () => { if (this.element.isConnected) this.layout() }
    document.fonts.ready.then(this.onFontsReady)
  }

  disconnect() {
    this.observer.disconnect()
    this.mobile.removeEventListener("change", this.onBreakpointChange)
    cancelAnimationFrame(this.frame)
  }

  layout() {
    this.naturalFlow = this.mobile.matches
    if (this.naturalFlow) {
      if (this.hasViewportTarget) {
        this.viewportTarget.dataset.layout = "spread"
        this.viewportTarget.removeAttribute("tabindex")
      }
      this.page = 0
      this.pages = 1
      this.updatePosition()
      return
    }

    if (!this.hasViewportTarget) {
      this.pages = 1
      this.updatePosition()
      return
    }

    const viewport = this.viewportTarget
    viewport.setAttribute("tabindex", "0")
    if (viewport.dataset.categoryPages) {
      this.layoutCategories()
    } else {
      viewport.dataset.layout = "spread"
      const summary = viewport.querySelector(".app-dashboard-summary")
      const consumption = viewport.querySelector(".app-dashboard-consumption")
      const comparison = viewport.querySelector(".app-dashboard-comparison")
      this.reference ||= comparison.querySelector(".app-dashboard-comparison-reference")
      comparison.append(this.reference)
      const gap = parseFloat(getComputedStyle(viewport).rowGap) || 0
      const needed = summary.offsetHeight + consumption.offsetHeight + comparison.offsetHeight + gap * 2
      let panels = [viewport]
      if (needed <= viewport.clientHeight) {
        this.labels = ["Resumo e comparação"]
      } else {
        viewport.dataset.layout = "chapters"
        if (viewport.clientWidth >= 620 && [summary, consumption, comparison].every(panel => panel.offsetHeight <= viewport.clientHeight)) {
          panels = [summary, consumption, comparison]
        } else {
          viewport.dataset.layout = "deck"
          panels = [...summary.querySelectorAll(".app-dashboard-slip"), consumption, comparison]
          if (comparison.offsetHeight > viewport.clientHeight) {
            comparison.querySelector(".app-dashboard-comparison-item:last-child").append(this.reference)
            viewport.dataset.layout = "details"
            panels = [...summary.querySelectorAll(".app-dashboard-slip"), consumption, ...comparison.querySelectorAll(".app-dashboard-comparison-item")]
          }
        }
      }
      this.pages = panels.length
      if (this.pages > 1) this.labels = panels.map(panel => panel.dataset.dashboardLabel || panel.querySelector("h3").textContent.trim())
    }

    this.page = Math.min(this.page, this.pages - 1)
    this.scrollToPage("instant")
    this.updatePosition()
  }

  layoutCategories() {
    const viewport = this.viewportTarget
    const styles = getComputedStyle(viewport)
    const minimum = parseFloat(styles.getPropertyValue("--dashboard-category-row-min"))
    this.columns = viewport.clientWidth >= 620 ? 2 : 1
    viewport.style.setProperty("--dashboard-category-columns", this.columns)

    const heights = Array.from(viewport.children, item => {
      const itemStyles = getComputedStyle(item)
      const [heading, measure] = item.children
      return heading.offsetHeight + measure.offsetHeight + parseFloat(getComputedStyle(measure).marginTop) +
        parseFloat(itemStyles.paddingTop) + parseFloat(itemStyles.paddingBottom) + 1
    })
    const rowHeight = Math.max(minimum, ...heights)
    this.rows = Math.max(1, Math.min(4, Math.floor(viewport.clientHeight / rowHeight)))
    viewport.style.setProperty("--dashboard-category-rows", this.rows)
    const size = this.rows * this.columns
    this.pages = Math.ceil(viewport.children.length / size)
    const finalColumn = this.pages * this.columns
    viewport.dataset.pagePadding = Math.ceil(viewport.children.length / this.rows) < finalColumn
    viewport.style.setProperty("--dashboard-category-last-column", finalColumn)
    Array.from(viewport.children).forEach((item, index) => item.toggleAttribute("data-page-start", index % size === 0))
  }

  updatePosition() {
    if (this.naturalFlow) {
      this.controlsTarget.hidden = true
      this.previousTarget.disabled = true
      this.nextTarget.disabled = true
      return
    }
    if (this.hasViewportTarget) {
      const gap = parseFloat(getComputedStyle(this.viewportTarget).columnGap) || 0
      this.step = this.viewportTarget.clientWidth + gap
      this.page = Math.max(0, Math.min(this.pages - 1, Math.round(this.viewportTarget.scrollLeft / this.step)))
    }

    this.controlsTarget.hidden = this.pages <= 1
    this.previousTarget.disabled = this.page === 0
    this.nextTarget.disabled = this.page >= this.pages - 1

    let label
    if (this.hasViewportTarget && this.viewportTarget.dataset.categoryPages) {
      const count = this.viewportTarget.children.length
      const size = this.rows * this.columns
      const first = this.page * size + 1
      const last = Math.min((this.page + 1) * size, count)
      label = first === last ? `Categoria ${first} de ${count}` : `Categorias ${first}–${last} de ${count}`
    } else if (this.pages > 1) {
      label = `${this.labels[this.page]} · ${this.page + 1} de ${this.pages}`
    } else {
      label = this.hasViewportTarget ? "Resumo e comparação" : "Nenhuma despesa neste mês"
    }
    if (this.positionTarget.textContent !== label) this.positionTarget.textContent = label
  }

  previous() { this.goToPage(this.page - 1) }
  next() { this.goToPage(this.page + 1) }

  goToPage(page) {
    if (this.naturalFlow || !this.hasViewportTarget) return
    this.page = Math.max(0, Math.min(this.pages - 1, page))
    const reducedMotion = window.matchMedia("(prefers-reduced-motion: reduce)").matches
    this.scrollToPage(reducedMotion ? "instant" : "smooth")
  }

  scrollToPage(behavior) {
    if (this.naturalFlow || !this.hasViewportTarget) return
    const gap = parseFloat(getComputedStyle(this.viewportTarget).columnGap) || 0
    this.step = this.viewportTarget.clientWidth + gap
    this.viewportTarget.scrollTo({ left: this.page * this.step, behavior })
  }

  navigateWithKeyboard(event) {
    if (this.naturalFlow) return
    if (event.target !== this.viewportTarget || !["ArrowLeft", "ArrowRight", "Home", "End"].includes(event.key)) return
    event.preventDefault()
    if (event.key === "Home") this.goToPage(0)
    else if (event.key === "End") this.goToPage(this.pages - 1)
    else this.goToPage(this.page + (event.key === "ArrowRight" ? 1 : -1))
  }
}
