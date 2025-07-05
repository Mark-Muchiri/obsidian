-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices.

-- For example, changing the initial geometry for new windows:
config.initial_cols = 80
config.initial_rows = 28

-- or, changing the font size and color scheme.
config.font_size = 10
config.font = wezterm.font("VictorMono Nerd Font")
config.default_cursor_style = "BlinkingBar"
config.cursor_blink_rate = 700
config.window_decorations = "NONE"
config.hide_tab_bar_if_only_one_tab = true
config.color_scheme = "Aura (Gogh)"
-- config.color_scheme = 'duckbones'
config.front_end = "OpenGL" -- "OpenGL" or "WebGpu"
-- If using WebGpu, you can also set:
-- config.webgpu_power_preference = "HighPerformance" -- or "LowPower"

-- Finally, return the configuration to wezterm:
return config
