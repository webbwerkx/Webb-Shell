return {
    'nvim-telescope/telescope.nvim',
    tag = 'v0.1.9',
    dependencies = { 'nvim-lua/plenary.nvim' },

    config = function()
        require('telescope').setup({
            defaults = {
                hidden = true,            -- show hidden files
                file_ignore_patterns = {}, -- ignore nothing
            }
        })

        ---------------------------------------------------------------------
        -- FIND FILES — all files in home directory
        ---------------------------------------------------------------------
        vim.keymap.set("n", "<leader>ff", function()
            require("telescope.builtin").find_files({
                cwd = vim.fn.expand("~"),   -- search from home directory
                hidden = true,              -- include hidden files
                no_ignore = true,           -- ignore .gitignore
                no_ignore_parent = true,    -- ignore parent .gitignore
            })
        end, { desc = "Telescope: Find ALL files in HOME" })

        ---------------------------------------------------------------------
        -- LIVE GREP — all files in home directory
        ---------------------------------------------------------------------
        vim.keymap.set("n", "<leader>fg", function()
            require("telescope.builtin").live_grep({
                cwd = vim.fn.expand("~"),   -- search from home directory
                additional_args = function(_)
                    return {
                        "--hidden",            -- include hidden files
                        "--no-ignore",         -- ignore .gitignore
                        "--no-ignore-parent",  -- ignore parent .gitignore
                    }
                end,
            })
        end, { desc = "Telescope: Grep ALL files in HOME" })

        ---------------------------------------------------------------------
        -- Other pickers
        ---------------------------------------------------------------------
        local builtin = require("telescope.builtin")
        vim.keymap.set('n', '<leader>fb', builtin.buffers,   { desc = "Telescope: Buffers" })
        vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = "Telescope: Help" })
    end,
}

