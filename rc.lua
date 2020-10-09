-- awesome_mode: api-level=4:screen=on
-- If LuaRocks is installed, make sure that packages installed through it are
-- found (e.g. lgi). If LuaRocks is not installed, do nothing.
pcall(require, "luarocks.loader")

-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
-- Declarative object management
local ruled = require("ruled")
local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup")
-- Enable hotkeys help widget for VIM and other apps
-- when client with a matching name is opened:
require("awful.hotkeys_popup.keys")

-- provides setenv
local posix = require("posix")
posix.stdlib.setenv("QT_QPA_PLATFORMTHEME", "qt5ct") -- qt5ct gnome gtk2 gtk3
posix.stdlib.setenv("QT_STYLE_OVERRIDE", "Breeze") -- Breeze Windows Fusion
--posix.stdlib.setenv("QT_AUTO_SCREEN_SCALE_FACTOR", "0")
posix.stdlib.setenv("QT_FONT_DPI", "128")
--posix.stdlib.setenv("GDK_DPI_SCALE", "1.28")
--posix.stdlib.setenv("EDITOR", "vim")

-- Freedesktop.org menu and desktop icons support
-- https://github.com/lcpz/awesome-freedesktop
local freedesktop = require("freedesktop")

-- Alt-Tab for the awesome window manager (and more)
-- https://github.com/blueyed/awesome-cyclefocus
local cyclefocus = require('cyclefocus')
-- cyclefocus.debug_level = 2
-- cyclefocus.debug_use_naughty_notify = true
cyclefocus.move_mouse_pointer = false
cyclefocus.display_next_count = 3
cyclefocus.display_prev_count = 3
cyclefocus.default_preset.base_font_size = 14
cyclefocus.default_preset.scale_factor_for_entry_offset = { ["0"] = 1.5, ["1"] = 1.4,  ["2"] = 1.3,  ["3"] = 1.2,  ["4"] = 1.1, }

-- https://github.com/streetturtle/awesome-wm-widgets
local cpu_widget = require("awesome-wm-widgets.cpu-widget.cpu-widget")
local ram_widget = require("awesome-wm-widgets.ram-widget.ram-widget")
-- local brightness_widget = require("awesome-wm-widgets.brightness-widget.brightness")
local battery_widget = require("awesome-wm-widgets.battery-widget.battery")
local logout_popup = require("awesome-wm-widgets.logout-popup-widget.logout-popup")
local volume_widget = require('awesome-wm-widgets.volume-widget.volume')
local fs_widget = require("awesome-wm-widgets.fs-widget.fs-widget")

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
naughty.connect_signal("request::display_error", function(message, startup)
    naughty.notification {
        urgency = "critical",
        title   = "Oops, an error happened"..(startup and " during startup!" or "!"),
        message = message
    }
end)
-- }}}

