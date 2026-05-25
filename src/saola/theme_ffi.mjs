const _registered = {}

export function mediaQuerySub(query, callback) {
  if (_registered[query]) return
  _registered[query] = true
  window.matchMedia(query).addEventListener('change', e => callback(e.matches))
}

export function getCurrentDarkMode() {
  if (typeof window === 'undefined') return false
  return window.matchMedia('(prefers-color-scheme: dark)').matches
}
