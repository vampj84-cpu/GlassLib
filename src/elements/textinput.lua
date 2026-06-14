--[[
    GlassLib - TextInput Element
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

	local row = Util.Create("Frame", {
		Size = UDim2.new(1, 0, 0, 66),
		BackgroundColor3 = theme.Surface,
		BackgroundTransparency = 0.6,
		BorderSizePixel = 0,
		LayoutOrder = order or 0,
		Parent = parent,
	})
	Util.Create("UICorner", {CornerRadius = UDim.new(0, 10), Parent = row})
	Util.Create("UIStroke", {
		Color = Color3.fromRGB(255, 255, 255),
		Transparency = 0.92,
		Thickness = 1,
		Parent = row,
	})
	Util.Create("UIPadding", {
		PaddingLeft = UDim.new(0, 12),
		PaddingRight = UDim.new(0, 12),
		PaddingTop = UDim.new(0, 8),
		Parent = row,
	})

	Util.Create("TextLabel", {
		Size = UDim2.new(1, 0, 0, 16),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamMedium,
		Text = title,
		TextColor3 = theme.Text,
		TextSize = 12.5,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = row,
	})

	local input = Util.Create("TextBox", {
		Size = UDim2.new(1, 0, 0, 32),
		Position = UDim2.new(0, 0, 1, -8),
		AnchorPoint = Vector2.new(0, 1),
		BackgroundColor3 = theme.SurfaceLight,
		BackgroundTransparency = 0.3,
		BorderSizePixel = 0,
		Font = Enum.Font.Gotham,
		PlaceholderText = placeholder,
		PlaceholderColor3 = theme.TextMuted,
		Text = default,
		TextColor3 = theme.Text,
		TextSize = 12,
		ClearTextOnFocus = false,
		Parent = row,
	})
	Util.Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = input})
	local inputStroke = Util.Create("UIStroke", {
		Color = Color3.fromRGB(255, 255, 255),
		Transparency = 0.9,
		Thickness = 1,
		Parent = input,
	})
	Util.Create("UIPadding", {
		PaddingLeft = UDim.new(0, 10),
		PaddingRight = UDim.new(0, 10),
		Parent = input,
	})

	input.Focused:Connect(function()
		Util.Tween(input, {BackgroundTransparency = 0.15}, 0.2)
		inputStroke.Color = theme.Accent
		inputStroke.Transparency = 0.5
	end)

	input.FocusLost:Connect(function()
		Util.Tween(input, {BackgroundTransparency = 0.3}, 0.2)
		inputStroke.Color = Color3.fromRGB(255, 255, 255)
		inputStroke.Transparency = 0.9
		callback(input.Text)
	end)

	self._frame = row
	self._input = input
	return input
end

function TextInput:Get()
	return self._input and self._input.Text or ""
end

function TextInput:Set(value)
	if self._input then
		self._input.Text = value
	end
end

return TextInput
