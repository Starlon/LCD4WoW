local MAJOR = "LibScriptableLCDCoreLite-1.0" 
local MINOR = 19

local LibCore = LibStub:NewLibrary(MAJOR, MINOR)
if not LibCore then return end
local LibTimer = LibStub("LibScriptableUtilsTimer-1.0", true)
assert(LibTimer, MAJOR .. " requires LibScriptableUtilsTimer-1.0")
local LibError = LibStub("LibScriptableUtilsError-1.0", true)
assert(LibError, MAJOR .. " requires LibScriptableUtilsError-1.0")
local LibCFG = LibStub("LibScriptableUtilsCFG-1.0", true)
assert(LibCFG, MAJOR .. " requires LibScriptableUtilsCFG-1.0")

local WidgetText = LibStub("LibScriptableWidgetText-1.0", true)
assert(WidgetText, MAJOR .. " requires LibScriptableWidgetText-1.0")
local WidgetBar = LibStub("LibScriptableWidgetBar-1.0", true)
assert(WidgetBar, MAJOR .. " requires LibScriptableWidgetBar-1.0")
local WidgetIcon = LibStub("LibScriptableWidgetIcon-1.0", true)
assert(WidgetIcon, MAJOR .. " requires LibScriptableWidgetIcon-1.0")
local WidgetHistogram = LibStub("LibScriptableWidgetHistogram-1.0", true)
assert(WidgetHistogram, MAJOR .. " requires LibScriptableWidgetHistogram-1.0")
local WidgetBignums = LibStub("LibScriptableWidgetBignums-1.0", true)
--assert(WidgetBignums, MAJOR .. " requires LibScriptableWidgetBignums-1.0")
local WidgetKey = LibStub("LibScriptableWidgetKey-1.0", true)
assert(WidgetKey, MAJOR .. " requires LibScriptableWidgetKey-1.0")
local WidgetTimer = LibStub("LibScriptableWidgetTimer-1.0", true)
assert(WidgetTimer, MAJOR .. " requires LibScriptableWidgetTimer-1.0")
local WidgetGestures = LibStub("LibScriptableWidgetGestures-1.0")
assert(WidgetGestures, MAJOR .. "LibScriptableWidgetGestures-1.0")

local Evaluator = LibStub("LibScriptableUtilsEvaluator-1.0", true)
assert(Evaluator, MAJOR .. " requires LibScriptableUtilsEvaluator-1.0")

