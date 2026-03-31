return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  config = function()
    require("nvim-treesitter").setup({
      ensure_installed = { "markdown", "markdown_inline", "bash", "lua", "vim", "vimdoc", "javascript", "typescript", "qmljs" },
      highlight = { enable = true },
      indent = { enable = true },
    })
  end,
}
