local wezterm = require "wezterm"

return {
	window_background_opacity = 0.9,
	macos_window_background_blur = 20,
	color_scheme = 'Apple System Colors',
	window_close_confirmation = 'NeverPrompt',
--	tab_bar_at_bottom = true,
	adjust_window_size_when_changing_font_size = false,
--	hide_tab_bar_if_only_one_tab = true,
	integrated_title_button_style = "MacOsNative",
	window_decorations = "INTEGRATED_BUTTONS|RESIZE"
}
