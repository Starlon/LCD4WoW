local MAJOR = "LibScriptablePluginMath-1.0" 
local MINOR = 17

local PluginMath = LibStub:NewLibrary(MAJOR, MINOR)
if not PluginMath then return end

local _G = _G

if not PluginMath.__index then
	PluginMath.__index = PluginMath
end

local ScriptEnv = {}

-- Populate an environment with this plugin's fields
-- @usage :New(environment) 
-- @parma environment This will be the environment when setfenv is called.
-- @return A new plugin object, aka the environment
function PluginMath:New(environment)
	
	for k, v in pairs(ScriptEnv) do
		environment[k] = v
	end
	
	environment.abs = _G.abs
	environment.acos = _G.acos
	environment.asin = _G.asin
	environment.atan = _G.atan
	environment.atan2 = _G.atan2
	environment.ceil = _G.ceil
	environment.cos = _G.cos
	environment.deg = _G.deg
	environment.exp = _G.exp
	environment.floor = _G.floor
	environment.frexp = _G.frexp
	environment.ldexp = _G.ldexp
	environment.log = _G.log
	environment.log10 = _G.log10
	environment.max = _G.max
	environment.min = _G.min
	environment.mod = _G.mod
	environment.rad = _G.rad
	environment.random = _G.random
	environment.sin = _G.sin
	environment.sqrt = _G.sqrt
	environment.tan = _G.tan
	environment.pow = _G.math.pow
	environment.rand = _G.random
	
	return environment
end

local function isnonzero(x)
	return abs(x) > 0.00001
end
ScriptEnv.isnonzero = isnonzero

local function sqr(x)
	return x*x
end
ScriptEnv.sqr = sqr

local function sigmoid(a, b)
	local t = 1+exp(-a * b);

	local val
	if isnonzero(t) then
		val = 1.0/t
	else
		val = 0
	end
	
	return val
end
ScriptEnv.sigmoid = sigmoid

local function above(val1, val2)
	return val1 > val2 and 1 or 0
end
ScriptEnv.above = above

local function below(val1, val2)
	return val1 < val2 and 1 or 0
end
ScriptEnv.below = below

local function if2(bool, a, b)
	return bool == 0 and b or a
end
ScriptEnv.if2 = if2

local function sign(v)
	if v < 0 then
		return -1
	elseif v > 0 then
		return 1
	end
	return 0
end
ScriptEnv.sign = sign

local function equal(a, b)
	return a == b and 1 or 0
end
ScriptEnv.equal = equal