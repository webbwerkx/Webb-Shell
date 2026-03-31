return {
  "norcalli/nvim-colorizer.lua",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    require("colorizer").setup(
      { "*" },
      {
        RGB = true,
        RRGGBB = true,
        RRGGBBAA = true, -- required for #aec6ffff
        names = false,
      }
    )
  end,
}
