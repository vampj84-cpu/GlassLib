--[[GlassLib v2.0.0 — https://github.com/vampj84-cpu/GlassLib]]

local Players = game:GetService('Players')
local UIS = game:GetService('UserInputService')
local TS = game:GetService('TweenService')
local RS = game:GetService('RunService')
local HttpService = game:GetService('HttpService')
local ContentProvider = game:GetService('ContentProvider')
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- src/util.lua
do
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


end

-- src/theme.lua
do

local Theme = {}
Theme.__index = Theme

-- ══════════════════════════════════════════════════════════════
-- BUILT-IN THEMES
-- ══════════════════════════════════════════════════════════════

Theme.Presets = {
	Dark = {
		Accent = Color3.fromHex("#6366f1"),
		AccentLight = Color3.fromHex("#818cf8"),
		Background = Color3.fromHex("#09090b"),
		Surface = Color3.fromHex("#18181b"),
		SurfaceLight = Color3.fromHex("#27272a"),
		Border = Color3.fromHex("#3f3f46"),
		Text = Color3.fromHex("#fafafa"),
		TextSecondary = Color3.fromHex("#a1a1aa"),
		TextMuted = Color3.fromHex("#52525b"),
		Success = Color3.fromHex("#34d399"),
		Warning = Color3.fromHex("#fbbf24"),
		Danger = Color3.fromHex("#f87171"),
	},
	Midnight = {
		Accent = Color3.fromHex("#06b6d4"),
		AccentLight = Color3.fromHex("#22d3ee"),
		Background = Color3.fromHex("#0c0c14"),
		Surface = Color3.fromHex("#141420"),
		SurfaceLight = Color3.fromHex("#1e1e2e"),
		Border = Color3.fromHex("#2a2a3a"),
		Text = Color3.fromHex("#f0f0f5"),
		TextSecondary = Color3.fromHex("#8888aa"),
		TextMuted = Color3.fromHex("#4a4a5a"),
		Success = Color3.fromHex("#34d399"),
		Warning = Color3.fromHex("#fbbf24"),
		Danger = Color3.fromHex("#f87171"),
	},
	Aurora = {
		Accent = Color3.fromHex("#a855f7"),
		AccentLight = Color3.fromHex("#c084fc"),
		Background = Color3.fromHex("#0a0a10"),
		Surface = Color3.fromHex("#16161e"),
		SurfaceLight = Color3.fromHex("#22222e"),
		Border = Color3.fromHex("#333344"),
		Text = Color3.fromHex("#f5f5ff"),
		TextSecondary = Color3.fromHex("#9999bb"),
		TextMuted = Color3.fromHex("#555566"),
		Success = Color3.fromHex("#34d399"),
		Warning = Color3.fromHex("#fbbf24"),
		Danger = Color3.fromHex("#f87171"),
	},
	Frost = {
		Accent = Color3.fromHex("#10b981"),
		AccentLight = Color3.fromHex("#34d399"),
		Background = Color3.fromHex("#080c10"),
		Surface = Color3.fromHex("#121820"),
		SurfaceLight = Color3.fromHex("#1c242e"),
		Border = Color3.fromHex("#2a3440"),
		Text = Color3.fromHex("#f0faf5"),
		TextSecondary = Color3.fromHex("#88aa99"),
		TextMuted = Color3.fromHex("#4a5a55"),
		Success = Color3.fromHex("#34d399"),
		Warning = Color3.fromHex("#fbbf24"),
		Danger = Color3.fromHex("#f87171"),
	},
	Amber = {
		Accent = Color3.fromHex("#f59e0b"),
		AccentLight = Color3.fromHex("#fbbf24"),
		Background = Color3.fromHex("#0c0a08"),
		Surface = Color3.fromHex("#1a1612"),
		SurfaceLight = Color3.fromHex("#262018"),
		Border = Color3.fromHex("#3a3228"),
		Text = Color3.fromHex("#fefce8"),
		TextSecondary = Color3.fromHex("#aaaa88"),
		TextMuted = Color3.fromHex("#5a5544"),
		Success = Color3.fromHex("#34d399"),
		Warning = Color3.fromHex("#fbbf24"),
		Danger = Color3.fromHex("#f87171"),
	},
	Rose = {
		Accent = Color3.fromHex("#f43f5e"),
		AccentLight = Color3.fromHex("#fb7185"),
		Background = Color3.fromHex("#0c0809"),
		Surface = Color3.fromHex("#1a1214"),
		SurfaceLight = Color3.fromHex("#26181c"),
		Border = Color3.fromHex("#3a2830"),
		Text = Color3.fromHex("#fff1f2"),
		TextSecondary = Color3.fromHex("#aa8890"),
		TextMuted = Color3.fromHex("#5a4448"),
		Success = Color3.fromHex("#34d399"),
		Warning = Color3.fromHex("#fbbf24"),
		Danger = Color3.fromHex("#f87171"),
	},
}

-- ══════════════════════════════════════════════════════════════
-- THEME CONSTRUCTOR
-- ══════════════════════════════════════════════════════════════

function Theme.new(configFolder)
	local self = setmetatable({}, Theme)
	self._current = "Dark"
	self._values = {}
	self._listeners = {}
	self._configFolder = configFolder or "GlassLib"

	-- Copy defaults
	for k, v in pairs(Theme.Presets.Dark) do
		self._values[k] = v
	end

	return self
end

function Theme:Get()
	return self._values
end

function Theme:GetName()
	return self._current
end

function Theme:Set(themeName)
	if Theme.Presets[themeName] then
		self._current = themeName
		for k, v in pairs(Theme.Presets[themeName]) do
			self._values[k] = v
		end
		self:_NotifyListeners()
	end
end

function Theme:SetCustom(values)
	for k, v in pairs(values) do
		self._values[k] = v
	end
	self._current = "Custom"
	self:_NotifyListeners()
end

function Theme:OnChanged(callback)
	table.insert(self._listeners, callback)
end

function Theme:_NotifyListeners()
	for _, cb in ipairs(self._listeners) do
		cb(self._values, self._current)
	end
end

-- ══════════════════════════════════════════════════════════════
-- PERSISTENCE
-- ══════════════════════════════════════════════════════════════

function Theme:Save(name)
	local data = {
		ThemeName = self._current,
		Custom = self._current == "Custom" and self._values or nil,
	}
	pcall(function()
		if not isfolder(self._configFolder) then
			makefolder(self._configFolder)
		end
		writefile(self._configFolder .. "/theme_" .. (name or "default") .. ".json", Util.HttpService:JSONEncode(data))
	end)
end

function Theme:Load(name)
	local success, result = pcall(function()
		return readfile(self._configFolder .. "/theme_" .. (name or "default") .. ".json")
	end)
	if success and result then
		local data = Util.HttpService:JSONDecode(result)
		if data.ThemeName and Theme.Presets[data.ThemeName] then
			self:Set(data.ThemeName)
		elseif data.Custom then
			self:SetCustom(data.Custom)
		end
		return true
	end
	return false
end

function Theme:GetPresets()
	local names = {}
	for name in pairs(Theme.Presets) do
		table.insert(names, name)
	end
	table.sort(names)
	return names
end


end

-- src/acrylic.lua
do

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


end

-- src/config.lua
do

local Config = {}
Config.__index = Config

-- ══════════════════════════════════════════════════════════════
-- CONFIG CONSTRUCTOR
-- ══════════════════════════════════════════════════════════════

function Config.new(configFolder)
	local self = setmetatable({}, Config)
	self._folder = configFolder or "GlassLib"
	self._flags = {}
	self._elements = {}
	return self
end

-- ══════════════════════════════════════════════════════════════
-- FLAG SYSTEM
-- ══════════════════════════════════════════════════════════════

function Config:RegisterFlag(flag, element, default)
	self._flags[flag] = {
		Element = element,
		Default = default,
		Value = default,
	}
end

function Config:SetFlag(flag, value)
	if self._flags[flag] then
		self._flags[flag].Value = value
	end
end

function Config:GetFlag(flag)
	if self._flags[flag] then
		return self._flags[flag].Value
	end
	return nil
end

function Config:GetFlags()
	local data = {}
	for flag, info in pairs(self._flags) do
		data[flag] = info.Value
	end
	return data
end

function Config:SetFlags(data)
	for flag, value in pairs(data) do
		if self._flags[flag] then
			self._flags[flag].Value = value
			-- Update the connected element if it has a Set method
			local element = self._flags[flag].Element
			if element and element.Set then
				element:Set(value)
			end
		end
	end
end

-- ══════════════════════════════════════════════════════════════
-- FILE OPERATIONS
-- ══════════════════════════════════════════════════════════════

function Config:Save(name)
	local data = self:GetFlags()
	local success, err = pcall(function()
		if not isfolder(self._folder) then
			makefolder(self._folder)
		end
		writefile(self._folder .. "/" .. name .. ".json", Util.HttpService:JSONEncode(data))
	end)
	return success, err
end

function Config:Load(name)
	local success, result = pcall(function()
		return readfile(self._folder .. "/" .. name .. ".json")
	end)
	if success and result then
		local data = Util.HttpService:JSONDecode(result)
		self:SetFlags(data)
		return true
	end
	return false
end

function Config:Delete(name)
	pcall(function()
		delfile(self._folder .. "/" .. name .. ".json")
	end)
end

function Config:List()
	local files = {}
	pcall(function()
		files = listfiles(self._folder)
	end)
	local configs = {}
	for _, file in ipairs(files) do
		if file:match("%.json$") then
			table.insert(configs, file:match("([^/]+)%.json$"))
		end
	end
	return configs
end

-- ══════════════════════════════════════════════════════════════
-- AUTOLOAD
-- ══════════════════════════════════════════════════════════════

function Config:SetAutoload(name)
	pcall(function()
		if not isfolder(self._folder) then
			makefolder(self._folder)
		end
		writefile(self._folder .. "/autoload.txt", name or "")
	end)
end

function Config:GetAutoload()
	local success, result = pcall(function()
		return readfile(self._folder .. "/autoload.txt")
	end)
	if success and result and result ~= "" then
		return result
	end
	return nil
end

function Config:ClearAutoload()
	pcall(function()
		delfile(self._folder .. "/autoload.txt")
	end)
end


end

-- src/notify.lua
do

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


end

-- src/dialog.lua
do

local Dialog = {}
Dialog.__index = Dialog

function Dialog.new(theme, config)
	local self = setmetatable({}, Dialog)
	self._theme = theme
	self._config = config or {}
	self._gui = nil
	return self
end

-- ══════════════════════════════════════════════════════════════
-- SHOW DIALOG
-- ══════════════════════════════════════════════════════════════

function Dialog:Show(config)
	config = config or {}
	local title = config.Title or "Dialog"
	local content = config.Content or ""
	local confirmText = config.ConfirmText or "Confirm"
	local cancelText = config.CancelText or "Cancel"
	local onConfirm = config.OnConfirm or function() end
	local onCancel = config.OnCancel or function() end
	local theme = self._theme:Get()

	-- ScreenGui
	local gui = Util.Create("ScreenGui", {
		Name = "GlassLibDialog",
		DisplayOrder = 200,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		ResetOnSpawn = false,
		Parent = Util.LocalPlayer:WaitForChild("PlayerGui"),
	})
	self._gui = gui

	-- Backdrop
	local backdrop = Util.Create("Frame", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundColor3 = Color3.fromRGB(0, 0, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Parent = gui,
	})

	Util.Tween(backdrop, {BackgroundTransparency = 0.5}, 0.25)

	-- Dialog frame
	local dialog = Util.Create("Frame", {
		Size = UDim2.new(0, 340, 0, 0),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = theme.Surface,
		BackgroundTransparency = 0.05,
		BorderSizePixel = 0,
		Parent = backdrop,
	})
	Util.Create("UICorner", {CornerRadius = UDim.new(0, 16), Parent = dialog})
	Util.Create("UIStroke", {
		Color = Color3.fromRGB(255, 255, 255),
		Transparency = 0.85,
		Thickness = 1,
		Parent = dialog,
	})

	-- Title
	Util.Create("TextLabel", {
		Size = UDim2.new(1, -40, 0, 24),
		Position = UDim2.new(0, 20, 0, 20),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamBold,
		Text = title,
		TextColor3 = theme.Text,
		TextSize = 16,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = dialog,
	})

	-- Content
	local contentLabel = Util.Create("TextLabel", {
		Size = UDim2.new(1, -40, 0, 0),
		Position = UDim2.new(0, 20, 0, 50),
		BackgroundTransparency = 1,
		Font = Enum.Font.Gotham,
		Text = content,
		TextColor3 = theme.TextSecondary,
		TextSize = 13,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		AutomaticSize = Enum.AutomaticSize.Y,
		Parent = dialog,
	})

	-- Buttons
	local btnHolder = Util.Create("Frame", {
		Size = UDim2.new(1, -40, 0, 36),
		Position = UDim2.new(0, 20, 1, -56),
		BackgroundTransparency = 1,
		Parent = dialog,
	})
	Util.Create("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		HorizontalAlignment = Enum.HorizontalAlignment.Right,
		Padding = UDim.new(0, 8),
		Parent = btnHolder,
	})

	-- Cancel button
	local cancelBtn = Util.Create("TextButton", {
		Size = UDim2.new(0, 80, 0, 36),
		BackgroundColor3 = theme.SurfaceLight,
		BackgroundTransparency = 0.3,
		BorderSizePixel = 0,
		AutoButtonColor = false,
		Font = Enum.Font.GothamMedium,
		Text = cancelText,
		TextColor3 = theme.TextSecondary,
		TextSize = 13,
		Parent = btnHolder,
	})
	Util.Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = cancelBtn})

	-- Confirm button
	local confirmBtn = Util.Create("TextButton", {
		Size = UDim2.new(0, 80, 0, 36),
		BackgroundColor3 = theme.Accent,
		BackgroundTransparency = 0,
		BorderSizePixel = 0,
		AutoButtonColor = false,
		Font = Enum.Font.GothamMedium,
		Text = confirmText,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextSize = 13,
		Parent = btnHolder,
	})
	Util.Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = confirmBtn})
	Util.MakeAccentGradient(confirmBtn, theme)

	-- Interactions
	cancelBtn.MouseButton1Click:Connect(function()
		onCancel()
		gui:Destroy()
	end)

	confirmBtn.MouseButton1Click:Connect(function()
		onConfirm()
		gui:Destroy()
	end)

	backdrop.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			onCancel()
			gui:Destroy()
		end
	end)

	-- Animate in
	local dialogHeight = 50 + math.max(contentLabel.TextBounds.Y, 20) + 80
	Util.SpringTween(dialog, {
		Size = UDim2.new(0, 340, 0, dialogHeight),
	}, 0.4)

	Util.AddHover(cancelBtn, 0.3, 0.15)
	Util.AddHover(confirmBtn, 0, 0.1)

	return gui
