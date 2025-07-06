-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This will hold the configuration.
local config = wezterm.config_builder()

-- Appearance
config.initial_cols = 84
config.initial_rows = 32
config.font_size = 10.3
config.font = wezterm.font("VictorMono Nerd Font")
config.default_cursor_style = "BlinkingBar"
config.cursor_blink_rate = 700
config.window_decorations = "NONE"
config.hide_tab_bar_if_only_one_tab = true
config.color_scheme = "Aura (Gogh)"
config.front_end = "OpenGL"

-- Keybindings
config.keys = {
  -- vertical split
  {
    key = 'o',
    mods = 'CTRL|SHIFT',
    action = wezterm.action.SplitHorizontal { domain = 'CurrentPaneDomain' },
  },
  -- horizontal split
  {
    key = 'i',
    mods = 'CTRL|SHIFT',
    action = wezterm.action.SplitVertical { domain = 'CurrentPaneDomain' },
  },
}

-- Finally, return the configuration to wezterm:
return config
