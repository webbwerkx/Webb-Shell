return {
  -- Mason
  {
    "williamboman/mason.nvim",
    cmd = "Mason",
    config = true,
  },

  -- Bridge Mason ↔ Neovim LSP
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim" },
    opts = {
      ensure_installed = {
        "cssls",
        "jsonls",
        "lua_ls",
        "pyright",
        -- qmlls is NOT available via Mason, it is configured manually below
      },
    },
  },

  -- LSP (Neovim 0.11 native config)
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      -- Lua
      vim.lsp.config("lua_ls", {
        settings = {
          Lua = {
            diagnostics = {
              globals = { "vim" },
            },
            workspace = {
              library = vim.api.nvim_get_runtime_file("", true),
              checkThirdParty = false,
            },
            telemetry = {
              enable = false,
            },
          },
        },
      })

      -- CSS / SCSS
      vim.lsp.config("cssls", {})

      -- JSON
      vim.lsp.config("jsonls", {})

      -- Python
      vim.lsp.config("pyright", {})

      -- QML (bundled with Qt 6, install via: sudo pacman -S qt6-declarative)
      vim.lsp.config("qmlls", {
        cmd = { "/usr/lib/qt6/bin/qmlls" },
        filetypes = { "qml" },
        cmd_env = {
          QML_IMPORT_PATH = "/usr/lib/qt6/qml",
        },
      })

      -- Enable all configured servers
      vim.lsp.enable({
        "lua_ls",
        "cssls",
        "jsonls",
        "pyright",
        "qmlls",
      })
    end,
  },
}
