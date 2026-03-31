return {
  -- Keep your tokyonight as fallback
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
  },
  
  -- Matugen colorscheme
  {
    "matugen-colorscheme",
    dir = vim.fn.stdpath("config") .. "/colors",
    lazy = false,
    priority = 1001, -- Higher priority means it loads after tokyonight
    config = function()
      -- Load matugen colors
      local ok, colors = pcall(dofile, vim.fn.stdpath("config") .. "/colors/matugen.lua")
      
      if ok then
        vim.cmd("highlight clear")
        if vim.fn.exists("syntax_on") then
          vim.cmd("syntax reset")
        end
        
        vim.o.termguicolors = true
        vim.g.colors_name = "matugen"
        
        -- Apply highlights
        local hl = vim.api.nvim_set_hl
        
        -- Base UI
        hl(0, "Normal", { fg = colors.base.text, bg = colors.base.background })
        hl(0, "NormalFloat", { fg = colors.base.text, bg = colors.base.surface })
        hl(0, "FloatBorder", { fg = colors.ui.border, bg = colors.base.surface })
        hl(0, "CursorLine", { bg = colors.ui.cursor_line })
        hl(0, "CursorLineNr", { fg = colors.base.pine })
        hl(0, "LineNr", { fg = colors.base.muted })
        hl(0, "Visual", { bg = colors.ui.visual })
        hl(0, "Search", { bg = colors.ui.selection, fg = colors.base.text })
        hl(0, "IncSearch", { bg = colors.base.gold, fg = colors.base.background })
        
        -- Syntax
        hl(0, "Comment", { fg = colors.syntax.comment, italic = true })
        hl(0, "Keyword", { fg = colors.syntax.keyword, bold = true })
        hl(0, "Function", { fg = colors.syntax.func })
        hl(0, "String", { fg = colors.syntax.string })
        hl(0, "Number", { fg = colors.ui.selection })
        hl(0, "Constant", { fg = colors.syntax.constant })
        hl(0, "Type", { fg = colors.syntax.type })
        hl(0, "Variable", { fg = colors.syntax.variable })
        hl(0, "Identifier", { fg = colors.base.text })
        hl(0, "Operator", { fg = colors.base.rose })
        
        -- Diagnostics
        hl(0, "DiagnosticError", { fg = colors.error })
        hl(0, "DiagnosticWarn", { fg = colors.warning })
        hl(0, "DiagnosticInfo", { fg = colors.info })
        hl(0, "DiagnosticHint", { fg = colors.hint })
        
        -- Popup menus
        hl(0, "Pmenu", { fg = colors.base.text, bg = colors.ui.pmenu_bg })
        hl(0, "PmenuSel", { fg = colors.base.text, bg = colors.ui.pmenu_sel, bold = true })
        hl(0, "PmenuBorder", { fg = colors.ui.border, bg = colors.ui.pmenu_bg })
        
        -- StatusLine
        hl(0, "StatusLine", { fg = colors.base.text, bg = colors.base.surface })
        
        -- TreeSitter
        hl(0, "@keyword", { link = "Keyword" })
        hl(0, "@function", { link = "Function" })
        hl(0, "@string", { link = "String" })
        hl(0, "@number", { link = "Number" })
        hl(0, "@constant", { link = "Constant" })
        hl(0, "@type", { link = "Type" })
        hl(0, "@variable", { link = "Variable" })
        hl(0, "@comment", { link = "Comment" })
      else
        -- Fallback to tokyonight if matugen colors not found
        vim.cmd.colorscheme("tokyonight")
      end
    end,
  },
}
