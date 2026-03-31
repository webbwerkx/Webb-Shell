-- nvim-colors.lua — matugen template
-- Generates a vibrant warm-toned palette with cool accents for contrast.
-- Place this in your matugen templates directory and run matugen to regenerate matugen.lua.

return {
  base = {
    -- Backgrounds: stepped layers for depth
    background = "{{colors.background.default.hex}}",
    surface    = "{{colors.surface.default.hex}}",
    overlay    = "{{colors.surface_variant.default.hex}}",
    muted      = "{{colors.surface_container_high.default.hex}}",
    subtle     = "{{colors.surface_container_highest.default.hex}}",
    text       = "{{colors.on_background.default.hex}}",

    -- Warm accent ramp (hue-shifted for better differentiation)
    love       = "{{colors.error.default.hex}}",           -- vivid red/orange → errors, constants
    gold       = "{{colors.tertiary.default.hex}}",        -- bright yellow → strings, warnings
    rose       = "{{colors.secondary.default.hex}}",       -- pink/magenta → functions, fields
    pine       = "{{colors.primary.default.hex}}",         -- orange → keywords

    -- Cool accents (contrast against the warm ramp)
    foam       = "{{colors.tertiary_container.default.hex}}",    -- teal → types, builtins
    iris       = "{{colors.secondary_container.default.hex}}",   -- violet → numbers, macros, namespaces
  },

  -- Diagnostic severity mapping
  error   = "{{colors.error.default.hex}}",
  warning = "{{colors.tertiary.default.hex}}",
  info    = "{{colors.tertiary_container.default.hex}}",
  hint    = "{{colors.secondary_container.default.hex}}",

  syntax = {
    -- Each token uses a visually distinct hue:
    keyword  = "{{colors.primary.default.hex}}",             -- orange    (bold)
    func     = "{{colors.secondary.default.hex}}",           -- pink      (italic calls)
    string   = "{{colors.tertiary.default.hex}}",            -- yellow
    number   = "{{colors.secondary_container.default.hex}}", -- violet    (cool, stands apart)
    constant = "{{colors.error.default.hex}}",               -- red-orange (loud, special)
    type     = "{{colors.tertiary_container.default.hex}}",  -- teal      (only cool non-violet)
    variable = "{{colors.on_background.default.hex}}",       -- warm white (default)
    comment  = "{{colors.outline.default.hex}}",             -- muted gray (recedes)
  },

  ui = {
    border      = "{{colors.outline_variant.default.hex}}",       -- visible but soft
    cursor_line = "{{colors.surface_container.default.hex}}",     -- subtle row highlight
    selection   = "{{colors.primary_container.default.hex}}",     -- orange-tinted selection
    visual      = "{{colors.secondary_container.default.hex}}",   -- violet-tinted visual block
    pmenu_bg    = "{{colors.surface_container_low.default.hex}}", -- darker than surface
    pmenu_sel   = "{{colors.primary_container.default.hex}}",     -- matches selection
  }
}
