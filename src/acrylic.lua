--[[
    GlassLib - Acrylic Module
    3D glass blur effects, acrylic panels
]]

local Util = require(script.Parent.util)

local Acrylic = {}

-- ══════════════════════════════════════════════════════════════
-- ASSETS
-- ══════════════════════════════════════════════════════════════

local Assets = {
	Shadow = "rbxassetid://6015897843",
	ShadowSmall = "rbxassetid://6014219553",
}

-- ══════════════════════════════════════════════════════════════
-- SHADOW
-- ══════════════════════════════════════════════════════════════

function Acrylic.AddShadow(frame, size, transparency)
	size = size or 50
	transparency = transparency or 0.6
	return Util.Create("ImageLabel", {
		Size = UDim2.new(1, size, 1, size),
		Position = UDim2.new(0.5, 0, 0.5, 8),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		Image = Assets.Shadow,
		ImageColor3 = Color3.fromRGB(0, 0, 0),
		ImageTransparency = transparency,
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(49, 49, 450, 450),
		Parent = frame,
		ZIndex = -1,
	})
end

function Acrylic.AddSmallShadow(frame, transparency)
	transparency = transparency or 0.5
	return Util.Create("ImageLabel", {
		Size = UDim2.new(1, 30, 1, 30),
		Position = UDim2.new(0.5, 0, 0.5, 4),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		Image = Assets.ShadowSmall,
		ImageColor3 = Color3.fromRGB(0, 0, 0),
		ImageTransparency = transparency,
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(30, 30, 170, 170),
		Parent = frame,
		ZIndex = -1,
	})
end

-- ══════════════════════════════════════════════════════════════
-- 3D GLASS / ACRYLIC BACKGROUND (MacLib style)
-- ══════════════════════════════════════════════════════════════

function Acrylic.AddAcrylic(parent, theme)
	local acrylicFolder = Instance.new("Folder")
	acrylicFolder.Name = "Acrylic"
	acrylicFolder.Parent = parent

	-- Glass layer
	local glass = Util.Create("Frame", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundColor3 = theme.Background,
		BackgroundTransparency = 0.3,
		BorderSizePixel = 0,
		Parent = acrylicFolder,
	})
	Util.Create("UICorner", {CornerRadius = UDim.new(0, 15), Parent = glass})

	-- Glass gradient overlay
	local overlay = Util.Create("Frame", {
		Size = UDim2.new(1, 0, 0.4, 0),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 0.94,
		BorderSizePixel = 0,
		Parent = glass,
	})
	Util.Create("UICorner", {CornerRadius = UDim.new(0, 15), Parent = overlay})

	return glass
end

-- ══════════════════════════════════════════════════════════════
-- GLOW LINE
-- ══════════════════════════════════════════════════════════════

function Acrylic.AddGlowLine(parent, theme)
	local glowLine = Util.Create("Frame", {
		Size = UDim2.new(0.6, 0, 0, 1),
		Position = UDim2.new(0.2, 0, 0, 0),
		BackgroundColor3 = theme.Accent,
		BackgroundTransparency = 0.5,
		BorderSizePixel = 0,
		Parent = parent,
	})
	Util.Create("UIGradient", {
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1),
			NumberSequenceKeypoint.new(0.3, 0),
			NumberSequenceKeypoint.new(0.7, 0),
			NumberSequenceKeypoint.new(1, 1),
		}),
		Parent = glowLine,
	})
	return glowLine
end

-- ══════════════════════════════════════════════════════════════
-- TOP HIGHLIGHT
-- ══════════════════════════════════════════════════════════════

function Acrylic.AddTopHighlight(parent, transparency, height)
	transparency = transparency or 0.92
	height = height or 0.4
	local hl = Util.Create("Frame", {
		Size = UDim2.new(1, 0, height, 0),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = transparency,
		BorderSizePixel = 0,
		Parent = parent,
	})
	local corner = parent:FindFirstChildOfClass("UICorner")
	if corner then
		Util.Create("UICorner", {CornerRadius = corner.CornerRadius, Parent = hl})
	end
	return hl
end

return Acrylic
