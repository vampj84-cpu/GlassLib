--[[
    GlassLib Build Script v3
    Reads all source files, concatenates into one loadstring file.
    No custom require — just one flat scope.
    
    Usage: lua build.lua
    Outputs: GlassLib_Compiled.lua
--]]

local insert = table.insert
local concat = table.concat
local format = string.format
local gsub = string.gsub
local match = string.match
local gmatch = string.gmatch

-- All files in dependency order
local FILES = {
	{ path = "src/util.lua",             var = "Util" },
	{ path = "src/theme.lua",            var = "Theme" },
	{ path = "src/acrylic.lua",          var = "Acrylic" },
	{ path = "src/config.lua",           var = "Config" },
	{ path = "src/notify.lua",           var = "Notify" },
	{ path = "src/dialog.lua",           var = "Dialog" },
	{ path = "src/toggle.lua",           var = "ToggleBtn" },
	{ path = "src/elements/button.lua",  var = "El_Button" },
	{ path = "src/elements/toggle.lua",  var = "El_Toggle" },
	{ path = "src/elements/slider.lua",  var = "El_Slider" },
	{ path = "src/elements/dropdown.lua", var = "El_Dropdown" },
	{ path = "src/elements/textinput.lua", var = "El_TextInput" },
	{ path = "src/elements/keybind.lua", var = "El_Keybind" },
	{ path = "src/elements/colorpicker.lua", var = "El_ColorPicker" },
	{ path = "src/elements/label.lua",   var = "El_Label" },
	{ path = "src/elements/paragraph.lua", var = "El_Paragraph" },
	{ path = "src/elements/divider.lua", var = "El_Divider" },
	{ path = "src/elements/init.lua",    var = "Elements", isElementsInit = true },
	{ path = "src/section.lua",          var = "Section" },
	{ path = "src/tab.lua",              var = "Tab" },
	{ path = "src/window.lua",           var = "Window" },
	{ path = "init.lua",                 var = nil },
}

local function readFile(path)
	local f = io.open(path, "r")
	if not f then return nil end
	local content = f:read("*a")
	f:close()
	return content
end

local function stripHeader(code)
	-- Remove leading comment blocks
	code = gsub(code, "^%s*%-%-%[%-%-%-%-.-\n", "")
	code = gsub(code, "^%s*%-%-%[%[.-%]%]%s*\n?", "")
	return code
end

local function stripServices(code)
	for _, pat in ipairs({
		"local Players = game:GetService%(\"Players%\")\n?",
		"local UIS = game:GetService%(\"UserInputService%\")\n?",
		"local TS = game:GetService%(\"TweenService%\")\n?",
		"local RS = game:GetService%(\"RunService%\")\n?",
		"local HttpService = game:GetService%(\"HttpService%\")\n?",
		"local ContentProvider = game:GetService%(\"ContentProvider%\")\n?",
		"local LocalPlayer = Players%.LocalPlayer\n?",
		"local Mouse = LocalPlayer%.GetMouse%(%)",
	}) do
		code = gsub(code, pat, "")
	end
	return code
end

local function stripRequires(code)
	code = gsub(code, 'require%(%s*script:WaitForChild%("[^"]+"%)%s*%)', "nil")
	code = gsub(code, 'require%(script%.Parent%.[%w%.]+%)', "nil")
	code = gsub(code, 'require%(script%.Parent%.[%w]+%)', "nil")
	code = gsub(code, 'require%(script%.[%w]+%)', "nil")
	return code
end

local function stripReturn(code)
	-- Remove standalone "return X" at end of module
	code = gsub(code, "\nreturn (%w+)\n?\n?$", "\n")
	return code
end

local output = {}

