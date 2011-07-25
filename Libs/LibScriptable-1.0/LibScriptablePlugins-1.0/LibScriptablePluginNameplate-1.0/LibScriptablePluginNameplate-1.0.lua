local MAJOR = "LibScriptablePluginNameplate-1.0"
local MINOR = 19
assert(LibStub, MAJOR.." requires LibStub")
local PluginNameplate = LibStub:NewLibrary(MAJOR, MINOR)
if not PluginNameplate then return end
local LibNameplate = LibStub("LibNameplate-1.0")
assert(LibNameplate, MAJOR .. " requires LibNameplate-1.0")

--- Populate an environment with this plugin's fields
-- @usage :New(environment) 
-- @param environment This will be the environment when setfenv is called.
-- @return A new plugin object, aka the environment
function PluginNameplate:New(environment)

	environment.LibNameplate = LibNameplate
	
	return environment
end
