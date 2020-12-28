
-- ---- Init ---- --
local awesome, client, mouse, screen, tag = awesome, client, mouse, screen, tag
local ipairs, string, os, table, tostring, tonumber, type = ipairs, string, os, table, tostring, tonumber, type

-- Standard awesome library
local gears         = require("gears") --Utilities such as color parsing and objects
local awful         = require("awful") --Everything related to window managment
                      require("awful.autofocus")
-- Widget and layout library
local wibox         = require("wibox")
local menubar = require("menubar")

-- Theme handling library
local beautiful     = require("beautiful")

-- Notification library
local naughty       = require("naughty")
naughty.config.defaults['icon_size'] = 100

local lain          = require("lain")
local freedesktop   = require("freedesktop")

-- Enable hotkeys help widget for VIM and other apps
-- when client with a matching name is opened:
local hotkeys_popup = require("awful.hotkeys_popup").widget
                      require("awful.hotkeys_popup.keys")
local my_table      = awful.util.table or gears.table -- 4.{0,1} compatibility


-- error handling
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = tostring(err) })
        in_error = false
    end)
end

local function run_once(cmd_arr)
    for _, cmd in ipairs(cmd_arr) do
        awful.spawn.with_shell(string.format("pgrep -u $USER -fx '%s' > /dev/null || (%s)", cmd, cmd))
    end
end

run_once({ "unclutter -root" }) -- entries must be comma-separated




-- ---- Autorun ---- --
awful.spawn.with_shell("~/.config/awesome/autorun.sh")
awful.spawn.with_shell("volumeicon")
-- awful.spawn.with_shell("nitrogen --restore")
-- awful.spawn.with_shell("picom --config  $HOME/.config/picom/picom.conf")
-- awful.spawn.with_shell("nm-applet")



-- ---- Themes ---- --
local themes = {
    "powerarrow-blue", -- 1
    "powerarrow",      -- 2
    "multicolor",      -- 3
}

-- choose your theme here
local chosen_theme = themes[1]
local theme_path = string.format("%s/.config/awesome/themes/%s/theme.lua", os.getenv("HOME"), chosen_theme)
beautiful.init(theme_path)
--beautiful.init(string.format(gears.filesystem.get_configuration_dir() .. "/themes/%s/theme.lua", chosen_theme))



-- ---- Variables ---- --
-- keys
local modkey       = "Mod4"
local altkey       = "Mod1"
local modkey1      = "Control"

-- personal variables
local terminal          = "alacritty" or os.getenv("TERMINAL")
-- local browser           = "exo-open --launch WebBrowser" or "firefox"
local browser           = "firefox"
local editor            = os.getenv("EDITOR") or "micro"
local editorgui         = "leafpad"
local filemanager       = "thunar"
local mediaplayer       = "vlc"

-- awesome variables
awful.util.terminal = terminal


-- ---- Layouts ---- --
awful.layout.suit.tile.left.mirror = true
awful.layout.layouts = {
    awful.layout.suit.tile,
    awful.layout.suit.floating,
    --awful.layout.suit.tile.left,
    awful.layout.suit.tile.bottom,
    --awful.layout.suit.tile.top,
    --awful.layout.suit.fair,
    --awful.layout.suit.fair.horizontal,
    --awful.layout.suit.spiral,
    --awful.layout.suit.spiral.dwindle,
    awful.layout.suit.max,
    --awful.layout.suit.max.fullscreen,
    awful.layout.suit.magnifier,
    --awful.layout.suit.corner.nw,
    --awful.layout.suit.corner.ne,
    --awful.layout.suit.corner.sw,
    --awful.layout.suit.corner.se,
    --lain.layout.cascade,
    --lain.layout.cascade.tile,
    --lain.layout.centerwork,
    --lain.layout.centerwork.horizontal,
    --lain.layout.termfair,
    --lain.layout.termfair.center,
}

