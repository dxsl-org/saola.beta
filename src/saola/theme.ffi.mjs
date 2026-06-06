const DARK_QUERY = '(prefers-color-scheme: dark)'
let darkRegistered = false

export function watchDarkMode(callback) {
  if (darkRegistered) return
  darkRegistered = true
  window.matchMedia(DARK_QUERY).addEventListener('change', e => callback(e.matches))
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
