return {
    "nvim-tree/nvim-tree.lua",
    version = "*",
    lazy = false,
    dependencies = {
        "nvim-tree/nvim-web-devicons",
    },
    config = function()
        require("nvim-tree").setup({
            view = {
                width = 30,
            },
            renderer = {
                icons = {
                    glyphs = {
                        default = "",
                        symlink = "",
                        folder = {
                            default = "",
                            open = "",
                            empty = "",
                            empty_open = "",
                            symlink = "",
                        },
                    },
                },
            },
        })

        -- Apply matugen colors to nvim-tree
        local function apply_nvim_tree_colors()
            local ok, colors = pcall(dofile, vim.fn.stdpath("config") .. "/colors/matugen.lua")
            if not ok then return end

            local hl = vim.api.nvim_set_hl

            -- Tree background and text
            hl(0, "NvimTreeNormal", { fg = colors.base.text, bg = colors.base.surface })
            hl(0, "NvimTreeEndOfBuffer", { bg = colors.base.surface })
            hl(0, "NvimTreeVertSplit", { fg = colors.ui.border, bg = colors.base.surface })
            hl(0, "NvimTreeWinSeparator", { fg = colors.ui.border, bg = colors.base.surface })
            
            -- Folder colors
            hl(0, "NvimTreeFolderName", { fg = colors.base.pine })
            hl(0, "NvimTreeOpenedFolderName", { fg = colors.base.pine, bold = true })
            hl(0, "NvimTreeEmptyFolderName", { fg = colors.base.overlay })
            hl(0, "NvimTreeFolderIcon", { fg = colors.base.pine })
            
            -- File colors
            hl(0, "NvimTreeFileIcon", { fg = colors.base.text })
            hl(0, "NvimTreeExecFile", { fg = colors.base.foam })
            hl(0, "NvimTreeSpecialFile", { fg = colors.base.gold })
            hl(0, "NvimTreeSymlink", { fg = colors.base.rose })
            hl(0, "NvimTreeImageFile", { fg = colors.base.iris })
            
            -- Git colors
            hl(0, "NvimTreeGitDirty", { fg = colors.warning })
            hl(0, "NvimTreeGitStaged", { fg = colors.info })
            hl(0, "NvimTreeGitMerge", { fg = colors.base.gold })
            hl(0, "NvimTreeGitRenamed", { fg = colors.base.rose })
            hl(0, "NvimTreeGitNew", { fg = colors.hint })
            hl(0, "NvimTreeGitDeleted", { fg = colors.error })
            
            -- Selection and cursor
            hl(0, "NvimTreeCursorLine", { bg = colors.ui.cursor_line })
            hl(0, "NvimTreeCursorLineNr", { fg = colors.base.pine })
            
            -- Root folder
            hl(0, "NvimTreeRootFolder", { fg = colors.base.pine, bold = true })
            
            -- Indentation
            hl(0, "NvimTreeIndentMarker", { fg = colors.ui.border })
        end

        -- Apply colors on colorscheme change
        vim.api.nvim_create_autocmd("ColorScheme", {
            pattern = "matugen",
            callback = apply_nvim_tree_colors,
        })

        -- Apply colors immediately if matugen is active
        vim.schedule(function()
            if vim.g.colors_name == "matugen" then
                apply_nvim_tree_colors()
            end
        end)
    end,
}
