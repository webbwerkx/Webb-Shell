return {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
        local lualine = require("lualine")
        local lazy_status = require("lazy.status") -- to configure lazy pending updates count
        
        -- Function to get matugen colors with fallback
        local function get_colors()
            local ok, matugen_colors = pcall(dofile, vim.fn.stdpath("config") .. "/colors/matugen.lua")
            if ok then
                -- Use matugen colors
                return {
                    color0 = matugen_colors.base.background,
                    color1 = matugen_colors.base.love,
                    color2 = matugen_colors.base.text,
                    color3 = matugen_colors.base.surface,
                    color6 = matugen_colors.base.muted,
                    color7 = matugen_colors.base.pine,
                    color8 = matugen_colors.base.iris,
                }
            else
                -- Fallback to your original colors
                return {
                    color0 = "#092236",
                    color1 = "#ff5874",
                    color2 = "#c3ccdc",
                    color3 = "#1c1e26",
                    color6 = "#a1aab8",
                    color7 = "#828697",
                    color8 = "#ae81ff",
                }
            end
        end
        
        local colors = get_colors()
        
        local my_lualine_theme = {
            replace = {
                a = { fg = colors.color0, bg = colors.color1, gui = "bold" },
                b = { fg = colors.color2, bg = colors.color3 },
            },
            inactive = {
                a = { fg = colors.color6, bg = colors.color3, gui = "bold" },
                b = { fg = colors.color6, bg = colors.color3 },
                c = { fg = colors.color6, bg = colors.color3 },
            },
            normal = {
                a = { fg = colors.color0, bg = colors.color7, gui = "bold" },
                b = { fg = colors.color2, bg = colors.color3 },
                c = { fg = colors.color2, bg = colors.color3 },
            },
            visual = {
                a = { fg = colors.color0, bg = colors.color8, gui = "bold" },
                b = { fg = colors.color2, bg = colors.color3 },
            },
            insert = {
                a = { fg = colors.color0, bg = colors.color2, gui = "bold" },
                b = { fg = colors.color2, bg = colors.color3 },
            },
        }
        
        local mode = {
            'mode',
            fmt = function(str)
                return ' ' .. str
            end,
        }
        
        local diff = {
            'diff',
            colored = true,
            symbols = { added = ' ', modified = ' ', removed = ' ' },
        }
        
        local filename = {
            'filename',
            file_status = true,
            path = 0,
        }
        
        -- Get branch color from matugen or use fallback
        local branch_color = "#A6D4DE"
        local ok, matugen = pcall(dofile, vim.fn.stdpath("config") .. "/colors/matugen.lua")
        if ok then
            branch_color = matugen.base.pine
        end
        
        local branch = { 'branch', icon = { '', color = { fg = branch_color } }, '|' }
        
        lualine.setup({
            icons_enabled = true,
            options = {
                theme = my_lualine_theme,
                component_separators = { left = "|", right = "|" },
                section_separators = { left = "|", right = "" },
            },
            sections = {
                lualine_a = { mode },
                lualine_b = { branch },
                lualine_c = { diff, filename },
                lualine_x = {
                    {
                        lazy_status.updates,
                        cond = lazy_status.has_updates,
                        color = { fg = "#ff9e64" },
                    },
                    { "filetype" },
                },
            },
        })
    end,
}
