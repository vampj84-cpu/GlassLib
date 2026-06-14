--[[
    GlassLib - Theme Module
    Liquid glass themes with depth
]]

local Util = require(script.Parent.util)

local Theme = {}
Theme.__index = Theme

Theme.Presets = {
	Glass = {
		Accent = Color3.fromHex("#7c6bf0"),
		AccentLight = Color3.fromHex("#a5a0f7"),
		Background = Color3.fromHex("#1a1a2e"),
		Surface = Color3.fromHex("#ffffff"),
		SurfaceLight = Color3.fromHex("#ffffff"),
		Border = Color3.fromHex("#ffffff"),
		Text = Color3.fromHex("#ffffff"),
		TextSecondary = Color3.fromHex("#c4c4d4"),
		TextMuted = Color3.fromHex("#7a7a8e"),
		Success = Color3.fromHex("#5de8a0"),
		Warning = Color3.fromHex("#f5c542"),
		Danger = Color3.fromHex("#f06b7c"),
		GlassTint = Color3.fromHex("#ffffff"),
		GlassStroke = Color3.fromHex("#e0e0ff"),
	},
	Frost = {
		Accent = Color3.fromHex("#38bdf8"),
		AccentLight = Color3.fromHex("#7dd3fc"),
		Background = Color3.fromHex("#0f172a"),
		Surface = Color3.fromHex("#ffffff"),
		SurfaceLight = Color3.fromHex("#ffffff"),
		Border = Color3.fromHex("#ffffff"),
		Text = Color3.fromHex("#f0f9ff"),
		TextSecondary = Color3.fromHex("#bae6fd"),
		TextMuted = Color3.fromHex("#4a6a80"),
		Success = Color3.fromHex("#4ade80"),
		Warning = Color3.fromHex("#facc15"),
		Danger = Color3.fromHex("#fb7185"),
		GlassTint = Color3.fromHex("#e0f2fe"),
		GlassStroke = Color3.fromHex("#bae6fd"),
	},
	Aurora = {
		Accent = Color3.fromHex("#c084fc"),
		AccentLight = Color3.fromHex("#d8b4fe"),
		Background = Color3.fromHex("#1a0a2e"),
		Surface = Color3.fromHex("#ffffff"),
		SurfaceLight = Color3.fromHex("#ffffff"),
		Border = Color3.fromHex("#ffffff"),
		Text = Color3.fromHex("#faf5ff"),
		TextSecondary = Color3.fromHex("#d8b4fe"),
		TextMuted = Color3.fromHex("#6a5080"),
		Success = Color3.fromHex("#86efac"),
		Warning = Color3.fromHex("#fde047"),
		Danger = Color3.fromHex("#fda4af"),
		GlassTint = Color3.fromHex("#f3e8ff"),
		GlassStroke = Color3.fromHex("#d8b4fe"),
	},
	Rose = {
		Accent = Color3.fromHex("#f472b6"),
		AccentLight = Color3.fromHex("#f9a8d4"),
		Background = Color3.fromHex("#1a0a14"),
		Surface = Color3.fromHex("#ffffff"),
		SurfaceLight = Color3.fromHex("#ffffff"),
		Border = Color3.fromHex("#ffffff"),
		Text = Color3.fromHex("#fff1f2"),
		TextSecondary = Color3.fromHex("#fecdd3"),
		TextMuted = Color3.fromHex("#8a5060"),
		Success = Color3.fromHex("#86efac"),
		Warning = Color3.fromHex("#fde047"),
		Danger = Color3.fromHex("#fb7185"),
		GlassTint = Color3.fromHex("#ffe4e6"),
		GlassStroke = Color3.fromHex("#fecdd3"),
	},
	Emerald = {
		Accent = Color3.fromHex("#34d399"),
		AccentLight = Color3.fromHex("#6ee7b7"),
		Background = Color3.fromHex("#0a1a14"),
		Surface = Color3.fromHex("#ffffff"),
		SurfaceLight = Color3.fromHex("#ffffff"),
		Border = Color3.fromHex("#ffffff"),
		Text = Color3.fromHex("#ecfdf5"),
		TextSecondary = Color3.fromHex("#a7f3d0"),
		TextMuted = Color3.fromHex("#4a7a60"),
		Success = Color3.fromHex("#86efac"),
		Warning = Color3.fromHex("#fde047"),
		Danger = Color3.fromHex("#fb7185"),
		GlassTint = Color3.fromHex("#d1fae5"),
		GlassStroke = Color3.fromHex("#a7f3d0"),
	},
	Ocean = {
		Accent = Color3.fromHex("#22d3ee"),
		AccentLight = Color3.fromHex("#67e8f9"),
		Background = Color3.fromHex("#0a1a2e"),
		Surface = Color3.fromHex("#ffffff"),
		SurfaceLight = Color3.fromHex("#ffffff"),
		Border = Color3.fromHex("#ffffff"),
		Text = Color3.fromHex("#ecfeff"),
		TextSecondary = Color3.fromHex("#a5f3fc"),
		TextMuted = Color3.fromHex("#4a7a8a"),
		Success = Color3.fromHex("#86efac"),
		Warning = Color3.fromHex("#fde047"),
		Danger = Color3.fromHex("#fb7185"),
		GlassTint = Color3.fromHex("#cffafe"),
		GlassStroke = Color3.fromHex("#a5f3fc"),
	},
}

function Theme.new(configFolder)
	local self = setmetatable({}, Theme)
	self._current = "Glass"
	self._values = {}
	self._listeners = {}
	self._configFolder = configFolder or "GlassLib"

	for k, v in pairs(Theme.Presets.Glass) do
		self._values[k] = v
	end

	return self
end

function Theme:Get()
	return self._values
end

function Theme:GetName()
	return self._current
end

function Theme:Set(themeName)
	if Theme.Presets[themeName] then
		self._current = themeName
		for k, v in pairs(Theme.Presets[themeName]) do
			self._values[k] = v
		end
		self:_NotifyListeners()
	end
end

function Theme:SetCustom(values)
	for k, v in pairs(values) do
		self._values[k] = v
	end
	self._current = "Custom"
	self:_NotifyListeners()
end

function Theme:OnChanged(callback)
	table.insert(self._listeners, callback)
end

function Theme:_NotifyListeners()
	for _, cb in ipairs(self._listeners) do
		cb(self._values, self._current)
	end
end

function Theme:Save(name)
	local data = {
		ThemeName = self._current,
		Custom = self._current == "Custom" and self._values or nil,
	}
	pcall(function()
		if not isfolder(self._configFolder) then
			makefolder(self._configFolder)
		end
		writefile(self._configFolder .. "/theme_" .. (name or "default") .. ".json", Util.HttpService:JSONEncode(data))
	end)
end

function Theme:Load(name)
	local success, result = pcall(function()
		return readfile(self._configFolder .. "/theme_" .. (name or "default") .. ".json")
	end)
	if success and result then
		local data = Util.HttpService:JSONDecode(result)
		if data.ThemeName and Theme.Presets[data.ThemeName] then
			self:Set(data.ThemeName)
		elseif data.Custom then
			self:SetCustom(data.Custom)
		end
		return true
	end
	return false
end

function Theme:GetPresets()
	local names = {}
	for name in pairs(Theme.Presets) do
		table.insert(names, name)
	end
	table.sort(names)
	return names
end

return Theme
