--[[
    GlassLib - Elements Module
    Factory for all UI element types
]]

local Elements = {}

Elements.Button = require(script.Parent.elements.button)
Elements.Toggle = require(script.Parent.elements.toggle)
Elements.Slider = require(script.Parent.elements.slider)
Elements.Dropdown = require(script.Parent.elements.dropdown)
Elements.TextInput = require(script.Parent.elements.textinput)
Elements.Keybind = require(script.Parent.elements.keybind)
Elements.ColorPicker = require(script.Parent.elements.colorpicker)
Elements.Label = require(script.Parent.elements.label)
Elements.Paragraph = require(script.Parent.elements.paragraph)
Elements.Divider = require(script.Parent.elements.divider)

return Elements