lain.layout.termfair.nmaster           = 3
lain.layout.termfair.ncol              = 1
lain.layout.termfair.center.nmaster    = 3
lain.layout.termfair.center.ncol       = 1
lain.layout.cascade.tile.offset_x      = 2
lain.layout.cascade.tile.offset_y      = 32
lain.layout.cascade.tile.extra_padding = 5
lain.layout.cascade.tile.nmaster       = 5
lain.layout.cascade.tile.ncol          = 2



-- ---- Taglist ---- --
awful.util.tagnames = { "Main", "1", "2", "3" }
awful.util.taglist_buttons = my_table.join(
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
    awful.button({ }, 4, function(t) awful.tag.viewnext(t.screen) end),
    awful.button({ }, 5, function(t) awful.tag.viewprev(t.screen) end)
)



-- ---- Tasklist ---- --
awful.util.tasklist_buttons = my_table.join(
    awful.button({ }, 1, function (c)
        if c == client.focus then
            c.minimized = true
        else
            c:emit_signal("request::activate", "tasklist", {raise = true})
        end
    end),
    awful.button({ }, 3, function ()
        local instance = nil

        return function ()
            if instance and instance.wibox.visible then
                instance:hide()
                instance = nil
            else
                instance = awful.menu.clients({theme = {width = 250}})
            end
        end
    end),
    awful.button({ }, 4, function () awful.client.focus.byidx(1) end),
    awful.button({ }, 5, function () awful.client.focus.byidx(-1) end)
)



-- ---- Main menu ---- --
myawesomemenu = {    
	{ "Hotkeys", function() return false, hotkeys_popup.show_help end, menubar.utils.lookup_icon("preferences-desktop-keyboard-shortcuts") },
    -- { "Manual", terminal .. " -e 'man awesome'" },
    { "Edit config (GUI)", editorgui .. " " .. awesome.conffile,  menubar.utils.lookup_icon("accessories-text-editor") },
    { "Restart", awesome.restart, menubar.utils.lookup_icon("system-restart") },
}

myexitmenu = {
    { "Log Out", function() awesome.quit() end, menubar.utils.lookup_icon("system-log-out") },
    { "Suspend", "systemctl suspend", menubar.utils.lookup_icon("system-suspend") },
    -- { "Hibernate", "systemctl hibernate", menubar.utils.lookup_icon("system-suspend-hibernate") },
    { "Reboot", "systemctl reboot", menubar.utils.lookup_icon("system-reboot") },
    { "Shutdown", "poweroff", menubar.utils.lookup_icon("system-shutdown") }
}

awful.util.mymainmenu = freedesktop.menu.build({
    before = { -- items always on top
        { "Awesome", myawesomemenu, beautiful.awesome_icon },
        { "Terminal", terminal, menubar.utils.lookup_icon("utilities-terminal") },
        { "Browser", browser, menubar.utils.lookup_icon("internet-web-browser") },
        { "Files", filemanager, menubar.utils.lookup_icon("system-file-manager") },
    },
    after = { -- items always on the bottom
        { "Exit", myexitmenu, menubar.utils.lookup_icon("system-shutdown") },
    }
})



-- ---- Wallpaper ----
-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
local function set_wallpaper(s)
    -- Wallpaper
    if beautiful.wallpaper then
        local wallpaper = beautiful.wallpaper
        -- If wallpaper is a function, call it with the screen
        if type(wallpaper) == "function" then
            wallpaper = wallpaper(s)
        end
        gears.wallpaper.maximized(wallpaper, s, true)
    end
end
-- Create a wibox for each screen and add it
-- awful.screen.connect_for_each_screen(function(s) beautiful.at_screen_connect(s) end)




-- ---- Widgets ---- --

-- Main launcher
mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
                                     menu = awful.util.mymainmenu })

-- Create a textclock widget
mytextclock = wibox.widget.textclock("%H:%M:%S") -- TODO: seconds don't work

-- Keyboard map indicator and switcher
mykeyboardlayout = awful.widget.keyboardlayout()



