-- A light color scheme for Wezterm
-- stylua: ignore
local light = {
    -- Base colors
    rosewater = '#dc8a78',
    flamingo  = '#dd7878',
    pink      = '#ea76cb',
    mauve     = '#8839ef',
    red       = '#d20f39',
    maroon    = '#e64553',
    peach     = '#fe640b',
    yellow    = '#df8e1d',
    green     = '#40a02b',
    teal      = '#179299',
    sky       = '#04a5e5',
    sapphire  = '#209fb5',
    blue      = '#1e66f5',
    lavender  = '#7287fd',
    text      = '#4c4f69',
    subtext1  = '#5c5f77',
    subtext0  = '#6c6f85',
    overlay2  = '#7c7f93',
    overlay1  = '#8f92a6',
    overlay0  = '#9c9faf',
    surface2  = '#acb0be',
    surface1  = '#bcc0cc',
    surface0  = '#ccd0da',
    base      = '#eff1f5',
    mantle    = '#e6e9ef',
    crust     = '#dce0e8',
}

local colorscheme = {
    foreground = light.text,
    background = light.base,
    cursor_bg = light.rosewater,
    cursor_border = light.rosewater,
    cursor_fg = light.crust,
    selection_bg = light.surface2,
    selection_fg = light.text,
    ansi = {
        light.overlay2, -- black
        light.red,       -- red
        light.green,     -- green
        light.yellow,    -- yellow
        light.blue,      -- blue
        light.mauve,     -- magenta/purple
        light.teal,      -- cyan
        light.text,      -- white
    },
    brights = {
        light.overlay0,  -- black
        light.maroon,    -- red
        light.sapphire,  -- green
        light.peach,     -- yellow
        light.sky,       -- blue
        light.pink,      -- magenta/purple
        light.sapphire,  -- cyan
        light.subtext0,  -- white
    },
    tab_bar = {
        background = 'rgba(255, 255, 255, 0.8)',
        active_tab = {
           bg_color = light.surface2,
           fg_color = light.text,
        },
        inactive_tab = {
            bg_color = light.surface0,
            fg_color = light.text,
        },
        inactive_tab_hover = {
            bg_color = light.surface1,
            fg_color = light.text,
        },
        new_tab = {
           bg_color = light.base,
           fg_color = light.text,
        },
        new_tab_hover = {
           bg_color = light.mantle,
           fg_color = light.text,
           italic = true,
        },
    },
    visual_bell = light.red,
    indexed = {
       [16] = light.peach,
       [17] = light.rosewater,
    },
    scrollbar_thumb = light.surface2,
    split = light.overlay0,
    compose_cursor = light.flamingo,
}

return colorscheme