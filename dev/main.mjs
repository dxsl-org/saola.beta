import '../assets/app.css'
import '../assets/basecoat.css'
import '../assets/component.css'
import '../assets/saola-d3-bar-chart.mjs'
import '../assets/saola-codemirror-editor.mjs'
import '../assets/saola-carousel.mjs'
import { main } from './saola/preview.gleam'

// Vite injects BASE_URL at build time ("/" in dev, "/saola.beta/" on Pages).
// Exposed as a global so Gleam can read it through FFI for base-aware routing.
window.__SAOLA_BASE__ = import.meta.env.BASE_URL

main()
