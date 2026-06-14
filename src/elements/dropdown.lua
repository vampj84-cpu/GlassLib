--[[
    GlassLib - Dropdown Element
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

	local row = Util.Create("Frame", {
		Size = UDim2.new(1, 0, 0, 70),
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

	-- Trigger
	local trigger = Util.Create("TextButton", {
		Size = UDim2.new(1, 0, 0, 32),
		Position = UDim2.new(0, 0, 1, -8),
		AnchorPoint = Vector2.new(0, 1),
		BackgroundColor3 = theme.SurfaceLight,
		BackgroundTransparency = 0.3,
		BorderSizePixel = 0,
		AutoButtonColor = false,
		Font = Enum.Font.Gotham,
		Text = "",
		Parent = row,
	})
	Util.Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = trigger})
	Util.Create("UIStroke", {
		Color = Color3.fromRGB(255, 255, 255),
		Transparency = 0.9,
		Thickness = 1,
		Parent = trigger,
	})

	local selectedLabel = Util.Create("TextLabel", {
		Size = UDim2.new(1, -30, 1, 0),
		Position = UDim2.new(0, 10, 0, 0),
		BackgroundTransparency = 1,
		Font = Enum.Font.Gotham,
		Text = default or "",
		TextColor3 = theme.TextSecondary,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = trigger,
	})

	local arrow = Util.Create("TextLabel", {
		Size = UDim2.new(0, 20, 1, 0),
		Position = UDim2.new(1, -5, 0, 0),
		AnchorPoint = Vector2.new(1, 0),
		BackgroundTransparency = 1,
		Font = Enum.Font.Gotham,
		Text = "▾",
		TextColor3 = theme.TextMuted,
		TextSize = 12,
		Parent = trigger,
	})

	-- Menu
	local menuHeight = math.min(#options * 30 + 8, 150)
	local menu = Util.Create("Frame", {
		Size = UDim2.new(1, 0, 0, menuHeight),
		Position = UDim2.new(0, 0, 1, 4),
		BackgroundColor3 = theme.Surface,
		BackgroundTransparency = 0.05,
		BorderSizePixel = 0,
		Visible = false,
		ZIndex = 50,
		Parent = row,
	})
	Util.Create("UICorner", {CornerRadius = UDim.new(0, 10), Parent = menu})
	Util.Create("UIStroke", {
		Color = Color3.fromRGB(255, 255, 255),
		Transparency = 0.88,
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
			Size = UDim2.new(1, 0, 0, 28),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = option == default and 0.9 or 1,
			BorderSizePixel = 0,
			AutoButtonColor = false,
			Font = Enum.Font.Gotham,
			Text = option,
			TextColor3 = option == default and theme.AccentLight or theme.TextSecondary,
			TextSize = 12,
			ZIndex = 51,
			Parent = menu,
		})
		Util.Create("UICorner", {CornerRadius = UDim.new(0, 7), Parent = optBtn})

		optBtn.MouseEnter:Connect(function()
			if option ~= self._selected then
				Util.Tween(optBtn, {BackgroundTransparency = 0.92}, 0.1)
			end
		end)
		optBtn.MouseLeave:Connect(function()
			if option ~= self._selected then
				Util.Tween(optBtn, {BackgroundTransparency = 1}, 0.1)
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
					Util.Tween(child, {
						BackgroundTransparency = child.Text == self._selected and 0.9 or 1,
					}, 0.1)
					child.TextColor3 = child.Text == self._selected and theme.AccentLight or theme.TextSecondary
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
			Util.SpringTween(row, {Size = UDim2.new(1, 0, 0, 70 + menuHeight + 8)}, 0.3)
		else
			Util.SpringTween(row, {Size = UDim2.new(1, 0, 0, 70)}, 0.25)
		end
	end)

	self._frame = row
	self._menu = menu
	self._selectedLabel = selectedLabel
	self._options = options
	self._callback = callback
	return row
end

function Dropdown:Get()
	return self._selected
end

function Dropdown:Set(option)
	self._selected = option
	if self._selectedLabel then
		self._selectedLabel.Text = option
	end
	if self._menu then
		for _, child in ipairs(self._menu:GetChildren()) do
			if child:IsA("TextButton") then
				child.TextColor3 = child.Text == self._selected and (self._config._theme and self._config._theme.AccentLight or Color3.fromHex("#818cf8")) or Color3.fromHex("#a1a1aa")
			end
		end
	end
	if self._callback then
		self._callback(self._selected)
	end
end

function Dropdown:Refresh(options)
	self._options = options
	if self._menu then
		for _, child in ipairs(self._menu:GetChildren()) do
			if child:IsA("TextButton") then child:Destroy() end
		end
		-- Rebuild would require theme ref, leave for manual rebuild
	end
end

return Dropdown
