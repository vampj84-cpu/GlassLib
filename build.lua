--[[
    GlassLib Build Script v4
    Flat concatenation — no wrapping, no custom require.
    All modules share one scope.
    
    Usage: lua build.lua
    Outputs: GlassLib_Compiled.lua
--]]

local insert = table.insert
local concat = table.concat
local format = string.format
local gsub = string.gsub
local match = string.match
local gmatch = string.gmatch

local FILES = {
	"src/util.lua",
	"src/theme.lua",
	"src/acrylic.lua",
	"src/config.lua",
	"src/notify.lua",
	"src/dialog.lua",
	"src/toggle.lua",
	"src/elements/button.lua",
	"src/elements/toggle.lua",
	"src/elements/slider.lua",
	"src/elements/dropdown.lua",
	"src/elements/textinput.lua",
	"src/elements/keybind.lua",
	"src/elements/colorpicker.lua",
	"src/elements/label.lua",
	"src/elements/paragraph.lua",
	"src/elements/divider.lua",
	"src/elements/init.lua",
	"src/section.lua",
	"src/tab.lua",
	"src/window.lua",
	"init.lua",
}

-- Map of module internal table names -> unique flat names
local RENAME = {
	Util = "Util",
	Theme = "Theme",
	Acrylic = "Acrylic",
	Config = "Config",
	Notify = "Notify",
	Dialog = "Dialog",
	ToggleBtn = "ToggleBtn",
	Button = "El_Button",
	Toggle = "El_Toggle",
	Slider = "El_Slider",
	Dropdown = "El_Dropdown",
	TextInput = "El_TextInput",
	Keybind = "El_Keybind",
	ColorPicker = "El_ColorPicker",
	Label = "El_Label",
	Paragraph = "El_Paragraph",
	Divider = "El_Divider",
	Elements = "Elements",
	Section = "Section",
	Tab = "Tab",
	Window = "Window",
}

local function readFile(path)
	local f = io.open(path, "r")
	if not f then return nil end
	local c = f:read("*a")
	f:close()
	return c
end

local output = {}

-- Header
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

for _, path in ipairs(FILES) do
	local code = readFile(path)
	if not code then
		print("MISSING: " .. path)
		goto skip
	end

	-- Strip header comments
	code = gsub(code, "^%s*%-%-%[%-%-%-%-.-\n", "")
	code = gsub(code, "^%s*%-%-%[%[.-%]%]%s*\n?", "")

	-- Remove service declarations
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

	-- Remove all require() calls -> nil
	code = gsub(code, 'require%(%s*script:WaitForChild%("[^"]+"%)%s*%)', "nil")
	code = gsub(code, 'require%(script%.Parent%.[%w%.]+%)', "nil")
	code = gsub(code, 'require%(script%.Parent%.[%w]+%)', "nil")
	code = gsub(code, 'require%(script%.[%w]+%)', "nil")

	-- Remove "local X = nil" lines
	code = gsub(code, "local %w+ = nil\n", "")

	-- Remove trailing "return XXX"
	code = gsub(code, "\nreturn (%w+)\n?\n?$", "\n")

	-- For element modules: rename internal table names
	local modName = path:match("([%w_]+)%.lua$")
	if path:match("elements/") and not path:match("init%.lua") then
		local innerName = match(code, "local (%w+) = %{}")
		local flatName = RENAME[innerName]
		if flatName and flatName ~= innerName then
			-- Rename declaration
			code = gsub(code, "local " .. innerName .. " = %{}", "local " .. flatName .. " = {}")
			-- Rename __index
			code = gsub(code, innerName .. "%.__index = " .. innerName, flatName .. ".__index = " .. flatName)
			-- Rename all references (function calls, dot access, etc.)
			local function ren(s)
				return gsub(s, "([^%w_])(" .. innerName .. ")([^%w_])", function(b, n, a)
					return b .. flatName .. a
				end)
			end
			local lines = {}
			for ln in gmatch(code, "[^\n]+") do
				local m = ln
				if not match(m, "^%s*%-%-") then
					m = ren(m)
				end
				insert(lines, m)
			end
			code = concat(lines, "\n")
		end
	end

	-- For elements/init.lua: replace require nils with element variable names
	if path:match("elements/init%.lua") then
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

	insert(output, "-- " .. path)
	insert(output, code)
	insert(output, "")

	print(format("  %s", path))
	::skip::
end

local f = io.open("GlassLib_Compiled.lua", "w")
f:write(concat(output, "\n"))
f:close()
print("\nDone! GlassLib_Compiled.lua")
