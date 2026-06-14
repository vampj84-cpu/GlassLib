--[[
    GlassLib - Section Module
    Section containers that hold elements
]]

local Util = require(script.Parent.util)
local Elements = require(script.Parent.elements)

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

return Section
