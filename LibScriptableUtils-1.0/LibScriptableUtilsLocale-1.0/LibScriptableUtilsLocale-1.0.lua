local MAJOR = "LibScriptableUtilsLocale-1.0"
local MINOR = 16

local Locale = LibStub:NewLibrary(MAJOR, MINOR)
if not Locale then return end
local enUS = LibStub("LibScriptableUtilsLocale-enUS-1.0")

local L = setmetatable({}, {__index = function(self, key)
	str = rawget(self, key)
	if type(str) == "string" then
		return str
	else
		return key
	end
end})
Locale.L = L

if GetLocale() == "enUS" then
	for k, v in pairs(enUS.L) do
		L[k] = v
	end
end


