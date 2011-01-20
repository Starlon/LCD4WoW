local MAJOR = "LibScriptablePluginDPS-1.0"
local MINOR = 17
local PluginDPS = LibStub:NewLibrary(MAJOR, MINOR)
if not PluginDPS then return end
local LibTimer = LibStub("LibScriptableUtilsTimer-1.0", true)
assert(LibTimer, MAJOR .. " requires LibScriptableUtilsTimer-1.0")

local _G = _G
local frame = CreateFrame("Frame")
local data = {}
local update
local MAXRECORDS = 10

local ScriptEnv = {}

if not PluginDPS.__index then
	PluginDPS.__index = PluginDPS
end

-- Populate an environment with this plugin's fields
-- @usage :New(environment)
-- @parma environment This will be the environment when setfenv is called.
-- @return A new plugin object, aka the environment, and the plugin object as second return
function PluginDPS:New(environment)

	for k, v in pairs(ScriptEnv) do
		environment[k] = v
	end

	self.timer = self.timer or LibTimer:New(MAJOR, 300, true, update)

	return environment
end

local function onEvent(self, event, ...)
	if PluginDPS[event] then
		PluginDPS[event](PluginDPS, ...)
	end
end

frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
frame:Show()

local GetTime = _G.GetTime
local UnitGUID = _G.UnitGUID

-- Return the unit's DPS score.
-- @usage UnitDPS(unit)
-- @param unit The said unit, i.e mouseover, raid1
-- @return The unit's DPS
function PluginDPS.UnitDPS(unit)
	if not PluginDPS.active then return end
	local id = UnitGUID(unit)
	if not data[id] then return end
	local dps = data[id].damage / (GetTime() - data[id].startTime)
	return string.format("%.1f", dps), dps
end
ScriptEnv.UnitDPS = PluginDPS.UnitDPS

-- Clear all DPS data for a unit
-- @usage ResetDPS(unit)
-- @param unit The said unit, i.e. mouseover, raid1
function PluginDPS.ResetDPS(unit)
	local id = UnitGUID(unit)
	if not data[id] then return end
	data[id] = nil
end
ScriptEnv.ResetDPS = PluginDPS.ResetDPS

-- Wipe all DPS data
function PluginDPS.WipeDPS()
	wipe(data)
end
ScriptEnv.WipeDPS = PluginDPS.WipeDPS

-- Start DPS data collection
-- @usage StartDPS()
function PluginDPS.StartDPS()
	PluginDPS.timer:Start()
	frame:SetScript("OnEvent", onEvent)
	PluginDPS.active = true
end
ScriptEnv.StartDPS = PluginDPS.StartDPS

-- Stop DPS data collection
-- @usage StopDPS()
function PluginDPS.StopDPS()
	PluginDPS.timer:Stop()
	frame:SetScript("OnEvent", nil)
	PluginDPS.active = false
end
ScriptEnv.StopDPS = PluginDPS.StopDPS

function PluginDPS.GetData()
	return data
end
ScriptEnv.GetData = PluginDPS.GetData

local events = {
	SWING_DAMAGE = true,
	RANGE_DAMAGE = true,
	SPELL_DAMAGE = true,
	SPELL_PERIODIC_DAMAGE = true,
	DAMAGE_SHIELD = true,
	DAMAGE_SPLIT = true,
}

function PluginDPS:COMBAT_LOG_EVENT_UNFILTERED(_, eventType, id, _, _, _, _, _, spellID, _, _, damage)
	if not events[eventType] then return end
	if eventType == "SWING_DAMAGE" then
		damage = spellID
	end

	if not data[id] then
		data[id] = {}
		data[id].startTime = GetTime()
	end

	data[id].damage = (data[id].damage or 0) + damage
	data[id].lastUpdate = GetTime()
end

function update()
	for k, v in pairs(data) do
		local diff = GetTime() - (v.lastUpdate or 0)
		if v.lastUpdate and  diff > 5 then
			v.lastUpdate = GetTime()
			v.startTime = v.startTime + diff
		end
	end
end

