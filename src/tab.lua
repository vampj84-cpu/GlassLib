--[[
    GlassLib - Tab Module
    Tab system with sidebar buttons and content areas
]]

local Util = require(script.Parent.util)
local Section = require(script.Parent.section)

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

	-- ═══ SIDEBAR BUTTON (glass pill) ═══
	local tabBtn = Util.Create("TextButton", {
		Size = UDim2.new(0, 40, 0, 40),
		BackgroundColor3 = theme:Get().GlassTint,
		BackgroundTransparency = tabIcon == "" and 0.5 or 1,
		BorderSizePixel = 0,
		AutoButtonColor = false,
		Font = Enum.Font.GothamBold,
		Text = tabIcon == "" and string.sub(tabName, 1, 1) or "",
		TextColor3 = theme:Get().TextMuted,
		TextSize = 15,
		LayoutOrder = order,
		Parent = sidebarLayout,
	})
	Util.Create("UICorner", {CornerRadius = UDim.new(0, 12), Parent = tabBtn})

	local iconLabel = nil
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
			Util.Tween(t._btn, {BackgroundTransparency = 0.5}, 0.15)
			if t._iconLabel then
				Util.Tween(t._iconLabel, {ImageColor3 = theme:Get().TextMuted}, 0.15)
			else
				Util.Tween(t._btn, {TextColor3 = theme:Get().TextMuted}, 0.15)
			end
		end

		-- Show this
		tabContent.Visible = true
		indicator.Visible = true
		Util.Tween(tabBtn, {BackgroundTransparency = 0.15}, 0.15)
		if iconLabel then
			Util.Tween(iconLabel, {ImageColor3 = theme:Get().AccentLight}, 0.15)
		else
			Util.Tween(tabBtn, {TextColor3 = theme:Get().AccentLight}, 0.15)
		end
	end

	-- Hover
	tabBtn.MouseEnter:Connect(function()
		if windowRef._currentTab ~= tab then
			Util.Tween(tabBtn, {BackgroundTransparency = 0.3}, 0.15)
		end
	end)
	tabBtn.MouseLeave:Connect(function()
		if windowRef._currentTab ~= tab then
			Util.Tween(tabBtn, {BackgroundTransparency = 0.5}, 0.15)
		end
	end)

	return tab
end

return Tab