-- Header with services
insert(output, "--[[GlassLib v2.0.0 — https://github.com/vampj84-cpu/GlassLib]]")
insert(output, "")
insert(output, "local Players = game:GetService('Players')")
insert(output, "local UIS = game:GetService('UserInputService')")
insert(output, "local TS = game:GetService('TweenService')")
insert(output, "local RS = game:GetService('RunService')")
insert(output, "local HttpService = game:GetService('HttpService')")
insert(output, "local ContentProvider = game:GetService('ContentProvider')")
insert(output, "local LocalPlayer = Players.LocalPlayer")
insert(output, "local Mouse = LocalPlayer:GetMouse()")
insert(output, "")

-- Process each file
for _, file in ipairs(FILES) do
	local code = readFile(file.path)
	if not code then
		print("MISSING: " .. file.path)
		goto skip
	end

	code = stripHeader(code)
	code = stripServices(code)
	code = stripRequires(code)
	-- Remove "local X = nil" lines (stripped requires) so modules use outer scope
	code = gsub(code, "local %w+ = nil\n", "")

	if file.var then
		-- Module file: wrap in do...end
		insert(output, format("-- %s", file.path))

		if file.isElementsInit then
			-- Special handling: replace require() nils with actual element vars
			code = gsub(code, "Elements%.Button = nil", "Elements.Button = El_Button")
			code = gsub(code, "Elements%.Toggle = nil", "Elements.Toggle = El_Toggle")
			code = gsub(code, "Elements%.Slider = nil", "Elements.Slider = El_Slider")
			code = gsub(code, "Elements%.Dropdown = nil", "Elements.Dropdown = El_Dropdown")
			code = gsub(code, "Elements%.TextInput = nil", "Elements.TextInput = El_TextInput")
			code = gsub(code, "Elements%.Keybind = nil", "Elements.Keybind = El_Keybind")
			code = gsub(code, "Elements%.ColorPicker = nil", "Elements.ColorPicker = El_ColorPicker")
			code = gsub(code, "Elements%.Label = nil", "Elements.Label = El_Label")
			code = gsub(code, "Elements%.Paragraph = nil", "Elements.Paragraph = El_Paragraph")
			code = gsub(code, "Elements%.Divider = nil", "Elements.Divider = El_Divider")
		end

		-- For element files: rename the internal table variable
		if file.path:match("elements/") and not file.isElementsInit then
			-- Find the local table name (e.g. "local Button = {}")
			local innerName = match(code, "local (%w+) = %{}")
			if innerName and innerName ~= file.var then
				-- Rename the table declaration
				code = gsub(code, "local " .. innerName .. " = %{}", "local " .. file.var .. " = {}")
				-- Rename __index
				code = gsub(code, innerName .. "%.__index = " .. innerName, file.var .. ".__index = " .. file.var)
				-- Rename all function references: function X.Y -> function Z.Y
				-- But be careful not to replace inside strings
				-- Simple approach: replace "function InnerName" with "function VarName"
				-- and "InnerName." with "VarName."
				-- Use word boundary matching
				local function renameRefs(s)
					-- Match InnerName as a word (not inside quotes)
					return gsub(s, "([^%w_])(" .. innerName .. ")([^%w_])", function(before, name, after)
						return before .. file.var .. after
					end)
				end
				-- Process line by line to avoid string issues
				local lines = {}
				for ln in gmatch(code, "[^\n]+") do
					local modified = ln
					if not match(modified, "^%s*%-%-") then
						modified = renameRefs(modified)
					end
					insert(lines, modified)
				end
				code = concat(lines, "\n")
			end
		end

		-- Remove the "return XXX" line (last line of module)
		code = stripReturn(code)

		insert(output, "do")
		insert(output, code)
		insert(output, "end")
		insert(output, "")
	else
		-- init.lua: the entry point
		insert(output, "")
		insert(output, "-- ══════════════════════════════════════════════════════════════")
		insert(output, "-- ENTRY POINT")
		insert(output, "-- ══════════════════════════════════════════════════════════════")
		insert(output, code)
	end

	print(format("  %s -> %s", file.path, file.var or "ENTRY"))
	::skip::
end

-- Write file
local out = io.open("GlassLib_Compiled.lua", "w")
out:write(concat(output, "\n"))
out:close()
print("\nDone! GlassLib_Compiled.lua")
