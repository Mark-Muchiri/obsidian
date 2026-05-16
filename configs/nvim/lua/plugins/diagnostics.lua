-- local og_virt_text
-- local og_virt_line
return {
  "AstroNvim/astrocore",
  ---@type AstroCoreOpts
  opts = {
    features = {
      diagnostics = true,
    },
    diagnostics = {
      virtual_text = false,
      virtual_lines = false,
      underline = true,
      update_in_insert = false,
    },
  },
}
