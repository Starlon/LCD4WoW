local MAJOR = "LibScriptablePluginUnit-1.0" 
local MINOR = 16

local PluginUnit = LibStub:NewLibrary(MAJOR, MINOR)
if not PluginUnit then return end

if not PluginUnit.__index then
	PluginUnit.__index = PluginUnit
end


--- Populate an environment with this plugin's fields
-- @usage :New(environment) 
-- @parma environment This will be the environment when setfenv is called.
-- @return A new plugin object, aka the environment
function PluginUnit:New(environment)

	environment.CheckInteractDistance =  _G.CheckInteractDistance -- = _G.CheckInteractDistance =  _G.CheckInteractDistance -- -- ("unit",distIndex) 
	environment.GetUnitName = _G.GetUnitName -- ("unit", showServerName) - Returns a string with the unit's name and realm name if applicable. 
	environment.GetUnitPitch = _G.GetUnitPitch -- ("unit") - Returns the moving pitch of the unit. -- New for WoW 3.0.2 
	environment.GetUnitSpeed = _G.GetUnitSpeed -- ("unit") - Returns the moving speed of the unit. -- New for WoW 3.0.2 
	environment.IsUnitOnQuest = _G.IsUnitOnQuest -- (questIndex, "unit") - Determine if the specified unit is on the given quest. 
	environment.SpellCanTargetUnit = _G.SpellCanTargetUnit -- ("unit") - Returns true if the spell awaiting target selection can be cast on the specified unit. 
	environment.UnitAffectingCombat = _G.UnitAffectingCombat -- ("unit") - Determine if the unit is in combat or has aggro.  = _G.UnitAffectingCombat("unit") - Determine if the unit is in combat or has aggro.  --  -- (returns nil if "false" and 1 if "true") 
	environment.UnitArmor = _G.UnitArmor -- ("unit") - Returns the armor statistics relevant to the specified unit. 
	environment.UnitAttackBothHands = _G.UnitAttackBothHands --  = _G.UnitAttackBothHands = _G.UnitAttackBothHands --  -- ("unit") - Returns information about the unit's melee attacks. 
	environment.UnitAttackPower = _G.UnitAttackPower --  = _G.UnitAttackPower = _G.UnitAttackPower --  -- ("unit") - Returns the unit's melee attack power and modifiers. 
	environment.UnitAttackSpeed = _G.UnitAttackSpeed --  = _G.UnitAttackSpeed = _G.UnitAttackSpeed --  -- ("unit") - Returns the unit's melee attack speed for each hand. 
	environment.UnitAura = _G.UnitAura --  = _G.UnitAura = _G.UnitAura --  -- ("unit", index [, filter]) - Returns info about buffs and debuffs of a unit. 
	environment.UnitBuff = _G.UnitBuff -- ("unit", index [,raidFilter]) - Retrieves info about a buff of a certain unit.  -- (Updated in 2.0) 
	environment.UnitCanAssist = _G.UnitCanAssist -- ("unit", "otherUnit") - Indicates whether the first unit can assist the second unit. 
	environment.UnitCanAttack = _G.UnitCanAttack -- ("unit", "otherUnit") - Returns true if the first unit can attack the second, false otherwise. 
	environment.UnitCanCooperate = _G.UnitCanCooperate -- ("unit", "otherUnit") - Returns true if the first unit can cooperate with the second, false otherwise. 
	environment.UnitCharacterPoints = _G.UnitCharacterPoints -- ("unit") - Returns the number of unspent talent points for the specified unit -- usually 0. 
	environment.UnitClass = _G.UnitClass --("unit") - Returns the class name of the specified unit  -- (e.g., "Warrior" or "Shaman"). 
	environment.UnitClassification = _G.UnitClassification --("unit") - Returns the classification of the specified unit  -- (e.g., "elite" or "worldboss"). 
	environment.UnitCreatureFamily = _G.UnitCreatureFamily --("unit") - Returns the type of creature of the specified unit  -- (e.g., "Crab"). 
	environment.UnitCreatureType = _G.UnitCreatureType -- ("unit") - Returns the classification type of creature of the specified unit  -- (e.g., "Beast"). 
	environment.UnitDamage = _G.UnitDamage -- ("unit") - Returns the damage statistics relevant to the specified unit. 
	environment.UnitDebuff = _G.UnitDebuff -- ("unit", index [,raidFilter]) - Retrieves info about a debuff of a certain unit.  = _G.UnitDebuff("unit", index [,raidFilter]) - Retrieves info about a debuff of a certain unit.  -- (Updated in 2.0) 
	environment.UnitDefense = _G.UnitDefense -- ("unit") - Returns the base defense skill of the specified unit. 
	environment.UnitDetailedThreatSituation = _G.UnitDetailedThreatSituation -- ("unit", "mob") - Returns detailed information about the specified unit's threat on a mob. New in Patch 3.0. 
	environment.UnitExists = _G.UnitExists -- ("unit") - Returns 1 if the specified unit exists, nil otherwise. 
	environment.UnitFactionGroup = _G.UnitFactionGroup -- ("unit") - Returns the faction group id and name of the specified unit. (eg. "Alliance") - string returned is localization-independent  -- (used in filepath) 
	environment.UnitGroupRolesAssigned = _G.UnitGroupRolesAssigned -- ("unit") - Returns the assigned role in a group formed via the Dungeon Finder Tool.  -- (New in Patch 3.3) 
	environment.UnitGUID = _G.UnitGUID -- ("unit") - Returns the GUID as a string for the specified unit matching the GUIDs used by the new combat logs.  -- (New in Patch 2.4) 
	environment.GetPlayerInfoByGUID  = _G.GetPlayerInfoByGUID --("guid") - Added in 3.2, returns race, class, sex about the guid  -- (client must have seen the guid) 
	environment.UnitHasLFGDeserter = _G.UnitHasLFGDeserter --("unit") - Returns whether the unit is currently unable to use the dungeon finder due to leaving a group prematurely.  -- (3.3.3) 
	environment.UnitHasLFGRandomCooldown = _G.UnitHasLFGRandomCooldown --("unit") - Returns whether the unit is currently under the effects of the random dungeon cooldown.  -- (3.3.3) 
	environment.UnitHasRelicSlot = _G.UnitHasRelicSlot -- ("unit") 
	environment.UnitHealth = _G.UnitHealth -- ("unit") - Returns the current health, in points, of the specified unit. 
	environment.UnitHealthMax = _G.UnitHealthMax -- ("unit") - Returns the maximum health, in points, of the specified unit. 
	environment.UnitInParty = _G.UnitInParty -- ("unit") - Returns true if the unit is a member of your party. 
	environment.UnitInRaid = _G.UnitInRaid -- ("unit") - Returns the unit index if the unit is in your raid/battlegroud, nil otherwise. 
	environment.UnitInBattleground = _G.UnitInBattleground -- ("unit") - Returns the unit index if the unit is in your battleground, nil otherwise. 
	environment.UnitIsInMyGuild = _G.UnitIsInMyGuild -- ("unit") - Returns whether the specified unit is in the same guild as the player's character. 
	environment.UnitInRange = _G.UnitInRange -- ("unit") - Returns true if the unit (party or raid only) is in range of a typical spell such as flash heal.  -- (New in Patch 2.4)) 
	environment.UnitIsAFK = _G.UnitIsAFK -- ("unit") - Only works for friendly units. 
	environment.UnitIsCharmed = _G.UnitIsCharmed -- ("unit") - Returns true if the specified unit is charmed, false otherwise. 
	environment.UnitIsConnected = _G.UnitIsConnected -- ("unit") - Returns 1 if the specified unit is connected or npc, nil if offline or not a valid unit. 
	environment.UnitIsCorpse = _G.UnitIsCorpse -- ("unit") - Returns true if the specified unit is a corpse, false otherwise. 
	environment.UnitIsDead = _G.UnitIsDead -- ("unit") - Returns true if the specified unit is dead, nil otherwise. 
	environment.UnitIsDeadOrGhost = _G.UnitIsDeadOrGhost -- ("unit") - Returns true if the specified unit is dead or a ghost, nil otherwise. 
	environment.UnitIsDND = _G.UnitIsDND -- ("unit") - Only works for friendly units. 
	environment.UnitIsEnemy = _G.UnitIsEnemy -- ("unit", "otherUnit") - Returns true if the specified units are enemies, false otherwise. 
	environment.UnitIsFeignDeath = _G.UnitIsFeignDeath -- ("unit") - Returns true if the specified unit  -- (must be a member of your group) is feigning death.-- Added in 2.1 
	environment.UnitIsFriend = _G.UnitIsFriend -- ("unit", "otherUnit") - Returns true if the specified units are friends  -- (PC of same faction or friendly NPC), false otherwise. 
	environment.UnitIsGhost = _G.UnitIsGhost -- ("unit") - Returns true if the specified unit is a ghost, false otherwise. 
	environment.UnitIsPVP = _G.UnitIsPVP -- ("unit") - Returns true if the specified unit is flagged for PVP, false otherwise. 
	environment.UnitIsPVPFreeForAll = _G.UnitIsPVPFreeForAll -- ("unit") - Returns true if the specified unit is flagged for free-for-all PVP, false otherwise. 
	environment.UnitIsPVPSanctuary = _G.UnitIsPVPSanctuary -- ("unit") - Returns whether the unit is in a PvP sanctuary, and therefore cannot be attacked by other players. 
	environment.UnitIsPartyLeader = _G.UnitIsPartyLeader -- ("unit") - Returns true if the unit is the leader of its party. 
	environment.UnitIsPlayer = _G.UnitIsPlayer -- ("unit") - Returns true if the specified unit is a player character, false otherwise. 
	environment.UnitIsPossessed = _G.UnitIsPossessed -- ("unit") - Returns whether the specified unit is currently under control of another  -- (i.e. "pet" when casting Mind Control). 
	environment.UnitIsRaidOfficer = _G.UnitIsRaidOfficer -- ("unit") - Returns whether the specified unit is an officer in your raid. 
	environment.UnitIsSameServer = _G.UnitIsSameServer -- ("unit") - Returns whether the specified unit is from the same server as the player's character. 
	environment.UnitIsTapped = _G.UnitIsTapped -- ("unit") - Returns true if the specified unit is tapped, false otherwise. 
	environment.UnitIsTappedByPlayer = _G.UnitIsTappedByPlayer -- ("unit") - Returns true if the specified unit is tapped by the player himself, otherwise false. 
	environment.UnitIsTappedByAllThreatList = _G.UnitIsTappedByAllThreatList -- ("unit") - Returns whether the specified unit is a community monster, i.e. whether all players engaged in combat with it will receive kill  -- (quest) credit. 
	environment.UnitIsTrivial = _G.UnitIsTrivial -- ("unit") - Returns true if the specified unit is trivial  -- (Trivial means the unit is "grey" to the player. false otherwise. 
	environment.UnitIsUnit = _G.UnitIsUnit -- ("unit", "otherUnit") - Determine if two units are the same unit. 
	environment.UnitIsVisible = _G.UnitIsVisible -- ("unit") - 1 if visible, nil if not 
	environment.UnitLevel = _G.UnitLevel -- ("unit") - Returns the level of a unit. 
	environment.UnitMana = _G.UnitMana -- ("unit") - Returns the current mana (or energy,rage,etc), in points, of the specified unit. (Replaced by UnitPower -- () as of WoW 3.0.2) 
	environment.UnitManaMax = _G.UnitManaMax -- ("unit") - Returns the maximum mana (or energy,rage,etc), in points, of the specified unit. (Replaced by UnitPowerMax -- () as of WoW 3.0.2) 
	environment.UnitName = _G.UnitName -- ("unit") - Returns the name  -- (and realm name) of a unit. 
	environment.UnitOnTaxi = _G.UnitOnTaxi -- ("unit") - Returns 1 if unit is on a taxi. 
	environment.UnitPlayerControlled = _G.UnitPlayerControlled -- ("unit") - Returns true if the specified unit is controlled by a player, false otherwise. 
	environment.UnitPlayerOrPetInParty = _G.UnitPlayerOrPetInParty -- ("unit") - Returns 1 if the specified unit/pet is a member of the player's party, nil otherwise  -- (returns nil for "player" and "pet") - Added in 1.12 
	environment.UnitPlayerOrPetInRaid = _G.UnitPlayerOrPetInRaid -- ("unit") - Returns 1 if the specified unit/pet is a member of the player's raid, nil otherwise  -- (returns nil for "player" and "pet") - Added in 1.12 
	environment.UnitPVPName = _G.UnitPVPName -- ("unit") - Returns unit's name with PvP rank prefix  -- (e.g., "Corporal Allianceguy"). 
	environment.UnitPVPRank = _G.UnitPVPRank -- ("unit") - Get PvP rank information for requested unit. 
	environment.UnitPower = _G.UnitPower -- ("unit"[,type]) - Returns current power of the specified unit (Replaces UnitMana -- () as of WoW 3.0.2) 
	environment.UnitPowerMax = _G.UnitPowerMax -- ("unit"[,type]) - Returns max power of the specified unit (Replaces UnitManaMax -- () as of WoW 3.0.2) 
	environment.UnitPowerType = _G.UnitPowerType -- ("unit") - Returns a number corresponding to the power type  -- (e.g., mana, rage or energy) of the specified unit. 
	environment.UnitRace = _G.UnitRace -- ("unit") - Returns the race name of the specified unit  -- (e.g., "Human" or "Troll"). 
	environment.UnitRangedAttack = _G.UnitRangedAttack -- ("unit") - Returns the ranged attack number of the unit. 
	environment.UnitRangedAttackPower = _G.UnitRangedAttackPower -- ("unit") - Returns the ranged attack power of the unit. 
	environment.UnitRangedDamage = _G.UnitRangedDamage -- ("unit") - Returns the ranged attack speed and damage of the unit. 
	environment.UnitReaction = _G.UnitReaction -- ("unit", "otherUnit") - Returns a number corresponding to the reaction  -- (aggressive, neutral or friendly) of the first unit towards the second unit. 
	environment.UnitResistance = _G.UnitResistance -- ("unit", "resistanceIndex") - Returns the resistance statistics relevant to the specified unit and resistance type. 
	environment.UnitSelectionColor = _G.UnitSelectionColor -- (UnitId) - Returns RGBA values for the color of a unit's name. 
	environment.UnitSex = _G.UnitSex -- ("unit") - Returns a code indicating the gender of the specified unit, if known.  -- (1=unknown, 2=male, 3=female) ? changed in 1.11! 
	environment.UnitStat = _G.UnitStat -- ("unit", statIndex) - Returns the statistics relevant to the specified unit and basic attribute  -- (e.g., strength or intellect). 
	environment.UnitThreatSituation = _G.UnitThreatSituation -- ("unit", "mob") - Returns the specified unit's threat status on a mob. New in Patch 3.0. 
	environment.UnitUsingVehicle = _G.UnitUsingVehicle -- ("unit") - Returns whether the specified unit is currently using a vehicle  -- (including transitioning between seats). 
	environment.GetThreatStatusColor = _G.GetThreatStatusColor -- (status) - Returns RGB values for a given UnitThreatSituation return value. 
	environment.UnitXP = _G.UnitXP -- ("unit") - Returns the number of experience points the specified unit has in their current level.  -- (only works on your player) 
	environment.UnitXPMax = _G.UnitXPMax -- ("unit") - Returns the number of experience points the specified unit needs to reach their next level.  -- (only works on your player) 
	environment.SetPortraitTexture = _G.SetPortraitTexture -- (texture,"unit") - Paint a Texture object with the specified unit's portrait. 
	environment.SetPortraitToTexture = _G.SetPortraitToTexture -- (texture or "texture", "texturePath") - Sets the texture to be displayed from a file applying a circular opacity mask making it look round like portraits. 
	
	return environment
end
