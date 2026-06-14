--[[
    GlassLib - ColorPicker Element
]]

local Util = require(script.Parent.Parent.util)

local ColorPicker = {}
ColorPicker.__index = ColorPicker

function ColorPicker.new(config)
	local self = setmetatable({}, ColorPicker)
	self._config = config or {}
	self._color = nil
	self._frame = nil
	return self
end

function ColorPicker:Create(parent, theme, order)
	local cfg = self._config
	local title = cfg.Title or "Color"
	local default = cfg.Default or Color3.fromRGB(99, 102, 241)
	local callback = cfg.Callback or function() end
	self._color = default

	local row = Util.Create("Frame", {
		Size = UDim2.new(1, 0, 0, 42),
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
		Parent = row,
	})

	Util.Create("TextLabel", {
		Size = UDim2.new(1, -50, 1, 0),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamMedium,
		Text = title,
		TextColor3 = theme.Text,
		TextSize = 12.5,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = row,
	})

	local swatch = Util.Create("TextButton", {
		Size = UDim2.new(0, 28, 0, 28),
		Position = UDim2.new(1, 0, 0.5, 0),
		AnchorPoint = Vector2.new(1, 0.5),
		BackgroundColor3 = default,
		BorderSizePixel = 0,
		AutoButtonColor = false,
		Text = "",
		Parent = row,
	})
	Util.Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = swatch})
	Util.Create("UIStroke", {
		Color = Color3.fromRGB(255, 255, 255),
		Transparency = 0.7,
		Thickness = 2,
		Parent = swatch,
	})

	-- Color picker popup
	local pickerOpen = false
	local pickerFrame = Util.Create("Frame", {
		Size = UDim2.new(0, 200, 0, 160),
		Position = UDim2.new(1, -10, 0.5, 0),
		AnchorPoint = Vector2.new(1, 0.5),
		BackgroundColor3 = theme.Surface,
		BackgroundTransparency = 0.05,
		BorderSizePixel = 0,
		Visible = false,
		ZIndex = 60,
		Parent = row,
	})
	Util.Create("UICorner", {CornerRadius = UDim.new(0, 12), Parent = pickerFrame})
	Util.Create("UIStroke", {
		Color = Color3.fromRGB(255, 255, 255),
		Transparency = 0.88,
		Thickness = 1,
		ZIndex = 60,
		Parent = pickerFrame,
	})

	-- Color gradient square
	local colorSquare = Util.Create("Frame", {
		Size = UDim2.new(1, -20, 0, 100),
		Position = UDim2.new(0, 10, 0, 10),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BorderSizePixel = 0,
		ZIndex = 61,
		Parent = pickerFrame,
	})
	Util.Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = colorSquare})
	Util.Create("UIGradient", {
		Color = ColorSequence.new(Color3.fromRGB(255, 255, 255)),
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0),
			NumberSequenceKeypoint.new(1, 0),
		}),
		Parent = colorSquare,
	})

	-- Hue slider
	local hueBar = Util.Create("Frame", {
		Size = UDim2.new(1, -20, 0, 12),
		Position = UDim2.new(0, 10, 1, -30),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BorderSizePixel = 0,
		ZIndex = 61,
		Parent = pickerFrame,
	})
	Util.Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = hueBar})
	Util.Create("UIGradient", {
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
			ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
			ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
			ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
			ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0)),
		}),
		Parent = hueBar,
	})

	swatch.MouseButton1Click:Connect(function()
		pickerOpen = not pickerOpen
		pickerFrame.Visible = pickerOpen
	end)

	Util.AddHover(row, 0.6, 0.45)

	self._frame = row
	self._swatch = swatch
	self._callback = callback
	return row
end

function ColorPicker:Get()
	return self._color
end

function ColorPicker:Set(c)
	self._color = c
	if self._swatch then
		self._swatch.BackgroundColor3 = c
	end
	if self._callback then
		self._callback(c)
	end
end

return ColorPicker
