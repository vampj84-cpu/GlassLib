--[[
    GlassLib - Label Element
]]

local Util = require(script.Parent.Parent.util)

local Label = {}
Label.__index = Label

function Label.new(config)
	local self = setmetatable({}, Label)
	self._config = config or {}
	self._frame = nil
	return self
end

function Label:Create(parent, theme, order)
	local cfg = self._config
	local title = cfg.Title or "Label"
	local desc = cfg.Desc or ""
	local hasDesc = desc ~= ""
	local tv = theme:Get()
	local height = hasDesc and 42 or 30

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
		TextColor3 = tv.Text,
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = row,
	})

	if hasDesc then
		Util.Create("TextLabel", {
			Size = UDim2.new(1, 4, 0, 14),
			Position = UDim2.new(0, 4, 0, 20),
			BackgroundTransparency = 1,
			Font = Enum.Font.Gotham,
			Text = desc,
			TextColor3 = tv.TextMuted,
			TextSize = 11,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextWrapped = true,
			Parent = row,
		})
	end

	self._frame = row
	return row
end

return Label
