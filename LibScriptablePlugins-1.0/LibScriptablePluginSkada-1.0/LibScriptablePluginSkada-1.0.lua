local MAJOR = "LibScriptablePluginSkada-1.0" 
local MINOR = 19

local PluginSkada = LibStub:NewLibrary(MAJOR, MINOR)
if not PluginSkada then return end

local ScriptEnv = {}

--- Populate an environment with this plugin's fields
-- @usage :New(environment) 
-- @parma environment This will be the environment when setfenv is called.
-- @return A new plugin object, aka the environment
function PluginSkada:New(environment)
	for k, v in pairs(ScriptEnv) do
		environment[k] = v
		self[k] = v
	end
	return environment
end

--- Return Skada's DPS information, if any, for a given unit.
-- @usage ScriptEnv.SkadaUnitDPS(unit)
-- @param unit A unit id, i.e. player, target, pet, etc..
-- @return The unit's Skada's DPS information.
local function SkadaUnitDPS(unit)
	if not Skada then return end
	if not UnitExists(unit) then return end
	
	local set = Skada:find_set("current")
	if not set then return end
	
	local playerid = UnitGUID(unit)
	local player = Skada:find_player(set, playerid)
	
	if player then
		local totaltime = Skada:PlayerActiveTime(set, player)
		return player.damage / math.max(1,totaltime)
	end
end
ScriptEnv.SkadaUnitDPS = SkadaUnitDPS