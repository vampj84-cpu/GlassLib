--[[
    GlassLib - Toggle Element
    Glass pill toggle with liquid knob
]]

local Util = require(script.Parent.Parent.util)

local Toggle = {}
Toggle.__index = Toggle

function Toggle.new(config)
	local self = setmetatable({}, Toggle)
	self._config = config or {}
	self._state = false
	self._frame = nil
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
		Size = UDim2.new(1, -58, 0, 16),
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
			Size = UDim2.new(1, -58, 0, 12),
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

	-- Track (glass style)
	local track = Util.Create("Frame", {
		Size = UDim2.new(0, 44, 0, 24),
		Position = UDim2.new(1, 0, 0.5, 0),
		AnchorPoint = Vector2.new(1, 0.5),
		BackgroundColor3 = self._state and tv.Accent or tv.GlassTint,
		BackgroundTransparency = self._state and 0.1 or 0.3,
		BorderSizePixel = 0,
		Parent = row,
	})
	Util.Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = track})
	Util.Create("UIStroke", {
		Color = self._state and tv.Accent or tv.GlassStroke,
		Transparency = self._state and 0.3 or 0.5,
		Thickness = 1.5,
		Parent = track,
	})

	-- Knob
	local knob = Util.Create("Frame", {
		Size = UDim2.new(0, 18, 0, 18),
		Position = self._state and UDim2.new(1, -22, 0.5, 0) or UDim2.new(0, 3, 0.5, 0),
		AnchorPoint = self._state and Vector2.new(1, 0.5) or Vector2.new(0, 0.5),
		BackgroundColor3 = self._state and Color3.fromRGB(255, 255, 255) or tv.TextMuted,
		BorderSizePixel = 0,
		Parent = track,
	})
	Util.Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = knob})

	local function updateToggle(anim)
		self._state = not self._state
		if anim then
			Util.SpringTween(knob, {
				Position = self._state and UDim2.new(1, -22, 0.5, 0) or UDim2.new(0, 3, 0.5, 0),
				AnchorPoint = self._state and Vector2.new(1, 0.5) or Vector2.new(0, 0.5),
				BackgroundColor3 = self._state and Color3.fromRGB(255, 255, 255) or tv.TextMuted,
			}, 0.35)
			Util.Tween(track, {
				BackgroundColor3 = self._state and tv.Accent or tv.GlassTint,
				BackgroundTransparency = self._state and 0.1 or 0.3,
			}, 0.25)
			local stroke = track:FindFirstChildOfClass("UIStroke")
			if stroke then
				Util.Tween(stroke, {
					Color = self._state and tv.Accent or tv.GlassStroke,
					Transparency = self._state and 0.3 or 0.5,
				}, 0.25)
			end
		else
			knob.Position = self._state and UDim2.new(1, -22, 0.5, 0) or UDim2.new(0, 3, 0.5, 0)
			knob.AnchorPoint = self._state and Vector2.new(1, 0.5) or Vector2.new(0, 0.5)
			knob.BackgroundColor3 = self._state and Color3.fromRGB(255, 255, 255) or tv.TextMuted
			track.BackgroundColor3 = self._state and tv.Accent or tv.GlassTint
		end
		callback(self._state)
	end

	track.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then updateToggle(true) end
	end)
	knob.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then updateToggle(true) end
	end)

	Util.AddHover(row, 0.35, 0.2)

	self._frame = row
	self._updateToggle = updateToggle
	return row
end

function Toggle:Get() return self._state end

function Toggle:Set(value)
	if self._state ~= value then self._updateToggle(true) end
end

return Toggle
