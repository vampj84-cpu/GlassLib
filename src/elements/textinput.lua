--[[
    GlassLib - TextInput Element
    Glass input with focus glow
]]

local Util = require(script.Parent.Parent.util)

local TextInput = {}
TextInput.__index = TextInput

function TextInput.new(config)
	local self = setmetatable({}, TextInput)
	self._config = config or {}
	self._frame = nil
	self._input = nil
	return self
end

function TextInput:Create(parent, theme, order)
	local cfg = self._config
	local title = cfg.Title or "Input"
	local placeholder = cfg.Placeholder or ""
	local default = cfg.Default or ""
	local callback = cfg.Callback or function() end
	local tv = theme:Get()

	local row = Util.Create("Frame", {
		Size = UDim2.new(1, 0, 0, 70),
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
		PaddingTop = UDim.new(0, 10),
		Parent = row,
	})

	Util.Create("TextLabel", {
		Size = UDim2.new(1, 0, 0, 16),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamMedium,
		Text = title,
		TextColor3 = tv.Text,
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = row,
	})

	local input = Util.Create("TextBox", {
		Size = UDim2.new(1, 0, 0, 34),
		Position = UDim2.new(0, 0, 1, -10),
		AnchorPoint = Vector2.new(0, 1),
		BackgroundColor3 = tv.GlassTint,
		BackgroundTransparency = 0.2,
		BorderSizePixel = 0,
		Font = Enum.Font.Gotham,
		PlaceholderText = placeholder,
		PlaceholderColor3 = tv.TextMuted,
		Text = default,
		TextColor3 = tv.Text,
		TextSize = 12,
		ClearTextOnFocus = false,
		Parent = row,
	})
	Util.Create("UICorner", {CornerRadius = UDim.new(0, 10), Parent = input})
	local inputStroke = Util.Create("UIStroke", {
		Color = tv.GlassStroke,
		Transparency = 0.35,
		Thickness = 1,
		Parent = input,
	})
	Util.Create("UIPadding", {
		PaddingLeft = UDim.new(0, 12),
		PaddingRight = UDim.new(0, 12),
		Parent = input,
	})

	input.Focused:Connect(function()
		Util.Tween(input, {BackgroundTransparency = 0.05}, 0.2)
		Util.Tween(inputStroke, {Color = tv.Accent, Transparency = 0.2}, 0.2)
	end)

	input.FocusLost:Connect(function()
		Util.Tween(input, {BackgroundTransparency = 0.2}, 0.2)
		Util.Tween(inputStroke, {Color = tv.GlassStroke, Transparency = 0.35}, 0.2)
		callback(input.Text)
	end)

	self._frame = row
	self._input = input
	return input
end

function TextInput:Get() return self._input and self._input.Text or "" end
function TextInput:Set(value) if self._input then self._input.Text = value end end

return TextInput