-- {{{ Theme selection
-- Themes define colours, icons, font and wallpapers.
local function mytheme(config)
    local protected_call = require("gears.protected_call")
    local theme = protected_call(dofile, config)
    -- Nord: an arctic, north-bluish color palette
    -- Polar Night
    local nord0 = "#2E3440"
    local nord1 = "#3B4252"
    local nord2 = "#434C5E"
    local nord3 = "#4C566A"
    -- Snow Storm
    local nord4 = "#D8DEE9"
    local nord5 = "#E5E9F0"
    local nord6 = "#ECEFF4"
    -- Frost
    local nord7 = "#8FBCBB"
    local nord8 = "#88C0D0"
    local nord9 = "#81A1C1"
    local nord10 = "#5E81AC"
    -- Aurora
    local nord11 = "#BF616A"
    local nord12 = "#D08770"
    local nord13 = "#EBCB8B"
    local nord14 = "#A3BE8C"
    local nord15 = "#B48EAD"
    -- theme.tasklist_fg_focus = nord1
    -- theme.tasklist_bg_focus = nord9
    -- theme.tasklist_fg_normal = nord4
    -- theme.tasklist_bg_normal = nord1
    -- theme.titlebar_fg_focus = nord1
    -- theme.titlebar_bg_focus = nord10
    -- theme.titlebar_fg_normal = nord4
    -- theme.titlebar_bg_normal = nord1
    -- theme.border_normal = nord15
    -- theme.border_focus  = nord14
    -- theme.border_marked = nord13
    -- theme.wibar_border_color = nord15
    -- -- theme.wibar_fg = nord4
    -- -- theme.wibar_bg = nord0

    -- icon theme
    theme.icon_theme="Papirus-Dark"
    -- theme.icon_theme="Nordic-Darker"

    -- sizes
    theme.menu_height = 32
    theme.menu_width = 256
    theme.wibar_height = 30
    theme.wibar_border_width = 1

    theme.wibar_opacity = 0.5

    -- fonts
    theme.font = "Sans 12"
    theme.tasklist_font = "Sans 11"
    theme.tasklist_font_focus = "Sans bold italic 11"
    theme.taglist_font = "Sans 14"
    theme.menu_font = "Sans 14"
    theme.notification_font = "Sans 13"
    -- theme.hotkeys_font = "Sans 14"
    -- theme.hotkeys_description_font = "Sans bold italic 13"
    -- theme.titlebar_font_focus = "Sans bold italic 13" -- this variable does not exist

    local mywallpaper = os.getenv("HOME") .. "/.local/share/backgrounds/awesome_1920x1080.png"
    if gears.filesystem.file_readable(mywallpaper) then
        theme.wallpaper = mywallpaper
    end

    return theme
end

-- https://thibaultmarin.github.io/blog/posts/2016-10-05-Awesome-wm_configuration.html
function get_current_theme()
    local theme_name = "default"
    local theme_fname = gears.filesystem.get_configuration_dir() .. "theme"
    if gears.filesystem.file_readable(theme_fname) then
        for line in io.lines(theme_fname) do
            if string.find(line, "^%s*[^#]") ~= nil then
                theme_name = line:gsub("^%s*(.-)%s*$", "%1")
            end
        end
    end
    local theme_file = get_first_found_file(
        { gears.filesystem.get_configuration_dir() .. "themes/",
          gears.filesystem.get_themes_dir(),
        },
        theme_name .. "/theme.lua"
    )
    return theme_file
end

function get_first_found_file(path_list, fname)
    for _, f in ipairs(path_list) do
        fname_full = f .. fname
        if gears.filesystem.file_readable(fname_full) then
            return fname_full
        end
    end
end

beautiful.init(mytheme(get_current_theme()))
-- }}}

-- {{{ Variable definitions
-- This is used later as the default terminal and editor to run.
terminal = "terminology"
editor = os.getenv("EDITOR") or "emacs"
editor_cmd = terminal .. " -e " .. editor

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"
altkey = "Mod1"
-- }}}

-- {{{ Helper functions
local function confirm_action(name, func)
    return function()
        mouse.screen.mywibox:set_bg(beautiful.bg_urgent)
        mouse.screen.mywibox:set_fg(beautiful.fg_urgent)
        awful.prompt.run {
            prompt = " <b>" .. name .. "</b>?" .. " [y/N]  ",
            textbox = mouse.screen.mypromptbox.widget,
            exe_callback = function (input)
                if string.lower(input) == 'y' then
                    func()
                end
            end,
            history_path = nil,
            done_callback = function ()
                mouse.screen.mywibox:set_bg(beautiful.screen_highlight_bg_active)
                mouse.screen.mywibox:set_fg(beautiful.screen_highlight_fg_active)
            end
        }
    end
end
-- }}}

