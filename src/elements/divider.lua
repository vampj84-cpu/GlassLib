--[[
    GlassLib - Divider Element
    Frosted glass divider line
]]

local Util = require(script.Parent.Parent.util)

local Divider = {}
Divider.__index = Divider

function Divider.new(config)
	local self = setmetatable({}, Divider)
	self._config = config or {}
	self._frame = nil
	return self
end

function Divider:Create(parent, theme, order)
	local tv = theme:Get()
	local divider = Util.Create("Frame", {
		Size = UDim2.new(1, 0, 0, 1),
		BackgroundColor3 = tv.GlassStroke,
		BackgroundTransparency = 0.5,
		BorderSizePixel = 0,
		LayoutOrder = order or 0,
		Parent = parent,
	})
	self._frame = divider
	return divider
end

return Divider
