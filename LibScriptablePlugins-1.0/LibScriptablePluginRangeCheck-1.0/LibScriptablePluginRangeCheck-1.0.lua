local MAJOR = "LibScriptablePluginRangeCheck-1.0" 
local MINOR = 17

local PluginRangeFinder = LibStub:NewLibrary(MAJOR, MINOR)
if not PluginRangeFinder then return end
local RangeCheck = LibStub("LibRangeCheck-2.0", true)

if not PluginRangeFinder.__index then
	PluginRangeFinder.__index = PluginRangeFinder
end

--- Populate an environment with this plugin's fields
-- @usage :New(environment) 
-- @param environment This will be the environment when setfenv is called.
-- @return A new plugin object, aka the environment
function PluginRangeFinder:New(environment)
		
	environment.RangeCheck = RangeCheck
	
	return environment
	
end