end

function Dialog:Destroy()
	if self._gui then
		self._gui:Destroy()
	end
end


end

-- src/toggle.lua
do

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


end

-- src/elements/button.lua
do
local El_Button = {}
El_Button.__index = El_Button
function El_Button.new(config)
	local self = setmetatable({}, El_Button)
	self._config = config or {}
	self._frame = nil
	self._btn = nil
	return self
end
function El_Button:Create(parent, theme, order)
	local cfg = self._config
	local title = cfg.Title or "El_Button"
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

end

-- src/elements/toggle.lua
do
local El_Toggle = {}
El_Toggle.__index = El_Toggle
function El_Toggle.new(config)
	local self = setmetatable({}, El_Toggle)
	self._config = config or {}
	self._state = false
	self._frame = nil
	self._track = nil
	self._knob = nil
	return self
end
function El_Toggle:Create(parent, theme, order)
	local cfg = self._config
	local title = cfg.Title or "El_Toggle"
	local desc = cfg.Desc or ""
	local default = cfg.Default or false
	local callback = cfg.Callback or function() end
	local hasDesc = desc ~= ""
	self._state = default
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
		Size = UDim2.new(1, -56, 0, 16),
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
			Size = UDim2.new(1, -56, 0, 12),
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
	-- Track
	local track = Util.Create("Frame", {
		Size = UDim2.new(0, 40, 0, 22),
		Position = UDim2.new(1, 0, 0.5, 0),
		AnchorPoint = Vector2.new(1, 0.5),
		BackgroundColor3 = self._state and theme.Accent or Color3.fromRGB(60, 60, 70),
		BorderSizePixel = 0,
		Parent = row,
	})
	Util.Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = track})
	if self._state then
		Util.MakeAccentGradient(track, theme)
	end
	-- Knob
	local knob = Util.Create("Frame", {
		Size = UDim2.new(0, 18, 0, 18),
		Position = self._state and UDim2.new(1, -20, 0.5, 0) or UDim2.new(0, 2, 0.5, 0),
		AnchorPoint = Vector2.new(0, 0.5),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BorderSizePixel = 0,
		Parent = track,
	})
	Util.Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = knob})
	local function updateGradient()
		for _, c in ipairs(track:GetChildren()) do
			if c:IsA("UIGradient") then c:Destroy() end
		end
		if self._state then
			Util.MakeAccentGradient(track, theme)
		end
	end
	local function updateToggle(anim)
		self._state = not self._state
		if anim then
			Util.SpringTween(knob, {
				Position = self._state and UDim2.new(1, -20, 0.5, 0) or UDim2.new(0, 2, 0.5, 0),
			}, 0.35)
			Util.Tween(track, {
				BackgroundColor3 = self._state and theme.Accent or Color3.fromRGB(60, 60, 70),
			}, 0.25)
		else
			knob.Position = self._state and UDim2.new(1, -20, 0.5, 0) or UDim2.new(0, 2, 0.5, 0)
			track.BackgroundColor3 = self._state and theme.Accent or Color3.fromRGB(60, 60, 70)
		end
		updateGradient()
		callback(self._state)
	end
	track.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			updateToggle(true)
		end
	end)
	knob.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			updateToggle(true)
		end
	end)
	Util.AddHover(row, 0.6, 0.45)
	self._frame = row
	self._track = track
	self._knob = knob
	self._updateToggle = updateToggle
	return row
