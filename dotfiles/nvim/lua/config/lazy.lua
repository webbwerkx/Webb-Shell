local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end

vim.opt.rtp:prepend(lazypath)

-- QML filetype detection
vim.filetype.add({
  extension = { qml = "qml" },
})

require("config.options")
require("config.keymaps")
require("config.autocmds")

require("lazy").setup({
  spec = {
    { import = "plugins" },
  },
})