-- {{{ Menu
-- theme menu
function create_themes_menu()
    -- List of search paths
    path_list = {
        gears.filesystem.get_themes_dir(),
        gears.filesystem.get_configuration_dir() .. "themes/",
    }

    -- Initialize table
    theme_list = {}

    -- Perform search
    for _, path in ipairs(path_list) do
        local p = io.popen("find -L '" .. path .. "' -name theme.lua -type f")
        for fname in p:lines() do
            fold = string.gsub(fname, ".*/(.*)/theme.lua$", "%1")
            theme_list[fold] = fname
            -- naughty.notify({text=fname .. " => " .. fold, title="Theme", timeout=30})
        end
    end

    -- Create menu
    menu_items = {}
    for theme_name, theme_file in pairs(theme_list) do
        theme = nil;
        theme = dofile(theme_file)
        theme_icon = theme.awesome_icon
        theme = nil
        table.insert(menu_items, {
                         theme_name,
                         function ()
                             local theme_fname = gears.filesystem.get_configuration_dir() .. "theme"
                             local file = io.open(theme_fname, "w")
                             file:write(theme_name .. "\n")
                             file:close()
                             awesome.restart()
                         end,
                         theme_icon
        })
    end

    return menu_items
end
-- Create a launcher widget and a main menu
myawesomemenu = {
   { "&Hotkeys", function() hotkeys_popup.show_help(nil, awful.screen.focused()) end },
   { "&Manual", terminal .. " -e man awesome" },
   { "&Edit config", editor_cmd .. " " .. awesome.conffile },
   { "Restart", awesome.restart },
   { "Quit", function() awesome.quit() end },
}

mymainmenu = freedesktop.menu.build({
    before = {
        { "&Awesome", myawesomemenu, beautiful.awesome_icon },
        -- other triads can be put here
    },
    after = {
        { "&Themes", create_themes_menu() },
        { "&Terminal", terminal, menubar.utils.lookup_icon("terminal") },
        { "Loc&k Screen", "xscreensaver-command -lock", menubar.utils.lookup_icon("system-lock-screen") },
        { "&Log Out", function() awesome.quit() end, menubar.utils.lookup_icon("system-log-out") },
        { "Sus&pend", "systemctl suspend", menubar.utils.lookup_icon("system-suspend") },
        { "&Hibernate", "systemctl hibernate", menubar.utils.lookup_icon("system-suspend-hibernate") },
        { "&Reboot",
          confirm_action("Reboot", function() awesome.emit_signal("exit", nil); awful.spawn("systemctl reboot") end),
          menubar.utils.lookup_icon("system-reboot") },
        { "&Shutdown",
          confirm_action("Shutdown", function() awesome.emit_signal("exit", nil); awful.spawn("poweroff") end),
          menubar.utils.lookup_icon("system-shutdown") },
        -- other triads can be put here
    }
})

mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
                                     menu = mymainmenu })

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

-- {{{ Tag
-- Table of layouts to cover with awful.layout.inc, order matters.
tag.connect_signal("request::default_layouts", function()
    awful.layout.append_default_layouts({
        awful.layout.suit.floating,
        awful.layout.suit.tile,
        awful.layout.suit.tile.left,
        awful.layout.suit.tile.bottom,
        awful.layout.suit.tile.top,
        awful.layout.suit.fair,
        awful.layout.suit.fair.horizontal,
        awful.layout.suit.spiral,
        awful.layout.suit.spiral.dwindle,
        awful.layout.suit.max,
        awful.layout.suit.max.fullscreen,
        awful.layout.suit.magnifier,
        awful.layout.suit.corner.nw,
    })
end)
-- }}}

-- {{{ Wibar

-- Keyboard map indicator and switcher
mykeyboardlayout = awful.widget.keyboardlayout()

-- Create a textclock widget
mytextclock = wibox.widget.textclock(" %a %b %d, %T")
mytextclock:connect_signal("button::press",
                           function (a, b, c, btnumber)
                              --naughty.notify({text=item .. " " .. button .. " " .. mods, title="Titre"})
                              if btnumber == 1 then
                                 awful.spawn("gsimplecal next_month")
                              elseif btnumber == 3 then
                                 awful.spawn("gsimplecal prev_month")
                              end
                           end)

screen.connect_signal("request::wallpaper", function(s)
    -- Wallpaper
    if beautiful.wallpaper then
        local wallpaper = beautiful.wallpaper
        -- If wallpaper is a function, call it with the screen
        if type(wallpaper) == "function" then
            wallpaper = wallpaper(s)
        end
        gears.wallpaper.maximized(wallpaper, s, true)
    end
end)

screen.connect_signal("request::desktop_decoration", function(s)
    -- Each screen has its own tag table.
    awful.tag({ "➊", "➋", "➌", "➍", "➎", "➏", "➐", "➑", "➒" }, s, awful.layout.layouts[1])

    -- Create a promptbox for each screen
    s.mypromptbox = awful.widget.prompt()

    -- Create an imagebox widget which will contain an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    s.mylayoutbox = awful.widget.layoutbox {
        screen  = s,
        buttons = {
            awful.button({ }, 1, function () awful.layout.inc( 1) end),
            awful.button({ }, 3, function () awful.layout.inc(-1) end),
            awful.button({ }, 4, function () awful.layout.inc(-1) end),
            awful.button({ }, 5, function () awful.layout.inc( 1) end),
        }
    }

    -- Create a taglist widget
    s.mytaglist = awful.widget.taglist {
        screen  = s,
        filter  = awful.widget.taglist.filter.all,
        buttons = {
            awful.button({ }, 1, function(t) t:view_only() end),
            awful.button({ modkey }, 1, function(t)
                                            if client.focus then
                                                client.focus:move_to_tag(t)
                                            end
                                        end),
            awful.button({ }, 3, awful.tag.viewtoggle),
            awful.button({ modkey }, 3, function(t)
                                            if client.focus then
                                                client.focus:toggle_tag(t)
                                            end
                                        end),
            awful.button({ }, 4, function(t) awful.tag.viewprev(t.screen) end),
            awful.button({ }, 5, function(t) awful.tag.viewnext(t.screen) end),
        }
    }

    -- Create a tasklist widget
    s.mytasklist = awful.widget.tasklist {
        screen  = s,
        filter  = awful.widget.tasklist.filter.currenttags,
        buttons = {
            awful.button({ }, 1, function (c)
                c:activate { context = "tasklist", action = "toggle_minimization" }
            end),
            awful.button({ }, 3, function() awful.menu.client_list { theme = { width = 250 } } end),
            awful.button({ }, 4, function() awful.client.focus.byidx(-1) end),
            awful.button({ }, 5, function() awful.client.focus.byidx( 1) end),
        }
    }

    -- Create the wibox
    s.mywibox = awful.wibar({ position = "bottom", screen = s })

    -- Add widgets to the wibox
    s.mywibox.widget = {
        layout = wibox.layout.align.horizontal,
        { -- Left widgets
            layout = wibox.layout.fixed.horizontal,
            mylauncher,
            s.mytaglist,
            s.mypromptbox,
        },
        s.mytasklist, -- Middle widget
        { -- Right widgets
            layout = wibox.layout.fixed.horizontal,
            mykeyboardlayout,
            wibox.widget.systray(),
            cpu_widget(),
            ram_widget(),
            battery_widget({
                    path_to_icons = path_to_icons,
                    show_current_level = true,
                    display_notification = true,
                    timeout = 5,
            }),
            -- brightness_widget({
            --         get_brightness_cmd = 'brightnessctl get',
            --         inc_brightness_cmd = 'brightnessctl set +5%',
            --         dec_brightness_cmd = 'brightnessctl set -5%',
            --         path_to_icon = menubar.utils.lookup_icon("display-brightness-symbolic.svg"),
            -- }),
            volume_widget({ icon_dir = path_to_icons }),
            -- fs_widget({ mounts = { '/', '/alt' } }),
            mytextclock,
            s.mylayoutbox,
            -- logout_popup.widget{},
        },
    }
end)
-- }}}

-- {{{ Snap client to screen edges
-- Awesome 4 adds edge snapping, the following disables it.
awful.mouse.snap.edge_enabled = false
-- }}}

-- {{{ Mouse bindings
awful.mouse.append_global_mousebindings({
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewprev),
    awful.button({ }, 5, awful.tag.viewnext),
})
-- }}}

