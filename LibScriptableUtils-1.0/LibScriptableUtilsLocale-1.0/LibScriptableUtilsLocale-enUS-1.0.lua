local MAJOR = "LibScriptableUtilsLocale-enUS-1.0"
local MINOR = 18

local Locale = LibStub:NewLibrary(MAJOR, MINOR)
if not Locale then return end
local L = {}
Locale.L = L

L["Test"] = "test"
