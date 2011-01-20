local MAJOR = "LibScriptablePluginDBM-1.0" 
local MINOR = 16
do return end
local PluginDBM = LibStub:NewLibrary(MAJOR, MINOR)
if not PluginDBM then return end
local LibTimer = LibStub("LibScriptableUtilsTimer-1.0", true)
assert(LibTimer, MAJOR .. " requires LibScriptableUtilsTimer-1.0")

local _G = _G

if not PluginDBM.__index then
	PluginDBM.__index = PluginDBM
end

local hooks = {}
local function hook(mod, method, func)
	if not mod then return end
	hooks[method] = mod[method]
	mod[method] = function(...)
		func(...)
		return hooks[method](...)
	end
end

local function remove_hook(mod, method)
	mod[method] = hooks[method]
end

local history = {}
local bosses = {}

-- Populate an environment with this plugin's fields
-- @usage :New(environment) 
-- @parma environment This will be the environment when setfenv is called.
-- @return A new plugin object, aka the environment, and the plugin object as second return
function PluginDBM:New(environment)
	
	self.spellsDBM = {}
	
	local obj = {spellsDBM={}}

	setmetatable(obj, self)
	
	environment.DBMGetAnnounce = self.DBMGetAnnounce

	if DBM then
		obj:Start()
	elseif BigWigs then				
		local function NewBoss(module, ...)
			local mod = BigWigs:GetBossModule(module) 
			hook(mod, "DelayedMessage", function(key, delay, text, ...) tinsert(history, {text = text, time = GetTime()}) end)			
		end
		
		hook(BigWigs, "NewBoss", NewBoss)
	end
	
	
	return environment, obj		
end

function PluginDBM.DBMGetAnnounce(index)
	return history[index]
end

-- Borrowed from BosModTTS
function PluginDBM:InitializeDBM()
	--PluginDBM:RegisterDBM()

	local sound = nil
	local timer = nil
	local text = nil
	
	local function ShowAnnounce(t)
		tinsert(history, t.text)
	end
	
	local function NewAnnounce(announce, _, spellId, ...)
		if announce == nil then
			local spellName = spellId
			text = self.localization.warnings[spellId]
		else
			local spellName = GetSpellInfo(spellId) or "unknown"
			
			if announce == "move" or announce == "you" or announce == "warningspell" then
				if announce == "warningspell" then
					announce = "spell"
				end
			  
				text = DBM_CORE_AUTO_SPEC_WARN_TEXTS[announce]:format(spellName)
				
				if announce == "you" or announce == "move" then
					spellId = spellId .. "SELF"
				end
			else
				local spellHaste = select(7, GetSpellInfo(53142)) / 10000 -- 53142 = Dalaran Portal, should have 10000 ms cast time
				local timer = (select(7, GetSpellInfo(spellId)) or 1000) / spellHaste
			
				text = DBM_CORE_AUTO_ANNOUNCE_TEXTS[announce]:format(spellName, (timer / 1000))
			end
		end
		
		self.spellsDBM[text] = spellId
	end
		
	local function HookAnnounce(boss)		
		local mod = DBM:GetModByName(boss)
		local announces = mod.announces
		
		for i=1, #announces do
			hook(announces[i], "Show", ShowAnnounce)
		end
	end
	
	local function NewMod(_, boss, ...)
		local mod = DBM:GetModByName(boss)
		
		self.localization = DBM:GetModLocalization(boss)
		
		--[[hook(mod, "NewTargetAnnounce", function(...) NewAnnounce("target", ...) end)
		hook(mod, "NewSpellAnnounce", function(...) NewAnnounce("spell", ...) end)
		hook(mod, "NewCastAnnounce", function(...) NewAnnounce("cast", ...) end)
		hook(mod, "NewAnnounce", function(...) NewAnnounce(nil, ...) end)
		hook(mod, "NewSpecialWarningMove", function(...) NewAnnounce("move", ...) end)
		hook(mod, "NewSpecialWarningYou", function(...) NewAnnounce("you", ...) end)
		hook(mod, "NewSpecialWarningSpell", function(...) NewAnnounce("warningspell", ...) end)
		]]
		tinsert(bosses, boss)
	end 

	--hook(DBM, "NewMod", NewMod)
end

function PluginDBM:Start()
	self:InitializeDBM()
end

function PluginDBM:Stop()
	for _, boss in pairs(bosses) do
		local mod = DBM:GetModByName(boss)
		unhook(mod, "NewTargetAnnounce")
		unhook(mod, "NewSpellAnnounce")
		unhook(mod, "NewCastAnnounce")
		unhook(mod, "NewAnnounce")
		unhook(mod, "NewSpecialWarningMove")
		unhook(mod, "NewSpecialWarningYou")
		unhook(mod, "NewSpecialWarningSpell")
	end
	wipe(bosses)
end