local PluginRangeCheck = LibStub("LibScriptablePluginRangeCheck-1.0", true)
assert(PluginRangeCheck, MAJOR .. " requires LibScriptableRangeCheck-1.0")
local PluginUnit = LibStub("LibScriptablePluginUnit-1.0", true)
assert(PluginUnit, MAJOR .. " requires LibScriptablePluginUnit-1.0")
local PluginBit = LibStub("LibScriptablePluginBit-1.0", true)
assert(PluginBit, MAJOR .. " requires LibScriptablePluginBit-1.0")
local PluginLua = LibStub("LibScriptablePluginLua-1.0", true)
assert(PluginLua, MAJOR .. " requires LibScriptablePluginLua-1.0")
local PluginMath = LibStub("LibScriptablePluginMath-1.0", true)
assert(PluginMath, MAJOR .. " requires LibScriptablePluginMath-1.0")
local PluginString = LibStub("LibScriptablePluginString-1.0", true)
assert(PluginString, MAJOR .. " requires LibScriptablePluginString-1.0")
local PluginTable = LibStub("LibScriptablePluginTable-1.0", true)
assert(PluginTable, MAJOR .. " requires LibScriptablePluginTable-1.0")
local PluginResourceTools = LibStub("LibScriptablePluginResourceTools-1.0", true)
assert(PluginResourceTools, MAJOR .. " requires LibScriptablePluginResourceTools-1.0")
local PluginCharacterStats = LibStub("LibScriptablePluginCharacterStats-1.0", true)
assert(PluginCharacterStats, MAJOR .. " requires LibScriptablePluginCharacterStats-1.0")
local PluginLocation = LibStub("LibScriptablePluginLocation-1.0", true)
assert(PluginLocation, MAJOR .. " requires LibScriptablePluginLocation-1.0")
local PluginUnitTooltipScan = LibStub("LibScriptablePluginUnitTooltipScan-1.0", true)
assert(PluginUnitTooltipScan, MAJOR .. " requires LibScriptablePluginUnitTooltipScan-1.0")
local PluginDBM = LibStub("LibScriptablePluginDBM-1.0", true) -- no assertion needed.
local PluginLinq = LibStub("LibScriptablePluginLinq-1.0", true)
assert(PluginLinq, MAJOR .. " requires LibScriptablePluginLinq-1.0")
local PluginGuild = LibStub("LibScriptablePluginGuild-1.0", true)
assert(PluginGuild, MAJOR .. " requires LibScriptablePluginGuild-1.0")
local PluginSpell = LibStub("LibScriptablePluginSpell-1.0", true)
assert(PluginSpell, MAJOR .. " requires LibScriptablePluginSpell-1.0")
local PluginComm = LibStub("LibScriptablePluginComm-1.0", true)
assert(PluginComm, MAJOR .. " requires LibScriptablePluginComm-1.0")
local PluginSerializer = LibStub("LibScriptablePluginSerializer-1.0", true)
assert(PluginSerializer, MAJOR .. " requires LibScriptablePluginSerializer-1.0")
local PluginColor = LibStub("LibScriptablePluginColor-1.0", true)
assert(PluginColor, MAJOR .. " requires LibScriptablePluginColor-1.0")
local PluginLuaTexts = LibStub("LibScriptablePluginLuaTexts-1.0", true)
assert(PluginLuaTexts, MAJOR .. " requires LibScriptablePluginLuaTexts-1.0")
local PluginTalents = LibStub("LibScriptablePluginTalents-1.0", true)
assert(PluginTalents, MAJOR .. " requires LibScriptablePluginTalents-1.0")
local PluginUtils = LibStub("LibScriptablePluginUtils-1.0", true)
assert(PluginUtils, MAJOR .. " requires LibScriptablePluginUtils-1.0")
local PluginUnitControl = LibStub("LibScriptablePluginUnitControl-1.0", true)
assert(PluginUnitControl, MAJOR .. " requires LibScriptablePluginUnitControl-1.0")
local PluginFail = LibStub("LibScriptablePluginFail-1.0")
assert(PluginFail, MAJOR .. " requires LibScriptablePluginFail-1.0")
local PluginBlend = LibStub("LibScriptablePluginBlend-1.0")
assert(PluginBlend, MAJOR .. " requires LibScriptablePluginBlend-1.0")
local PluginNameplate = LibStub("LibScriptablePluginNameplate-1.0")
assert(PluginNameplate, MAJOR .. " requires LibScriptablePluginNameplate-1.0")
local PluginTransition = LibStub("LibScriptablePluginTransition-1.0", true)
assert(PluginTransition, MAJOR .. " requires LibScriptablePluginTransition-1.0")
local PluginDPS = LibStub("LibScriptablePluginDPS-1.0", true)
assert(PluginDPS, MAJOR .. " requires LibScriptablePluginDPS-1.0")
local PluginNoise = LibStub("LibScriptablePluginNoise-1.0", true)
assert(PluginNoise, MAJOR .. " requires LibScriptablePluginNoise-1.0")
local PluginSkada = LibStub("LibScriptablePluginSkada-1.0", true)
assert(PluginSkada, MAJOR .. " requires LibScriptablePluginSkada-1.0")
local PluginRecount = LibStub("LibScriptablePluginRecount-1.0", true)
assert(PluginRecount, MAJOR .. " requires LibScriptablePluginRecount-1.0")

local pool = setmetatable({}, {__mode = "k"})
local objects = {}
local objectDicts = {}

