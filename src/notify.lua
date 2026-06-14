--[[
    GlassLib - Notification Module
    Toast notifications with liquid glass style
]]

local Util = require(script.Parent.util)

local Notify = {}
Notify.__index = Notify

-- ══════════════════════════════════════════════════════════════
-- NOTIFY CONSTRUCTOR
-- ══════════════════════════════════════════════════════════════

function Notify.new(theme)
	local self = setmetatable({}, Notify)
	self._theme = theme
	self._holder = nil
	return self
end

-- ══════════════════════════════════════════════════════════════
-- CREATE NOTIFICATION
-- ══════════════════════════════════════════════════════════════

function Notify:Show(config)
	config = config or {}
	local title = config.Title or "Notification"
	local content = config.Content or ""
	local duration = config.Duration or 3
	local icon = config.Icon or "rbxassetid://6023426926"
	local theme = self._theme:Get()

	-- Lazy init holder
	if not self._holder or not self._holder.Parent then
		self._holder = Util.Create("ScreenGui", {
			Name = "GlassLibNotifications",
			DisplayOrder = 999,
			ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
			ResetOnSpawn = false,
			Parent = Util.LocalPlayer:WaitForChild("PlayerGui"),
		})
	end

	-- Build notification
	local notif = Util.Create("Frame", {
		Size = UDim2.new(0, 300, 0, 70),
		Position = UDim2.new(1, -20, 1, -20),
		AnchorPoint = Vector2.new(1, 1),
		BackgroundColor3 = theme.Surface,
		BackgroundTransparency = 0.1,
		BorderSizePixel = 0,
		Parent = self._holder,
	})

	Util.Create("UICorner", {CornerRadius = UDim.new(0, 12), Parent = notif})
	Util.Create("UIStroke", {
		Color = Color3.fromRGB(255, 255, 255),
		Transparency = 0.88,
		Thickness = 1,
		Parent = notif,
	})

	-- Top highlight
	local hl = Util.Create("Frame", {
		Size = UDim2.new(1, 0, 0.4, 0),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 0.92,
		BorderSizePixel = 0,
		Parent = notif,
	})
	Util.Create("UICorner", {CornerRadius = UDim.new(0, 12), Parent = hl})

	-- Icon
	local iconFrame = Util.Create("Frame", {
		Size = UDim2.new(0, 32, 0, 32),
		Position = UDim2.new(0, 14, 0.5, 0),
		AnchorPoint = Vector2.new(0, 0.5),
		BackgroundColor3 = theme.Accent,
		BackgroundTransparency = 0.1,
		BorderSizePixel = 0,
		Parent = notif,
	})
	Util.Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = iconFrame})
	Util.Create("ImageLabel", {
		Size = UDim2.new(0, 16, 0, 16),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		Image = icon,
		ImageColor3 = Color3.fromRGB(255, 255, 255),
		Parent = iconFrame,
	})

	-- Title
	Util.Create("TextLabel", {
		Size = UDim2.new(1, -60, 0, 18),
		Position = UDim2.new(0, 54, 0, 16),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamMedium,
		Text = title,
		TextColor3 = theme.Text,
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = notif,
	})

	-- Content
	Util.Create("TextLabel", {
		Size = UDim2.new(1, -60, 0, 14),
		Position = UDim2.new(0, 54, 0, 36),
		BackgroundTransparency = 1,
		Font = Enum.Font.Gotham,
		Text = content,
		TextColor3 = theme.TextMuted,
		TextSize = 11,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = notif,
	})

	-- Progress bar
	local progressBg = Util.Create("Frame", {
		Size = UDim2.new(1, -28, 0, 2),
		Position = UDim2.new(0, 14, 1, -8),
		BackgroundTransparency = 0.92,
		BorderSizePixel = 0,
		Parent = notif,
	})
	Util.Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = progressBg})

	local progressFill = Util.Create("Frame", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundColor3 = theme.Accent,
		BackgroundTransparency = 0.2,
		BorderSizePixel = 0,
		Parent = progressBg,
	})
	Util.Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = progressFill})
	Util.MakeAccentGradient(progressFill, theme)

	-- Animate in
	notif.Position = UDim2.new(1, 100, 1, -20)
	notif.BackgroundTransparency = 1
	Util.SpringTween(notif, {
		Position = UDim2.new(1, -20, 1, -20),
		BackgroundTransparency = 0.1,
	}, 0.5)

	-- Icon pop
	iconFrame.Size = UDim2.new(0, 0, 0, 0)
	Util.BounceTween(iconFrame, {
		Size = UDim2.new(0, 32, 0, 32),
	}, 0.4)

	-- Progress countdown
	Util.Tween(progressFill, {
		Size = UDim2.new(0, 0, 1, 0),
	}, duration, Enum.EasingStyle.Linear)

	-- Dismiss
	task.delay(duration, function()
		Util.Tween(notif, {
			Position = UDim2.new(1, 100, 1, -20),
			BackgroundTransparency = 1,
		}, 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
		task.delay(0.3, function()
			notif:Destroy()
		end)
	end)
end

-- Convenience methods
function Notify:Success(title, content, duration)
	self:Show({Title = title, Content = content, Duration = duration, Icon = "rbxassetid://6023426926"})
end

function Notify:Warning(title, content, duration)
	self:Show({Title = title, Content = content, Duration = duration, Icon = "rbxassetid://6023426926"})
end

function Notify:Error(title, content, duration)
	self:Show({Title = title, Content = content, Duration = duration, Icon = "rbxassetid://6023426926"})
end

return Notify