-- {{{ Key bindings

-- General Awesome keys
awful.keyboard.append_global_keybindings({
    awful.key({ modkey,           }, "s",      hotkeys_popup.show_help,
              {description="show help", group="awesome"}),
    awful.key({ modkey,           }, "w", function () mymainmenu:show() end,
              {description = "show main menu", group = "awesome"}),
    awful.key({ modkey, "Control" }, "r", awesome.restart,
              {description = "reload awesome", group = "awesome"}),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit,
              {description = "quit awesome", group = "awesome"}),
    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run {
                    prompt       = "Run Lua code: ",
                    textbox      = awful.screen.focused().mypromptbox.widget,
                    exe_callback = awful.util.eval,
                    history_path = awful.util.get_cache_dir() .. "/history_eval"
                  }
              end,
              {description = "lua execute prompt", group = "awesome"}),
    awful.key({ modkey,           }, "Return", function () awful.spawn(terminal) end,
              {description = "open a terminal", group = "launcher"}),
    awful.key({ modkey },            "r",     function () awful.screen.focused().mypromptbox:run() end,
              {description = "run prompt", group = "launcher"}),
    awful.key({ modkey }, "p", function() menubar.show() end,
              {description = "show the menubar", group = "launcher"}),
})

-- Tags related keybindings
awful.keyboard.append_global_keybindings({
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev,
              {description = "view previous", group = "tag"}),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext,
              {description = "view next", group = "tag"}),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore,
              {description = "go back", group = "tag"}),
})

