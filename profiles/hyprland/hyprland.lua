hl.config({
  general = {
    gaps_in = 0,
    gaps_out = 0,
    border_size = 0,
    ["col.active_border"] = "rgba(88888888)",
    ["col.inactive_border"] = "rgba(00000088)",
    allow_tearing = true,
    resize_on_border = true,
  },
  input = {
    kb_options = "caps:escape_shifted_capslock",
  },
})

hl.on("hyprland.start", function()
  hl.exec_cmd("noctalia")
  hl.exec_cmd("fcitx5 -d")
end)

hl.window_rule({
  no_anim = true,
  match = {
    class = "^(UnrealEditor)$",
    title = "^\\w*$",
  },
})

hl.window_rule({
  no_initial_focus = true,
  match = {
    class = "^(UnrealEditor)$",
    title = "^\\w*$",
  },
})

hl.window_rule({
  no_focus = true,
  match = {
    class = "^(UnrealEditor)$",
    title = "^$",
  },
})

local mod = "SUPER"

hl.bind(mod .. " + Return", hl.dsp.exec_cmd("kitty"))
hl.bind(mod .. " + W", hl.dsp.window.close())
hl.bind(mod .. " + M", hl.dsp.exec_cmd("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'"))
hl.bind(mod .. " + E", hl.dsp.exec_cmd("open ."))
hl.bind(mod .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mod .. " + P", hl.dsp.window.pseudo())
hl.bind(mod .. " + J", hl.dsp.layout("togglesplit"))    -- dwindle only

hl.bind(mod .. " + left",  hl.dsp.focus({ direction = "left" }))
hl.bind(mod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mod .. " + up",    hl.dsp.focus({ direction = "up" }))
hl.bind(mod .. " + down",  hl.dsp.focus({ direction = "down" }))

for i = 1, 10 do
    local key = i % 10
    hl.bind(mod .. " + " .. key,             hl.dsp.focus({ workspace = i}))
    hl.bind(mod .. " + SHIFT + " .. key,     hl.dsp.window.move({ workspace = i }))
end

hl.bind(mod .. " + S",         hl.dsp.workspace.toggle_special("magic"))
hl.bind(mod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

hl.bind(mod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

hl.bind(mod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),      { locked = true, repeating = true })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),     { locked = true, repeating = true })
hl.bind("XF86AudioMicMute",     hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),   { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp",  hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"),                  { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown",hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"),                  { locked = true, repeating = true })

hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true })

hl.bind(mod .. " + SPACE", hl.dsp.exec_cmd("noctalia msg panel-toggle launcher"))
hl.bind(mod .. " + print", hl.dsp.exec_cmd("noctalia msg plugin noctalia/screen-recorder:service all toggle"))
hl.bind("print", hl.dsp.exec_cmd("hyprshot -z -m output -o <constants.directories.home.screenshots>"))
hl.bind(mod .. " + slash", hl.dsp.exec_cmd("noctalia msg plugin noctalia/keybind-cheatsheet:service all toggle"))