if not LibCore.__index then
	LibCore.__index = LibCore
	LibCore.driverList = {}
	LibCore.driverDict = {}
end

LibCore.TRANSITION_RIGHT = 0
LibCore.TRANSITION_LEFT = 1
LibCore.TRANSITION_BOTH = 2
LibCore.TRANSITION_UP = 3
LibCore.TRANSITION_DOWN = 4
LibCore.TRANSITION_TENTACLE = 5
LibCore.TRANSITION_ALPHABLEND = 6
LibCore.TRANSITION_CHECKERBOARD = 7

local defaults = {rows = 4, cols = 20, transition_timeout = 10000, transition_speed = 100, timeout = 500}

LibCore.defaults = defaults

-- @name LibScriptableCore:New
-- @description Note that you must provide the object an lcd object: core.lcd = myTextLCD
-- @usage LibScriptableCore:New(visitor, environment, name, config, typeOf, lcd, errorLevel)
-- @parma visitor App table
-- @return A new LibScriptableCore object
function LibCore:New(environment, name, errorLevel)
	
	local obj = next(pool)

	if obj then
		pool[obj] = nil
	else
		obj = {}
	end

	if type(config) == "string" then
		config = Evaluator.ExecuteCode(environment, "LibCore:New", config)
	end

	setmetatable(obj, self)
	
	tinsert(objects, obj)
		
	obj.visitor = visitor
	obj.environment = environment
	obj.error = LibError:New(MAJOR, errorLevel)
	obj.errorLevel = errorLevel
	
	environment.visitor = obj
	
	-- Plugins
	PluginRangeCheck:New(environment)
	PluginUnit:New(environment)
	PluginBit:New(environment)
	PluginLua:New(environment)
	PluginMath:New(environment)
	PluginString:New(environment)
	PluginTable:New(environment)
	PluginResourceTools:New(environment)
	PluginLocation:New(environment)
	PluginUnitTooltipScan:New(environment)
	if PluginDBM then PluginDBM:New(environment) end
	PluginLinq:New(environment)
	PluginGuild:New(environment)
	PluginSpell:New(environment)
	PluginComm:New(environment)
	PluginSerializer:New(environment)
	PluginColor:New(environment)
	PluginLuaTexts:New(environment)
	PluginTalents:New(environment)
	PluginUtils:New(environment)
	PluginUnitControl:New(environment)
	PluginFail:New(environment)
	PluginBlend:New(environment)
	PluginNameplate:New(environment)
	PluginTransition:New(environment)
	PluginDPS:New(environment)
	PluginNoise:New(environment)
	PluginSkada:New(environment)	
	PluginRecount:New(environment)
	
	environment._G = _G
	environment.environment = environment

	environment.WidgetText = WidgetText
	environment.WidgetBar = WidgetBar
	environment.WidgetIcon = WidgetIcon
	environment.WidgetHistogram = WidgetHistogram
	environment.WidgetBignums = WidgetBignums
	environment.WidgetKey = WidgetKey
	environment.WidgetTimer = WidgetTimer
	environment.WidgetScript = WidgetScript
	environment.WidgetGestures = WidgetGestures
	environment.WidgetImage = WidgetImage
				
	return obj	
	
end

-- @name LibScriptableCore:Del
-- @usage LibScriptableCore:Del([core]) or object:Del()
-- @param core An optional core object
-- @return Nothing
function LibCore:Del(core)
	if not core then core = self end
	
	for i, v in ipairs(objects) do
		if v == self then
			tremove(objects, i)
		end
	end
	
	pool[core] = true
	
	for i, v in ipairs(core.widgets) do
		v:Del()
	end
	
	core.error:Del()
end

function LibCore:RegisterDriver(driver)
	tinsert(LibCore.driverList, driver)
	LibCore.driverDict[driver] = #LibCore.driverList
end