-- Focus related keybindings
awful.keyboard.append_global_keybindings({
    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.byidx( 1)
        end,
        {description = "focus next by index", group = "client"}
    ),
    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx(-1)
        end,
        {description = "focus previous by index", group = "client"}
    ),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end,
              {description = "focus the next screen", group = "screen"}),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end,
              {description = "focus the previous screen", group = "screen"}),
    awful.key({ modkey, "Control" }, "n",
              function ()
                  local c = awful.client.restore()
                  -- Focus restored client
                  if c then
                    c:activate { raise = true, context = "key.unminimize" }
                  end
              end,
              {description = "restore minimized", group = "client"}),

    -- Added by JRM

    -- awesome-cyclefocus: cycle through all clients on the same screen
    cyclefocus.key({ altkey, }, "Tab", {
            cycle_filters = { function (c, source_c)
                              if c == nil or source_c == nil then
                                  return false
                              end
                              for _, t in pairs(c:tags()) do
                                  for _, t2 in pairs(source_c:tags()) do
                                      if t.name == t2.name then
                                          return true
                                      end
                                  end
                              end
                              return false
                          end,
                          -- cyclefocus.filters.same_screen,
                        },
            keys = {'Tab', 'ISO_Left_Tab'},  -- default, could be left out
            display_notifications = true,
    }),

    -- Volume control
    awful.key({ }, "XF86AudioRaiseVolume",
        function () awful.spawn("pactl set-sink-volume @DEFAULT_SINK@ +2000") end,
        {description = "raise master volume", group = "custom"}),

    awful.key({ }, "XF86AudioLowerVolume",
        function () awful.spawn("pactl set-sink-volume @DEFAULT_SINK@ -2000") end,
        {description = "lower master volume", group = "custom"}),

    awful.key({ }, "XF86AudioMute",
        function () awful.spawn("pactl set-sink-mute @DEFAULT_SINK@ toggle") end,
        {description = "toggle mute sound", group = "custom"}),

    awful.key({ }, "XF86AudioPlay",
        function () awful.spawn("playerctl play-pause") end,
        {description = "toggle play/pause media", group = "custom"}),

    awful.key({ }, "XF86AudioNext",
        function () awful.spawn("playerctl next") end,
        {description = "skip to next track", group = "custom"}),

    awful.key({ }, "XF86AudioPrev",
        function () awful.spawn("playerctl previous") end,
        {description = "skip to previous track", group = "custom"}),
})

-- Layout related keybindings
awful.keyboard.append_global_keybindings({
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end,
              {description = "swap with next client by index", group = "client"}),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end,
              {description = "swap with previous client by index", group = "client"}),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto,
              {description = "jump to urgent client", group = "client"}),
    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)          end,
              {description = "increase master width factor", group = "layout"}),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)          end,
              {description = "decrease master width factor", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1, nil, true) end,
              {description = "increase the number of master clients", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1, nil, true) end,
              {description = "decrease the number of master clients", group = "layout"}),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1, nil, true)    end,
              {description = "increase the number of columns", group = "layout"}),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1, nil, true)    end,
              {description = "decrease the number of columns", group = "layout"}),
    awful.key({ modkey,           }, "space", function () awful.layout.inc( 1)                end,
              {description = "select next", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(-1)                end,
              {description = "select previous", group = "layout"}),
})


