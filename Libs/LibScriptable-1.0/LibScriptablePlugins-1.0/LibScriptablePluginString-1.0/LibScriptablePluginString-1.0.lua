local MAJOR = "LibScriptablePluginString-1.0" 
local MINOR = 19

local PluginString = LibStub:NewLibrary(MAJOR, MINOR)
if not PluginString then return end

local _G = _G

if not PluginString.__index then
	PluginString.__index = PluginString
end

--- Populate an environment with this plugin's fields
-- @usage :New(environment) 
-- @param environment This will be the environment when setfenv is called.
-- @return A new plugin object, aka the environment
function PluginString:New(environment)
	
	environment.string = _G.string
	environment.format = _G.format
	environment.gsub = _G.gsub
	environment.strbyte = _G.strbyte
	environment.strchar = _G.strchar
	environment.strfind = _G.strfind
	environment.strlen = _G.strlen
	environment.strlower = _G.strlower
	environment.strmatch = _G.strmatch
	environment.strrep = _G.strrep
	environment.strsub = _G.strsub
	environment.strupper = _G.strupper
	environment.tonumber = _G.tonumber
	environment.tostring = _G.tostring
	environment.strlenutf8 = _G.strlenutf8
	environment.strtrim = _G.strtrim
	environment.strsplit = _G.strsplit
	environment.strjoin = _G.strjoin
	environment.strconcat = _G.strconcat
	environment.tostringall = _G.tostringall
	
	environment.short = function(value)
		assert(type(value) == "number", MAJOR .. ".short requires a number")
		if value >= 10000000 or value <= -10000000 then
			value = ("%.1fm"):format(value / 1000000)
		elseif value >= 1000000 or value <= -1000000 then
			value = ("%.2fm"):format(value / 1000000)
		elseif value >= 100000 or value <= -100000 then
			value = ("%.0fk"):format(value / 1000)
		elseif value >= 1000 or value <= -1000 then
			value = ("%.1fk"):format(value / 1000)
		else
			value = tostring(floor(value+0.5))
		end
		return value
	end
	
	environment.memshort = function(value)
		assert(type(value) == "number", MAJOR .. ".memshort requires a number")
		if value <= 1024 then
			value = ("%.3fKb"):format(value)
		elseif value <= 1024 * 1024 then
			value = ("%.3fMb"):format(value / 1024)
		elseif value <= 1024 * 1024 * 1024 then
			value = ("%.3fGb"):format(value / ( 1024 * 1024) )
		elseif value <= 1024 * 1024 * 1024 * 1024 then
			value = ("%.3fTb"):format(value / (1024 * 1024 * 1024))
		end
		return value
	end
	
	environment.timeshort = function(value)
		assert(type(value) == "number", MAJOR .. ".timeshort requires a number")
		if value < 1000 then
			value = ("%.3fms"):format(value)
		elseif value / 1000 < 60 then
			value = ("%.3fs"):format(value / 1000)
		elseif value / 1000 / 60 < 60 then
			value = ("%.3fm"):format(value / 1000 / 60)
		elseif value / 1000 / 60 / 60 < 60 then
			value = ("%.3fh"):format(value / 1000 / 60 / 60)
		end
		return value
	end

	
	return environment
end