function LibCore:RebuildOpts(visitor, db)
	local options = {
--[[		name = {
			name = "Name",
			desc = "This display's name",
			type = "input",
			get = function() return db.name end,
			set = function(info, v)
				db.name = v
			end,
			order = 10
		},]]
		rows = {
			name = "Rows",
			desc = "This display's rows",
			type = "input",
			pattern = "%d",
			get = function() return tostring(db.rows or defaults.rows) end,
			set = function(info, v) db.rows = tonumber(v) end,
			order = 12
		},
		cols = {
			name = "Columns",
			desc = "This display's columns",
			type = "input",
			pattern = "%d",
			get = function() return tostring(db.cols or defaults.cols) end,
			set = function(info, v) db.cols = tonumber(v) end,
			order = 13
		},
		update = {
			name = "Update",
			desc = "This display's refresh rate",
			type = "input",
			pattern = "%d",
			get = function() return tostring(db.update or defaults.update) end,
			set = function(info, v) db.update = tonumber(v) end,
			order = 14
		},
		transition_timeout = {
			name = "Transition Timeout",
			desc = "This display's transition timeout",
			type = "input",
			pattern = "%d",
			get = function() return tostring(db.transition_timeout or defaults.transition_timeout) end,
			set = function(info, v) db.transition_timeout = tonumber(v) end,
			order = 16
		},
		transition_speed = {
			name = "Transition Speed",
			desc = "This display's transition speed",
			type = "input",
			pattern = "%d",
			get = function() return tostring(db.transition_speed or defaults.transition_speed) end,
			set = function(info, v) db.transition_speed = tonumber(v) end,
			order = 17
		},
		widgets = {
			name = "Widgets",
			type = "group",
			args = {
				add = {
					name = "Add a widget",
					desc = "Add a widget",
					type = "input",
					set = function(info, v)
						tinsert(db.widgets, "widget_" .. v)
						visitor:RebuildOpts(true)
					end,
					order = 1
				}
			},
			order = 18,
		},
		layouts = {
			name = "Layouts",
			type = "group",
			args = {
				add = {
					name = "Add a layout",
					desc = "Add a layout",
					type = "input",
					set = function(info, v)
						tinsert(db.layouts, "layout_" .. v)
						visitor:RebuildOpts(true)
					end,
					order = 1
				},
			},
			order = 19
		}
	}
	
	for i, v in ipairs(db.widgets or {}) do
		if v.type == "text" then
			options.widgets.args["widget" .. i] = {
				name = "Widget " .. i,
				type = "group",
				args = {
					name = {
						name = v,
						type = "input",
						get = function() return v end,
						set = function(info, v) 
							db.widgets[i] = v 
							visitor:RebuildOpts(true)
						end,
						order = 1
					},
					remove = {
						name = "Remove",
						type = "execute",
						func = function()
							tremove(db.widgets, i)
							visitor:RebuildOpts(true)
						end,
						order = 2
					}
				}
			}
		end
	end
	
	for i, v in ipairs(db.layouts) do
		options.layouts.args["layout" .. i] = {
			name = "Layout " .. i,
			type = "group",
			args = {
				name = {
					name = v,
					type = "input",
					get = function() return v end,
					set = function(info, v) 
						db.layouts[i] = v 
					end,
					order = 1
				},
				up = {
					name = "Up",
					desc = "Move this layout up in the list",
					type = "execute",
					func = function()
						if i == 1 then return end
						db.layouts[i] = db.layouts[i - 1]
						db.layouts[i - 1] = v
						visitor:RebuildOpts(true)
					end,
					order = 2
				},
				down = {
					name = "Down",
					desc = "Move this layout down in the list",
					type = "execute",
					func = function()
						if i == #db.layouts then return end
						db.layouts[i] = db.layouts[i + 1]
						db.layouts[i + 1] = v
						visitor:RebuildOpts(true)
					end,
					order = 3
				},
				remove = {
					name = "Remove",
					desc = "Remove this layout from the display's list",
					type = "execute",
					func = function()
						tremove(db.layouts, i)
						visitor:RebuildOpts()
					end,
					order = 4
				}
			}
		}
	end
	return options
end


