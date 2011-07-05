local MAJOR = "LibScriptablePluginSpell-1.0" 
local MINOR = 18

local PluginSpell = LibStub:NewLibrary(MAJOR, MINOR)
if not PluginSpell then return end

--- Populate an environment with this plugin's fields
-- @usage :New(environment) 
-- @param environment This will be the environment when setfenv is called.
-- @return A new plugin object, aka the environment
function PluginSpell:New(environment)

	environment.GetKnownSlotFromHighestRankSlot = _G.GetKnownSlotFromHighestRankSlot -- slot) - ?. 
	environment.GetMultiCastTotemSpells = _G.GetMultiCastTotemSpells -- (totemslot) - Returns a list of spellIDs that are applicable for the specified totem slot (1-4)  -- NEW in 3.2) 
	environment.GetNumShapeshiftForms = _G.GetNumShapeshiftForms -- ) 
	environment.GetNumSpellTabs = _G.GetNumSpellTabs -- ) - Returns the total number of tabs in the user's spellbook. 
	environment.GetQuestLogRewardSpell = _G.GetQuestLogRewardSpell -- - ?. 
	environment.GetRewardSpell  = _G.GetRewardSpell -- - ?. 
	environment.GetShapeshiftForm = _G.GetShapeshiftForm -- unknown) - returns zero-based index of current form/stance 
	environment.GetShapeshiftFormCooldown = _G.GetShapeshiftFormCooldown -- index) 
	environment.GetShapeshiftFormInfo = _G.GetShapeshiftFormInfo -- index) - Retrieves information about an available ShapeshiftForm or Stance. 
	environment.GetSpellAutocast = _G.GetSpellAutocast -- "spellName" | spellId, bookType) - Check whether the specified spell autocasts or not. 
	environment.GetSpellCooldown = _G.GetSpellCooldown -- spellName | spellID, "bookType") - Retrieves data on the cooldown of a specific spell. 
	environment.GetSpellInfo  = _G.GetSpellInfo  -- spellId | spellName | spellLink) - Returns the spell's info, including name, cost, icon, cast time, and range. 
	environment.GetSpellLink = _G.GetSpellLink -- (spellName, spellRank) - Returns the spell's link.  -- 2.4) 
	environment.GetSpellName = _G.GetSpellName -- spellID, "bookType") - Returns the spell name and spell rank for a spell in the player's spellbook. 
	environment.GetSpellTabInfo = _G.GetSpellTabInfo -- spellbookTabNum) - Returns information about the specified spellbook tab. 
	environment.GetSpellTexture = _G.GetSpellTexture -- spellName | spellID, "bookType") - Returns the texture used for the spell's icon. 
	environment.GetTotemInfo = _G.GetTotemInfo -- slot) - Returns information about a totem. 
	environment.IsAttackSpell = _G.IsAttackSpell -- spell) - Returns 1 if the spell is the "Attack" spell. 
	environment.IsAutoRepeatSpell = _G.IsAutoRepeatSpell -- spell) - 
	environment.IsPassiveSpell = _G.IsPassiveSpell -- (spellID, "bookType") - Returns whether the icon in your spellbook is a Passive ability. Formerly IsSpellPassive -- spell). 
	environment.IsSpellInRange = _G.IsSpellInRange -- "spellName", [unit]) - Is nil for no valid target, 0 for out of range, 1 for in range. 
	environment.IsUsableSpell = _G.IsUsableSpell -- spell) - 
	environment.PickupSpell = _G.PickupSpell -- "spellName" | spellID, "bookType") - Loads an action button onto the cursor to be dropped into a quickbar slot. 
	environment.QueryCastSequence = _G.QueryCastSequence -- "sequence") - Returns index, item, spell for the spell/item that will be used next if the cast sequence is executed. 
	environment.SpellCanTargetUnit = _G.SpellCanTargetUnit -- "unit") - Returns true if the spell awaiting target selection can be cast on the specified unit. 
	environment.SpellHasRange = _G.SpellHasRange -- (spell) - Returns true if the specified spell has a ranged effect  -- i.e. requires a target). 
	environment.SpellIsTargeting = _G.SpellIsTargeting -- ) - Returns true if a spell has been cast and is awaiting target selection. 
	environment.UnitCastingInfo = _G.UnitCastingInfo -- "unit") - Returns spellName, nameSubtext, text, texture, startTime, endTime, isTradeSkill, castID, interrupt . 
	environment.UnitChannelInfo = _G.UnitChannelInfo -- "unit") - Returns spellName, nameSubtext, text, texture, startTime, endTime, isTradeSkill, interrupt . 
	environment.UpdateSpells = _G.UpdateSpells -- ) - Causes "SPELLS_CHANGED" event to occur. 

	return environment
end
