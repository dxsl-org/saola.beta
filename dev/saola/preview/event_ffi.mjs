/**
 * Returns true when the click event's target is NOT a descendant of any
 * element matching `selector` — i.e. the user clicked outside all of them.
 *
 * @param {string} selector  CSS selector for the container elements to test
 * @param {MouseEvent} event
 * @returns {boolean}
 */
export function isOutside(selector, event) {
  const target = event?.target
  if (!target) return true
  return !target.closest(selector)
}

/**
 * App base path set by dev/main.mjs from Vite's BASE_URL.
 * Normalized: no trailing slash; empty string when served from the root.
 *
 * @returns {string}
 */
export function appBase() {
  const raw = globalThis.__SAOLA_BASE__ ?? '/'
  return raw === '/' ? '' : raw.replace(/\/$/, '')
}