-- ---- Set main panels ---- --                             
awful.screen.connect_for_each_screen(function(s)
	-- Trigger screen connect
	-- main panel is defined in theme files, only triggered here
	beautiful.at_screen_connect(s)
	
    -- Wallpaper
    set_wallpaper(s)    

    -- -- Create a promptbox for each screen
    -- s.mypromptbox = awful.widget.prompt()
-- 
    -- -- Create the wibox
    -- s.mywibox = awful.wibar({ position = "bottom", screen = s, height = 22 })
-- 
    -- -- Add widgets to the wibox
    -- s.mywibox:setup {
        -- layout = wibox.layout.align.horizontal,
        -- mylauncher,
        -- s.mypromptbox
    -- }
end)



-- ---- Behavior ---- --

-- New windows always as slave
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c)
    -- Set the windows at the slave,
    -- i.e. put it at the end of others instead of setting it master.
    -- if not awesome.startup then awful.client.setslave(c) end

    if awesome.startup and
      not c.size_hints.user_position
      and not c.size_hints.program_position then
        -- Prevent clients from being unreachable after screen count changes.
        awful.placement.no_offscreen(c)
    end
end)

-- Mouse bindings for main panel
-- root.buttons(gears.table.join(
root.buttons(my_table.join(
	-- awful.button({ }, 1, function () mymainmenu:hide() end),
    awful.button({ }, 3, function () awful.util.mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))

-- Mouse click move / resize window
clientbuttons = my_table.join(
    awful.button({ }, 1, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
    end),
    awful.button({ modkey }, 1, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
        awful.mouse.client.move(c)
    end),
    awful.button({ modkey }, 3, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
        awful.mouse.client.resize(c)
    end)
)

-- Autofocus window on mouse enter
client.connect_signal("mouse::enter", function(c)
    c:emit_signal("request::activate", "mouse_enter", {raise = true})
end)


-- No border for maximized clients
function border_adjust(c)
    if c.maximized then -- no borders if only 1 client visible
        c.border_width = 0
    elseif #awful.screen.focused().clients > 1 then
        c.border_width = beautiful.border_width
        c.border_color = beautiful.border_focus
    end
end

client.connect_signal("focus", border_adjust)
client.connect_signal("property::maximized", border_adjust)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)



-- ---- Titlebars ---- --
-- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal("request::titlebars", function(c)
    -- Custom
    if beautiful.titlebar_fun then
        beautiful.titlebar_fun(c)
        return
    end

    -- Default
    -- buttons for the titlebar
    local buttons = my_table.join(
        awful.button({ }, 1, function()
            c:emit_signal("request::activate", "titlebar", {raise = true})
            awful.mouse.client.move(c)
        end),
        awful.button({ }, 3, function()
            c:emit_signal("request::activate", "titlebar", {raise = true})
            awful.mouse.client.resize(c)
        end)
    )

    awful.titlebar(c, {size = 22}) : setup {
    -- awful.titlebar(c) : setup {
    	{ -- padding
	        {   -- Left
	            awful.titlebar.widget.iconwidget(c),
	            -- wibox.widget.separator{thickness=5, orientation="vertical"},
	            awful.titlebar.widget.ontopbutton(c),
	            buttons = buttons,
	            spacing=3,
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
	            awful.titlebar.widget.stickybutton   (c),
	            awful.titlebar.widget.minimizebutton (c),
	            awful.titlebar.widget.maximizedbutton(c),
	            awful.titlebar.widget.closebutton    (c),
	            spacing=3,
	            layout = wibox.layout.fixed.horizontal()
	        },
	        layout = wibox.layout.align.horizontal
    	},
   		margins = 2,
   		widget = wibox.container.margin
   		}
        -- Hide the menubar if we are not floating
   -- local l = awful.layout.get(c.screen)
   -- if not (l.name == "floating" or c.floating) then
   --     awful.titlebar.hide(c)
   -- end
end)



-- ---- Hotkeys ---- --
clientkeys = my_table.join(
    awful.key({ modkey,           }, "f",
        function (c)
            c.fullscreen = not c.fullscreen
            c:raise()
        end,
        {description = "toggle fullscreen", group = "client"}),
    awful.key({ modkey,           }, "x",      function (c) c:kill()                         end,
              {description = "close", group = "client"}),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ,
              {description = "toggle floating", group = "client"}),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end,
              {description = "move to master", group = "client"}),
    awful.key({ modkey,           }, "o",      function (c) c:move_to_screen()               end,
              {description = "move to screen", group = "client"}),
    awful.key({ }, "F12",      function (c) c.ontop = not c.ontop            end,
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
        {description = "(un)maximize horizontally", group = "client"})
)

globalkeys = my_table.join(
	-- awesome
    awful.key({ modkey,           }, "s",      hotkeys_popup.show_help,
              {description="show help", group="awesome"}),
    awful.key({ modkey,           }, "w", function () awful.util.mymainmenu:show() end,
              {description = "show main menu", group = "awesome"}),
    awful.key({ modkey, "Control" }, "r", awesome.restart,
              {description = "reload awesome", group = "awesome"}),
    awful.key({ modkey, "Control"   }, "q", awesome.quit,
              {description = "quit awesome", group = "awesome"}),

              
    -- awful.key({ modkey }, "ö",
        -- function ()
            -- awful.prompt.run {
              -- prompt       = "Run Lua code: ",
              -- textbox      = awful.screen.focused().mypromptbox.widget,
              -- exe_callback = awful.util.eval,
              -- history_path = awful.util.get_cache_dir() .. "/history_eval"
            -- }
        -- end,
        -- {description = "lua execute prompt", group = "awesome"}),

    -- tag
    awful.key({ "Control" },  "F1",   awful.tag.viewprev,
              {description = "view previous", group = "tag"}),
    awful.key({ "Control" }, "F2",  awful.tag.viewnext,
              {description = "view next", group = "tag"}),
                  
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore,
              {description = "go back", group = "tag"}),

	-- client
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
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end,
        {description = "go back", group = "client"}),
    awful.key({ modkey, "Control" }, "n",
        function ()
            local c = awful.client.restore()
            -- Focus restored client
            if c then
                client.focus = c
                c:raise()
            end
        end,
        {description = "restore minimized", group = "client"}),

	awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end,
              {description = "swap with next client by index", group = "client"}),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end,
              {description = "swap with previous client by index", group = "client"}),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto,
              {description = "jump to urgent client", group = "client"}),

    -- screen
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end,
              {description = "focus the next screen", group = "screen"}),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end,
              {description = "focus the previous screen", group = "screen"}),

    -- launcher
    awful.key({ modkey,           }, "t", function () awful.spawn(terminal) end,
              {description = "open a terminal", group = "launcher"}),
    awful.key({ modkey     }, "b", function () awful.spawn(browser)          end,
              {description = "launch browser", group = "launcher"}),
    awful.key({ modkey,           }, "e", function () awful.spawn(filemanager)            end,
              {description = "launch filemanager", group = "launcher"}),
    awful.key({ modkey }, "r", function () awful.spawn("/usr/bin/rofi -show drun -modi drun") end,
    	          {description = "launch rofi", group = "launcher"}),
	-- awful.key({ modkey }, "r", function () awful.screen.focused().mypromptbox:run() end,
	          -- {description = "run prompt", group = "launcher"}),
	-- awful.key({ modkey }, "p", function() menubar.show() end,
	          -- {description = "show the menubar", group = "launcher"}),

	-- layout
    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)                 end,
              {description = "increase master width factor", group = "layout"}),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)                 end,
              {description = "decrease master width factor", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1, nil, true)        end,
              {description = "increase the number of master clients", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1, nil, true)        end,
              {description = "decrease the number of master clients", group = "layout"}),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1, nil, true)           end,
              {description = "increase the number of columns", group = "layout"}),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1, nil, true)           end,
              {description = "decrease the number of columns", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(-1)                       end,
              {description = "select previous", group = "layout"}),

    -- screenshot          
    awful.key({                   }, "Print", function () awful.spawn.with_shell("sleep 0.1 && /usr/bin/i3-scrot -d")   end,
              {description = "capture a screenshot", group = "screenshot"}),
    awful.key({"Control"          }, "Print", function () awful.spawn.with_shell("sleep 0.1 && /usr/bin/i3-scrot -w")   end,
              {description = "capture a screenshot of active window", group = "screenshot"}),
    awful.key({"Shift"            }, "Print", function () awful.spawn.with_shell("sleep 0.1 && /usr/bin/i3-scrot -s")   end,
              {description = "capture a screenshot of selection", group = "screenshot"})
       
)

