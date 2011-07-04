local MAJOR = "LibScriptableWidget-1.0" 
local MINOR = 18

assert(LibStub, MAJOR.." requires LibStub") 
local LibWidget = LibStub:NewLibrary(MAJOR, MINOR)
if not LibWidget then return end
local LibProperty = LibStub("LibScriptableUtilsProperty-1.0", true)
assert(LibProperty, MAJOR .. " requires LibScriptableUtilsProperty-1.0")
local LibTimer = LibStub("LibScriptableUtilsTimer-1.0", true)
assert(LibTimer, MAJOR .. " requires LibScriptableUtilsTimer-1.0")
local LibError = LibStub("LibScriptableUtilsError-1.0", true)
assert(LibError, MAJOR .. " requires LibScriptableUtilsError-1.0")
local Utils = LibStub("LibScriptablePluginUtils-1.0")
assert(Utils, MAJOR .. " requires LibScriptablePluginUtils-1.0")
local Locale = LibStub("AceLocale-3.0", true)
assert(Locale, MAJOR .. " requires AceLocale-3.0")
local L = Locale:GetLocale("LibScriptable-1.0")

local pool = setmetatable({}, {__mode = "k"})

if not LibWidget.__index then
	LibWidget.__index = LibWidget
end

local function rfind(str, char)
	local i = strlen(str)
	while i > 0 do
		if str:sub(i, i) == char then
			return i
		end
		i = i - 1
	end
end

--- Create a new LibScriptableWidget object
-- @usage WidgetText:New(child, visitor, name, config, row, col, layer, typeOf, errorLevel)
-- @param visitor An LibScriptableCore-1.0 object, or provide your own
-- @parma name This widget's name
-- @param config This widget's parameters
-- @param row This widget's row
-- @param col This widget's column
-- @param layer This widget's layer
-- @param type Dict of widget types.
-- @param errorLevel The error level for this object.
-- @return A new LibScriptableWidgetText object
function LibWidget:New(child, visitor, name, config, row, col, layer, typeOf, errorLevel) 
	
	assert(type(child) == "table", "No child")
	assert(type(visitor) == "table", "No visitor")
	assert(type(name) == "string", "No name")
	assert(type(config) == "table", "No config")
	assert(type(row) == "number", "No row")
	assert(type(col) == "number", "No col")
	assert(type(typeOf) == "table", "No type")
	
	local obj = next(pool)

	if obj then
		pool[obj] = nil
	else
		obj = {}
	end
	
	obj.child = child
	obj.visitor = visitor
	obj.environment = visitor.environment
	obj.name = name
	obj.config = config
	obj.persistent = config.persistent
	obj.row = row
	obj.col = col
	obj.layer = layer
	obj.type = typeOf
	obj.errorLevel = errorLevel
	obj.lcd = visitor.lcd
	
	local pos1 = name:find(":")
	local pos2 = rfind(name, ":")
	if pos1 then
		obj.layout_base = name:sub(0, pos1 - 1)
		obj.widget_base = name:sub(pos1 + 1, pos2 - 1)	
	end
	obj.started = false
	obj.errorLevel = errorLevel or 3
	
	obj.IntersectUpdate = self.IntersectUpdate

	for k, v in pairs(obj) do
		child[k] = v
	end
	
	setmetatable(obj, self)

	obj.deleted = false
	
	return obj	
end


--- Delete this widget
-- @usage object:Del()
-- @return Nothing
function LibWidget:Del()
	pool[self] = true
	self.deleted = true
end
    
	

--- Check for intersecting frames.
-- @usage IntersectUpdate(objects)
-- @param objects A table of widgets.
-- @return Nothing
function LibWidget.IntersectUpdate(objects)
	assert(type(objects) == "table", "Invalid argument to IntersectUpdate")
	local frame = GetMouseFocus()
	if frame and frame ~= UIParent and frame ~= WorldFrame then
		for k, widget in pairs(objects) do
			if widget.config and widget.config.intersect then
				if Utils.Intersect(frame, widget.frame, widget.config.intersectxPad1 or widget.config.intersectPad or 0, widget.config.intersectyPad1 or widget.config.intersectPad or 0, widget.config.intersectxPad2 or widget.config.intersectPad or 0, widget.config.intersectyPad2 or widget.config.intersectPad or 0) then
					widget.hidden = true
					widget.frame:Hide()
				elseif widget.hidden then
					widget.hidden = false
					widget.frame:Show()
				end
			end
		end
	end
