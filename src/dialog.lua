--[[
    GlassLib - Dialog Module
    Modal dialogs and confirmation prompts
]]

local Util = require(script.Parent.util)

local Dialog = {}
Dialog.__index = Dialog

function Dialog.new(theme, config)
	local self = setmetatable({}, Dialog)
	self._theme = theme
	self._config = config or {}
	self._gui = nil
	return self
end

-- ══════════════════════════════════════════════════════════════
-- SHOW DIALOG
-- ══════════════════════════════════════════════════════════════

function Dialog:Show(config)
	config = config or {}
	local title = config.Title or "Dialog"
	local content = config.Content or ""
	local confirmText = config.ConfirmText or "Confirm"
	local cancelText = config.CancelText or "Cancel"
	local onConfirm = config.OnConfirm or function() end
	local onCancel = config.OnCancel or function() end
	local theme = self._theme:Get()

	-- ScreenGui
	local gui = Util.Create("ScreenGui", {
		Name = "GlassLibDialog",
		DisplayOrder = 200,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		ResetOnSpawn = false,
		Parent = Util.LocalPlayer:WaitForChild("PlayerGui"),
	})
	self._gui = gui

	-- Backdrop
	local backdrop = Util.Create("Frame", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundColor3 = Color3.fromRGB(0, 0, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Parent = gui,
	})

	Util.Tween(backdrop, {BackgroundTransparency = 0.5}, 0.25)

	-- Dialog frame
	local dialog = Util.Create("Frame", {
		Size = UDim2.new(0, 340, 0, 0),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = theme.Surface,
		BackgroundTransparency = 0.05,
		BorderSizePixel = 0,
		Parent = backdrop,
	})
	Util.Create("UICorner", {CornerRadius = UDim.new(0, 16), Parent = dialog})
	Util.Create("UIStroke", {
		Color = Color3.fromRGB(255, 255, 255),
		Transparency = 0.85,
		Thickness = 1,
		Parent = dialog,
	})

	-- Title
	Util.Create("TextLabel", {
		Size = UDim2.new(1, -40, 0, 24),
		Position = UDim2.new(0, 20, 0, 20),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamBold,
		Text = title,
		TextColor3 = theme.Text,
		TextSize = 16,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = dialog,
	})

	-- Content
	local contentLabel = Util.Create("TextLabel", {
		Size = UDim2.new(1, -40, 0, 0),
		Position = UDim2.new(0, 20, 0, 50),
		BackgroundTransparency = 1,
		Font = Enum.Font.Gotham,
		Text = content,
		TextColor3 = theme.TextSecondary,
		TextSize = 13,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		AutomaticSize = Enum.AutomaticSize.Y,
		Parent = dialog,
	})

	-- Buttons
	local btnHolder = Util.Create("Frame", {
		Size = UDim2.new(1, -40, 0, 36),
		Position = UDim2.new(0, 20, 1, -56),
		BackgroundTransparency = 1,
		Parent = dialog,
	})
	Util.Create("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		HorizontalAlignment = Enum.HorizontalAlignment.Right,
		Padding = UDim.new(0, 8),
		Parent = btnHolder,
	})

	-- Cancel button
	local cancelBtn = Util.Create("TextButton", {
		Size = UDim2.new(0, 80, 0, 36),
		BackgroundColor3 = theme.SurfaceLight,
		BackgroundTransparency = 0.3,
		BorderSizePixel = 0,
		AutoButtonColor = false,
		Font = Enum.Font.GothamMedium,
		Text = cancelText,
		TextColor3 = theme.TextSecondary,
		TextSize = 13,
		Parent = btnHolder,
	})
	Util.Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = cancelBtn})

	-- Confirm button
	local confirmBtn = Util.Create("TextButton", {
		Size = UDim2.new(0, 80, 0, 36),
		BackgroundColor3 = theme.Accent,
		BackgroundTransparency = 0,
		BorderSizePixel = 0,
		AutoButtonColor = false,
		Font = Enum.Font.GothamMedium,
		Text = confirmText,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextSize = 13,
		Parent = btnHolder,
	})
	Util.Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = confirmBtn})
	Util.MakeAccentGradient(confirmBtn, theme)

	-- Interactions
	cancelBtn.MouseButton1Click:Connect(function()
		onCancel()
		gui:Destroy()
	end)

	confirmBtn.MouseButton1Click:Connect(function()
		onConfirm()
		gui:Destroy()
	end)

	backdrop.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			onCancel()
			gui:Destroy()
		end
	end)

	-- Animate in
	local dialogHeight = 50 + math.max(contentLabel.TextBounds.Y, 20) + 80
	Util.SpringTween(dialog, {
		Size = UDim2.new(0, 340, 0, dialogHeight),
	}, 0.4)

	Util.AddHover(cancelBtn, 0.3, 0.15)
	Util.AddHover(confirmBtn, 0, 0.1)

	return gui
end

function Dialog:Destroy()
	if self._gui then
		self._gui:Destroy()
	end
end

return Dialog
