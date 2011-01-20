local MAJOR = "LibScriptablePluginRotLatency-1.0"
local MINOR = 16

local PluginRotLatency = LibStub:NewLibrary(MAJOR, MINOR)
if not PluginRotLatency then return end
local LibTimer = LibStub("LibScriptableUtilsTimer-1.0")

if not PluginRotLatency.__index then
	PluginRotLatency.__index = PluginRotLatency
end

local objects = {}
local timers = {}
local timer

local new, del
do
	local pool = setmetatable({}, {__mode = "k"})
	function new(...)
		local obj = next(pool)
		if obj then
			pool[obj] = nil
		else
			obj = {}
		end
		for i = 1, select("#", ...) do
			obj[i] = select(i, ...)
		end
		return obj
	end
	function del(tbl)
		pool[tbl] = true
	end
end

-- Populate an environment with this plugin's fields
-- @usage :New(environment) 
-- @parma environment This will be the environment when setfenv is called.
-- @return A new plugin object, aka the environment
function PluginRotLatency:New(environment, config)

	local obj = {}

	setmetatable(obj, self)

	tinsert(objects, obj)
	
	obj.config = config or {gap=10, gcd="Find Herbs"}

	timer = timer or LibTimer(MAJOR .. ".timer", 1, true, obj.Update, obj)
	timer:Start()
	obj.spells = { [BOOKTYPE_SPELL] = { }, [BOOKTYPE_PET] = { } }

	environment.RotLatency = obj
	
	return environment
end

function LibRotLatency:AddSpell(spell, booktype)
	if not booktype then booktype = "BOOKTYPE_SPELL" end
	tinsert(self.spells[booktype], spell)
end

do
	local update = 0

	local function calculate(self)

		if not self.gcd then self.gcd = {start = 0, finish = 0, active = false} end

		local gcd = self.gcd

		local now = GetTime()

		local gcdStart, gcdDur, gcdEnabled

		if self.gcd == 0 then
			return
		end

		for book, _ in pairs(self.spells) do
			gcdStart, gcdDur, gcdEnabled = GetSpellCooldown(self.gcd, book)
			if gcdStart ~= 0 then
				break
			end
		end

		if gcdStart == nil then
			return
		end

		if gcdStart ~= 0 and gcdEnabled == 1 and not gcd.active then
			gcd.start = now
			gcd.active = true
		elseif gcdStart == 0 and gcdEnabled == 1 and gcd.active then
			gcd.finish = now
			gcd.active = false
		end

		for book, spells in pairs(self.spells) do
			for key, spell in pairs(spells) do
				local start, dur, enabled = GetSpellCooldown(spell.id, book)

				local name = book .. key

				if not timers[name] then
					timers[name] = {}
					timers[name][0] = {active=false, start=0, finish=0}
				end

				local count = #timers[name]

				local timer = timers[name][count]

				if gcd.finish < now - self.config.gap and count > 1 and not timer.hasGap then
					timer.hasGap = true
				end

				if start ~= 0 and enabled == 1 and not timer.active then
					timers[name][count + 1] = {}
					timers[name][count + 1].active = true
					timers[name][count + 1].start = now
					timers[name][count + 1].gcd = gcdDur
					if timer.hasGap then
						timer.finish = now
						timer.hasGap = false
					end
					if timer.elapse and count > 0 then
						timer.finish = gcd.finish
						timer.elapse = false
					end
				elseif start == 0 and enabled == 1 and count > 0 and timer.active then
					timer.active = false
					timer.finish = now
					local delta = timer.finish - timer.start - .5
					if delta < timer.gcd and not spell.gcd then
						timers[name][count] = nil
					end
					if spell.gcd then
						timer.elapse = true
					end
				end
			end
		end
	end
	function PluginRotLatency:Update()
		for i, v in ipairs(objects) do
			calculate(v)
		end
	end
end

	self.options = {
		type = "group",
		args = {
			gcd = {
				type = "input",
				name = L["GCD Spell"],
				set = function(info, v)
					for book, _ in pairs(self.config.spells) do
						for i = 1, 500 do
							local name = GetSpellName(i, book)
							if name == v then
								self.config.gcd = i
							end
						end
					end
				end,
				get = function()
					if self.config.gcd == 0 then
						return ""
					end
					for book, _ in pairs(self.config.spells) do
						local name = GetSpellName(self.config.gcd, book)
						if name then
							return name
						end
					end
				end,
				validate = function(info, v)
					for book, spells in pairs(self.config.spells) do
						for i = 1, 500, 1 do
							local name = GetSpellName(i, book)
							if name == v then
								return true
							end
						end
					end
					return L["No such spell exists in your spell book."]
				end,
				usage = L["RotLatency will use this spell to track global cooldown. It should be a spell on the GCD, but does not have a cooldown of its own."],
				order = 1
			}
		},
		newLine = {
			type = "header",
			name = "",
			order = 2
		},
		gap = {
			type = "input",
			name = L["Time Gap"],
			set = function(info, v)
				self.config.gap = tonumber(v)
			end,
			get = function()
				return tostring(self.config.gap)
			end,
			pattern = "%d",
			usage = L["Enter the value in seconds for which to give up waiting for the next spell cast."],
			order = 3
		},
		limit = {
			type = "input",
			name = L["Display Limit"],
			set = function(info, v)
				self.config.limit = tonumber(v)
			end,
			get = function()
				return tostring(self.config.limit)
			end,
			pattern = "%d",
			usage = L["Enter how many records back to display."],
			order = 4
		},
		spells = {
			type = "group",
			name = L["Spells to Track"],
			args = {},
			order = 5
		}
	}
