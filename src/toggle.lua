--[[
    GlassLib - Toggle Button Module
    Floating toggle button for showing/hiding the UI
]]

local Util = require(script.Parent.util)

local ToggleBtn = {}
ToggleBtn.__index = ToggleBtn

function ToggleBtn.new(theme, glassLib)
	local self = setmetatable({}, ToggleBtn)
	self._theme = theme
	self._lib = glassLib
	self._holder = nil
	return self
end

-- ══════════════════════════════════════════════════════════════
-- CREATE TOGGLE BUTTON
-- ══════════════════════════════════════════════════════════════

function ToggleBtn:Create(config)
	config = config or {}
	local text = config.Text or "Toggle UI"
	local position = config.Position or UDim2.new(0, 20, 1, -70)
	local theme = self._theme:Get()

	self._holder = Util.Create("ScreenGui", {
		Name = "GlassLibToggle",
		DisplayOrder = 101,
		ResetOnSpawn = false,
		Parent = Util.LocalPlayer:WaitForChild("PlayerGui"),
	})

	local btn = Util.Create("TextButton", {
		Size = UDim2.new(0, 120, 0, 40),
		Position = position,
		BackgroundColor3 = theme.Background,
		BackgroundTransparency = 0.1,
		BorderSizePixel = 0,
		AutoButtonColor = false,
		Text = "",
		Parent = self._holder,
	})
	Util.Create("UICorner", {CornerRadius = UDim.new(0, 12), Parent = btn})
	Util.Create("UIStroke", {
		Color = Color3.fromRGB(255, 255, 255),
		Transparency = 0.85,
		Thickness = 1,
		Parent = btn,
	})

	-- Pulse ring
	local ring = Util.Create("Frame", {
		Size = UDim2.new(1, 8, 1, 8),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Parent = btn,
	})
	Util.Create("UICorner", {CornerRadius = UDim.new(0, 16), Parent = ring})
	local ringStroke = Util.Create("UIStroke", {
		Color = theme.Accent,
		Transparency = 0.7,
		Thickness = 1.5,
		Parent = ring,
	})

	-- Pulse animation
	task.spawn(function()
		while self._holder and self._holder.Parent do
			ring.Size = UDim2.new(1, 8, 1, 8)
			ringStroke.Transparency = 0.7
			Util.Tween(ring, {
				Size = UDim2.new(1, 16, 1, 16),
			}, 2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
			Util.Tween(ringStroke, {Transparency = 1}, 2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
			task.wait(2.5)
		end
	end)

	-- Icon
	local iconFrame = Util.Create("Frame", {
		Size = UDim2.new(0, 22, 0, 22),
		Position = UDim2.new(0, 14, 0.5, 0),
		AnchorPoint = Vector2.new(0, 0.5),
		BackgroundTransparency = 1,
		Parent = btn,
	})

	Util.Create("ImageLabel", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		Image = "rbxassetid://6023426926",
		ImageColor3 = theme.AccentLight,
		Parent = iconFrame,
	})

	-- Label
	Util.Create("TextLabel", {
		Size = UDim2.new(1, -44, 1, 0),
		Position = UDim2.new(0, 40, 0, 0),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamMedium,
		Text = text,
		TextColor3 = theme.TextSecondary,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = btn,
	})

	-- Hover effects
	btn.MouseEnter:Connect(function()
		Util.SpringTween(btn, {Size = UDim2.new(0, 126, 0, 42)}, 0.3)
		Util.Tween(btn, {BackgroundTransparency = 0.05}, 0.15)
	end)
	btn.MouseLeave:Connect(function()
		Util.SpringTween(btn, {Size = UDim2.new(0, 120, 0, 40)}, 0.3)
		Util.Tween(btn, {BackgroundTransparency = 0.1}, 0.15)
	end)

	-- Click
	btn.MouseButton1Click:Connect(function()
		Util.SpringTween(btn, {Size = UDim2.new(0, 112, 0, 38)}, 0.1)
		task.delay(0.1, function()
			Util.SpringTween(btn, {Size = UDim2.new(0, 120, 0, 40)}, 0.2)
		end)

		for _, win in ipairs(self._lib._windows) do
			win:Toggle()
		end
	end)

	return btn
end

function ToggleBtn:Destroy()
	if self._holder then
		self._holder:Destroy()
	end
end

return ToggleBtn
