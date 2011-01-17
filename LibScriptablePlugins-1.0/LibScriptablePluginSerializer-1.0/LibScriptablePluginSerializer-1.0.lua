local MAJOR = "LibScriptablePluginSerializer-1.0"
local MINOR = 16

local PluginSerializer = LibStub:NewLibrary(MAJOR, MINOR)
if not PluginSerializer then return end
local AceSerializer = LibStub("AceSerializer-3.0", true)
assert(AceSerializer, MAJOR .. " requires AceSerializer-3.0")

--- Populate an environment with this plugin's fields
-- @usage :New(environment) 
-- @param environment This will be the environment when setfenv is called.
-- @return A new plugin object, aka the environment
function PluginSerializer:New(environment)
	environment.Serialize = AceSerializer.Serialize
	environment.Deserialize = AceSerializer.Deserialize
	return environment
end
