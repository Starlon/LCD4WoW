
local MAJOR = "LibScriptablePluginUnitControl-1.0"
local MINOR = 17
assert(LibStub, MAJOR.." requires LibStub")
local PluginUnitControl = LibStub:NewLibrary(MAJOR, MINOR)
if not PluginUnitControl then return end
local LibUnitControl = LibStub("LibUnitControl-1.0")
assert(LibUnitControl, MAJOR .. " requires LibUnitControl-1.0")

--- Populate an environment with this plugin's fields
--- For docs check http://www.wowace.com/addons/libunitcontrol-1-0/
-- @usage :New(environment) 
-- @param environment This will be the environment when setfenv is called.
-- @return A new plugin object, aka the environment
function PluginUnitControl:New(environment)

	environment.GetEffectMaskByName = function(...) return LibUnitControl:GetEffectMaskByName(...) end
	environment.GetEffectMaskBySpell = function(...) return LibUnitControl:GetEffectMaskBySpell(...) end
	environment.GetEffectStringByMask = function(...) return LibUnitControl:GetEffectStringByMask(...) end
	environment.GetSpellEffectString = function(...) return LibUnitControl:GetSpellEffectString(...) end
	environment.SpellHasEffectString = function(...) return LibUnitControl:SpellHasEffectString(...) end
	environment.SpellHasAllEffectStrings = function(...) return LibUnitControl:SpellHasAllEffectStrings(...) end
	environment.GetUnitEffectMask = function(...) return LibUnitControl:GetUnitEffectMask(...) end
	environment.GetUnitEffectString = function(...) return LibUnitControl:GetUnitEffectString(...) end
	environment.UnitHasEffectMask = function(...) return LibUnitControl:UnitHasEffectMask(...) end
	environment.UnitHasAllEffectMasks = function(...) return LibUnitControl:UnitHasAllEffectMasks(...) end
	environment.UnitHasEffectString = function(...) return LibUnitControl:UnitHasEffectString(...) end
	environment.UnitHasAllEffectStrings = function(...) return LibUnitControl:UnitHasAllEffectStrings(...) end
	
	environment.UnitSlotIsDisarmed = function(...) return LibUnitControl:UnitSlotIsDisarmed(...) end
	environment.UnitHasControl = function(...) return LibUnitControl:UnitHasControl(...) end
	environment.UnitIsBanished = function(...) return LibUnitControl:UnitIsBanished(...) end
	environment.UnitIsCharmed = function(...) return LibUnitControl:UnitIsCharmed(...) end
	environment.UnitIsConfused = function(...) return LibUnitControl:UnitIsConfused(...) end
	environment.UnitIsDisoriented = function(...) return LibUnitControl:UnitIsDisoriented(...) end
	environment.UnitIsFeared = function(...) return LibUnitControl:UnitIsFeared(...) end
	environment.UnitIsFrozen = function(...) return LibUnitControl:UnitIsFrozen(...) end
	environment.UnitIsHorrified = function(...) return LibUnitControl:UnitIsHorrified(...) end
	environment.UnitIsIncapacitated = function(...) return LibUnitControl:UnitIsIncapacitated(...) end
	environment.UnitIsPolymorphed = function(...) return LibUnitControl:UnitIsPolymorphed(...) end
	environment.UnitIsSapped = function(...) return LibUnitControl:UnitIsSapped(...) end
	environment.UnitIsShackled = function(...) return LibUnitControl:UnitIsShackled(...) end
	environment.UnitIsAsleep = function(...) return LibUnitControl:UnitIsAsleep(...) end
	environment.UnitIsStunned = function(...) return LibUnitControl:UnitIsStunned(...) end
	environment.UnitIsTurned = function(...) return LibUnitControl:UnitIsTurned(...) end
	environment.UnitIsDisarmed = function(...) return LibUnitControl:UnitIsDisarmed(...) end
	environment.UnitIsPacified = function(...) return LibUnitControl:UnitIsPacified(...) end
	environment.UnitIsRooted = function(...) return LibUnitControl:UnitIsRooted(...) end
	environment.UnitIsSilenced = function(...) return LibUnitControl:UnitIsSilenced(...) end
	environment.UnitIsEnsnared = function(...) return LibUnitControl:UnitIsEnsnared(...) end
	environment.UnitIsEnraged = function(...) return LibUnitControl:UnitIsEnraged(...) end
	environment.UnitIsWounded = function(...) return LibUnitControl:UnitIsWounded(...) end

	return environment
end
