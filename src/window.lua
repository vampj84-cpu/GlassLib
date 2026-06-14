--[[
    GlassLib - Window Module
    Liquid glass window with layered depth
]]

local Util = require(script.Parent.util)
local Acrylic = require(script.Parent.acrylic)
local Tab = require(script.Parent.tab)

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
	local size = cfg.Size or UDim2.new(0, 500, 0, 560)
	local toggleKey = cfg.ToggleKey or Enum.KeyCode.RightControl
	local tv = theme:Get()

	-- ═══ SCREEN GUI ═══
	local gui = Util.Create("ScreenGui", {
		Name = "GlassLib_" .. title,
		DisplayOrder = 100,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		ResetOnSpawn = false,
		Parent = Util.LocalPlayer:WaitForChild("PlayerGui"),
	})
	self._gui = gui

	-- ═══ BACKDROP (darkened scene) ═══
	local backdrop = Util.Create("Frame", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundColor3 = Color3.fromRGB(0, 0, 0),
		BackgroundTransparency = 0.55,
		BorderSizePixel = 0,
		Parent = gui,
	})

	-- ═══ MAIN GLASS PANEL ═══
	local mainFrame = Util.Create("Frame", {
		Size = size,
		Position = UDim2.new(0.5, 0, 0.5, 0),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = tv.GlassTint,
		BackgroundTransparency = 0.4,
		BorderSizePixel = 0,
		Parent = gui,
	})
	self._mainFrame = mainFrame
	Util.Create("UICorner", {CornerRadius = UDim.new(0, 20), Parent = mainFrame})

	-- Glass border (bright, frosted)
	local mainStroke = Util.Create("UIStroke", {
		Color = tv.GlassStroke,
		Transparency = 0.3,
		Thickness = 1.5,
		Parent = mainFrame,
	})
	self._mainStroke = mainStroke

	-- Inner glass gradient (top light, bottom darker)
	local glassGradient = Util.Create("Frame", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 0.88,
		BorderSizePixel = 0,
		Parent = mainFrame,
	})
	Util.Create("UICorner", {CornerRadius = UDim.new(0, 20), Parent = glassGradient})
	Util.Create("UIGradient", {
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.5),
			NumberSequenceKeypoint.new(0.5, 0.85),
			NumberSequenceKeypoint.new(1, 0.7),
		}),
		Rotation = 90,
		Parent = glassGradient,
	})

	-- Shadow
	Acrylic.AddShadow(mainFrame, 60, 0.5)

	-- ═══ HEADER ═══
	local header = Util.Create("Frame", {
		Size = UDim2.new(1, 0, 0, 56),
		BackgroundColor3 = tv.GlassTint,
		BackgroundTransparency = 0.35,
		BorderSizePixel = 0,
		Parent = mainFrame,
	})
	Util.Create("UICorner", {CornerRadius = UDim.new(0, 20), Parent = header})
	-- Square off bottom corners
	Util.Create("Frame", {
		Size = UDim2.new(1, 0, 0, 20),
		Position = UDim2.new(0, 0, 1, -20),
		BackgroundColor3 = tv.GlassTint,
		BackgroundTransparency = 0.35,
		BorderSizePixel = 0,
		Parent = header,
	})
	self._header = header

	-- Header bottom separator (glass edge)
	Util.Create("Frame", {
		Size = UDim2.new(1, 0, 0, 1),
		Position = UDim2.new(0, 0, 1, 0),
		AnchorPoint = Vector2.new(0, 1),
		BackgroundColor3 = tv.GlassStroke,
		BackgroundTransparency = 0.5,
		BorderSizePixel = 0,
		Parent = header,
	})

	-- Header icon
	local iconSize = 32
	if icon ~= "" then
		Util.Create("ImageLabel", {
			Size = UDim2.new(0, iconSize, 0, iconSize),
			Position = UDim2.new(0, 20, 0.5, 0),
			AnchorPoint = Vector2.new(0, 0.5),
			BackgroundTransparency = 1,
			Image = icon,
			Parent = header,
		})
	else
		local headerIcon = Util.Create("Frame", {
			Size = UDim2.new(0, iconSize, 0, iconSize),
			Position = UDim2.new(0, 20, 0.5, 0),
			AnchorPoint = Vector2.new(0, 0.5),
			BackgroundColor3 = tv.Accent,
			BackgroundTransparency = 0.15,
			BorderSizePixel = 0,
			Parent = header,
		})
		Util.Create("UICorner", {CornerRadius = UDim.new(0, 10), Parent = headerIcon})
		Util.Create("TextLabel", {
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamBold,
			Text = string.sub(title, 1, 1),
			TextColor3 = Color3.fromRGB(255, 255, 255),
			TextSize = 15,
			Parent = headerIcon,
		})
	end

	-- Title + author
	local titleX = 20 + iconSize + 12
	Util.Create("TextLabel", {
		Size = UDim2.new(1, -160, 0, 20),
		Position = UDim2.new(0, titleX, 0, 13),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamBold,
		Text = title,
		TextColor3 = tv.Text,
		TextSize = 15,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = header,
	})

	if author ~= "" then
		Util.Create("TextLabel", {
			Size = UDim2.new(1, -160, 0, 14),
			Position = UDim2.new(0, titleX, 0, 33),
			BackgroundTransparency = 1,
			Font = Enum.Font.Gotham,
			Text = author,
			TextColor3 = tv.TextMuted,
			TextSize = 11,
			TextXAlignment = Enum.TextXAlignment.Left,
			Parent = header,
		})
	end

	-- Header buttons
	local btnSize = 30
	local btnGap = 6
	local headerBtns = Util.Create("Frame", {
		Size = UDim2.new(0, (btnSize + btnGap) * 2, 0, btnSize),
		Position = UDim2.new(1, -18, 0.5, 0),
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

	-- Minimize
	local minBtn = Util.Create("TextButton", {
		Size = UDim2.new(0, btnSize, 0, btnSize),
		BackgroundColor3 = tv.GlassTint,
		BackgroundTransparency = 0.6,
		BorderSizePixel = 0,
		Font = Enum.Font.GothamBold,
		Text = "—",
		TextColor3 = tv.TextSecondary,
		TextSize = 16,
		AutoButtonColor = false,
		Parent = headerBtns,
	})
	Util.Create("UICorner", {CornerRadius = UDim.new(0, 10), Parent = minBtn})

	-- Close
	local closeBtn = Util.Create("TextButton", {
		Size = UDim2.new(0, btnSize, 0, btnSize),
		BackgroundColor3 = tv.GlassTint,
		BackgroundTransparency = 0.6,
		BorderSizePixel = 0,
		Font = Enum.Font.GothamBold,
		Text = "✕",
		TextColor3 = tv.TextSecondary,
		TextSize = 13,
		AutoButtonColor = false,
		Parent = headerBtns,
	})
	Util.Create("UICorner", {CornerRadius = UDim.new(0, 10), Parent = closeBtn})

	-- Header button hovers
	for _, btn in ipairs({minBtn, closeBtn}) do
		btn.MouseEnter:Connect(function()
			Util.Tween(btn, {BackgroundTransparency = 0.35}, 0.15)
		end)
		btn.MouseLeave:Connect(function()
			Util.Tween(btn, {BackgroundTransparency = 0.6}, 0.15)
		end)
	end
	closeBtn.MouseEnter:Connect(function()
		Util.Tween(closeBtn, {TextColor3 = tv.Danger}, 0.15)
	end)
	closeBtn.MouseLeave:Connect(function()
		Util.Tween(closeBtn, {TextColor3 = tv.TextSecondary}, 0.15)
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

	-- ═══ SIDEBAR (floating dock style) ═══
	local sidebarWidth = 56
	local sidebarPad = 6
	local sidebar = Util.Create("Frame", {
		Size = UDim2.new(0, sidebarWidth, 1, -72),
		Position = UDim2.new(0, sidebarPad, 0, 60),
		BackgroundColor3 = tv.GlassTint,
		BackgroundTransparency = 0.3,
		BorderSizePixel = 0,
		Parent = mainFrame,
	})
	Util.Create("UICorner", {CornerRadius = UDim.new(0, 14), Parent = sidebar})
	Util.Create("UIStroke", {
		Color = tv.GlassStroke,
		Transparency = 0.4,
		Thickness = 1,
		Parent = sidebar,
	})
	self._sidebar = sidebar

	local sidebarLayout = Util.Create("Frame", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		Parent = sidebar,
	})
	Util.Create("UIListLayout", {
		FillDirection = Enum.FillDirection.Vertical,
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		Padding = UDim.new(0, 4),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = sidebarLayout,
	})
	Util.Create("UIPadding", {
		PaddingTop = UDim.new(0, 8),
		PaddingBottom = UDim.new(0, 8),
		Parent = sidebarLayout,
	})
	self._sidebarLayout = sidebarLayout

	-- ═══ CONTENT AREA ═══
	local contentLeft = sidebarWidth + sidebarPad * 2 + 8
	local contentFrame = Util.Create("ScrollingFrame", {
		Size = UDim2.new(1, -contentLeft - 14, 1, -72),
		Position = UDim2.new(0, contentLeft, 0, 60),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 3,
		ScrollBarImageColor3 = tv.Accent,
		ScrollBarImageTransparency = 0.5,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		Parent = mainFrame,
	})
	Util.Create("UIPadding", {
		PaddingTop = UDim.new(0, 10),
		PaddingBottom = UDim.new(0, 10),
		PaddingLeft = UDim.new(0, 10),
		PaddingRight = UDim.new(0, 10),
		Parent = contentFrame,
	})
	Util.Create("UIListLayout", {
		FillDirection = Enum.FillDirection.Vertical,
		Padding = UDim.new(0, 5),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = contentFrame,
	})
	self._contentFrame = contentFrame

	-- ═══ WINDOW METHODS ═══

	function window:Toggle()
		window._guiOpen = not window._guiOpen
		if window._guiOpen then
			mainFrame.Visible = true
			backdrop.Visible = true
			mainFrame.Size = UDim2.new(0, size.X.Offset * 0.92, 0, size.Y.Offset * 0.92)
			mainFrame.BackgroundTransparency = 0.8
			backdrop.BackgroundTransparency = 1
			Util.SpringTween(mainFrame, {Size = size, BackgroundTransparency = 0.4}, 0.5)
			Util.Tween(backdrop, {BackgroundTransparency = 0.55}, 0.3)
		else
			Util.Tween(mainFrame, {BackgroundTransparency = 0.8}, 0.2)
			Util.Tween(backdrop, {BackgroundTransparency = 1}, 0.2)
			task.delay(0.2, function()
				mainFrame.Visible = false
				backdrop.Visible = false
			end)
		end
	end

	function window:Open()
		if not window._guiOpen then
			window._guiOpen = true
			mainFrame.Visible = true
			backdrop.Visible = true
			mainFrame.BackgroundTransparency = 0.8
			backdrop.BackgroundTransparency = 1
			Util.SpringTween(mainFrame, {Size = size, BackgroundTransparency = 0.4}, 0.5)
			Util.Tween(backdrop, {BackgroundTransparency = 0.55}, 0.3)
		end
	end

	function window:Close()
		if window._guiOpen then
			window._guiOpen = false
			Util.Tween(mainFrame, {BackgroundTransparency = 0.8}, 0.2)
			Util.Tween(backdrop, {BackgroundTransparency = 1}, 0.2)
			task.delay(0.2, function()
				mainFrame.Visible = false
				backdrop.Visible = false
			end)
		end
	end

	function window:Destroy()
		gui:Destroy()
	end

	closeBtn.MouseButton1Click:Connect(function() window:Close() end)

	-- ═══ TAB CREATION ═══
	function window:CreateTab(tabConfig)
		local tab = Tab.new(tabConfig)
		local tabObj = tab:Create(window, theme, sidebarLayout, contentFrame, #self._tabs + 1)
		table.insert(self._tabs, tabObj)

		if #self._tabs == 1 then
			tabObj._content.Visible = true
			tabObj._indicator.Visible = true
			Util.Tween(tabObj._btn, {BackgroundTransparency = 0.2}, 0.15)
			if tabObj._iconLabel then
				Util.Tween(tabObj._iconLabel, {ImageColor3 = tv.AccentLight}, 0.15)
			else
				Util.Tween(tabObj._btn, {TextColor3 = tv.AccentLight}, 0.15)
			end
			self._currentTab = tabObj
		end

		tabObj._btn.MouseButton1Click:Connect(function()
			self._currentTab = tabObj
			tabObj:_Select(self._tabs)
		end)

		return tabObj
	end

	-- ═══ THEME APPLICATION ═══
	function window:_ApplyTheme(newTheme)
		tv = newTheme
		mainFrame.BackgroundColor3 = newTheme.GlassTint
		header.BackgroundColor3 = newTheme.GlassTint
		sidebar.BackgroundColor3 = newTheme.GlassTint
		mainStroke.Color = newTheme.GlassStroke
	end

	-- ═══ INTRO ANIMATION ═══
	if cfg.IntroEnabled ~= false then
		mainFrame.Size = UDim2.new(0, size.X.Offset * 0.88, 0, size.Y.Offset * 0.88)
		mainFrame.BackgroundTransparency = 1
		backdrop.BackgroundTransparency = 1
		for _, child in ipairs(mainFrame:GetDescendants()) do
			if child:IsA("GuiObject") then
				child.BackgroundTransparency = 1
			elseif child:IsA("TextLabel") or child:IsA("TextButton") then
				child.TextTransparency = 1
			end
		end
		task.delay(0.1, function()
			Util.SpringTween(mainFrame, {Size = size, BackgroundTransparency = 0.4}, 0.65)
			Util.Tween(backdrop, {BackgroundTransparency = 0.55}, 0.4)
			task.delay(0.15, function()
				for _, child in ipairs(mainFrame:GetDescendants()) do
					if child:IsA("GuiObject") and child.BackgroundTransparency == 1 then
						Util.Tween(child, {BackgroundTransparency = child:GetAttribute("OrigTransparency") or 0.3}, 0.4)
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

return Window
