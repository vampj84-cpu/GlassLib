--[[
    GlassLib - Toggle Element
]]

local Util = require(script.Parent.Parent.util)

local Toggle = {}
Toggle.__index = Toggle

function Toggle.new(config)
	local self = setmetatable({}, Toggle)
	self._config = config or {}
	self._state = false
	self._frame = nil
	self._track = nil
	self._knob = nil
	return self
end

function Toggle:Create(parent, theme, order)
	local cfg = self._config
	local title = cfg.Title or "Toggle"
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

function Toggle:Get()
	return self._state
end

function Toggle:Set(value)
	if self._state ~= value then
		self._updateToggle(true)
	end
end

return Toggle
