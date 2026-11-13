local mod      = "SUPER"
local terminal = "ghostty"
local menu     = "wofi --show drun"

hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1.25 })

hl.config({
  input = {
    kb_layout    = "us,gr",
    kb_options   = "grp:alt_shift_toggle",
    follow_mouse = 1,
    touchpad = {
      natural_scroll = true,
      tap_to_click   = true,
    },
  },

  general = {
    gaps_in     = 5,
    gaps_out    = 10,
    border_size = 2,
    col = {
      -- solid orange for the focused window (transopt.io brand accent), dim for the rest
      active_border   = "rgba(ff7a3dcc)",
      inactive_border = "rgba(23485280)",
    },
    layout = "dwindle",
  },

  decoration = {
    rounding = 10,
    rounding_power = 2,
    blur = { enabled = true, size = 6, passes = 2, vibrancy = 0.17 },
    shadow = {
      enabled      = true,
      range        = 18,
      render_power = 3,
      color        = "rgba(11111bee)",
    },
  },

  -- force_split = 2: new windows always land to the right of (or below) the focused one,
  -- instead of depending on which side of it the cursor is on.
  dwindle = { force_split = 2, preserve_split = true },

  animations = { enabled = true },

  misc = { disable_hyprland_logo = true },
})

-- smooth, short animations
hl.curve("easeOutQuint", { type = "bezier", points = { {0.23, 1},   {0.32, 1} } })
hl.curve("quick",        { type = "bezier", points = { {0.15, 0},   {0.1, 1}  } })
hl.animation({ leaf = "windows",       enabled = true, speed = 2,   bezier = "easeOutQuint", style = "popin 90%" })
hl.animation({ leaf = "windowsOut",    enabled = true, speed = 1.5, bezier = "quick",        style = "popin 90%" })
hl.animation({ leaf = "fade",          enabled = true, speed = 1.5, bezier = "quick" })
hl.animation({ leaf = "border",        enabled = true, speed = 3,   bezier = "easeOutQuint" })
hl.animation({ leaf = "layers",        enabled = true, speed = 2,   bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "workspaces",    enabled = true, speed = 2,   bezier = "easeOutQuint", style = "slide" })

-- frosted glass behind the (translucent) top bar
hl.layer_rule({
  name  = "waybar-blur",
  match = { namespace = "^waybar$" },
  blur  = true,
  ignore_alpha = 0.2,
})

-- launch / session
hl.bind(mod .. " + Return", hl.dsp.exec_cmd(terminal))
hl.bind(mod .. " + Space",  hl.dsp.exec_cmd(menu))
hl.bind(mod .. " + E",      hl.dsp.exec_cmd("dolphin"))
hl.bind(mod .. " + Escape", hl.dsp.exec_cmd("hyprlock"))
hl.bind(mod .. " + SHIFT + E", hl.dsp.exec_cmd("uwsm stop"))

-- window management
hl.bind(mod .. " + Q", hl.dsp.window.close())
hl.bind(mod .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mod .. " + F", hl.dsp.window.fullscreen())

-- focus with arrows
hl.bind(mod .. " + left",  hl.dsp.focus({ direction = "left" }))
hl.bind(mod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mod .. " + up",    hl.dsp.focus({ direction = "up" }))
hl.bind(mod .. " + down",  hl.dsp.focus({ direction = "down" }))

-- swap with neighbour (mod+SHIFT+arrows) / move within layout, across monitors (mod+CTRL+arrows)
for _, dir in ipairs({ "left", "right", "up", "down" }) do
  hl.bind(mod .. " + SHIFT + " .. dir, hl.dsp.window.swap({ direction = dir }))
  hl.bind(mod .. " + CTRL + "  .. dir, hl.dsp.window.move({ direction = dir }))
end

-- screenshots (hyprshot; saves to ~/Pictures/Screenshots and copies to clipboard)
hl.bind("Print",              hl.dsp.exec_cmd("hyprshot -m region"))
hl.bind("SHIFT + Print",      hl.dsp.exec_cmd("hyprshot -m window"))
hl.bind("CTRL + Print",       hl.dsp.exec_cmd("hyprshot -m output"))
-- region -> clipboard only, no file
hl.bind(mod .. " + Print",    hl.dsp.exec_cmd("hyprshot -m region --clipboard-only"))
-- region -> swappy annotation (previous behaviour)
hl.bind(mod .. " + SHIFT + S", hl.dsp.exec_cmd("hyprshot -m region --raw | swappy -f -"))

-- clipboard history
hl.bind(mod .. " + SHIFT + V", hl.dsp.exec_cmd("cliphist list | wofi --dmenu | cliphist decode | wl-copy"))

-- mod+1..9 switch workspace, mod+SHIFT+1..9 move window there
-- mod+CTRL+N moves the window there AND follows it. 0 is workspace 10.
for i = 1, 10 do
  local key = i % 10
  hl.bind(mod .. " + " .. key,          hl.dsp.focus({ workspace = i }))
  hl.bind(mod .. " + SHIFT + " .. key,  hl.dsp.window.move({ workspace = i }))
  hl.bind(mod .. " + CTRL + " .. key,   hl.dsp.window.move({ workspace = i, follow = true }))
end

-- close the gaps: renumber non-empty workspaces to 1..n (empty ones end up last)
hl.bind(mod .. " + SHIFT + C", hl.dsp.exec_cmd("compact-workspaces"))

-- vim-style workspace nav: mod+SHIFT+H/L = previous/next existing, J = first, K = last
-- (also: mod+Tab, mod+SHIFT+Tab, mod+scroll for previous/next)
hl.bind(mod .. " + SHIFT + L",    hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mod .. " + SHIFT + H",    hl.dsp.focus({ workspace = "e-1" }))
hl.bind(mod .. " + SHIFT + J",    hl.dsp.exec_cmd([[sh -c 'hyprctl dispatch "hl.dsp.focus({ workspace = $(hyprctl workspaces -j | jq "[.[].id | select(. > 0)] | min") })"']]))
hl.bind(mod .. " + SHIFT + K",    hl.dsp.exec_cmd([[sh -c 'hyprctl dispatch "hl.dsp.focus({ workspace = $(hyprctl workspaces -j | jq "[.[].id] | max") })"']]))
hl.bind(mod .. " + Tab",          hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mod .. " + SHIFT + Tab",  hl.dsp.focus({ workspace = "e-1" }))
hl.bind(mod .. " + mouse_down",   hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mod .. " + mouse_up",     hl.dsp.focus({ workspace = "e-1" }))

-- volume / brightness (repeat while held, work on lock screen)
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),      { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp",  hl.dsp.exec_cmd("brightnessctl set 5%+"),                          { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown",hl.dsp.exec_cmd("brightnessctl set 5%-"),                          { locked = true, repeating = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"),   { locked = true })

-- move / resize with mouse
hl.bind(mod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- autostart
-- (on NixOS these are home-manager systemd user services; elsewhere start them here)
hl.on("hyprland.start", function()
  hl.exec_cmd("wl-paste --watch cliphist store")
  hl.exec_cmd("waybar")
  hl.exec_cmd("hyprpaper")
  hl.exec_cmd("hypridle")
  hl.exec_cmd("dunst")
  hl.exec_cmd("systemctl --user start hyprpolkitagent")
  hl.exec_cmd("nm-applet --indicator")
end)
