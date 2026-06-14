--[[
    GlassLib - Window Module
    Window creation, dragging, sidebar, header, content area
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

return Window