end
function El_Toggle:Get()
	return self._state
end
function El_Toggle:Set(value)
	if self._state ~= value then
		self._updateToggle(true)
	end
end

end

-- src/elements/slider.lua
do
local El_Slider = {}
El_Slider.__index = El_Slider
function El_Slider.new(config)
	local self = setmetatable({}, El_Slider)
	self._config = config or {}
	self._value = 0
	self._frame = nil
	return self
end
function El_Slider:Create(parent, theme, order)
	local cfg = self._config
	local title = cfg.Title or "El_Slider"
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
function El_Slider:Get()
	return self._value
end
function El_Slider:Set(val)
	self._value = math.clamp(val, self._min, self._max)
	local pct = (self._value - self._min) / (self._max - self._min)
	self._trackFill.Size = UDim2.new(pct, 0, 1, 0)
	self._knob.Position = UDim2.new(pct, 0, 0.5, 0)
	self._valueLabel.Text = tostring(math.round(self._value))
end

end

-- src/elements/dropdown.lua
do
local El_Dropdown = {}
El_Dropdown.__index = El_Dropdown
function El_Dropdown.new(config)
	local self = setmetatable({}, El_Dropdown)
	self._config = config or {}
	self._selected = nil
	self._frame = nil
	return self
end
function El_Dropdown:Create(parent, theme, order)
	local cfg = self._config
	local title = cfg.Title or "El_Dropdown"
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
function El_Dropdown:Get()
	return self._selected
end
function El_Dropdown:Set(option)
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
function El_Dropdown:Refresh(options)
	self._options = options
	if self._menu then
		for _, child in ipairs(self._menu:GetChildren()) do
			if child:IsA("TextButton") then child:Destroy() end
		end
		-- Rebuild would require theme ref, leave for manual rebuild
	end
end

end

-- src/elements/textinput.lua
do
local El_TextInput = {}
El_TextInput.__index = El_TextInput
function El_TextInput.new(config)
	local self = setmetatable({}, El_TextInput)
	self._config = config or {}
	self._frame = nil
	self._input = nil
	return self
end
function El_TextInput:Create(parent, theme, order)
	local cfg = self._config
	local title = cfg.Title or "Input"
	local placeholder = cfg.Placeholder or ""
	local default = cfg.Default or ""
	local callback = cfg.Callback or function() end
	local row = Util.Create("Frame", {
		Size = UDim2.new(1, 0, 0, 66),
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
	local input = Util.Create("TextBox", {
		Size = UDim2.new(1, 0, 0, 32),
		Position = UDim2.new(0, 0, 1, -8),
		AnchorPoint = Vector2.new(0, 1),
		BackgroundColor3 = theme.SurfaceLight,
		BackgroundTransparency = 0.3,
		BorderSizePixel = 0,
		Font = Enum.Font.Gotham,
		PlaceholderText = placeholder,
		PlaceholderColor3 = theme.TextMuted,
		Text = default,
		TextColor3 = theme.Text,
		TextSize = 12,
		ClearTextOnFocus = false,
		Parent = row,
	})
	Util.Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = input})
	local inputStroke = Util.Create("UIStroke", {
		Color = Color3.fromRGB(255, 255, 255),
		Transparency = 0.9,
		Thickness = 1,
		Parent = input,
	})
	Util.Create("UIPadding", {
		PaddingLeft = UDim.new(0, 10),
		PaddingRight = UDim.new(0, 10),
		Parent = input,
	})
	input.Focused:Connect(function()
		Util.Tween(input, {BackgroundTransparency = 0.15}, 0.2)
		inputStroke.Color = theme.Accent
		inputStroke.Transparency = 0.5
	end)
	input.FocusLost:Connect(function()
		Util.Tween(input, {BackgroundTransparency = 0.3}, 0.2)
		inputStroke.Color = Color3.fromRGB(255, 255, 255)
		inputStroke.Transparency = 0.9
		callback(input.Text)
	end)
	self._frame = row
	self._input = input
	return input
