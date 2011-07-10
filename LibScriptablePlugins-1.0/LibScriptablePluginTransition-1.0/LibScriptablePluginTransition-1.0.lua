
local MAJOR = "LibScriptablePluginTransition-1.0"
local MINOR = 19
assert(LibStub, MAJOR.." requires LibStub")
local PluginTransition = LibStub:NewLibrary(MAJOR, MINOR)
if not PluginTransition then return end
local LibTransition = LibStub("LibTransition-1.0")
assert(LibTransition, MAJOR .. " requires LibTransition-1.0")

--- Populate an environment with this plugin's fields
-- @usage :New(environment) 
-- @param environment This will be the environment when setfenv is called.
-- @return A new plugin object, aka the environment
function PluginTransition:New(environment)

	environment.LibTransition = LibTransition
	
	return environment
end
