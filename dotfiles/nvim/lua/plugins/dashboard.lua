return {
    'nvimdev/dashboard-nvim',
    event = 'VimEnter',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
        require('dashboard').setup {
            theme = 'doom',
            config = {
                header = {
                    '                                                                               ',
                    '██╗    ██╗███████╗██████╗ ██████╗ ██╗    ██╗███████╗██████╗ ██╗  ██╗███████╗',
                    '██║    ██║██╔════╝██╔══██╗██╔══██╗██║    ██║██╔════╝██╔══██╗██║ ██╔╝╚══███╔╝',
                    '██║ █╗ ██║█████╗  ██████╔╝██████╔╝██║ █╗ ██║█████╗  ██████╔╝█████╔╝   ███╔╝ ',
                    '██║███╗██║██╔══╝  ██╔══██╗██╔══██╗██║███╗██║██╔══╝  ██╔══██╗██╔═██╗  ███╔╝  ',
                    '╚███╔███╔╝███████╗██████╔╝██████╔╝╚███╔███╔╝███████╗██║  ██║██║  ██╗███████╗',
                    ' ╚══╝╚══╝ ╚══════╝╚═════╝ ╚═════╝  ╚══╝╚══╝ ╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝',
                    '                                                                               ',
                },
                center = {
                    {
                        icon = ' ',
                        icon_hl = 'Title',
                        desc = 'Find File           ',
                        desc_hl = 'String',
                        key = 'f',
                        key_hl = 'Number',
                        action = 'Telescope find_files'
                    },
                    {
                        icon = ' ',
                        desc = 'Recent Files        ',
                        key = 'r',
                        action = 'Telescope oldfiles'
                    },
                    {
                        icon = ' ',
                        desc = 'Find Text           ',
                        key = 'g',
                        action = 'Telescope live_grep'
                    },
                    {
                        icon = ' ',
                        desc = 'Config              ',
                        key = 'c',
                        action = 'edit ~/.config/nvim/init.lua'
                    },
                    {
                        icon = ' ',
                        desc = 'Lazy                ',
                        key = 'l',
                        action = 'Lazy'
                    },
                    {
                        icon = ' ',
                        desc = 'Quit                ',
                        key = 'q',
                        action = 'quit'
                    },
                },
                footer = function()
                    local stats = require('lazy').stats()
                    local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
                    return { '⚡ Loaded ' .. stats.count .. ' plugins in ' .. ms .. 'ms' }
                end
            }
        }
    end
}
