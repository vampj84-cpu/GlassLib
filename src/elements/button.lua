--[[
    GlassLib - Button Element
]]

local Util = require(script.Parent.Parent.util)

local Button = {}
Button.__index = Button

function Button.new(config)
	local self = setmetatable({}, Button)
	self._config = config or {}
	self._frame = nil
	self._btn = nil
	return self
end

function Button:Create(parent, theme, order)
	local cfg = self._config
	local title = cfg.Title or "Button"
	local desc = cfg.Desc or ""
	local callback = cfg.Callback or function() end
	local color = cfg.Color
	local hasDesc = desc ~= ""

	local row = Util.Create("Frame", {
		Size = UDim2.new(1, 0, 0, hasDesc and 52 or 42),
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
		Size = UDim2.new(1, -90, 0, 16),
		Position = UDim2.new(0, 0, hasDesc and 0.2 or 0.5, 0),
		AnchorPoint = Vector2.new(0, hasDesc and 0 or 0.5),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamMedium,
		Text = title,
		TextColor3 = theme.Text,
		TextSize = 12.5,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = row,
	})

	if hasDesc then
		Util.Create("TextLabel", {
			Size = UDim2.new(1, -90, 0, 12),
			Position = UDim2.new(0, 0, 0.65, 0),
			BackgroundTransparency = 1,
			Font = Enum.Font.Gotham,
			Text = desc,
			TextColor3 = theme.TextMuted,
			TextSize = 10.5,
			TextXAlignment = Enum.TextXAlignment.Left,
			Parent = row,
		})
	end

	local btn = Util.Create("TextButton", {
		Size = UDim2.new(0, 70, 0, 30),
		Position = UDim2.new(1, 0, 0.5, 0),
		AnchorPoint = Vector2.new(1, 0.5),
		BackgroundColor3 = color or theme.Accent,
		BackgroundTransparency = color and 0.1 or 0,
		BorderSizePixel = 0,
		AutoButtonColor = false,
		Font = Enum.Font.GothamMedium,
		Text = title,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextSize = 12,
		Parent = row,
	})
	Util.Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = btn})

	if not color then
		Util.MakeAccentGradient(btn, theme)
	end

	-- Interactions
	row.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			Util.RippleEffect(row,
				input.Position.X - row.AbsolutePosition.X,
				input.Position.Y - row.AbsolutePosition.Y
			)
		end
	end)

	Util.AddButtonHover(row, 0.6, 0.45,
		UDim2.new(1, 0, 0, hasDesc and 54 or 44),
		UDim2.new(1, 0, 0, hasDesc and 52 or 42)
	)

	btn.MouseButton1Click:Connect(function()
		Util.SpringTween(btn, {Size = UDim2.new(0, 65, 0, 28)}, 0.15)
		task.delay(0.15, function()
			Util.SpringTween(btn, {Size = UDim2.new(0, 70, 0, 30)}, 0.2)
		end)
		callback()
	end)

	self._frame = row
	self._btn = btn
	return row
end

return Button
