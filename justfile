# Run server to preview the widgets.
preview $ERL_FLAGS="+B":
	@echo "Run Lustre app for preview"
	gleam run -m lustre/dev start saola/preview

build:
	@echo "Build to JS"
	gleam run -m lustre/dev build


build-preview:
	@echo "Build the preview app"
	gleam run -m lustre/dev build saola/preview

vite-build-preview:
	@echo "Build the preview app with Vite"
	bun run vite build

vite-dev-preview:
	@echo "Run preview app with Vite's dev server"
	bun run vite

# Slice compiled assets/basecoat.css into per-widget CSS files + base.css.
# Run after any upstream basecoat sync (see README for the full sync workflow).
# Security gate: diff-review external/basecoat/scripts/build.js + package.json devDeps
# BEFORE running "cd external/basecoat && bun run build" (executes untrusted code).
slice-css:
	@echo "Slicing basecoat CSS into per-widget files"
	bun scripts/build-css.mjs

# Bundle per-widget CSS files into distributable bundles in priv/static/.
# Also generates dev/dev-widgets.css for the Vite dev loop.
bundle-css:
	@echo "Bundling CSS into priv/static/ bundles"
	bun scripts/bundle-css.mjs

# Full CSS pipeline: slice basecoat → bundle into priv/static/ (one command).
build-css: slice-css bundle-css

