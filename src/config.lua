--[[
    GlassLib - Config Module
    Config system with flags (MacLib style)
    Element save/load using class parsers
]]

local Util = require(script.Parent.util)

local Config = {}
Config.__index = Config

-- ══════════════════════════════════════════════════════════════
-- CONFIG CONSTRUCTOR
-- ══════════════════════════════════════════════════════════════

function Config.new(configFolder)
	local self = setmetatable({}, Config)
	self._folder = configFolder or "GlassLib"
	self._flags = {}
	self._elements = {}
	return self
end

-- ══════════════════════════════════════════════════════════════
-- FLAG SYSTEM
-- ══════════════════════════════════════════════════════════════

function Config:RegisterFlag(flag, element, default)
	self._flags[flag] = {
		Element = element,
		Default = default,
		Value = default,
	}
end

function Config:SetFlag(flag, value)
	if self._flags[flag] then
		self._flags[flag].Value = value
	end
end

function Config:GetFlag(flag)
	if self._flags[flag] then
		return self._flags[flag].Value
	end
	return nil
end

function Config:GetFlags()
	local data = {}
	for flag, info in pairs(self._flags) do
		data[flag] = info.Value
	end
	return data
end

function Config:SetFlags(data)
	for flag, value in pairs(data) do
		if self._flags[flag] then
			self._flags[flag].Value = value
			-- Update the connected element if it has a Set method
			local element = self._flags[flag].Element
			if element and element.Set then
				element:Set(value)
			end
		end
	end
end

-- ══════════════════════════════════════════════════════════════
-- FILE OPERATIONS
-- ══════════════════════════════════════════════════════════════

function Config:Save(name)
	local data = self:GetFlags()
	local success, err = pcall(function()
		if not isfolder(self._folder) then
			makefolder(self._folder)
		end
		writefile(self._folder .. "/" .. name .. ".json", Util.HttpService:JSONEncode(data))
	end)
	return success, err
end

function Config:Load(name)
	local success, result = pcall(function()
		return readfile(self._folder .. "/" .. name .. ".json")
	end)
	if success and result then
		local data = Util.HttpService:JSONDecode(result)
		self:SetFlags(data)
		return true
	end
	return false
end

function Config:Delete(name)
	pcall(function()
		delfile(self._folder .. "/" .. name .. ".json")
	end)
end

function Config:List()
	local files = {}
	pcall(function()
		files = listfiles(self._folder)
	end)
	local configs = {}
	for _, file in ipairs(files) do
		if file:match("%.json$") then
			table.insert(configs, file:match("([^/]+)%.json$"))
		end
	end
	return configs
end

-- ══════════════════════════════════════════════════════════════
-- AUTOLOAD
-- ══════════════════════════════════════════════════════════════

function Config:SetAutoload(name)
	pcall(function()
		if not isfolder(self._folder) then
			makefolder(self._folder)
		end
		writefile(self._folder .. "/autoload.txt", name or "")
	end)
end

function Config:GetAutoload()
	local success, result = pcall(function()
		return readfile(self._folder .. "/autoload.txt")
	end)
	if success and result and result ~= "" then
		return result
	end
	return nil
end

function Config:ClearAutoload()
	pcall(function()
		delfile(self._folder .. "/autoload.txt")
	end)
end

return Config
