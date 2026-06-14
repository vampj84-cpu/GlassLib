--[[
    GlassLib - Keybind Element
    Glass keybind pill
]]

local Util = require(script.Parent.Parent.util)

local Keybind = {}
Keybind.__index = Keybind

function Keybind.new(config)
	local self = setmetatable({}, Keybind)
	self._config = config or {}
	self._bound = nil
	self._frame = nil
	return self
end

function Keybind:Create(parent, theme, order)
	local cfg = self._config
	local title = cfg.Title or "Keybind"
	local default = cfg.Default or Enum.KeyCode.Unknown
	local callback = cfg.Callback or function() end
	self._bound = default
	local listening = false
	local tv = theme:Get()

	local row = Util.Create("Frame", {
		Size = UDim2.new(1, 0, 0, 46),
		BackgroundColor3 = tv.GlassTint,
		BackgroundTransparency = 0.35,
		BorderSizePixel = 0,
		LayoutOrder = order or 0,
		Parent = parent,
	})
	Util.Create("UICorner", {CornerRadius = UDim.new(0, 14), Parent = row})
	Util.Create("UIStroke", {
		Color = tv.GlassStroke,
		Transparency = 0.45,
		Thickness = 1,
		Parent = row,
	})
	Util.Create("UIPadding", {
		PaddingLeft = UDim.new(0, 14),
		PaddingRight = UDim.new(0, 14),
		Parent = row,
	})

	Util.Create("TextLabel", {
		Size = UDim2.new(1, -84, 1, 0),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamMedium,
		Text = title,
		TextColor3 = tv.Text,
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = row,
	})

	local bindBtn = Util.Create("TextButton", {
		Size = UDim2.new(0, 72, 0, 30),
		Position = UDim2.new(1, 0, 0.5, 0),
		AnchorPoint = Vector2.new(1, 0.5),
		BackgroundColor3 = default ~= Enum.KeyCode.Unknown and tv.Accent or tv.GlassTint,
		BackgroundTransparency = default ~= Enum.KeyCode.Unknown and 0.3 or 0.2,
		BorderSizePixel = 0,
		AutoButtonColor = false,
		Font = Enum.Font.GothamMedium,
		Text = default ~= Enum.KeyCode.Unknown and default.Name or "Bind",
		TextColor3 = default ~= Enum.KeyCode.Unknown and tv.AccentLight or tv.TextMuted,
		TextSize = 11,
		Parent = row,
	})
	Util.Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = bindBtn})
	Util.Create("UIStroke", {
		Color = default ~= Enum.KeyCode.Unknown and tv.Accent or tv.GlassStroke,
		Transparency = 0.35,
		Thickness = 1,
		Parent = bindBtn,
	})

	bindBtn.MouseButton1Click:Connect(function()
		listening = true
		bindBtn.Text = "..."
		Util.Tween(bindBtn, {BackgroundColor3 = tv.Accent, BackgroundTransparency = 0.2}, 0.15)
	end)

	Util.UIS.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then return end
		if listening and input.UserInputType == Enum.UserInputType.Keyboard then
			self._bound = input.KeyCode
			listening = false
			bindBtn.Text = self._bound.Name
			Util.Tween(bindBtn, {BackgroundTransparency = 0.3}, 0.15)
			callback(self._bound)
		end
	end)

	Util.AddHover(row, 0.35, 0.2)

	self._frame = row
	return row
end

function Keybind:Get() return self._bound end
function Keybind:Set(keycode) self._bound = keycode end

return Keybind
