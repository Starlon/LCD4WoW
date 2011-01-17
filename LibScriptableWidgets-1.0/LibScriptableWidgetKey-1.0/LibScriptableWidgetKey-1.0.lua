local MAJOR = "LibScriptableWidgetKey-1.0" 
local MINOR = 16

assert(LibStub, MAJOR.." requires LibStub") 
local WidgetKey = LibStub:NewLibrary(MAJOR, MINOR)
if not WidgetKey then return end
local LibTimer = LibStub("LibScriptableUtilsTimer-1.0", true)
assert(LibTimer, MAJOR .. " requires LibScriptableUtilsTimer-1.0")
local Evaluator = LibStub("LibScriptableUtilsEvaluator-1.0", true)
assert(Evaluator, MAJOR .. " requires LibScriptableUtilsEvaluator-1.0")

local pool = setmetatable({}, {__mode = "k"})

WidgetKey.defaults = {
	expression = 'return',
	up = false,
	modifier = 1,
	simple = true
}

local widgetType = {key=true}

--- Create a new LibScriptableWidgetKey object
-- @usage WidgetKey:New(visitor, name, config, errorLevel)
-- @param visitor An LibScriptableCore-1.0 object
-- @param name A name for your key widget
-- @param config This widget's parameters.
-- @param errorLevel The errorLevel for this object
-- @return A new LibScriptableWidgetKey object
function WidgetKey:New(visitor, name, config, errorLevel) 
	assert(name, "WidgetKey requires a name.")
	assert(config, "Please provide the timer with a config")
	assert(config.expression, name .. ": Please provide the marquee with a string")
	
	local obj = next(pool)

	if obj then
		pool[obj] = nil
		obj.__index = nil
	else
		obj = {}
		obj.options = {}
	end
		
	setmetatable(obj, self)

	obj.widget = LibWidget:New(obj, visitor, name, config, 0, 0, 0, widgetType, errorLevel)
	
	obj.config = config
	obj.expression = config.expression or defaults.expression
	obj.up = config.up or defaults.up
	obj.modifier = config.modifier or defaults.modifier
	obj.simple = config.simple or defaults.simple
	
	obj.error = LibError:New(MAJOR .. ": " .. name, errorLevel)
	
	return obj	
end


--- Delete a LibScriptableWidgetKey object
-- @usage :Del()
-- @return Nothing
function WidgetKey:Del()
	local key = self
	key.widget:Del()
	key.widget = nil
	key:Stop()
	pool[key] = true
end

--- Start a LibScriptableWidgetKey
-- @usage :Start()
-- @return Nothing
function WidgetKey:Start()
	self.error:Print("WidgetKey:Start")
	self.enabled = true
end

--- Stop a LibScriptableWidgetKey
-- @usage :Stop()
-- @return Nothing
function WidgetKey:Stop()
	self.error:Print("WidgetKey:Stop")
	self.enabled = false
end

--- A key event fired, now execute this widget's code
-- @usagae :KeyEvent(modifier, up)
-- @param modifier Which key, i.e. LCTRL, RALT. Note that RALT and RALT both fire the same event.
-- @param up Whether this is the button release or not
-- @return Nothing
function WidgetKey:KeyEvent(modifier, up)
	if not self.enabled then return end
	local mod = modifier
	if self.modifier == 1 and self.simple then
		mod = (modifier == "LCTRL" or modifier == "RCTRL") and "LCTRL"
		modifier = "LCTRL"
	elseif self.modifier == 2 and self.simple then
		mod = (modifier == "LALT" or modifier == "RALT") and "LALT"
		modifier = "LALT"
	elseif self.modifier == 3 and self.simple then
		mod = (modifier == "LSHIFT" or modifier == "RSHIFT") and "LSHIFT"
		modifier = "LSHIFT"
	end
		
	if mod == modifier and self.up == up then
		self.visitor.environment.self = self
		Evaluator.ExecuteCode(self.visitor.environment, self.name, self.expression)
	end
end

--- Get an Ace3 option table. Plug this into a group type's args.
-- @usage :GetOptions(db, callback, data)
-- @param db The database table
-- @param callback Provide this if you want to execute the callback once an option is changed
-- @param data Some data to pass when executing the callback
-- @return An Ace3 options table -- `name.args = options`.
function WidgetKey:GetOptions(db, callback, data)
		local defaults = WidgetKey.defaults
		local options = {
			enabled = {
				name = "Enabled",
				desc = "Whether this timer is enabled or not",
				type = "toggle",
				get = function() return db.enabled end,
				set = function(info, v) db.enabled = v; db["enabledDirty"] = true end,
				order = 1
			},
			expression = {
				name = "Expression",
				desc = "Enter this widget's expression",
				type = "input",
				width = "full",
				multiline = true,
				get = function()
					return db.expression or defaults.expression
				end,
				set = function(info, v)
					db.expression = v
					db["expressionDirty"] = true
				end,
				order = 3
			},
			
		}
	return options
end
