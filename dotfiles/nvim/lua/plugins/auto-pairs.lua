return {
  {
    "romgrk/barbar.nvim",
    dependencies = {
      "lewis6991/gitsigns.nvim",
      "nvim-tree/nvim-web-devicons",
    },
    init = function()
      vim.g.barbar_auto_setup = false
    end,
    opts = {
      animation = false,
      auto_hide = false,
      insert_at_end = true,
      icons = {
        separator = { left = "", right = "" },
      },
    },
    config = function(_, opts)
      require("barbar").setup(opts)

      -- Apply styling after colorscheme loads
      local function apply_barbar_highlights()
        local ok, colors = pcall(
          dofile,
          vim.fn.stdpath("config") .. "/colors/matugen.lua"
        )
        if not ok then return end

        local hl = vim.api.nvim_set_hl

        -- CURRENT BUFFER
        hl(0, "BufferCurrent", {
          fg = colors.base.text,
          bg = colors.base.surface,
          bold = true,
        })

        hl(0, "BufferCurrentMod", {
          fg = colors.warning,
          bg = colors.base.surface,
        })

        hl(0, "BufferCurrentSign", {
          fg = colors.base.pine,
          bg = colors.base.surface,
        })

        -- VISIBLE (split window)
        hl(0, "BufferVisible", {
          fg = colors.base.text,
          bg = colors.ui.cursor_line,
        })

        hl(0, "BufferVisibleMod", {
          fg = colors.warning,
          bg = colors.ui.cursor_line,
        })

        -- INACTIVE
        hl(0, "BufferInactive", {
          fg = colors.base.muted,
          bg = colors.base.background,
        })

        hl(0, "BufferInactiveMod", {
          fg = colors.warning,
          bg = colors.base.background,
        })

        -- FILL AREA
        hl(0, "BufferTabpageFill", {
          bg = colors.base.background,
        })
      end

      -- Apply immediately
      apply_barbar_highlights()

      -- Reapply after colorscheme reload
      vim.api.nvim_create_autocmd("ColorScheme", {
        callback = function()
          apply_barbar_highlights()
        end,
      })
    end,
  },
}
