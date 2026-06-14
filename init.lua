--[[
    GlassLib v2.0.0
    Liquid Glass UI Library for Roblox Exploits
    
    Modular architecture inspired by MacLib
    
    Usage:
        local GlassLib = loadstring(game:HttpGet("URL"))()
        local Window = GlassLib:CreateWindow({Title = "My Hub", Icon = "..."})
        local Tab = Window:CreateTab({Name = "Main", Icon = "rbxassetid://123"})
        local Section = Tab:CreateSection({Name = "Section"})
        Section:CreateButton({Title = "Click", Callback = function() print("Hi") end})
--]]

local GlassLib = {}
GlassLib.__index = GlassLib

-- ══════════════════════════════════════════════════════════════
-- MODULES
-- ══════════════════════════════════════════════════════════════

local Util = require(script:WaitForChild("util"))
local Theme = require(script:WaitForChild("theme"))
local Acrylic = require(script:WaitForChild("acrylic"))
local Notify = require(script:WaitForChild("notify"))
local Config = require(script:WaitForChild("config"))
local Dialog = require(script:WaitForChild("dialog"))
local ToggleBtn = require(script:WaitForChild("toggle"))
local Window = require(script:WaitForChild("window"))

-- ══════════════════════════════════════════════════════════════
-- CONSTRUCTOR
-- ══════════════════════════════════════════════════════════════

function GlassLib.new(configFolder)
	local self = setmetatable({}, GlassLib)
	
	configFolder = configFolder or "GlassLib"
	
	-- Initialize modules
	self._theme = Theme.new(configFolder)
	self._notify = Notify.new(self._theme)
	self._config = Config.new(configFolder)
	self._dialog = Dialog.new(self._theme)
	self._windows = {}
	
	return self
end

-- ══════════════════════════════════════════════════════════════
-- PUBLIC API
-- ══════════════════════════════════════════════════════════════

function GlassLib:CreateWindow(config)
	local window = Window.new(config)
	local windowObj = window:Create(self._theme, self._notify, self._config, self._windows)
	table.insert(self._windows, windowObj)
	return windowObj
end

function GlassLib:Notify(config)
	self._notify:Show(config)
end

function GlassLib:SetTheme(themeName)
	self._theme:Set(themeName)
end

function GlassLib:GetTheme()
	return self._theme:Get()
end

function GlassLib:GetThemeName()
	return self._theme:GetName()
end

function GlassLib:GetThemes()
	return self._theme:GetPresets()
end

function GlassLib:SetToggleKey(keycode)
	-- Updated per-window
end

function GlassLib:CreateToggleBtn(config)
	local toggle = ToggleBtn.new(self._theme, self)
	toggle:Create(config)
	return toggle
end

function GlassLib:SaveConfig(name)
	return self._config:Save(name)
end

function GlassLib:LoadConfig(name)
	return self._config:Load(name)
end

function GlassLib:GetFlag(flag)
	return self._config:GetFlag(flag)
end

function GlassLib:SetFlag(flag, value)
	self._config:SetFlag(flag, value)
end

function GlassLib:Dialog(config)
	return self._dialog:Show(config)
end

function GlassLib:OnThemeChanged(callback)
	self._theme:OnChanged(callback)
end

-- ══════════════════════════════════════════════════════════════
-- RETURN
-- ══════════════════════════════════════════════════════════════

return GlassLib.new()
