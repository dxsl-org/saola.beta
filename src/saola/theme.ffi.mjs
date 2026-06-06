const registered = {}

export function watchMediaQuery(query, callback) {
  if (registered[query]) return
  registered[query] = true
  window.matchMedia(query).addEventListener('change', e => callback(e.matches))
}

export function getCurrentDarkMode() {
  if (typeof window === 'undefined') return false
  return window.matchMedia('(prefers-color-scheme: dark)').matches
}

export function setHtmlTheme(isDark) {
  if (isDark) {
    document.documentElement.classList.add('dark')
  } else {
    document.documentElement.classList.remove('dark')
  }
}