awful.keyboard.append_global_keybindings({
    awful.key {
        modifiers   = { modkey },
        keygroup    = "numrow",
        description = "only view tag",
        group       = "tag",
        on_press    = function (index)
            local screen = awful.screen.focused()
            local tag = screen.tags[index]
            if tag then
                tag:view_only()
            end
        end,
    },
    awful.key {
        modifiers   = { modkey, "Control" },
        keygroup    = "numrow",
        description = "toggle tag",
        group       = "tag",
        on_press    = function (index)
            local screen = awful.screen.focused()
            local tag = screen.tags[index]
            if tag then
                awful.tag.viewtoggle(tag)
            end
        end,
    },
    awful.key {
        modifiers = { modkey, "Shift" },
        keygroup    = "numrow",
        description = "move focused client to tag",
        group       = "tag",
        on_press    = function (index)
            if client.focus then
                local tag = client.focus.screen.tags[index]
                if tag then
                    client.focus:move_to_tag(tag)
                end
            end
        end,
    },
    awful.key {
        modifiers   = { modkey, "Control", "Shift" },
        keygroup    = "numrow",
        description = "toggle focused client on tag",
        group       = "tag",
        on_press    = function (index)
            if client.focus then
                local tag = client.focus.screen.tags[index]
                if tag then
                    client.focus:toggle_tag(tag)
                end
            end
        end,
    },
    awful.key {
        modifiers   = { modkey },
        keygroup    = "numpad",
        description = "select layout directly",
        group       = "layout",
        on_press    = function (index)
            local t = awful.screen.focused().selected_tag
            if t then
                t.layout = t.layouts[index] or t.layout
            end
        end,
    }
})

client.connect_signal("request::default_mousebindings", function()
    awful.mouse.append_client_mousebindings({
        awful.button({ }, 1, function (c)
            c:activate { context = "mouse_click" }
        end),
        awful.button({ modkey }, 1, function (c)
            c:activate { context = "mouse_click", action = "mouse_move"  }
        end),
        awful.button({ modkey }, 3, function (c)
            c:activate { context = "mouse_click", action = "mouse_resize"}
        end),
    })
end)

client.connect_signal("request::default_keybindings", function()
    awful.keyboard.append_client_keybindings({
        awful.key({ modkey,           }, "f",
            function (c)
                c.fullscreen = not c.fullscreen
                c:raise()
            end,
            {description = "toggle fullscreen", group = "client"}),
        awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end,
                {description = "close", group = "client"}),
        awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ,
                {description = "toggle floating", group = "client"}),
        awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end,
                {description = "move to master", group = "client"}),
        awful.key({ modkey,           }, "o",      function (c) c:move_to_screen()               end,
                {description = "move to screen", group = "client"}),
        awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end,
                {description = "toggle keep on top", group = "client"}),
        awful.key({ modkey,           }, "n",
            function (c)
                -- The client currently has the input focus, so it cannot be
                -- minimized, since minimized clients can't have the focus.
                c.minimized = true
            end ,
            {description = "minimize", group = "client"}),
        awful.key({ modkey,           }, "m",
            function (c)
                c.maximized = not c.maximized
                c:raise()
            end ,
            {description = "(un)maximize", group = "client"}),
        awful.key({ modkey, "Control" }, "m",
            function (c)
                c.maximized_vertical = not c.maximized_vertical
                c:raise()
            end ,
            {description = "(un)maximize vertically", group = "client"}),
        awful.key({ modkey, "Shift"   }, "m",
            function (c)
                c.maximized_horizontal = not c.maximized_horizontal
                c:raise()
            end ,
            {description = "(un)maximize horizontally", group = "client"}),
    })
end)

