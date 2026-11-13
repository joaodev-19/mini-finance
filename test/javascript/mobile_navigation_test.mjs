import { test } from "node:test"
import assert from "node:assert/strict"
import { readFileSync } from "node:fs"

// Exercise the controllers without adding a browser library or a JS build step.
function controller(name, dependencies = {}) {
  const source = readFileSync(new URL(`../../app/javascript/controllers/${name}_controller.js`, import.meta.url), "utf8")
    .replace(/^import .*\n/gm, "")
    .replace("export default class", "return class")
  return new Function("Controller", ...Object.keys(dependencies), source)(class {}, ...Object.values(dependencies))
}

test("filter popup fits a short desktop viewport and clears its bounds in mobile flow", () => {
  const FilterPanel = controller("filter_panel")
  const instance = new FilterPanel()
  const classes = new Set()
  const properties = new Map()
  const query = { matches: false }
  globalThis.window = { matchMedia: () => query, innerHeight: 600 }
  const menu = {
    classList: { add: name => classes.add(name), remove: name => classes.delete(name) },
    style: { setProperty: (key, value) => properties.set(key, value), removeProperty: key => properties.delete(key) },
    getBoundingClientRect: () => ({ top: 260, height: 334 })
  }
  instance.element = { open: true, querySelector: () => menu }
  instance.fit()
  assert.equal(classes.has("app-notebook-filter-menu--constrained"), true)
  assert.equal(properties.get("--notebook-filter-max-height"), "324px")
  window.innerHeight = 900
  instance.fit()
  assert.equal(classes.size, 0)
  assert.equal(properties.size, 0)
  window.innerHeight = 600
  instance.fit()
  query.matches = true
  instance.fit()
  assert.equal(classes.size, 0)
  assert.equal(properties.size, 0)
})

test("Escape closes the filter and returns focus without reaching other dropdown handlers", () => {
  const FilterPanel = controller("filter_panel")
  const instance = new FilterPanel()
  let focused = false
  let prevented = false
  let stopped = false
  instance.element = { open: true, querySelector: () => ({ focus() { focused = true } }) }
  instance.close({ preventDefault() { prevented = true }, stopPropagation() { stopped = true } })
  assert.equal(instance.element.open, false)
  assert.equal(focused, true)
  assert.equal(prevented, true)
  assert.equal(stopped, true)
})

test("page size overlay reveals its choices and updates without navigating until submission", () => {
  const PageSize = controller("page_size")
  const instance = new PageSize()
  let scrolled = 0
  let focused = false
  instance.valueTarget = { textContent: "10" }
  instance.element = {
    open: false,
    querySelector() { return { focus() { focused = true }, scrollIntoView() { scrolled++ } } }
  }
  instance.reveal()
  assert.equal(scrolled, 0)
  instance.element.open = true
  instance.reveal()
  assert.equal(scrolled, 1)
  instance.choose({ target: { value: "20" } })
  assert.equal(instance.valueTarget.textContent, "20")
  assert.equal(instance.element.open, false)
  assert.equal(focused, true)
})

test("mobile pagination does not observe height or navigate, including pending desktop resize callbacks", () => {
  const query = { matches: true, addEventListener() {}, removeEventListener() {} }
  globalThis.window = { matchMedia: () => query }
  globalThis.ResizeObserver = class {
    observe() { this.observed = true }
    disconnect() { this.observed = false }
  }
  const visits = []
  const Pagination = controller("notebook_pagination", { Turbo: { visit: url => visits.push(url) } })
  const instance = new Pagination()
  instance.rowsTarget = {}
  instance.connect()
  assert.equal(instance.observer.observed, false)
  instance.fitPage()
  assert.deepEqual(visits, [])
  query.matches = false
  instance.onBreakpointChange()
  assert.equal(instance.observer.observed, true)
  query.matches = true
  instance.onBreakpointChange()
  instance.fitPage()
  assert.equal(instance.observer.observed, false)
  assert.deepEqual(visits, [])
  instance.disconnect()
})

test("mobile category flow avoids measurements, scroll interception and continuation controls", () => {
  const Dashboard = controller("dashboard_layout")
  const instance = new Dashboard()
  const attributes = new Set(["tabindex"])
  instance.mobile = { matches: true }
  instance.hasViewportTarget = true
  instance.viewportTarget = {
    dataset: { categoryPages: "true" },
    removeAttribute(name) { attributes.delete(name) },
    get clientHeight() { throw Error("Mobile must not measure category height") },
    scrollTo() { throw Error("Mobile must not scroll horizontally") }
  }
  instance.controlsTarget = { hidden: false }
  instance.previousTarget = { disabled: false }
  instance.nextTarget = { disabled: false }
  instance.layout()
  instance.goToPage(1)
  instance.scrollToPage("smooth")
  instance.navigateWithKeyboard({ key: "ArrowRight", preventDefault() { throw Error("Natural scrolling must not be intercepted") } })
  assert.equal(instance.pages, 1)
  assert.equal(instance.controlsTarget.hidden, true)
  assert.equal(instance.previousTarget.disabled, true)
  assert.equal(instance.nextTarget.disabled, true)
  assert.equal(attributes.has("tabindex"), false)
})

test("desktop category pagination retains four-row columns and correctly marks the last page", () => {
  globalThis.getComputedStyle = element => element.styles
  const Dashboard = controller("dashboard_layout")
  const instance = new Dashboard()
  const children = Array.from({ length: 9 }, () => ({
    children: [{ offsetHeight: 40 }, { offsetHeight: 12, styles: { marginTop: "8" } }],
    styles: { paddingTop: "12", paddingBottom: "12" },
    toggleAttribute(name, value) { this[name] = value }
  }))
  instance.viewportTarget = {
    clientWidth: 822, clientHeight: 600, children, dataset: {},
    styles: { getPropertyValue: () => "88" }, style: { setProperty() {} }
  }
  instance.layoutCategories()
  assert.equal(instance.rows, 4)
  assert.equal(instance.columns, 2)
  assert.equal(instance.pages, 2)
  assert.equal(instance.viewportTarget.dataset.pagePadding, true)
  assert.deepEqual(children.flatMap((item, index) => item["data-page-start"] ? [index] : []), [0, 8])
})
