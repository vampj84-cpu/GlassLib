# GlassLib

Liquid glass UI library for Roblox exploits.

## Setup

Paste this into your script:

```lua
local GlassLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/vampj84-cpu/GlassLib/main/GlassLib_Compiled.lua"))()
```

That's it. You now have `GlassLib` ready to use.

## Example

```lua
local GlassLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/vampj84-cpu/GlassLib/main/GlassLib_Compiled.lua"))()

local Window = GlassLib:CreateWindow({
    Title = "My Hub",
    Author = "by Me",
})

local Tab = Window:CreateTab({Name = "Main"})
local Section = Tab:CreateSection({Name = "Combat"})

Section:CreateButton({
    Title = "Click Me",
    Callback = function()
        GlassLib:Notify({Title = "Clicked!", Content = "It works", Duration = 2})
    end,
})

Section:CreateToggle({
    Title = "Auto Farm",
    Default = false,
    Callback = function(state) print(state) end,
})

Section:CreateSlider({
    Title = "Speed",
    Min = 16,
    Max = 500,
    Default = 100,
    Callback = function(val) print(val) end,
})

Section:CreateDropdown({
    Title = "Weapon",
    Options = {"Sword", "Bow", "Staff"},
    Callback = function(opt) print(opt) end,
})
```

## Themes

```lua
GlassLib:SetTheme("Dark")     -- default
GlassLib:SetTheme("Midnight") -- cyan
GlassLib:SetTheme("Aurora")   -- purple
GlassLib:SetTheme("Frost")    -- green
GlassLib:SetTheme("Amber")    -- orange
GlassLib:SetTheme("Rose")     -- red
```

## Floating Toggle Button

```lua
GlassLib:CreateToggleBtn({Text = "Toggle UI"})
```

## Save/Load Config

Add `Flag` to any element to save it:

```lua
Section:CreateToggle({
    Title = "Auto Farm",
    Flag = "AutoFarm",  -- this gets saved
    Callback = function(s) end,
})

-- Save
GlassLib:SaveConfig("myConfig")

-- Load
GlassLib:LoadConfig("myConfig")
```

## Notifications

```lua
GlassLib:Notify({
    Title = "Hello",
    Content = "This is a notification",
    Duration = 3,
})
```

## All Elements

```lua
Section:CreateButton({Title, Desc, Color, Callback})
Section:CreateToggle({Title, Desc, Default, Flag, Callback})
Section:CreateSlider({Title, Min, Max, Default, Flag, Callback})
Section:CreateDropdown({Title, Options, Default, Flag, Callback})
Section:CreateTextInput({Title, Placeholder, Default, Flag, Callback})
Section:CreateKeybind({Title, Default, Callback})
Section:CreateColorPicker({Title, Default, Flag, Callback})
Section:CreateLabel({Title, Desc})
Section:CreateParagraph({Title, Body})
Section:CreateDivider()
```

## Window Controls

```lua
Window:Toggle()   -- show/hide
Window:Open()     -- show
Window:Close()    -- hide
Window:Destroy()  -- remove entirely
```