end
function El_TextInput:Get()
	return self._input and self._input.Text or ""
end
function El_TextInput:Set(value)
	if self._input then
		self._input.Text = value
	end
end

end

-- src/elements/keybind.lua
do
local El_Keybind = {}
El_Keybind.__index = El_Keybind
function El_Keybind.new(config)
	local self = setmetatable({}, El_Keybind)
	self._config = config or {}
	self._bound = nil
	self._frame = nil
	return self
end
function El_Keybind:Create(parent, theme, order)
	local cfg = self._config
	local title = cfg.Title or "El_Keybind"
	local default = cfg.Default or Enum.KeyCode.Unknown
	local callback = cfg.Callback or function() end
	self._bound = default
	local listening = false
	local row = Util.Create("Frame", {
		Size = UDim2.new(1, 0, 0, 42),
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
		Size = UDim2.new(1, -80, 1, 0),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamMedium,
		Text = title,
		TextColor3 = theme.Text,
		TextSize = 12.5,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = row,
	})
	local bindBtn = Util.Create("TextButton", {
		Size = UDim2.new(0, 70, 0, 28),
		Position = UDim2.new(1, 0, 0.5, 0),
		AnchorPoint = Vector2.new(1, 0.5),
		BackgroundColor3 = default ~= Enum.KeyCode.Unknown and theme.Accent or theme.SurfaceLight,
		BackgroundTransparency = default ~= Enum.KeyCode.Unknown and 0.85 or 0.3,
		BorderSizePixel = 0,
		AutoButtonColor = false,
		Font = Enum.Font.GothamMedium,
		Text = default ~= Enum.KeyCode.Unknown and default.Name or "Bind",
		TextColor3 = default ~= Enum.KeyCode.Unknown and theme.AccentLight or theme.TextMuted,
		TextSize = 11,
		Parent = row,
	})
	Util.Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = bindBtn})
	Util.Create("UIStroke", {
		Color = Color3.fromRGB(255, 255, 255),
		Transparency = 0.88,
		Thickness = 1,
		Parent = bindBtn,
	})
	bindBtn.MouseButton1Click:Connect(function()
		listening = true
		bindBtn.Text = "..."
		Util.Tween(bindBtn, {BackgroundColor3 = theme.Accent, BackgroundTransparency = 0.7}, 0.15)
	end)
	Util.UIS.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then return end
		if listening and input.UserInputType == Enum.UserInputType.Keyboard then
			self._bound = input.KeyCode
			listening = false
			bindBtn.Text = self._bound.Name
			Util.Tween(bindBtn, {BackgroundTransparency = 0.85}, 0.15)
			callback(self._bound)
		end
	end)
	Util.AddHover(row, 0.6, 0.45)
	self._frame = row
	return row
end
function El_Keybind:Get()
	return self._bound
end
function El_Keybind:Set(keycode)
	self._bound = keycode
end

end

-- src/elements/colorpicker.lua
do
local El_ColorPicker = {}
El_ColorPicker.__index = El_ColorPicker
function El_ColorPicker.new(config)
	local self = setmetatable({}, El_ColorPicker)
	self._config = config or {}
	self._color = nil
	self._frame = nil
	return self
