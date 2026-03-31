-- nvim-colors.lua — matugen template
-- Generates a vibrant warm-toned palette with cool accents for contrast.
-- Place this in your matugen templates directory and run matugen to regenerate matugen.lua.

return {
  base = {
    -- Backgrounds: stepped layers for depth
    background = "#13140d",
    surface    = "#13140d",
    overlay    = "#46483b",
    muted      = "#2a2b22",
    subtle     = "#35352d",
    text       = "#e4e3d6",

    -- Warm accent ramp (hue-shifted for better differentiation)
    love       = "#ffb4ab",           -- vivid red/orange → errors, constants
    gold       = "#a2d0c3",        -- bright yellow → strings, warnings
    rose       = "#c5c9a8",       -- pink/magenta → functions, fields
    pine       = "#c0ce7e",         -- orange → keywords

    -- Cool accents (contrast against the warm ramp)
    foam       = "#224e45",    -- teal → types, builtins
    iris       = "#45492f",   -- violet → numbers, macros, namespaces
  },

  -- Diagnostic severity mapping
  error   = "#ffb4ab",
  warning = "#a2d0c3",
  info    = "#224e45",
  hint    = "#45492f",

  syntax = {
    -- Each token uses a visually distinct hue:
    keyword  = "#c0ce7e",             -- orange    (bold)
    func     = "#c5c9a8",           -- pink      (italic calls)
    string   = "#a2d0c3",            -- yellow
    number   = "#45492f", -- violet    (cool, stands apart)
    constant = "#ffb4ab",               -- red-orange (loud, special)
    type     = "#224e45",  -- teal      (only cool non-violet)
    variable = "#e4e3d6",       -- warm white (default)
    comment  = "#919283",             -- muted gray (recedes)
  },

  ui = {
    border      = "#46483b",       -- visible but soft
    cursor_line = "#1f2018",     -- subtle row highlight
    selection   = "#414b08",     -- orange-tinted selection
    visual      = "#45492f",   -- violet-tinted visual block
    pmenu_bg    = "#1b1c15", -- darker than surface
    pmenu_sel   = "#414b08",     -- matches selection
  }
}
