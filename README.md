# GlassLib

Liquid glass UI library for Roblox exploits. Modular, themed, and animated.

## Features

- **Liquid glass aesthetic** — translucent panels, subtle highlights, accent gradients
- **iOS spring-bounce animations** on all interactive elements
- **6 built-in themes** — Dark, Midnight, Aurora, Frost, Amber, Rose
- **Full element suite** — Button, Toggle, Slider, Dropdown, TextInput, Keybind, ColorPicker, Label, Paragraph, Divider
- **Config system** — flag-based save/load with autoload support
- **Floating toggle button** — horizontal pill with pulse ring
- **Notification toasts** — animated progress bar, icon pop
- **Modal dialogs** — confirm/cancel prompts
- **Modular architecture** — 23 separate modules, easy to extend

## Installation

### Loadstring (recommended)

```lua
local GlassLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/vampj84-cpu/GlassLib/main/GlassLib_Compiled.lua"))()
```

### Module-based

Clone the repo and use a module loader or [Rojo](https://rojo.space/):

```lua
local GlassLib = require(path.to.GlassLib)
```

## Quick Start

```lua
local GlassLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/vampj84-cpu/GlassLib/main/GlassLib_Compiled.lua"))()

-- Set theme
GlassLib:SetTheme("Dark")

-- Create window
local Window = GlassLib:CreateWindow({
    Title = "My Hub",
    Author = "by Me",
    Icon = "rbxassetid://6023426926",
    Size = UDim2.new(0, 440, 0, 540),
})

-- Floating toggle button
GlassLib:CreateToggleBtn({Text = "Toggle UI"})

-- Create tab and section
local Tab = Window:CreateTab({Name = "Main", Icon = "rbxassetid://6023426926"})
local Section = Tab:CreateSection({Name = "Combat"})

-- Add elements
Section:CreateToggle({
    Title = "Auto Farm",
    Desc = "Collects resources automatically",
    Default = false,
    Flag = "AutoFarm",        -- saved in config
    Callback = function(state)
        print("Auto Farm:", state)
    end,
})

Section:CreateSlider({
    Title = "Speed",
    Min = 16,
    Max = 500,
    Default = 100,
    Callback = function(value)
        print("Speed:", value)
    end,
})

Section:CreateButton({
    Title = "Click Me",
    Callback = function()
        GlassLib:Notify({Title = "Clicked!", Content = "Button pressed", Duration = 2})
    end,
})
```

## API Reference

### GlassLib

| Method | Description |
|--------|-------------|
| `GlassLib:CreateWindow(config)` | Create a new window |
| `GlassLib:Notify(config)` | Show a toast notification |
| `GlassLib:SetTheme(name)` | Switch theme |
| `GlassLib:GetTheme()` | Get current theme table |
| `GlassLib:GetThemeName()` | Get current theme name |
| `GlassLib:GetThemes()` | List all theme names |
| `GlassLib:CreateToggleBtn(config)` | Create floating toggle button |
| `GlassLib:SaveConfig(name)` | Save all flagged elements to file |
| `GlassLib:LoadConfig(name)` | Load config from file |
| `GlassLib:GetFlag(flag)` | Get a flag's value |
| `GlassLib:SetFlag(flag, value)` | Set a flag's value |
| `GlassLib:Dialog(config)` | Show a modal dialog |
| `GlassLib:OnThemeChanged(callback)` | Listen for theme changes |

### Window

| Method | Description |
|--------|-------------|
| `Window:CreateTab(config)` | Add a tab |
| `Window:Toggle()` | Toggle visibility |
| `Window:Open()` | Show window |
| `Window:Close()` | Hide window |
| `Window:Destroy()` | Remove window entirely |

### Tab

| Method | Description |
|--------|-------------|
| `Tab:CreateSection(config)` | Add a section |

### Section

| Method | Description |
|--------|-------------|
| `Section:CreateButton(config)` | Add a button |
| `Section:CreateToggle(config)` | Add a toggle |
| `Section:CreateSlider(config)` | Add a slider |
| `Section:CreateDropdown(config)` | Add a dropdown |
| `Section:CreateTextInput(config)` | Add a text input |
| `Section:CreateKeybind(config)` | Add a keybind |
| `Section:CreateColorPicker(config)` | Add a color picker |
| `Section:CreateLabel(config)` | Add a label |
| `Section:CreateParagraph(config)` | Add a paragraph |
| `Section:CreateDivider()` | Add a divider |

## Themes

| Name | Accent |
|------|--------|
| Dark | Indigo `#6366f1` |
| Midnight | Cyan `#06b6d4` |
| Aurora | Purple `#a855f7` |
| Frost | Emerald `#10b981` |
| Amber | Amber `#f59e0b` |
| Rose | Rose `#f43f5e` |

## Building

To compile all modules into a single `GlassLib_Compiled.lua`:

```bash
cd GlassLib
luau build.lua
# or
lua build.lua
```

This reads all `src/` modules and produces a single loadstring-compatible file.

## File Structure

```
GlassLib/
├── init.lua              Entry point
├── build.lua             Compiles to single file
└── src/
    ├── util.lua          Services, helpers, tweens
    ├── theme.lua         Theme system
    ├── acrylic.lua       Blur/shadow effects
    ├── config.lua        Flag-based save/load
    ├── notify.lua        Toast notifications
    ├── dialog.lua        Modal dialogs
    ├── toggle.lua        Floating toggle button
    ├── section.lua       Section containers
    ├── tab.lua           Tab system
    ├── window.lua        Window frame
    └── elements/         UI element modules
        ├── button.lua
        ├── toggle.lua
        ├── slider.lua
        ├── dropdown.lua
        ├── textinput.lua
        ├── keybind.lua
        ├── colorpicker.lua
        ├── label.lua
        ├── paragraph.lua
        └── divider.lua
```

## License

MIT
