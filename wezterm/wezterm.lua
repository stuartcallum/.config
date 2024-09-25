local wezterm = require "wezterm"

function scheme_for_appearance(appearance)
  if appearance:find "Dark" then
    return "Catppuccin Mocha"
  else
    return "Catppuccin Latte"
  end
end

return {
	window_background_opacity = 0.7,
	macos_window_background_blur = 20,
	color_scheme = scheme_for_appearance(wezterm.gui.get_appearance()),
	initial_rows = 64,
	initial_cols = 128,
	font_size = 16,
	window_close_confirmation = 'NeverPrompt',
	tab_bar_at_bottom = true,
}