end
	
local anchors = {
	"TOP",
	"TOPRIGHT",
	"TOPLEFT",
	"BOTTOM",
	"BOTTOMRIGHT",
	"BOTTOMLEFT",
	"RIGHT",
	"LEFT",
	"CENTER"
}

local anchorsDict = {}

for i, v in ipairs(anchors) do
	anchorsDict[v] = i
end
	
local strataNameList = {
	"TOOLTIP", "FULLSCREEN_DIALOG", "FULLSCREEN", "DIALOG", "HIGH", "MEDIUM", "LOW", "BACKGROUND"
}

local strataLocaleList = {
	L["Tooltip"], L["Fullscreen Dialog"], L["Fullscreen"], L["Dialog"], L["High"], L["Medium"], L["Low"], L["Background"]
}
LibWidget.anchors = anchors
LibWidget.anchorsDict = anchorsDict
LibWidget.strataNameList = strataNameList
LibWidget.strataLocaleList = strataLocaleList

	
--- Get an Ace3 option table. Plug this into a group type's args.
-- @param db The database table
-- @param callback Provide this if you want to execute the callback once an option is changed
-- @param data Some data to pass when executing the callback
-- @return An Ace3 options table: `name.args = options`.	
function LibWidget:GetOptions(db, callback, data)
	local options = {
		name = "Frame Details",
		type = "group",
		args = {
			add = {
				name = L["Add Point"],
				desc = L["Add a new point"],
				type = "input",
				set = function(info, v)
					tinsert(db.points, {"Center", "GameTooltip", "Center", 0, 0})
					if type(callback) == "function" then
						callback(data)
					end
				end,
				order = 1
			},
			frameName = {
				name = L["Frame Name"],
				desc = L["This is the frame's global name. Follow all rules for naming in Lua."],
				type = "input",
				get = function() return db.name end,
				set = function(info, val) 
					db.frameName = val
					db.frameNameDirty = true
					if type(callback) == "function" then
						callback(data)
					end
				end,
				order = 2
			},
			parent = {
				name = L["Frame Parent"],
				type = "input",
				get = function() return db.parent or "GameTooltip" end,
				set = function(info, val) 
					db.parent = val; 
					db["parentDirty"] = true 
					if type(callback) == "function" then
						callback(data)
					end
				end,
				order = 5
			},
			strata = {
				name = L["Frame Strata"],
				type = "select",
				values = strataLocaleList,
				get = function()
					return db.strata or 1
				end,
				set = function(info, val)
					db.strata = val
					db["strataDirty"] = true
					if type(callback) == "function" then
						callback(data)
					end
				end,
				order = 6
			},
			level = {
				name = L["Frame Level"],
				type = "input",
				pattern = "%d",
				get = function()
					return tostring(db.level or 1)
				end,
				set = function(info, val)
					db.level = tonumber(val)
					db["levelDirty"] = true
					if type(callback) == "function" then
						callback(data)
					end
				end,
				order = 7
			},
			alwaysShown = {
				name = L["Always Shown"],
				type = "toggle",
				desc = "Toggle whether to always show the widget or not",
				get = function() return db.alwaysShown end,
				set = function(info, val)
					db.alwaysShown = val
				end,
				order = 8
			},
			--[[intersect = {
				name = "Intersect Frames",
				desc = "Whether to check for intersecting frames or not",
				type = "toggle",
				get = function() return db.intersect end,
				set = function(info, v) 
					db.intersect = v 
					db["intersectDirty"] = true
					if type(callback) == "function" then
						callback(data)
					end
				end,
				order = 9
			},
			intersectxPad1 = {
				name = "Intersect X Pad #1",
				type = "input",
				pattern = "%d",
				get = function() return tostring(db.intersectxPad1 or 0) end,
				set = function(info, v) 
					db.intersectxPad1 = tonumber(v)
					db["intersectxPad1Dirty"] = true
					if type(callback) == "function" then
						callback(data)
					end
					db.interesectPad = nil
				end,
				order = 10
			},
			intersectyPad1 = {
				name = "Intersect Y Pad #1",
				type = "input",
				pattern = "%d",
				get = function() return tostring(db.intersectyPad1 or 0) end,
				set = function(info, v) 
					db.intersectyPad1 = tonumber(v)
					db["intersectyPad1Dirty"] = true
					if type(callback) == "function" then
						callback(data)
					end
					db.intersectPad = nil
				end,
				order = 11
			},
			intersectxPad2 = {
				name = "Intersect X Pad #2",
				type = "input",
				pattern = "%d",
				get = function() return tostring(db.intersectxPad2 or 0) end,
				set = function(info, v) 
					db.intersectxPad2 = tonumber(v) 
					db["intersectxPad2Dirty"] = true
					if type(callback) == "function" then
						callback(data)
					end
					db.interesectPad = nil
				end,
				order = 12
			},
			intersectyPad2 = {
				name = "Intersect Y Pad #2",
				type = "input",
				pattern = "%d",
				get = function() return tostring(db.intersectyPad2 or 0) end,
				set = function(info, v) 
					db.intersectyPad2 = tonumber(v) 
					db["intersectyPad2Dirty"] = true
					if type(callback) == "function" then
						callback(data)
					end
					db.interesectPad = nil
				end,
				order = 11
			},
			intersectPad = {
				name = "Intersect Padding",
				desc = "Use this to specify a universal padding",
				type = "input",
				pattern = "%d",
				get = function() return tostring(db.intersectPad or 0) end,
				set = function(info, v)
					db.intersectPad = tonumber(v)
					db.intersectxPad1 = nil
					db.intersectyPad1 = nil
					db.intersectxPad2 = nil
					db.intersectyPad2 = nil
				end,
				order = 12
			}]]
		}
	}
	for i, point in ipairs(db.points or {}) do
			options.args["point" .. i] = {
				name = "Point #" .. i,
				type = "group",
				args = {
					point = {
						name = L["Text anchor"],
						type = "select",
						values = anchors,
						get = function() return anchorsDict[point[1] or 1] end,
						set = function(info, v) 
							point[1] = anchors[v]; 
							db["pointsDirty"] = true 
							if type(callback) == "function" then
								callback(data)
							end							
						end,
						order = 1
					},
					relativeFrame = {
						name = L["Relative Frame"],
						type = "input",
						get = function() return point[2] end,
						set = function(info, v) 
							point[2] = v; 
							db["pointsDirty"] = true 
							if type(callback) == "function" then
								callback(data)
							end							
						end,
						order = 2
					},
					relativePoint = {
						name = L["Relative Point"],
						type = "select",
						values = anchors,
						get = function() return anchorsDict[point[3] or 1] end,
						set = function(info, v) 
							point[3] = anchors[v]; 
							db["pointsDirty"] = true 
							if type(callback) == "function" then
								callback(data)
							end
						end,
						order = 3
					},
					xOfs = {
						name = L["X Offset"],
						type = "input",
						pattern = "%d",
						get = function() return tostring(point[4] or 0) end,
						set = function(info, v) 
							point[4] = tonumber(v); 
							db["pointsDirty"] = true 
							if type(callback) == "function" then
								callback(data)
							end
						end,
						order = 4
					},
					yOfs = {
						name = L["Y Offset"],
						type = "input",
						pattern = "%d",
						get = function() return tostring(point[5] or 0) end,
						set = function(info, v) 
							point[5] = tonumber(v);
							db["pointsDirty"] = true 
							if type(callback) == "function" then
								callback(data)
							end
						end,
						order = 5					
					},
					delete = {
						name = L["Delete"],
						type = "execute",
						func = function()
							tremove(db.points, i)
							if type(callback) == "function" then
								callback(data)
							end
						end,
						order = 6
					}					
				},
				order = i
			}
	end
	return options
end