-- }}}

-- {{{ Rules
-- Rules to apply to new clients.
ruled.client.connect_signal("request::rules", function()
    -- All clients will match this rule.
    ruled.client.append_rule {
        id         = "global",
        rule       = { },
        properties = {
            focus     = awful.client.focus.filter,
            raise     = true,
            screen    = awful.screen.preferred,
            placement = awful.placement.no_overlap+awful.placement.no_offscreen
        }
    }

    -- Floating clients.
    ruled.client.append_rule {
        id       = "floating",
        rule_any = {
            instance = { "copyq", "pinentry" },
            class    = {
                "Arandr", "Blueman-manager", "Gpick", "Kruler", "Sxiv",
                "Tor Browser", "Wpa_gui", "veromix", "xtightvncviewer"
            },
            -- Note that the name property shown in xprop might be set slightly after creation of the client
            -- and the name shown there might not match defined rules here.
            name    = {
                "Event Tester",  -- xev.
            },
            role    = {
                "AlarmWindow",    -- Thunderbird's calendar.
                "ConfigManager",  -- Thunderbird's about:config.
                "pop-up",         -- e.g. Google Chrome's (detached) Developer Tools.
            }
        },
        properties = { floating = true }
    }

    -- Add titlebars to normal clients and dialogs
    ruled.client.append_rule {
        id         = "titlebars",
        rule_any   = { type = { "normal", "dialog" } },
        properties = { titlebars_enabled = true      }
    }

    -- Set Firefox to always map on the tag named "2" on screen 1.
    -- ruled.client.append_rule {
    --     rule       = { class = "Firefox"     },
    --     properties = { screen = 1, tag = "2" }
    -- }
end)

-- }}}

-- {{{ Titlebars
-- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal("request::titlebars", function(c)
    -- buttons for the titlebar
    local buttons = {
        awful.button({ }, 1, function()
            c:activate { context = "titlebar", action = "mouse_move"  }
        end),
        awful.button({ }, 3, function()
            c:activate { context = "titlebar", action = "mouse_resize"}
        end),
    }

    awful.titlebar(c).widget = {
        { -- Left
            awful.titlebar.widget.iconwidget(c),
            buttons = buttons,
            layout  = wibox.layout.fixed.horizontal
        },
        { -- Middle
            { -- Title
                align  = "center",
                widget = awful.titlebar.widget.titlewidget(c)
            },
            buttons = buttons,
            layout  = wibox.layout.flex.horizontal
        },
        { -- Right
            awful.titlebar.widget.floatingbutton (c),
            awful.titlebar.widget.maximizedbutton(c),
            awful.titlebar.widget.stickybutton   (c),
            awful.titlebar.widget.ontopbutton    (c),
            awful.titlebar.widget.closebutton    (c),
            layout = wibox.layout.fixed.horizontal()
        },
        layout = wibox.layout.align.horizontal
    }
end)

-- {{{ Notifications

ruled.notification.connect_signal('request::rules', function()
    -- All notifications will match this rule.
    ruled.notification.append_rule {
        rule       = { },
        properties = {
            screen           = awful.screen.preferred,
            implicit_timeout = 5,
        }
    }
end)

naughty.connect_signal("request::display", function(n)
    naughty.layout.box { notification = n }
end)

-- }}}

-- {{{ Run script on startup
-- https://askubuntu.com/questions/1133769/run-script-on-awesome-wm-startup
--
-- On the exit signal, that performs only on awesome restart we're
-- creating a flag file, that tells to the startup signal that this
-- startup is going immediately after the awesome restart. On the startup
-- signal fired we're removing this flag and if it doesn't remove
-- successfully (doesn't exist) - we're running our startup-only script.

awesome.connect_signal(
    'exit',
    function(args)
        awful.util.spawn('touch /tmp/awesomw-restart')
    end
)

awesome.connect_signal(
    'startup',
    function(args)
        awful.util.spawn('bash -c "rm /tmp/awesomw-restart || $HOME/.config/awesome/start.sh')
    end
)

awful.spawn.with_shell("$HOME/.config/awesome/start.sh")
-- }}}
