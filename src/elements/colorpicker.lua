--[[
    GlassLib - ColorPicker Element
    Glass swatch with popup picker
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
	local default = cfg.Default or Color3.fromHex("#7c6bf0")
	local callback = cfg.Callback or function() end
	self._color = default
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
		Size = UDim2.new(1, -54, 1, 0),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamMedium,
		Text = title,
		TextColor3 = tv.Text,
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = row,
	})

	local swatch = Util.Create("TextButton", {
		Size = UDim2.new(0, 30, 0, 30),
		Position = UDim2.new(1, 0, 0.5, 0),
		AnchorPoint = Vector2.new(1, 0.5),
		BackgroundColor3 = default,
		BorderSizePixel = 0,
		AutoButtonColor = false,
		Text = "",
		Parent = row,
	})
	Util.Create("UICorner", {CornerRadius = UDim.new(0, 10), Parent = swatch})
	Util.Create("UIStroke", {
		Color = tv.GlassStroke,
		Transparency = 0.3,
		Thickness = 2,
		Parent = swatch,
	})

	-- Color picker popup
	local pickerOpen = false
	local pickerFrame = Util.Create("Frame", {
		Size = UDim2.new(0, 210, 0, 170),
		Position = UDim2.new(1, -12, 0.5, 0),
		AnchorPoint = Vector2.new(1, 0.5),
		BackgroundColor3 = tv.GlassTint,
		BackgroundTransparency = 0.1,
		BorderSizePixel = 0,
		Visible = false,
		ZIndex = 60,
		Parent = row,
	})
	Util.Create("UICorner", {CornerRadius = UDim.new(0, 14), Parent = pickerFrame})
	Util.Create("UIStroke", {
		Color = tv.GlassStroke,
		Transparency = 0.25,
		Thickness = 1,
		ZIndex = 60,
		Parent = pickerFrame,
	})

	local colorSquare = Util.Create("Frame", {
		Size = UDim2.new(1, -22, 0, 105),
		Position = UDim2.new(0, 11, 0, 11),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BorderSizePixel = 0,
		ZIndex = 61,
		Parent = pickerFrame,
	})
	Util.Create("UICorner", {CornerRadius = UDim.new(0, 10), Parent = colorSquare})
	Util.Create("UIGradient", {
		Color = ColorSequence.new(Color3.fromRGB(255, 255, 255)),
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0),
			NumberSequenceKeypoint.new(1, 0),
		}),
		Parent = colorSquare,
	})

	local hueBar = Util.Create("Frame", {
		Size = UDim2.new(1, -22, 0, 14),
		Position = UDim2.new(0, 11, 1, -32),
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

	Util.AddHover(row, 0.35, 0.2)

	self._frame = row
	self._swatch = swatch
	self._callback = callback
	return row
end

function ColorPicker:Get() return self._color end

function ColorPicker:Set(c)
	self._color = c
	if self._swatch then self._swatch.BackgroundColor3 = c end
	if self._callback then self._callback(c) end
end

return ColorPicker
