--[[
    GlassLib - Utility Module
    Services, helpers, tween functions, glass panel factory
]]

local Util = {}

-- ══════════════════════════════════════════════════════════════
-- SERVICES
-- ══════════════════════════════════════════════════════════════

Util.Players = game:GetService("Players")
Util.UIS = game:GetService("UserInputService")
Util.TS = game:GetService("TweenService")
Util.RS = game:GetService("RunService")
Util.HttpService = game:GetService("HttpService")
Util.ContentProvider = game:GetService("ContentProvider")

Util.LocalPlayer = Util.Players.LocalPlayer
Util.Mouse = Util.LocalPlayer:GetMouse()

-- ══════════════════════════════════════════════════════════════
-- INSTANCE CREATION
-- ══════════════════════════════════════════════════════════════

function Util.Create(className, props)
	local inst = Instance.new(className)
	for k, v in pairs(props or {}) do
		if k ~= "Parent" and k ~= "Children" then
			pcall(function() inst[k] = v end)
		end
	end
	if props then
		for _, child in ipairs(props.Children or {}) do
			child.Parent = inst
		end
		if props.Parent then
			inst.Parent = props.Parent
		end
	end
	return inst
end

-- ══════════════════════════════════════════════════════════════
-- TWEEN FUNCTIONS
-- ══════════════════════════════════════════════════════════════

function Util.Tween(obj, props, duration, style, dir)
	style = style or Enum.EasingStyle.Quint
	dir = dir or Enum.EasingDirection.Out
	local info = TweenInfo.new(duration or 0.3, style, dir)
	local t = Util.TS:Create(obj, info, props)
	t:Play()
	return t
end

function Util.SpringTween(obj, props, duration)
	local info = TweenInfo.new(duration or 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
	local t = Util.TS:Create(obj, info, props)
	t:Play()
	return t
end

function Util.BounceTween(obj, props, duration)
	local info = TweenInfo.new(duration or 0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
	local t = Util.TS:Create(obj, info, props)
	t:Play()
	return t
end

function Util.SmoothTween(obj, props, duration)
	local info = TweenInfo.new(duration or 0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local t = Util.TS:Create(obj, info, props)
	t:Play()
	return t
end

-- ══════════════════════════════════════════════════════════════
-- MATH / COLOR HELPERS
-- ══════════════════════════════════════════════════════════════

function Util.Lerp(a, b, t)
	return a + (b - a) * t
end

function Util.Color3Lerp(c1, c2, t)
	return Color3.new(
		Util.Lerp(c1.R, c2.R, t),
		Util.Lerp(c1.G, c2.G, t),
		Util.Lerp(c1.B, c2.B, t)
	)
end

function Util.HexToColor3(hex)
	return Color3.fromHex(hex)
end

-- ══════════════════════════════════════════════════════════════
-- EFFECTS
-- ══════════════════════════════════════════════════════════════

function Util.RippleEffect(frame, x, y)
	local ripple = Util.Create("Frame", {
		Size = UDim2.new(0, 0, 0, 0),
		Position = UDim2.new(0, x, 0, y),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 0.85,
		BorderSizePixel = 0,
		Parent = frame,
	})
	Util.Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = ripple})

	local maxSize = math.max(frame.AbsoluteSize.X, frame.AbsoluteSize.Y) * 2.5
	Util.Tween(ripple, {
		Size = UDim2.new(0, maxSize, 0, maxSize),
		BackgroundTransparency = 1,
	}, 0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

	task.delay(0.5, function()
		ripple:Destroy()
	end)
end

-- ══════════════════════════════════════════════════════════════
-- GLASS PANEL FACTORY
-- ══════════════════════════════════════════════════════════════

function Util.MakeGlassPanel(props)
	local theme = props.Theme
	local panel = Util.Create("Frame", {
		Size = props.Size or UDim2.new(1, 0, 1, 0),
		Position = props.Position or UDim2.new(0, 0, 0, 0),
		AnchorPoint = props.AnchorPoint or Vector2.new(0, 0),
		BackgroundColor3 = theme.Surface,
		BackgroundTransparency = 0.15,
		BorderSizePixel = 0,
		Parent = props.Parent,
	})

	Util.Create("UICorner", {
		CornerRadius = props.CornerRadius or UDim.new(0, 12),
		Parent = panel,
	})

	local stroke = Util.Create("UIStroke", {
		Color = Color3.fromRGB(255, 255, 255),
		Transparency = 0.9,
		Thickness = 1,
		Parent = panel,
	})

	local highlight = Util.Create("Frame", {
		Size = UDim2.new(1, 0, 0.45, 0),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 0.92,
		BorderSizePixel = 0,
		Parent = panel,
	})
	Util.Create("UICorner", {
		CornerRadius = props.CornerRadius or UDim.new(0, 12),
		Parent = highlight,
	})

	return panel, stroke, highlight
end

-- ══════════════════════════════════════════════════════════════
-- GRADIENT FACTORY
-- ══════════════════════════════════════════════════════════════

function Util.MakeAccentGradient(parent, theme)
	local grad = Util.Create("UIGradient", {
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, theme.Accent),
			ColorSequenceKeypoint.new(1, theme.AccentLight),
		}),
		Parent = parent,
	})
	return grad
end

function Util.MakeTransparentGradient(parent)
	return Util.Create("UIGradient", {
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1),
			NumberSequenceKeypoint.new(0.3, 0),
			NumberSequenceKeypoint.new(0.7, 0),
			NumberSequenceKeypoint.new(1, 1),
		}),
		Parent = parent,
	})
end

-- ══════════════════════════════════════════════════════════════
-- HOVER HELPERS
-- ══════════════════════════════════════════════════════════════

function Util.AddHover(element, normalTransparency, hoverTransparency, duration)
	element.MouseEnter:Connect(function()
		Util.Tween(element, {BackgroundTransparency = hoverTransparency}, duration or 0.15)
	end)
	element.MouseLeave:Connect(function()
		Util.Tween(element, {BackgroundTransparency = normalTransparency}, duration or 0.15)
	end)
end

function Util.AddButtonHover(btn, normalTrans, hoverTrans, scaleSize, normalSize)
	btn.MouseEnter:Connect(function()
		Util.Tween(btn, {BackgroundTransparency = hoverTrans}, 0.15)
		if scaleSize then
			Util.SpringTween(btn, {Size = scaleSize}, 0.25)
		end
	end)
	btn.MouseLeave:Connect(function()
		Util.Tween(btn, {BackgroundTransparency = normalTrans}, 0.15)
		if normalSize then
			Util.SpringTween(btn, {Size = normalSize}, 0.25)
		end
	end)
end

return Util
