// @ts-check

/**
 * Queries all matching elements from a ShadowRoot or Element.
 *
 * @param {ShadowRoot|Element} root
 * @param {string} selector
 * @returns {Element[]}
 */
export function querySelectorAll(root, selector) {
  return Array.from(root.querySelectorAll(selector))
}

/**
 * Returns true if element is scrolled out of view within its container.
 *
 * @param {Element} element
 * @param {Element} container
 * @returns {boolean}
 */
export function isOutOfView(element, container) {
  const el = element.getBoundingClientRect()
  const ct = container.getBoundingClientRect()
  const relYOffset = el.top - ct.top
  const isBelow = container.clientHeight <= relYOffset + el.height
  const isAbove = relYOffset < 0
  return isBelow || isAbove
}

/**
 * Registers a document-level click listener that fires when a click
 * lands outside the host element.
 *
 * Self-cleaning: Lustre components expose no disconnect hook to Gleam,
 * so the handler unregisters itself on the first click that arrives
 * while the host is no longer connected — otherwise the closure keeps
 * the unmounted component's runtime alive forever.
 *
 * Idempotent per host: re-registering replaces the previous listener,
 * so callers may register on every open without stacking handlers —
 * this also revives dismissal after a disconnect→reconnect DOM move.
 *
 * @param {ShadowRoot|Element} root
 * @param {() => void} callback
 * @returns {void}
 */
export function addOutsideClickListener(root, callback) {
  const host = root instanceof ShadowRoot ? root.host : root
  if (host.__saolaOutsideClick) {
    document.removeEventListener('click', host.__saolaOutsideClick)
  }
  const handler = (event) => {
    if (!host.isConnected) {
      document.removeEventListener('click', handler)
      if (host.__saolaOutsideClick === handler) {
        host.__saolaOutsideClick = null
      }
      return
    }
    if (!event.composedPath().includes(host)) {
      callback()
    }
  }
  host.__saolaOutsideClick = handler
  document.addEventListener('click', handler)
}
