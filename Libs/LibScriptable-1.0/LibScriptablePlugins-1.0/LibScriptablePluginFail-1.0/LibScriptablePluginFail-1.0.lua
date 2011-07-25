local MAJOR = "LibScriptablePluginFail-1.0" 
local MINOR = 19

local PluginFail = LibStub:NewLibrary(MAJOR, MINOR)
if not PluginFail then return end
local LibFail = LibStub("LibFail-2.0", true)
assert(LibFail, MAJOR .. " requires LibFail-2.0")

local libfail_events = LibFail:GetSupportedEvents()
local fails = {}
local fails_events = {}
local fails_by_who = {}
local fails_types = {}
local ScriptEnv = {}

-- Populate an environment with this plugin's fields
-- @usage :New(environment) 
-- @parma environment This will be the environment when setfenv is called.
-- @return A new plugin object, aka the environment
function PluginFail:New(environment)
	for k, v in pairs(ScriptEnv) do
		environment[k] = v
	end
	
	return environment
end

-- Return the number of fails for unit and optionally spell
-- @usage NewFails(unit[, spell])
-- @param unit The unit in question
-- @param spell An optional spell id
-- @return The unit's number of failures
local function NumFails(unit)
	local name = UnitName(unit)
	local count = 0
	for i, v in ipairs(fails) do
		if unit == v.who or name == v.who then
			count = count + 1
		end
	end
	return count
end
ScriptEnv.NumFails = NumFails

-- Return all fails for unit and optionally spell id
-- @usage GetFails(unit[, spell])
-- @param unit The unit in question
-- @param spell An optional spell id
-- @return A list of all internal fail objects -- each comprises of {spell={id=id, name=name, icon=icon}, event=event, who=who, type=type, time=GetTime()}
local function GetFails(unit, spell)
	local obj = {}
	for i, v in ipairs(fails) do
		if not event or v.spell.id == spell or v.spell.name == spell then
			if UnitName(unit) == v[2] then
				tinsert(obj, v)
				v.elapsed = GetTime() - v.time
			end
		end
	end
	return obj
end
ScriptEnv.GetFails = GetFails

-- Return the unit's time since last failure
-- @usage TimeSinceLastFail(unit[, spell])
-- @param unit The unit in question
-- @param spell An optional spell id
-- @return The time since last known failure
local function TimeSinceLastFail(unit, spell)
	local soonest = 0xdead
	local name = UnitName(unit)
	for i, v in ipairs(fails) do
		if name == v.who and (spell == nil or spell == v.spell) then
			if v.elapsed < soonest then
				soonest = v.elapsed
			end
		end
	end
	if soonest == 0xdead then
		soonest = 0
	end
	return soonest
end
ScriptEnv.TimeSinceLastFail = TimeSinceLastFail

-- Return all failures for a said LibFail event
-- @usage GetFailsForEvent(event)
-- @param event A LibFail event, i.e. Fail_Deconstructor_Light, Fail_Yogg_Sanity
-- @return A list of all fails related to the event
local function GetFailsForEvent(event)
	if type(event) ~= "string" then return end
	return fails_events[event]
end
ScriptEnv.GetFailsForEvent = GetFailsForEvent

-- Return all failures of the said LibFail type
-- @usage GetFailsForType(ftype)
-- @param ftype A LibFail type, i.e. notmoving, spreading, wrongplace, etc...
-- @return A list of all failures for a giving type
local function GetFailsForType(ftype)
	if type(ftype) ~= "string" then return end
	return fails_types[ftype]
end
ScriptEnv.GetFailsForType = GetFailsForType

-- Return a localized string of a failure type
-- @usage GetFailLocalization(type)
-- @param type A LibFail type -- i.e. notattacking, notdispelling, switching
-- @return A table of localized types
local function GetFailLocalization(type)
	return types[type]
end
ScriptEnv.GetFailLocalization = GetFailLocalization

local function onFail(event, who, type)
	local desc = LibFail:GetEventDescription(event)
	
	local fail = {event=event, who=who, type=type, time=GetTime()}

	fails_events[event] = fails_events[event] or {}
	fails_by_who[who] = fails_by_who[who] or {}
	fails_types[type] = fails_types[type] or {}
	
	tinsert(fails_events[event], fail)
	tinsert(fails_types[type], fail)
	tinsert(fails_by_who[who], fail)
	tinsert(fails, fail)
end

for _, event in ipairs(libfail_events) do
    LibFail.RegisterCallback(PluginFail, event, onFail)
end

