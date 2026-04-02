# Run server to preview the widgets.
preview $ERL_FLAGS="+B":
	@echo "Run Lustre app for preview"
	gleam run -m lustre/dev start saola/preview

build:
	@echo "Build to JS"
	gleam run -m lustre/dev build
