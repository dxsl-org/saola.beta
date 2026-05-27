/**
 * Returns true when the click event's target is NOT contained within any
 * element matching `selector` — i.e. the user clicked outside all of them.
 *
 * Uses `Node.contains` rather than `Element.closest` so that the check is
 * rooted at each matched container node, not at the target walking upward.
 *
 * @param {string} selector  CSS selector for the container elements to test
 * @param {MouseEvent} event
 * @returns {boolean}
 */
export function isOutside(selector, event) {
  const target = event?.target
  if (!target) return true
  const containers = document.querySelectorAll(selector)
  return !Array.from(containers).some(el => el.contains(target))
}
