--[[
    GlassLib - Slider Element
]]

local Util = require(script.Parent.Parent.util)

local Slider = {}
Slider.__index = Slider

function Slider.new(config)
	local self = setmetatable({}, Slider)
	self._config = config or {}
	self._value = 0
	self._frame = nil
	return self
end

function Slider:Create(parent, theme, order)
	local cfg = self._config
	local title = cfg.Title or "Slider"
	local min = cfg.Min or 0
	local max = cfg.Max or 100
	local default = cfg.Default or min
	local callback = cfg.Callback or function() end
	self._value = default
	local pct = (default - min) / (max - min)

	local row = Util.Create("Frame", {
		Size = UDim2.new(1, 0, 0, 56),
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
		PaddingTop = UDim.new(0, 10),
		Parent = row,
	})

	-- Header
	Util.Create("TextLabel", {
		Size = UDim2.new(1, -50, 0, 16),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamMedium,
		Text = title,
		TextColor3 = theme.Text,
		TextSize = 12.5,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = row,
	})

	local valueLabel = Util.Create("TextLabel", {
		Size = UDim2.new(0, 40, 0, 16),
		Position = UDim2.new(1, 0, 0, 0),
		AnchorPoint = Vector2.new(1, 0),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamBold,
		Text = tostring(math.round(default)),
		TextColor3 = theme.AccentLight,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Right,
		Parent = row,
	})

	-- Track
	local trackBg = Util.Create("Frame", {
		Size = UDim2.new(1, 0, 0, 5),
		Position = UDim2.new(0, 0, 1, -12),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 0.92,
		BorderSizePixel = 0,
		Parent = row,
	})
	Util.Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = trackBg})

	local trackFill = Util.Create("Frame", {
		Size = UDim2.new(pct, 0, 1, 0),
		BackgroundColor3 = theme.Accent,
		BorderSizePixel = 0,
		Parent = trackBg,
	})
	Util.Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = trackFill})
	Util.MakeAccentGradient(trackFill, theme)

	local knob = Util.Create("Frame", {
		Size = UDim2.new(0, 16, 0, 16),
		Position = UDim2.new(pct, 0, 0.5, 0),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BorderSizePixel = 0,
		Parent = trackBg,
	})
	Util.Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = knob})

	local dragging = false

	local function updateSlider(inputX)
		local relX = (inputX - trackBg.AbsolutePosition.X) / trackBg.AbsoluteSize.X
		relX = math.clamp(relX, 0, 1)
		pct = relX
		self._value = min + (max - min) * pct

		trackFill.Size = UDim2.new(pct, 0, 1, 0)
		knob.Position = UDim2.new(pct, 0, 0.5, 0)
		valueLabel.Text = tostring(math.round(self._value))

		callback(math.round(self._value))
	end

	trackBg.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			updateSlider(input.Position.X)
		end
	end)

	knob.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
		end
	end)

	Util.UIS.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end)

	Util.UIS.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			updateSlider(input.Position.X)
		end
	end)

	knob.MouseEnter:Connect(function()
		Util.SpringTween(knob, {Size = UDim2.new(0, 20, 0, 20)}, 0.2)
	end)
	knob.MouseLeave:Connect(function()
		Util.SpringTween(knob, {Size = UDim2.new(0, 16, 0, 16)}, 0.2)
	end)

	Util.AddHover(row, 0.6, 0.45)

	self._frame = row
	self._trackBg = trackBg
	self._trackFill = trackFill
	self._knob = knob
	self._valueLabel = valueLabel
	self._min = min
	self._max = max
	return row
end

function Slider:Get()
	return self._value
end

function Slider:Set(val)
	self._value = math.clamp(val, self._min, self._max)
	local pct = (self._value - self._min) / (self._max - self._min)
	self._trackFill.Size = UDim2.new(pct, 0, 1, 0)
	self._knob.Position = UDim2.new(pct, 0, 0.5, 0)
	self._valueLabel.Text = tostring(math.round(self._value))
end

return Slider
