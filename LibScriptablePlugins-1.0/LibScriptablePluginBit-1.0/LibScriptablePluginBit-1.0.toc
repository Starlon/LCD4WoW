local MAJOR = "LibScriptablePluginBit-1.0" 
local MINOR = 18

local PluginBit = LibStub:NewLibrary(MAJOR, MINOR)
if not PluginBit then return end

local _G = _G

if not PluginBit.__index then
	PluginBit.__index = PluginBit
end

-- Populate an environment with this plugin's fields
-- @usage :New(environment) 
-- @parma environment This will be the environment when setfenv is called.
-- @return A new plugin object, aka the environment
function PluginBit:New(environment)

	environment.bnot = _G.bit.bnot
	environment.band = _G.bit.band
	environment.bor = _G.bit.bor
	environment.bxor = _G.bit.bxor
	environment.lshift = _G.bit.lshift
	environment.rshift = _G.bit.rshift
	environment.arshift = _G.bit.arshift
	environment.mod = _G.bit.mod
	
	return environment
	
end
