--[[
    GlassLib - Paragraph Element
    Glass card with title + body
]]

local Util = require(script.Parent.Parent.util)

local Paragraph = {}
Paragraph.__index = Paragraph

function Paragraph.new(config)
	local self = setmetatable({}, Paragraph)
	self._config = config or {}
	self._frame = nil
	return self
end

function Paragraph:Create(parent, theme, order)
	local cfg = self._config
	local title = cfg.Title or ""
	local body = cfg.Body or cfg.Content or ""
	local tv = theme:Get()

	local height = 36
	if title ~= "" then height = height + 18 end
	if body ~= "" then
		local estimatedLines = math.ceil(#body / 48)
		height = height + (estimatedLines * 14) + 6
	end

	local row = Util.Create("Frame", {
		Size = UDim2.new(1, 0, 0, height),
		BackgroundColor3 = tv.GlassTint,
		BackgroundTransparency = 0.4,
		BorderSizePixel = 0,
		LayoutOrder = order or 0,
		Parent = parent,
	})
	Util.Create("UICorner", {CornerRadius = UDim.new(0, 14), Parent = row})
	Util.Create("UIStroke", {
		Color = tv.GlassStroke,
		Transparency = 0.5,
		Thickness = 1,
		Parent = row,
	})
	Util.Create("UIPadding", {
		PaddingLeft = UDim.new(0, 14),
		PaddingRight = UDim.new(0, 14),
		PaddingTop = UDim.new(0, 10),
		PaddingBottom = UDim.new(0, 10),
		Parent = row,
	})

	if title ~= "" then
		Util.Create("TextLabel", {
			Size = UDim2.new(1, 0, 0, 16),
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamBold,
			Text = title,
			TextColor3 = tv.Text,
			TextSize = 13,
			TextXAlignment = Enum.TextXAlignment.Left,
			Parent = row,
		})
	end

	if body ~= "" then
		Util.Create("TextLabel", {
			Size = UDim2.new(1, 0, 0, 0),
			Position = UDim2.new(0, 0, 0, title ~= "" and 22 or 0),
			BackgroundTransparency = 1,
			Font = Enum.Font.Gotham,
			Text = body,
			TextColor3 = tv.TextSecondary,
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

return Paragraph
