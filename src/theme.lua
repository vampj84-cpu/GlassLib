--[[
    GlassLib - Theme Module
    Theme management with save/load, preset themes
]]

local Util = require(script.Parent.util)

local Theme = {}
Theme.__index = Theme

-- ══════════════════════════════════════════════════════════════
-- BUILT-IN THEMES
-- ══════════════════════════════════════════════════════════════

Theme.Presets = {
	Dark = {
		Accent = Color3.fromHex("#6366f1"),
		AccentLight = Color3.fromHex("#818cf8"),
		Background = Color3.fromHex("#09090b"),
		Surface = Color3.fromHex("#18181b"),
		SurfaceLight = Color3.fromHex("#27272a"),
		Border = Color3.fromHex("#3f3f46"),
		Text = Color3.fromHex("#fafafa"),
		TextSecondary = Color3.fromHex("#a1a1aa"),
		TextMuted = Color3.fromHex("#52525b"),
		Success = Color3.fromHex("#34d399"),
		Warning = Color3.fromHex("#fbbf24"),
		Danger = Color3.fromHex("#f87171"),
	},
	Midnight = {
		Accent = Color3.fromHex("#06b6d4"),
		AccentLight = Color3.fromHex("#22d3ee"),
		Background = Color3.fromHex("#0c0c14"),
		Surface = Color3.fromHex("#141420"),
		SurfaceLight = Color3.fromHex("#1e1e2e"),
		Border = Color3.fromHex("#2a2a3a"),
		Text = Color3.fromHex("#f0f0f5"),
		TextSecondary = Color3.fromHex("#8888aa"),
		TextMuted = Color3.fromHex("#4a4a5a"),
		Success = Color3.fromHex("#34d399"),
		Warning = Color3.fromHex("#fbbf24"),
		Danger = Color3.fromHex("#f87171"),
	},
	Aurora = {
		Accent = Color3.fromHex("#a855f7"),
		AccentLight = Color3.fromHex("#c084fc"),
		Background = Color3.fromHex("#0a0a10"),
		Surface = Color3.fromHex("#16161e"),
		SurfaceLight = Color3.fromHex("#22222e"),
		Border = Color3.fromHex("#333344"),
		Text = Color3.fromHex("#f5f5ff"),
		TextSecondary = Color3.fromHex("#9999bb"),
		TextMuted = Color3.fromHex("#555566"),
		Success = Color3.fromHex("#34d399"),
		Warning = Color3.fromHex("#fbbf24"),
		Danger = Color3.fromHex("#f87171"),
	},
	Frost = {
		Accent = Color3.fromHex("#10b981"),
		AccentLight = Color3.fromHex("#34d399"),
		Background = Color3.fromHex("#080c10"),
		Surface = Color3.fromHex("#121820"),
		SurfaceLight = Color3.fromHex("#1c242e"),
		Border = Color3.fromHex("#2a3440"),
		Text = Color3.fromHex("#f0faf5"),
		TextSecondary = Color3.fromHex("#88aa99"),
		TextMuted = Color3.fromHex("#4a5a55"),
		Success = Color3.fromHex("#34d399"),
		Warning = Color3.fromHex("#fbbf24"),
		Danger = Color3.fromHex("#f87171"),
	},
	Amber = {
		Accent = Color3.fromHex("#f59e0b"),
		AccentLight = Color3.fromHex("#fbbf24"),
		Background = Color3.fromHex("#0c0a08"),
		Surface = Color3.fromHex("#1a1612"),
		SurfaceLight = Color3.fromHex("#262018"),
		Border = Color3.fromHex("#3a3228"),
		Text = Color3.fromHex("#fefce8"),
		TextSecondary = Color3.fromHex("#aaaa88"),
		TextMuted = Color3.fromHex("#5a5544"),
		Success = Color3.fromHex("#34d399"),
		Warning = Color3.fromHex("#fbbf24"),
		Danger = Color3.fromHex("#f87171"),
	},
	Rose = {
		Accent = Color3.fromHex("#f43f5e"),
		AccentLight = Color3.fromHex("#fb7185"),
		Background = Color3.fromHex("#0c0809"),
		Surface = Color3.fromHex("#1a1214"),
		SurfaceLight = Color3.fromHex("#26181c"),
		Border = Color3.fromHex("#3a2830"),
		Text = Color3.fromHex("#fff1f2"),
		TextSecondary = Color3.fromHex("#aa8890"),
		TextMuted = Color3.fromHex("#5a4448"),
		Success = Color3.fromHex("#34d399"),
		Warning = Color3.fromHex("#fbbf24"),
		Danger = Color3.fromHex("#f87171"),
	},
}

-- ══════════════════════════════════════════════════════════════
-- THEME CONSTRUCTOR
-- ══════════════════════════════════════════════════════════════

function Theme.new(configFolder)
	local self = setmetatable({}, Theme)
	self._current = "Dark"
	self._values = {}
	self._listeners = {}
	self._configFolder = configFolder or "GlassLib"

	-- Copy defaults
	for k, v in pairs(Theme.Presets.Dark) do
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

-- ══════════════════════════════════════════════════════════════
-- PERSISTENCE
-- ══════════════════════════════════════════════════════════════

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
