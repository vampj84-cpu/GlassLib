--[[
    GlassLib - Button Element
    Glass card with liquid press effect
]]

local Util = require(script.Parent.Parent.util)

local Button = {}
Button.__index = Button

function Button.new(config)
	local self = setmetatable({}, Button)
	self._config = config or {}
	self._frame = nil
	return self
end

function Button:Create(parent, theme, order)
	local cfg = self._config
	local title = cfg.Title or "Button"
	local desc = cfg.Desc or ""
	local callback = cfg.Callback or function() end
	local color = cfg.Color
	local hasDesc = desc ~= ""
	local tv = theme:Get()

	local row = Util.Create("Frame", {
		Size = UDim2.new(1, 0, 0, hasDesc and 56 or 46),
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
		Size = UDim2.new(1, -90, 0, 16),
		Position = UDim2.new(0, 0, hasDesc and 0.22 or 0.5, 0),
		AnchorPoint = Vector2.new(0, hasDesc and 0 or 0.5),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamMedium,
		Text = title,
		TextColor3 = tv.Text,
		TextSize = 13,
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
			TextColor3 = tv.TextMuted,
			TextSize = 11,
			TextXAlignment = Enum.TextXAlignment.Left,
			Parent = row,
		})
	end

	local btn = Util.Create("TextButton", {
		Size = UDim2.new(0, 72, 0, 32),
		Position = UDim2.new(1, 0, 0.5, 0),
		AnchorPoint = Vector2.new(1, 0.5),
		BackgroundColor3 = color or tv.Accent,
		BackgroundTransparency = color and 0.15 or 0,
		BorderSizePixel = 0,
		AutoButtonColor = false,
		Font = Enum.Font.GothamMedium,
		Text = title,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextSize = 12,
		Parent = row,
	})
	Util.Create("UICorner", {CornerRadius = UDim.new(0, 10), Parent = btn})

	if not color then
		Util.MakeAccentGradient(btn, theme:Get())
	end

	row.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			Util.RippleEffect(row,
				input.Position.X - row.AbsolutePosition.X,
				input.Position.Y - row.AbsolutePosition.Y
			)
		end
	end)

	Util.AddButtonHover(row, 0.35, 0.2,
		UDim2.new(1, 0, 0, hasDesc and 58 or 48),
		UDim2.new(1, 0, 0, hasDesc and 56 or 46)
	)

	btn.MouseButton1Click:Connect(function()
		Util.SpringTween(btn, {Size = UDim2.new(0, 66, 0, 30)}, 0.12)
		task.delay(0.12, function()
			Util.SpringTween(btn, {Size = UDim2.new(0, 72, 0, 32)}, 0.18)
		end)
		callback()
	end)

	self._frame = row
	return row
end

return Button
