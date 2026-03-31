# Fish shell completions for webb CLI

set -l subcommands shell toggle scheme screenshot record clipboard emoji wallpaper resizer

complete -c webb -f
complete -c webb -n "not __fish_seen_subcommand_from $subcommands" -a shell      -d "Start or message the shell"
complete -c webb -n "not __fish_seen_subcommand_from $subcommands" -a toggle     -d "Toggle a special workspace"
complete -c webb -n "not __fish_seen_subcommand_from $subcommands" -a scheme     -d "Manage the colour scheme"
complete -c webb -n "not __fish_seen_subcommand_from $subcommands" -a screenshot -d "Take a screenshot"
complete -c webb -n "not __fish_seen_subcommand_from $subcommands" -a record     -d "Start a screen recording"
complete -c webb -n "not __fish_seen_subcommand_from $subcommands" -a clipboard  -d "Open clipboard history"
complete -c webb -n "not __fish_seen_subcommand_from $subcommands" -a emoji      -d "Emoji/glyph utilities"
complete -c webb -n "not __fish_seen_subcommand_from $subcommands" -a wallpaper  -d "Manage the wallpaper"
complete -c webb -n "not __fish_seen_subcommand_from $subcommands" -a resizer    -d "Window resizer daemon"
complete -c webb -s v -l version -d "Print the current version"

# shell subcommand
complete -c webb -n "__fish_seen_subcommand_from shell" -s d -l daemon    -d "Start the shell detached"
complete -c webb -n "__fish_seen_subcommand_from shell" -s s -l show      -d "Print all shell IPC commands"
complete -c webb -n "__fish_seen_subcommand_from shell" -s l -l log       -d "Print the shell log"
complete -c webb -n "__fish_seen_subcommand_from shell" -s k -l kill      -d "Kill the shell"
complete -c webb -n "__fish_seen_subcommand_from shell" -l log-rules      -d "Log rules to apply" -r

# scheme subcommand
set -l scheme_subcmds list get set
complete -c webb -n "__fish_seen_subcommand_from scheme; and not __fish_seen_subcommand_from $scheme_subcmds" -a list -d "List available schemes"
complete -c webb -n "__fish_seen_subcommand_from scheme; and not __fish_seen_subcommand_from $scheme_subcmds" -a get  -d "Get scheme properties"
complete -c webb -n "__fish_seen_subcommand_from scheme; and not __fish_seen_subcommand_from $scheme_subcmds" -a set  -d "Set the current scheme"

complete -c webb -n "__fish_seen_subcommand_from scheme; and __fish_seen_subcommand_from list" -s n -l names    -d "List scheme names"
complete -c webb -n "__fish_seen_subcommand_from scheme; and __fish_seen_subcommand_from list" -s f -l flavours -d "List scheme flavours"
complete -c webb -n "__fish_seen_subcommand_from scheme; and __fish_seen_subcommand_from list" -s m -l modes    -d "List scheme modes"
complete -c webb -n "__fish_seen_subcommand_from scheme; and __fish_seen_subcommand_from list" -s v -l variants -d "List scheme variants"

complete -c webb -n "__fish_seen_subcommand_from scheme; and __fish_seen_subcommand_from get" -s n -l name    -d "Print current scheme name"
complete -c webb -n "__fish_seen_subcommand_from scheme; and __fish_seen_subcommand_from get" -s f -l flavour -d "Print current scheme flavour"
complete -c webb -n "__fish_seen_subcommand_from scheme; and __fish_seen_subcommand_from get" -s m -l mode    -d "Print current scheme mode"
complete -c webb -n "__fish_seen_subcommand_from scheme; and __fish_seen_subcommand_from get" -s v -l variant -d "Print current scheme variant"

complete -c webb -n "__fish_seen_subcommand_from scheme; and __fish_seen_subcommand_from set" -s r -l random  -d "Switch to a random scheme"
complete -c webb -n "__fish_seen_subcommand_from scheme; and __fish_seen_subcommand_from set" -l notify       -d "Send a notification on error"
complete -c webb -n "__fish_seen_subcommand_from scheme; and __fish_seen_subcommand_from set" -s n -l name    -d "Scheme name" -r
complete -c webb -n "__fish_seen_subcommand_from scheme; and __fish_seen_subcommand_from set" -s f -l flavour -d "Scheme flavour" -r
complete -c webb -n "__fish_seen_subcommand_from scheme; and __fish_seen_subcommand_from set" -s m -l mode    -d "Scheme mode" -r -a "dark light"
complete -c webb -n "__fish_seen_subcommand_from scheme; and __fish_seen_subcommand_from set" -s v -l variant -d "Scheme variant" -r -a "tonalspot vibrant expressive fidelity fruitsalad monochrome neutral rainbow content"

# wallpaper subcommand
complete -c webb -n "__fish_seen_subcommand_from wallpaper" -s f -l file     -d "Path to wallpaper" -r -F
complete -c webb -n "__fish_seen_subcommand_from wallpaper" -s r -l random   -d "Switch to a random wallpaper" -r -F
complete -c webb -n "__fish_seen_subcommand_from wallpaper" -s p -l print    -d "Print scheme for a wallpaper" -r -F
complete -c webb -n "__fish_seen_subcommand_from wallpaper" -s n -l no-filter -d "Do not filter by size"
complete -c webb -n "__fish_seen_subcommand_from wallpaper" -s N -l no-smart  -d "Do not auto-change scheme mode"
complete -c webb -n "__fish_seen_subcommand_from wallpaper" -s t -l threshold -d "Minimum size threshold" -r

# screenshot subcommand
complete -c webb -n "__fish_seen_subcommand_from screenshot" -s r -l region -d "Take a screenshot of a region"
complete -c webb -n "__fish_seen_subcommand_from screenshot" -s f -l freeze -d "Freeze screen while selecting"

# record subcommand
complete -c webb -n "__fish_seen_subcommand_from record" -s r -l region    -d "Record a region"
complete -c webb -n "__fish_seen_subcommand_from record" -s s -l sound     -d "Record audio"
complete -c webb -n "__fish_seen_subcommand_from record" -s p -l pause     -d "Pause/resume the recording"
complete -c webb -n "__fish_seen_subcommand_from record" -s c -l clipboard -d "Copy recording path to clipboard"

# clipboard subcommand
complete -c webb -n "__fish_seen_subcommand_from clipboard" -s d -l delete -d "Delete from clipboard history"

# emoji subcommand
complete -c webb -n "__fish_seen_subcommand_from emoji" -s p -l picker -d "Open the emoji/glyph picker"
complete -c webb -n "__fish_seen_subcommand_from emoji" -s f -l fetch  -d "Fetch emoji/glyph data from remote"

# resizer subcommand
complete -c webb -n "__fish_seen_subcommand_from resizer" -s d -l daemon -d "Start the resizer daemon"
