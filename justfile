# Run server to preview the widgets.
preview $ERL_FLAGS="+B":
	@echo "Run Lustre app for preview"
	gleam run -m lustre/dev start preview
