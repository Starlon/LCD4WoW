local MAJOR = "LibScriptablePluginFail-1.0" 
local MINOR = 17

local PluginFail = LibStub:NewLibrary(MAJOR, MINOR)
if not PluginFail then return end
local LibFail = LibStub("LibFail-1.0", true)
assert(LibFail, MAJOR .. " requires LibFail-1.0")
local L = LibStub("LibScriptableUtilsLocale-1.0")
assert(L, MAJOR .. " requires LibScriptableUtilsLocale-1.0")
L = L.L

local fail_events = LibFail:GetSupportedEvents()
local fails = {}
local fails_events = {}
local fails_spells = {}
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
local function NumFails(unit, spell)
	local name = UnitName(unit)
	local count = 0
	for i, v in ipairs(fails) do
		if name == v.who and (spell == nil or spell == v.spell) then
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

-- Return all failures for a given spell id
-- @usage GetFailsForSpell(spellid)
-- @return A list of all fails related to the spell id
local function GetFailsForSpell(spellid)
	if type(spellid) ~= "number" then return end
	return fails_spells[spellid]
end
ScriptEnv.GetFailsForSPell = GetFailsForSPell

-- Return all failures of the said LibFail type
-- @usage GetFailsForType(ftype)
-- @param ftype A LibFail type, i.e. notmoving, spreading, wrongplace, etc...
-- @return A list of all failures for a giving type
local function GetFailsForType(ftype)
	if type(ftype) ~= "string" then return end
	return fails_types[ftype]
end
ScriptEnv.GetFailsForType = GetFailsForType

local types = {}
types.notmoving = L["Failed at not moving"]
types.moving = L["Failed at moving"]
types.spreading = L["Failed at not spreading"]
types.dispelling = L["Failed at dispelling"]
types.notdispelling = L["Failed at not dispelling"]
types.wrongplace = L["At the wrong place at the wrong time"]
types.notcasting = L["Shouldn't be casting"]
types.notattacking = L["Shouldn't be attacking"]
types.casting = L["Not casting"]
types.switching = L["Failed at switching tank"]

-- Return a localized string of a failure type
-- @usage GetFailLocalization(type)
-- @param type A LibFail type -- i.e. notattacking, notdispelling, switching
-- @return A table of localized types
local function GetFailLocalization(type)
	return types[type]
end
ScriptEnv.GetFailLocalization = GetFailLocalization

local function onFail(event, who, type)
	local id = LibFail:GetEventSpellId(event)
	local name, _, icon = GetSpellInfo(id)
	
	if not name then return end
	
	local fail = {spell={id=id, name=name, icon=icon}, event=event, who=who, type=type, time=GetTime()}

	fails_events[event] = fails_events[event] or {}
	fails_spells[id] = fails_events[id] or {}
	fails_types[type] = fails_types[type] or {}
	
	tinsert(fails_events[event], fail)
	tinsert(fails_spells[id], fail)
	tinsert(fails_types[type], fail)
	tinsert(fails, fail)
end

for _, event in ipairs(fail_events) do
    LibFail.RegisterCallback(PluginFail, event, onFail)
end

