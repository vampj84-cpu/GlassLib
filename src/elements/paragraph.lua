--[[
    GlassLib - Paragraph Element
    Rich text paragraph with title and body
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

return Paragraph
