local MAJOR = "LibScriptablePluginLua-1.0" 
local MINOR = 16

local PluginLua = LibStub:NewLibrary(MAJOR, MINOR)
if not PluginLua then return end

local _G = _G

if not PluginLua.__index then
	PluginLua.__index = PluginLua
end

-- Populate an environment with this plugin's fields
-- @usage :New(environment) 
-- @parma environment This will be the environment when setfenv is called.
-- @return A new plugin object, aka the environment
function PluginLua:New(environment)
	
	-- Lua functions
	environment.assert = _G.assert
	environment.collectgarbage = _G.collectgarbage
	environment.date = _G.date
	environment.error = _G.error
	environment.gcinfo = _G.gcinfo
	environment.getfenv = _G.getfenv
	environment.getmetatable = _G.getmetatable
	environment.loadstring = _G.loadstring
	environment.next = _G.next
	environment.newproxy = _G.newproxy
	environment.pcall = _G.pcall
	environment.select = _G.select
	environment.setfenv = _G.setfenv
	environment.setmetatable = _G.setmetatable
	environment.time = _G.time
	environment.type = _G.type
	environment.unpack = _G.unpack
	environment.xpcall = _G.xpcall
	environment.random = _G.random
	environment.coroutine = _G.coroutine
	environment.GetTime = _G.GetTime
	
	return environment
end