-- Set keys
root.keys(globalkeys)




-- ---- Window rules ---- --
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = awful.client.focus.filter,
                     raise = true,
                     keys = clientkeys,
                     buttons = clientbuttons,
                     screen = awful.screen.preferred,
                     placement = awful.placement.no_overlap+awful.placement.no_offscreen,
                     size_hints_honor = false
     }
    },

    -- Titlebars
    { rule_any = { type = { "dialog", "normal" } },
      properties = { titlebars_enabled = true } },

    -- Set applications to always map on the tag 1 on screen 1.
    -- find class or role via xprop command
    --{ rule = { class = browser1 },
      --properties = { screen = 1, tag = awful.util.tagnames[1] } },

    --{ rule = { class = editorgui },
        --properties = { screen = 1, tag = awful.util.tagnames[2] } },

    --{ rule = { class = "Geany" },
        --properties = { screen = 1, tag = awful.util.tagnames[2] } },

    -- Set applications to always map on the tag 3 on screen 1.
    --{ rule = { class = "Inkscape" },
        --properties = { screen = 1, tag = awful.util.tagnames[3] } },

    -- Set applications to always map on the tag 4 on screen 1.
    --{ rule = { class = "Gimp" },
        --properties = { screen = 1, tag = awful.util.tagnames[4] } },

    -- Set applications to be maximized at startup.
    -- find class or role via xprop command

    { rule = { class = editorgui },
          properties = { maximized = true } },

    { rule = { class = "Gimp*", role = "gimp-image-window" },
          properties = { maximized = true } },

    { rule = { class = "inkscape" },
          properties = { maximized = true } },

    -- { rule = { class = mediaplayer },
          -- properties = { maximized = true } },

    { rule = { class = "Vlc" },
          properties = { maximized = true } },

    -- { rule = { class = "VirtualBox Manager" },
          -- properties = { maximized = true } },

    -- { rule = { class = "VirtualBox Machine" },
          -- properties = { maximized = true } },

    -- { rule = { class = "Xfce4-settings-manager" },
          -- properties = { floating = false } },

    -- { rule = { instance = "qutebrowser" },
          -- properties = { screen = 1, tag = " SYS " } },


    -- Floating clients.
    { rule_any = {
        instance = {
          "DTA",  -- Firefox addon DownThemAll.
          "copyq",  -- Includes session name in class.
        },
        class = {
          "Arandr",
          "Blueberry",
          "Galculator",
          "Gnome-font-viewer",
          "Gpick",
          "Imagewriter",
          "Font-manager",
          "Kruler",
          "MessageWin",  -- kalarm.
          "Oblogout",
          "Peek",
          "Skype",
          "System-config-printer.py",
          "Sxiv",
          "Unetbootin.elf",
          "Wpa_gui",
          "pinentry",
          "veromix",
          "xtightvncviewer"},

        name = {
          "Event Tester",  -- xev.
        },
        role = {
          "AlarmWindow",  -- Thunderbird's calendar.
          "pop-up",       -- e.g. Google Chrome's (detached) Developer Tools.
          "Preferences",
          "setup",
        }
      }, properties = { floating = true }},
}


