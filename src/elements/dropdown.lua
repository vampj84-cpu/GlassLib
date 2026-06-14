--[[
    GlassLib - Dropdown Element
    Glass dropdown with floating menu
]]

local Util = require(script.Parent.Parent.util)

local Dropdown = {}
Dropdown.__index = Dropdown

function Dropdown.new(config)
	local self = setmetatable({}, Dropdown)
	self._config = config or {}
	self._selected = nil
	self._frame = nil
	return self
end

function Dropdown:Create(parent, theme, order)
	local cfg = self._config
	local title = cfg.Title or "Dropdown"
	local options = cfg.Options or {}
	local default = cfg.Default or options[1]
	local callback = cfg.Callback or function() end
	self._selected = default
	local isOpen = false
	local tv = theme:Get()

	local row = Util.Create("Frame", {
		Size = UDim2.new(1, 0, 0, 74),
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

	-- Trigger
	local trigger = Util.Create("TextButton", {
		Size = UDim2.new(1, 0, 0, 34),
		Position = UDim2.new(0, 0, 1, -10),
		AnchorPoint = Vector2.new(0, 1),
		BackgroundColor3 = tv.GlassTint,
		BackgroundTransparency = 0.2,
		BorderSizePixel = 0,
		AutoButtonColor = false,
		Font = Enum.Font.Gotham,
		Text = "",
		Parent = row,
	})
	Util.Create("UICorner", {CornerRadius = UDim.new(0, 10), Parent = trigger})
	Util.Create("UIStroke", {
		Color = tv.GlassStroke,
		Transparency = 0.35,
		Thickness = 1,
		Parent = trigger,
	})

	local selectedLabel = Util.Create("TextLabel", {
		Size = UDim2.new(1, -32, 1, 0),
		Position = UDim2.new(0, 12, 0, 0),
		BackgroundTransparency = 1,
		Font = Enum.Font.Gotham,
		Text = default or "",
		TextColor3 = tv.TextSecondary,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = trigger,
	})

	local arrow = Util.Create("TextLabel", {
		Size = UDim2.new(0, 20, 1, 0),
		Position = UDim2.new(1, -6, 0, 0),
		AnchorPoint = Vector2.new(1, 0),
		BackgroundTransparency = 1,
		Font = Enum.Font.Gotham,
		Text = "▾",
		TextColor3 = tv.TextMuted,
		TextSize = 13,
		Parent = trigger,
	})

	-- Menu
	local menuHeight = math.min(#options * 32 + 8, 160)
	local menu = Util.Create("Frame", {
		Size = UDim2.new(1, 0, 0, menuHeight),
		Position = UDim2.new(0, 0, 1, 4),
		BackgroundColor3 = tv.GlassTint,
		BackgroundTransparency = 0.15,
		BorderSizePixel = 0,
		Visible = false,
		ZIndex = 50,
		Parent = row,
	})
	Util.Create("UICorner", {CornerRadius = UDim.new(0, 12), Parent = menu})
	Util.Create("UIStroke", {
		Color = tv.GlassStroke,
		Transparency = 0.3,
		Thickness = 1,
		ZIndex = 50,
		Parent = menu,
	})
	Util.Create("UIPadding", {
		PaddingTop = UDim.new(0, 4),
		PaddingBottom = UDim.new(0, 4),
		PaddingLeft = UDim.new(0, 4),
		PaddingRight = UDim.new(0, 4),
		Parent = menu,
	})
	Util.Create("UIListLayout", {
		FillDirection = Enum.FillDirection.Vertical,
		Padding = UDim.new(0, 2),
		Parent = menu,
	})

	for _, option in ipairs(options) do
		local optBtn = Util.Create("TextButton", {
			Size = UDim2.new(1, 0, 0, 30),
			BackgroundColor3 = tv.GlassTint,
			BackgroundTransparency = option == default and 0.15 or 0.6,
			BorderSizePixel = 0,
			AutoButtonColor = false,
			Font = Enum.Font.Gotham,
			Text = option,
			TextColor3 = option == default and tv.AccentLight or tv.TextSecondary,
			TextSize = 12,
			ZIndex = 51,
			Parent = menu,
		})
		Util.Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = optBtn})

		optBtn.MouseEnter:Connect(function()
			if option ~= self._selected then
				Util.Tween(optBtn, {BackgroundTransparency = 0.25}, 0.1)
			end
		end)
		optBtn.MouseLeave:Connect(function()
			if option ~= self._selected then
				Util.Tween(optBtn, {BackgroundTransparency = 0.6}, 0.1)
			end
		end)

		optBtn.MouseButton1Click:Connect(function()
			self._selected = option
			selectedLabel.Text = option
			isOpen = false
			menu.Visible = false
			Util.Tween(arrow, {Rotation = 0}, 0.2)
			for _, child in ipairs(menu:GetChildren()) do
				if child:IsA("TextButton") then
					child.BackgroundTransparency = child.Text == self._selected and 0.15 or 0.6
					child.TextColor3 = child.Text == self._selected and tv.AccentLight or tv.TextSecondary
				end
			end
			callback(self._selected)
		end)
	end

	trigger.MouseButton1Click:Connect(function()
		isOpen = not isOpen
		menu.Visible = isOpen
		Util.Tween(arrow, {Rotation = isOpen and 180 or 0}, 0.25)
		if isOpen then
			Util.SpringTween(row, {Size = UDim2.new(1, 0, 0, 74 + menuHeight + 8)}, 0.3)
		else
			Util.SpringTween(row, {Size = UDim2.new(1, 0, 0, 74)}, 0.25)
		end
	end)

	Util.AddHover(row, 0.35, 0.2)

	self._frame = row
	self._menu = menu
	self._selectedLabel = selectedLabel
	self._callback = callback
	return row
end

function Dropdown:Get() return self._selected end

function Dropdown:Set(option)
	self._selected = option
	if self._selectedLabel then self._selectedLabel.Text = option end
	if self._callback then self._callback(self._selected) end
end

return Dropdown