end
function El_ColorPicker:Create(parent, theme, order)
	local cfg = self._config
	local title = cfg.Title or "Color"
	local default = cfg.Default or Color3.fromRGB(99, 102, 241)
	local callback = cfg.Callback or function() end
	self._color = default
	local row = Util.Create("Frame", {
		Size = UDim2.new(1, 0, 0, 42),
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
		Size = UDim2.new(1, -50, 1, 0),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamMedium,
		Text = title,
		TextColor3 = theme.Text,
		TextSize = 12.5,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = row,
	})
	local swatch = Util.Create("TextButton", {
		Size = UDim2.new(0, 28, 0, 28),
		Position = UDim2.new(1, 0, 0.5, 0),
		AnchorPoint = Vector2.new(1, 0.5),
		BackgroundColor3 = default,
		BorderSizePixel = 0,
		AutoButtonColor = false,
		Text = "",
		Parent = row,
	})
	Util.Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = swatch})
	Util.Create("UIStroke", {
		Color = Color3.fromRGB(255, 255, 255),
		Transparency = 0.7,
		Thickness = 2,
		Parent = swatch,
	})
	-- Color picker popup
	local pickerOpen = false
	local pickerFrame = Util.Create("Frame", {
		Size = UDim2.new(0, 200, 0, 160),
		Position = UDim2.new(1, -10, 0.5, 0),
		AnchorPoint = Vector2.new(1, 0.5),
		BackgroundColor3 = theme.Surface,
		BackgroundTransparency = 0.05,
		BorderSizePixel = 0,
		Visible = false,
		ZIndex = 60,
		Parent = row,
	})
	Util.Create("UICorner", {CornerRadius = UDim.new(0, 12), Parent = pickerFrame})
	Util.Create("UIStroke", {
		Color = Color3.fromRGB(255, 255, 255),
		Transparency = 0.88,
		Thickness = 1,
		ZIndex = 60,
		Parent = pickerFrame,
	})
	-- Color gradient square
	local colorSquare = Util.Create("Frame", {
		Size = UDim2.new(1, -20, 0, 100),
		Position = UDim2.new(0, 10, 0, 10),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BorderSizePixel = 0,
		ZIndex = 61,
		Parent = pickerFrame,
	})
	Util.Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = colorSquare})
	Util.Create("UIGradient", {
		Color = ColorSequence.new(Color3.fromRGB(255, 255, 255)),
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0),
			NumberSequenceKeypoint.new(1, 0),
		}),
		Parent = colorSquare,
	})
	-- Hue slider
	local hueBar = Util.Create("Frame", {
		Size = UDim2.new(1, -20, 0, 12),
		Position = UDim2.new(0, 10, 1, -30),
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
	Util.AddHover(row, 0.6, 0.45)
	self._frame = row
	self._swatch = swatch
	self._callback = callback
	return row
end
function El_ColorPicker:Get()
	return self._color
end
function El_ColorPicker:Set(c)
	self._color = c
	if self._swatch then
		self._swatch.BackgroundColor3 = c
	end
	if self._callback then
		self._callback(c)
	end
end

end

-- src/elements/label.lua
do
local El_Label = {}
El_Label.__index = El_Label
function El_Label.new(config)
	local self = setmetatable({}, El_Label)
	self._config = config or {}
	self._frame = nil
	return self
end
function El_Label:Create(parent, theme, order)
	local cfg = self._config
	local title = cfg.Title or "El_Label"
	local desc = cfg.Desc or ""
	local hasDesc = desc ~= ""
	local height = hasDesc and 40 or 28
	local row = Util.Create("Frame", {
		Size = UDim2.new(1, 0, 0, height),
		BackgroundTransparency = 1,
		LayoutOrder = order or 0,
		Parent = parent,
	})
	Util.Create("TextLabel", {
		Size = UDim2.new(1, 0, 0, hasDesc and 16 or height),
		Position = UDim2.new(0, 4, 0, 0),
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
			Size = UDim2.new(1, 4, 0, 14),
			Position = UDim2.new(0, 4, 0, 18),
			BackgroundTransparency = 1,
			Font = Enum.Font.Gotham,
			Text = desc,
			TextColor3 = theme.TextMuted,
			TextSize = 10.5,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextWrapped = true,
			Parent = row,
		})
	end
	self._frame = row
	return row
end

end

-- src/elements/paragraph.lua
do
local El_Paragraph = {}
El_Paragraph.__index = El_Paragraph
function El_Paragraph.new(config)
	local self = setmetatable({}, El_Paragraph)
	self._config = config or {}
	self._frame = nil
	return self
end
function El_Paragraph:Create(parent, theme, order)
	local cfg = self._config
	local title = cfg.Title or ""
	local body = cfg.Body or cfg.Content or ""
	local height = 32
	if title ~= "" then height = height + 18 end
	if body ~= "" then
		-- Estimate wrapped lines
		local estimatedLines = math.ceil(#body / 50)
		height = height + (estimatedLines * 14) + 4
	end
	local row = Util.Create("Frame", {
		Size = UDim2.new(1, 0, 0, height),
		BackgroundColor3 = theme.Surface,
		BackgroundTransparency = 0.7,
		BorderSizePixel = 0,
		LayoutOrder = order or 0,
		Parent = parent,
	})
	Util.Create("UICorner", {CornerRadius = UDim.new(0, 10), Parent = row})
	Util.Create("UIPadding", {
		PaddingLeft = UDim.new(0, 12),
		PaddingRight = UDim.new(0, 12),
		PaddingTop = UDim.new(0, 8),
		PaddingBottom = UDim.new(0, 8),
		Parent = row,
	})
	if title ~= "" then
		Util.Create("TextLabel", {
			Size = UDim2.new(1, 0, 0, 16),
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamBold,
			Text = title,
			TextColor3 = theme.Text,
			TextSize = 13,
			TextXAlignment = Enum.TextXAlignment.Left,
			Parent = row,
		})
	end
	if body ~= "" then
		Util.Create("TextLabel", {
			Size = UDim2.new(1, 0, 0, 0),
			Position = UDim2.new(0, 0, 0, title ~= "" and 20 or 0),
			BackgroundTransparency = 1,
			Font = Enum.Font.Gotham,
			Text = body,
			TextColor3 = theme.TextSecondary,
			TextSize = 12,
			TextWrapped = true,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Top,
			AutomaticSize = Enum.AutomaticSize.Y,
			Parent = row,
		})
	end
	self._frame = row
	return row
end

end

-- src/elements/divider.lua
do
local El_Divider = {}
El_Divider.__index = El_Divider
function El_Divider.new(config)
	local self = setmetatable({}, El_Divider)
	self._config = config or {}
	self._frame = nil
	return self
end
function El_Divider:Create(parent, theme, order)
	local divider = Util.Create("Frame", {
		Size = UDim2.new(1, 0, 0, 1),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 0.9,
		BorderSizePixel = 0,
		LayoutOrder = order or 0,
		Parent = parent,
	})
	self._frame = divider
	return divider
end

end

-- src/elements/init.lua
do
local Elements = {}

Elements.Button = El_Button
Elements.Toggle = El_Toggle
Elements.Slider = El_Slider
Elements.Dropdown = El_Dropdown
Elements.TextInput = El_TextInput
Elements.Keybind = El_Keybind
Elements.ColorPicker = El_ColorPicker
Elements.Label = El_Label
Elements.Paragraph = El_Paragraph
Elements.Divider = El_Divider


end

-- src/section.lua
do

local Section = {}
Section.__index = Section

function Section.new(config)
	local self = setmetatable({}, Section)
	self._config = config or {}
	self._elements = {}
	self._frame = nil
	return self
end

function Section:Create(parent, theme, windowRef)
	local cfg = self._config
	local name = cfg.Name or ""

	local section = {}
	section._elements = {}
	section._elementOrder = 0
	section._theme = theme
	section._parent = parent
	section._windowRef = windowRef

	-- Section header
	if name ~= "" then
		Util.Create("TextLabel", {
			Size = UDim2.new(1, 0, 0, 20),
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamBold,
			Text = string.upper(name),
			TextColor3 = theme:Get().TextMuted,
			TextSize = 10,
			TextXAlignment = Enum.TextXAlignment.Left,
			LayoutOrder = 1,
			Parent = parent,
		})
	end

	-- ═══ ELEMENT CREATION METHODS ═══

	function section:_NextOrder()
		self._elementOrder = self._elementOrder + 1
		return self._elementOrder * 10
	end

	function section:CreateButton(btnConfig)
		local el = Elements.Button.new(btnConfig)
		local frame = el:Create(self._parent, self._theme:Get(), self:_NextOrder())
		table.insert(self._elements, el)
		return el
	end

	function section:CreateToggle(togConfig)
		local el = Elements.Toggle.new(togConfig)
		local frame = el:Create(self._parent, self._theme:Get(), self:_NextOrder())
		table.insert(self._elements, el)

		-- Register flag if config is provided
		if togConfig.Flag and self._windowRef and self._windowRef._config then
			self._windowRef._config:RegisterFlag(togConfig.Flag, el, togConfig.Default or false)
		end

		return el
	end

	function section:CreateSlider(sliderConfig)
		local el = Elements.Slider.new(sliderConfig)
		local frame = el:Create(self._parent, self._theme:Get(), self:_NextOrder())
		table.insert(self._elements, el)

		if sliderConfig.Flag and self._windowRef and self._windowRef._config then
			self._windowRef._config:RegisterFlag(sliderConfig.Flag, el, sliderConfig.Default or sliderConfig.Min or 0)
		end

		return el
	end

	function section:CreateDropdown(ddConfig)
		local el = Elements.Dropdown.new(ddConfig)
		local frame = el:Create(self._parent, self._theme:Get(), self:_NextOrder())
		table.insert(self._elements, el)

		if ddConfig.Flag and self._windowRef and self._windowRef._config then
			self._windowRef._config:RegisterFlag(ddConfig.Flag, el, ddConfig.Default)
		end

		return el
	end

	function section:CreateTextInput(tiConfig)
		local el = Elements.TextInput.new(tiConfig)
		local frame = el:Create(self._parent, self._theme:Get(), self:_NextOrder())
		table.insert(self._elements, el)

		if tiConfig.Flag and self._windowRef and self._windowRef._config then
			self._windowRef._config:RegisterFlag(tiConfig.Flag, el, tiConfig.Default or "")
		end

		return el
	end

	function section:CreateKeybind(kbConfig)
		local el = Elements.Keybind.new(kbConfig)
		local frame = el:Create(self._parent, self._theme:Get(), self:_NextOrder())
		table.insert(self._elements, el)

		if kbConfig.Flag and self._windowRef and self._windowRef._config then
			self._windowRef._config:RegisterFlag(kbConfig.Flag, el, kbConfig.Default)
		end

		return el
	end

	function section:CreateColorPicker(cpConfig)
		local el = Elements.ColorPicker.new(cpConfig)
		local frame = el:Create(self._parent, self._theme:Get(), self:_NextOrder())
		table.insert(self._elements, el)

		if cpConfig.Flag and self._windowRef and self._windowRef._config then
			self._windowRef._config:RegisterFlag(cpConfig.Flag, el, cpConfig.Default or Color3.fromRGB(99, 102, 241))
		end

		return el
	end

	function section:CreateLabel(labelConfig)
		local el = Elements.Label.new(labelConfig)
		local frame = el:Create(self._parent, self._theme:Get(), self:_NextOrder())
		table.insert(self._elements, el)
		return el
	end

	function section:CreateParagraph(paraConfig)
		local el = Elements.Paragraph.new(paraConfig)
		local frame = el:Create(self._parent, self._theme:Get(), self:_NextOrder())
		table.insert(self._elements, el)
		return el
	end

	function section:CreateDivider(divConfig)
		local el = Elements.Divider.new(divConfig or {})
		local frame = el:Create(self._parent, self._theme:Get(), self:_NextOrder())
		table.insert(self._elements, el)
		return el
	end

	return section
end


end

-- src/tab.lua
do

local Tab = {}
Tab.__index = Tab

function Tab.new(config)
	local self = setmetatable({}, Tab)
	self._config = config or {}
	self._sections = {}
	self._frame = nil
	return self
end

function Tab:Create(windowRef, theme, sidebarLayout, contentFrame, order)
	local cfg = self._config
	local tabName = cfg.Name or "Tab"
	local tabIcon = cfg.Icon or ""

	local tab = {}
	tab._sections = {}
	tab._order = order
	tab._windowRef = windowRef
	tab._theme = theme

	-- ═══ SIDEBAR BUTTON ═══
	local tabBtn = Util.Create("TextButton", {
		Size = UDim2.new(0, 40, 0, 40),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = tabIcon == "" and 0.95 or 1,
		BorderSizePixel = 0,
		AutoButtonColor = false,
		Font = Enum.Font.GothamBold,
		Text = tabIcon == "" and string.sub(tabName, 1, 1) or "",
		TextColor3 = theme:Get().TextMuted,
		TextSize = 15,
		LayoutOrder = order,
		Parent = sidebarLayout,
	})
	Util.Create("UICorner", {CornerRadius = UDim.new(0, 10), Parent = tabBtn})

		if tabIcon ~= "" then
		iconLabel = Util.Create("ImageLabel", {
			Size = UDim2.new(0, 20, 0, 20),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			Image = tabIcon,
			ImageColor3 = theme:Get().TextMuted,
			Parent = tabBtn,
		})
	end

	-- Active indicator
	local indicator = Util.Create("Frame", {
		Size = UDim2.new(0, 3, 0, 18),
		Position = UDim2.new(0, -1, 0.5, 0),
		AnchorPoint = Vector2.new(1, 0.5),
		BackgroundColor3 = theme:Get().Accent,
		BorderSizePixel = 0,
		Visible = false,
		Parent = tabBtn,
	})
	Util.Create("UICorner", {CornerRadius = UDim.new(0, 3), Parent = indicator})

	-- Tab content frame
	local tabContent = Util.Create("Frame", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		Visible = false,
		Parent = contentFrame,
	})
	Util.Create("UIListLayout", {
		FillDirection = Enum.FillDirection.Vertical,
		Padding = UDim.new(0, 6),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = tabContent,
	})

	tab._btn = tabBtn
	tab._indicator = indicator
	tab._iconLabel = iconLabel
	tab._content = tabContent
	tab._theme = theme

	-- ═══ SECTION CREATION ═══

	function tab:CreateSection(sectionConfig)
		local section = Section.new(sectionConfig)
		local sectionObj = section:Create(tabContent, theme, windowRef)
		table.insert(self._sections, sectionObj)
		return sectionObj
	end

	-- ═══ TAB SELECTION ═══

	function tab:_Select(allTabs)
		-- Hide all
		for _, t in ipairs(allTabs) do
			t._content.Visible = false
			t._indicator.Visible = false
			Util.Tween(t._btn, {BackgroundTransparency = 0.95}, 0.15)
			if t._iconLabel then
				Util.Tween(t._iconLabel, {ImageColor3 = theme:Get().TextMuted}, 0.15)
			else
				Util.Tween(t._btn, {TextColor3 = theme:Get().TextMuted}, 0.15)
			end
		end

		-- Show this
		tabContent.Visible = true
		indicator.Visible = true
		Util.Tween(tabBtn, {BackgroundTransparency = 0.88}, 0.15)
		if iconLabel then
			Util.Tween(iconLabel, {ImageColor3 = theme:Get().AccentLight}, 0.15)
		else
			Util.Tween(tabBtn, {TextColor3 = theme:Get().AccentLight}, 0.15)
		end
	end

	-- Hover
	tabBtn.MouseEnter:Connect(function()
		if windowRef._currentTab ~= tab then
			Util.Tween(tabBtn, {BackgroundTransparency = 0.9}, 0.15)
		end
	end)
	tabBtn.MouseLeave:Connect(function()
		if windowRef._currentTab ~= tab then
			Util.Tween(tabBtn, {BackgroundTransparency = 0.95}, 0.15)
		end
	end)

	return tab
end


end

-- src/window.lua
do

local Window = {}
Window.__index = Window

function Window.new(config)
	local self = setmetatable({}, Window)
	self._config = config or {}
	self._tabs = {}
	self._currentTab = nil
	self._elements = {}
	self._gui = nil
	self._mainFrame = nil
	return self
end

function Window:Create(theme, notifyRef, configRef, allWindows)
	local cfg = self._config
	local title = cfg.Title or "GlassLib"
	local icon = cfg.Icon or ""
	local author = cfg.Author or ""
	local size = cfg.Size or UDim2.new(0, 440, 0, 540)
	local toggleKey = cfg.ToggleKey or Enum.KeyCode.RightControl
	local themeValues = theme:Get()

	-- ═══ SCREEN GUI ═══
	local gui = Util.Create("ScreenGui", {
		Name = "GlassLib_" .. title,
		DisplayOrder = 100,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		ResetOnSpawn = false,
		Parent = Util.LocalPlayer:WaitForChild("PlayerGui"),
	})
	self._gui = gui

	-- ═══ MAIN FRAME ═══
	local mainFrame = Util.Create("Frame", {
		Size = size,
		Position = UDim2.new(0.5, 0, 0.5, 0),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = themeValues.Background,
		BackgroundTransparency = 0.05,
		BorderSizePixel = 0,
		Parent = gui,
	})
	self._mainFrame = mainFrame

	Util.Create("UICorner", {CornerRadius = UDim.new(0, 15), Parent = mainFrame})
	local mainStroke = Util.Create("UIStroke", {
		Color = Color3.fromRGB(255, 255, 255),
		Transparency = 0.88,
		Thickness = 1,
		Parent = mainFrame,
	})
	self._mainStroke = mainStroke

	-- Shadow
	Acrylic.AddShadow(mainFrame, 50, 0.6)
	-- Top highlight
	Acrylic.AddTopHighlight(mainFrame, 0.92, 0.4)
	-- Glow line
	local glowLine = Acrylic.AddGlowLine(mainFrame, themeValues)
	self._glowLine = glowLine

	-- ═══ HEADER ═══
	local header = Util.Create("Frame", {
		Size = UDim2.new(1, 0, 0, 50),
		BackgroundColor3 = themeValues.Background,
		BackgroundTransparency = 0.05,
		BorderSizePixel = 0,
		Parent = mainFrame,
	})
	Util.Create("UICorner", {CornerRadius = UDim.new(0, 15), Parent = header})
	self._header = header

	-- Header bottom border
	Util.Create("Frame", {
		Size = UDim2.new(1, -32, 0, 1),
		Position = UDim2.new(0, 16, 1, 0),
		AnchorPoint = Vector2.new(0, 1),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 0.9,
		BorderSizePixel = 0,
		Parent = header,
	})

	-- Header icon
	if icon ~= "" then
		Util.Create("ImageLabel", {
			Size = UDim2.new(0, 28, 0, 28),
			Position = UDim2.new(0, 18, 0.5, 0),
			AnchorPoint = Vector2.new(0, 0.5),
			BackgroundTransparency = 1,
			Image = icon,
			Parent = header,
		})
	else
		local headerIcon = Util.Create("Frame", {
			Size = UDim2.new(0, 28, 0, 28),
			Position = UDim2.new(0, 18, 0.5, 0),
			AnchorPoint = Vector2.new(0, 0.5),
			BackgroundColor3 = themeValues.Accent,
			BackgroundTransparency = 0.1,
			BorderSizePixel = 0,
			Parent = header,
		})
		Util.Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = headerIcon})
		Util.Create("TextLabel", {
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamBold,
			Text = string.sub(title, 1, 1),
			TextColor3 = Color3.fromRGB(255, 255, 255),
			TextSize = 14,
			Parent = headerIcon,
		})
	end

	-- Title
	Util.Create("TextLabel", {
		Size = UDim2.new(1, -120, 0, 18),
		Position = UDim2.new(0, 54, 0, 12),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamBold,
		Text = title,
		TextColor3 = themeValues.Text,
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = header,
	})

	if author ~= "" then
		Util.Create("TextLabel", {
			Size = UDim2.new(1, -120, 0, 12),
			Position = UDim2.new(0, 54, 0, 30),
			BackgroundTransparency = 1,
			Font = Enum.Font.Gotham,
			Text = author,
			TextColor3 = themeValues.TextMuted,
			TextSize = 10,
			TextXAlignment = Enum.TextXAlignment.Left,
			Parent = header,
		})
	end

	-- ═══ HEADER BUTTONS ═══
	local btnSize = 28
	local btnGap = 4
	local headerBtns = Util.Create("Frame", {
		Size = UDim2.new(0, (btnSize + btnGap) * 2, 0, btnSize),
		Position = UDim2.new(1, -16, 0.5, 0),
		AnchorPoint = Vector2.new(1, 0.5),
		BackgroundTransparency = 1,
		Parent = header,
	})
	Util.Create("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		HorizontalAlignment = Enum.HorizontalAlignment.Right,
		Padding = UDim.new(0, btnGap),
		Parent = headerBtns,
	})

	-- Minimize button
	local minBtn = Util.Create("TextButton", {
		Size = UDim2.new(0, btnSize, 0, btnSize),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 0.92,
		BorderSizePixel = 0,
		Font = Enum.Font.Gotham,
		Text = "—",
		TextColor3 = themeValues.TextMuted,
		TextSize = 14,
		Parent = headerBtns,
	})
	Util.Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = minBtn})

	-- Close button
	local closeBtn = Util.Create("TextButton", {
		Size = UDim2.new(0, btnSize, 0, btnSize),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 0.92,
		BorderSizePixel = 0,
		Font = Enum.Font.Gotham,
		Text = "✕",
		TextColor3 = themeValues.TextMuted,
		TextSize = 12,
		Parent = headerBtns,
	})
	Util.Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = closeBtn})

	-- Hover
	for _, btn in ipairs({minBtn, closeBtn}) do
		btn.MouseEnter:Connect(function()
			Util.Tween(btn, {BackgroundTransparency = 0.85}, 0.15)
		end)
		btn.MouseLeave:Connect(function()
			Util.Tween(btn, {BackgroundTransparency = 0.92}, 0.15)
		end)
	end

	closeBtn.MouseEnter:Connect(function()
		Util.Tween(closeBtn, {TextColor3 = themeValues.Danger}, 0.15)
	end)
	closeBtn.MouseLeave:Connect(function()
		Util.Tween(closeBtn, {TextColor3 = themeValues.TextMuted}, 0.15)
	end)

	-- ═══ DRAGGING ═══
	local dragging, dragStart, startPos

	header.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = mainFrame.Position
		end
	end)

	header.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)

	Util.UIS.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = input.Position - dragStart
			mainFrame.Position = UDim2.new(
				startPos.X.Scale, startPos.X.Offset + delta.X,
				startPos.Y.Scale, startPos.Y.Offset + delta.Y
			)
		end
	end)

	-- ═══ SIDEBAR ═══
	local sidebarWidth = 54
	local sidebar = Util.Create("Frame", {
		Size = UDim2.new(0, sidebarWidth, 1, -50),
		Position = UDim2.new(0, 0, 0, 50),
		BackgroundColor3 = themeValues.Background,
		BackgroundTransparency = 0.05,
		BorderSizePixel = 0,
		Parent = mainFrame,
	})
	self._sidebar = sidebar

	-- Sidebar right border
	Util.Create("Frame", {
		Size = UDim2.new(0, 1, 1, -20),
		Position = UDim2.new(1, 0, 0, 10),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 0.9,
		BorderSizePixel = 0,
		Parent = sidebar,
	})

	local sidebarLayout = Util.Create("Frame", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		Parent = sidebar,
	})
	Util.Create("UIListLayout", {
		FillDirection = Enum.FillDirection.Vertical,
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		Padding = UDim.new(0, 2),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = sidebarLayout,
	})
	Util.Create("UIPadding", {
		PaddingTop = UDim.new(0, 8),
		Parent = sidebarLayout,
	})
	self._sidebarLayout = sidebarLayout

	-- ═══ CONTENT AREA ═══
	local contentFrame = Util.Create("ScrollingFrame", {
		Size = UDim2.new(1, -sidebarWidth, 1, -50),
		Position = UDim2.new(0, sidebarWidth, 0, 50),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 3,
		ScrollBarImageColor3 = themeValues.Accent,
		ScrollBarImageTransparency = 0.6,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		Parent = mainFrame,
	})
	Util.Create("UIPadding", {
		PaddingTop = UDim.new(0, 12),
		PaddingBottom = UDim.new(0, 12),
		PaddingLeft = UDim.new(0, 12),
		PaddingRight = UDim.new(0, 12),
		Parent = contentFrame,
	})
	Util.Create("UIListLayout", {
		FillDirection = Enum.FillDirection.Vertical,
		Padding = UDim.new(0, 6),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = contentFrame,
	})
	self._contentFrame = contentFrame

	-- ═══ WINDOW METHODS ═══

	function window:Toggle()
		window._guiOpen = not window._guiOpen
		if window._guiOpen then
			mainFrame.Visible = true
			mainFrame.Size = UDim2.new(0, size.X.Offset * 0.9, 0, size.Y.Offset * 0.9)
			mainFrame.BackgroundTransparency = 1
			Util.SpringTween(mainFrame, {
				Size = size,
				BackgroundTransparency = 0.05,
			}, 0.45)
		else
			Util.Tween(mainFrame, {
				Size = UDim2.new(0, size.X.Offset * 0.9, 0, size.Y.Offset * 0.9),
				BackgroundTransparency = 1,
			}, 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
			task.delay(0.3, function()
				mainFrame.Visible = false
			end)
		end
	end

	function window:Open()
		if not window._guiOpen then
			window._guiOpen = true
			mainFrame.Visible = true
			mainFrame.Size = UDim2.new(0, size.X.Offset * 0.9, 0, size.Y.Offset * 0.9)
			mainFrame.BackgroundTransparency = 1
			Util.SpringTween(mainFrame, {
				Size = size,
				BackgroundTransparency = 0.05,
			}, 0.45)
		end
	end

	function window:Close()
		if window._guiOpen then
			window._guiOpen = false
			Util.Tween(mainFrame, {
				Size = UDim2.new(0, size.X.Offset * 0.9, 0, size.Y.Offset * 0.9),
				BackgroundTransparency = 1,
			}, 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
			task.delay(0.3, function()
				mainFrame.Visible = false
			end)
		end
	end

	function window:Destroy()
		gui:Destroy()
	end

	closeBtn.MouseButton1Click:Connect(function()
		window:Close()
	end)

	-- ═══ TAB CREATION ═══
	function window:CreateTab(tabConfig)
		local tab = Tab.new(tabConfig)
		local tabObj = tab:Create(window, theme, sidebarLayout, contentFrame, #self._tabs + 1)
		table.insert(self._tabs, tabObj)

		-- Auto-select first tab
		if #self._tabs == 1 then
			tabObj._content.Visible = true
			tabObj._indicator.Visible = true
			Util.Tween(tabObj._btn, {BackgroundTransparency = 0.88}, 0.15)
			if tabObj._iconLabel then
				Util.Tween(tabObj._iconLabel, {ImageColor3 = themeValues.AccentLight}, 0.15)
			else
				Util.Tween(tabObj._btn, {TextColor3 = themeValues.AccentLight}, 0.15)
			end
			self._currentTab = tabObj
		end

		-- Click handler
		tabObj._btn.MouseButton1Click:Connect(function()
			self._currentTab = tabObj
			tabObj:_Select(self._tabs)
		end)

		return tabObj
	end

	-- ═══ THEME APPLICATION ═══
	function window:_ApplyTheme(newTheme)
		themeValues = newTheme
		mainFrame.BackgroundColor3 = newTheme.Background
		header.BackgroundColor3 = newTheme.Background
		sidebar.BackgroundColor3 = newTheme.Background
		mainStroke.Color = Color3.fromRGB(255, 255, 255)
		glowLine.BackgroundColor3 = newTheme.Accent

		-- Update accent gradient on all gradient elements
		for _, desc in ipairs(mainFrame:GetDescendants()) do
			if desc:IsA("UIGradient") and desc.Parent then
				local parent = desc.Parent
				if parent.Name ~= "HueBar" and (parent.BackgroundColor3 == newTheme.Accent or parent.Name == "TrackFill") then
					desc.Color = ColorSequence.new({
						ColorSequenceKeypoint.new(0, newTheme.Accent),
						ColorSequenceKeypoint.new(1, newTheme.AccentLight),
					})
				end
			end
		end
	end

	-- ═══ INTRO ANIMATION ═══
	if cfg.IntroEnabled ~= false then
		mainFrame.Size = UDim2.new(0, size.X.Offset * 0.85, 0, size.Y.Offset * 0.85)
		mainFrame.BackgroundTransparency = 1
		for _, child in ipairs(mainFrame:GetDescendants()) do
			if child:IsA("GuiObject") then
				child.BackgroundTransparency = 1
			elseif child:IsA("TextLabel") or child:IsA("TextButton") then
				child.TextTransparency = 1
			end
		end

		task.delay(0.1, function()
			Util.SpringTween(mainFrame, {
				Size = size,
				BackgroundTransparency = 0.05,
			}, 0.6)

			task.delay(0.15, function()
				for _, child in ipairs(mainFrame:GetDescendants()) do
					if child:IsA("GuiObject") and child.BackgroundTransparency == 1 then
						Util.Tween(child, {BackgroundTransparency = child:GetAttribute("OrigTransparency") or 0.6}, 0.4)
					elseif (child:IsA("TextLabel") or child:IsA("TextButton")) and child.TextTransparency == 1 then
						Util.Tween(child, {TextTransparency = 0}, 0.4)
					end
				end
			end)
		end)
	end

	-- ═══ TOGGLE KEY ═══
	Util.UIS.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then return end
		if input.KeyCode == toggleKey then
			window:Toggle()
		end
	end)

	return window
end


end


-- ══════════════════════════════════════════════════════════════
-- ENTRY POINT
-- ══════════════════════════════════════════════════════════════
local GlassLib = {}
GlassLib.__index = GlassLib

-- ══════════════════════════════════════════════════════════════
-- MODULES
-- ══════════════════════════════════════════════════════════════


-- ══════════════════════════════════════════════════════════════
-- CONSTRUCTOR
-- ══════════════════════════════════════════════════════════════

function GlassLib.new(configFolder)
	local self = setmetatable({}, GlassLib)
	
	configFolder = configFolder or "GlassLib"
	
	-- Initialize modules
	self._theme = Theme.new(configFolder)
	self._notify = Notify.new(self._theme)
	self._config = Config.new(configFolder)
	self._dialog = Dialog.new(self._theme)
	self._windows = {}
	
	return self
end

-- ══════════════════════════════════════════════════════════════
-- PUBLIC API
-- ══════════════════════════════════════════════════════════════

function GlassLib:CreateWindow(config)
	local window = Window.new(config)
	local windowObj = window:Create(self._theme, self._notify, self._config, self._windows)
	table.insert(self._windows, windowObj)
	return windowObj
end

function GlassLib:Notify(config)
	self._notify:Show(config)
end

function GlassLib:SetTheme(themeName)
	self._theme:Set(themeName)
end

function GlassLib:GetTheme()
	return self._theme:Get()
end

function GlassLib:GetThemeName()
	return self._theme:GetName()
end

function GlassLib:GetThemes()
	return self._theme:GetPresets()
end

function GlassLib:SetToggleKey(keycode)
	-- Updated per-window
end

function GlassLib:CreateToggleBtn(config)
	local toggle = ToggleBtn.new(self._theme, self)
	toggle:Create(config)
	return toggle
end

function GlassLib:SaveConfig(name)
	return self._config:Save(name)
end

function GlassLib:LoadConfig(name)
	return self._config:Load(name)
end

function GlassLib:GetFlag(flag)
	return self._config:GetFlag(flag)
end

function GlassLib:SetFlag(flag, value)
	self._config:SetFlag(flag, value)
end

function GlassLib:Dialog(config)
	return self._dialog:Show(config)
end

function GlassLib:OnThemeChanged(callback)
	self._theme:OnChanged(callback)
end

-- ══════════════════════════════════════════════════════════════
-- RETURN
-- ══════════════════════════════════════════════════════════════

return GlassLib.new()
