local MAJOR = "LibScriptablePluginComm-1.0"
local MINOR = 19

local PluginComm = LibStub:NewLibrary(MAJOR, MINOR)
if not PluginComm then return end
local AceComm = LibStub("AceComm-3.0", true)
assert(AceComm, MAJOR .. " requires AceComm-3.0")

-- Populate an environment with this plugin's fields
-- @usage :New(environment) 
-- @parma environment This will be the environment when setfenv is called.
-- @return A new plugin object, aka the environment
function PluginComm:New(environment)
	environment.SendAddonMessage = AceComm.SendAddonMessage
	environment.AceComm = AceComm
	return environment
end
