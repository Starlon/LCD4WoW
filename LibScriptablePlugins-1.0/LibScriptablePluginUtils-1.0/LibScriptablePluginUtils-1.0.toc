--A lot of this comes from ckknight.

local MAJOR = "LibScriptablePluginUtils-1.0" 
local MINOR = 18
local PluginUtils = LibStub:NewLibrary(MAJOR, MINOR)
if not PluginUtils then return end
local LibError = LibStub("LibScriptableUtilsError-1.0", false)
assert(LibError, MAJOR .. " requires LibScriptableUtilsError-1.0")
local LibBossIDs = LibStub("LibBossIDs-1.0")
local _G = _G

local ScriptEnv = {}

--- Populate an environment with this plugin's fields
-- @usage :New(environment) 
-- @parma environment This will be the environment when setfenv is called.
-- @return A new plugin object, aka the environment
function PluginUtils:New(environment)
	for k, v in pairs(ScriptEnv) do
		environment[k] = v
	end
	return environment
end


local L = setmetatable({}, {__index = function(self, key)
	str = rawget(self, key)
	if str then
		return str
	else
		return key
	end
end})

--local DEBUG = PitBull4.DEBUG
--local expect = PitBull4.expect

do
	local target_same_mt = { __index=function(self, key)
		if type(key) ~= "string" then
			return false
		end
		
		if key:sub(-6) == "target" then
			local value = self[key:sub(1, -7)]
			self[key] = value
			return value
		end
		
		self[key] = false
		return false
	end }
	
	local target_same_with_target_mt = { __index=function(self, key)
		if type(key) ~= "string" then
			return false
		end
		
		if key:sub(-6) == "target" then
			local value = self[key:sub(1, -7)]
			value = value and value .. "target"
			self[key] = value
			return value
		end
		
		self[key] = false
		return false
	end }
	
	local better_unit_ids = {
		player = "player",
		pet = "pet",
		vehicle = "pet",
		playerpet = "pet",
		mouseover = "mouseover",
		focus = "focus",
		target = "target",
		playertarget = "target",
		npc = "npc",
	}
	for i = 1, MAX_PARTY_MEMBERS do
		better_unit_ids["party" .. i] = "party" .. i
		better_unit_ids["partypet" .. i] = "partypet" .. i
		better_unit_ids["party" .. i .. "pet"] = "partypet" .. i
	end
	for i = 1, MAX_RAID_MEMBERS do
		better_unit_ids["raid" .. i] = "raid" .. i
		better_unit_ids["raidpet" .. i] = "raidpet" .. i
		better_unit_ids["raid" .. i .. "pet"] = "raidpet" .. i
	end
	for i = 1, MAX_ARENA_TEAM_MEMBERS do
		better_unit_ids["arena" .. i] = "arena" .. i
		better_unit_ids["arenapet" .. i] = "arenapet" .. i
		better_unit_ids["arena" .. i .. "pet"] = "arenapet" .. i
	end
	for i = 1, MAX_BOSS_FRAMES do
		better_unit_ids["boss" .. i] = "boss" .. i
	end
	setmetatable(better_unit_ids, target_same_with_target_mt)
	
	--- Return the best UnitID for the UnitID provided
	-- @param unit the known UnitID
	-- @usage PluginUtils.GetBestUnitID("playerpet") == "pet"
	-- @return the best UnitID. If the ID is invalid, it will return false
	function PluginUtils.GetBestUnitID(unit)
		return better_unit_ids[unit]
	end
	
	local valid_singleton_unit_ids = {
		player = true,
		pet = true,
		mouseover = true,
		focus = true,
		target = true,
	}
	setmetatable(valid_singleton_unit_ids, target_same_mt)
	
	--- Return whether the UnitID provided is a singleton
	-- @param unit the UnitID to check
	-- @usage PluginUtils.IsSingletonUnitID("player") == true
	-- @usage PluginUtils.IsSingletonUnitID("party1") == false
	-- @return whether it is a singleton
	function PluginUtils.IsSingletonUnitID(unit)
		return valid_singleton_unit_ids[unit]
	end
	
	local valid_classifications = {
		player = true,
		pet = true,
		mouseover = true,
		focus = true,
		target = true,
		party = true,
		partypet = true,
		raid = true,
		raidpet = true,
	}
	setmetatable(valid_classifications, target_same_mt)
	
	--- Return whether the classification is valid
	-- @param classification the classification to check
	-- @usage PluginUtils.IsValidClassification("player") == true
	-- @usage PluginUtils.IsValidClassification("party") == true
	-- @usage PluginUtils.IsValidClassification("partytarget") == true
	-- @usage PluginUtils.IsValidClassification("partypettarget") == true
	-- @usage PluginUtils.IsValidClassification("party1") == false
	-- @return whether it is a a valid classification
	function PluginUtils.IsValidClassification(unit)
		return valid_classifications[unit]
	end
	
	local non_wacky_unit_ids = {
		player = true,
		pet = true,
		mouseover = true,
		focus = true,
		target = true,
		party = true,
		partypet = true,
		raid = true,
		raidpet = true,
	}
	
	--- Return whether the classification provided is considered "wacky"
	-- @param classification the classification in question
	-- @usage assert(not PluginUtils.IsWackyUnitGroup("player"))
	-- @usage assert(PluginUtils.IsWackyUnitGroup("targettarget"))
	-- @usage assert(PluginUtils.IsWackyUnitGroup("partytarget"))
	-- @return whether it is wacky
	function PluginUtils.IsWackyUnitGroup(classification)
		return not non_wacky_unit_ids[classification]
	end
	ScriptEnv.IsWackyUnitGroup = PluginUtils.IsWackyUnitGroup
end

do
	local classifications = {
		player = L["Player"],
		target = L["Target"],
		pet = L["Player's pet"],
		party = L["Party"],
		party_sing = L["Party"],
		partypet = L["Party pets"],
		partypet_sing = L["Party pet"],
		raid = L["Raid"],
		raid_sing = L["Raid"],
		raidpet = L["Raid pets"],
		raidpet_sing = L["Raid pet"],
		mouseover = L["Mouse-over"],
		focus = L["Focus"],
		maintank = L["Main tanks"],
		maintank_sing = L["Main tank"],
		mainassist = L["Main assists"],
		mainassist_sing = L["Main assist"]
	}
	setmetatable(classifications, {__index=function(self, group)
		local nonTarget
		local singular = false
		if group:find("target$") then
			nonTarget = group:sub(1, -7)
		elseif group:find("target_sing$") then
			singular = true
			nonTarget = group:sub(1, -12)
		else
			self[group] = group
			return group
		end
		local good
		if group:find("^player") or group:find("^pet") or group:find("^mouseover") or group:find("^target") or group:find("^focus") then
			good = L["%s's target"]:format(self[nonTarget])
		elseif singular then
			good = L["%s target"]:format(self[nonTarget .. "_sing"])
		else
			good = L["%s targets"]:format(self[nonTarget .. "_sing"])
		end
		self[group] = good
		return good
	end})
	
	--- Return a localized form of the unit classification.
	-- @param classification a unit classification, e.g. "player", "party", "partypet"
	-- @usage PluginUtils.GetLocalizedClassification("player") == "Player"
	-- @usage PluginUtils.GetLocalizedClassification("target") == "Player's target"
	-- @usage PluginUtils.GetLocalizedClassification("partypettarget") == "Party pet targets"
	-- @return a localized string of the unit classification
	function PluginUtils.GetLocalizedClassification(classification)
		if DEBUG then
			expect(classification, 'typeof', 'string')
			expect(classification, 'inset', classifications)
		end
		
		return classifications[classification]
	end
	ScriptEnv.GetLocalizedClassification = PluginUtils.GetLocalizedClassification
end

--- Leave a function as-is or if a string is passed in, convert it to a namespace-method function call.
-- @param namespace a table with the method func_name on it
-- @param func_name a function (which would then just return) or a string, which is the name of the method.
-- @usage PluginUtils.ConvertMethodToFunction({}, function(value) return value end)("blah") == "blah"
-- @usage PluginUtils.ConvertMethodToFunction({ method = function(self, value) return value end }, "method")("blah") == "blah"
-- @return a function
function PluginUtils.ConvertMethodToFunction(namespace, func_name)
	if type(func_name) == "function" then
		return func_name
	end
	
	if DEBUG then
		expect(namespace[func_name], 'typeof', 'function')
	end
	
	return function(...)
		return namespace[func_name](namespace, ...)
	end
end
ScriptEnv.ConvertMethodToFunction = PluginUtils.ConvertMethodToFunction

--- Return the Mob ID of the given GUID.
-- It doesn't matter if the guid starts with "0x" or not.
-- This will only work for NPCs, not other types of guids, such as players.
-- @usage PluginUtils.GetMobIDFromGuid("0xF13000046514911F") == 1125
-- @usage PluginUtils.GetMobIDFromGuid("F13000046514911F") == 1125
function PluginUtils.GetMobIDFromGuid(guid)
    if DEBUG then
        expect(guid, 'typeof', 'string')
        assert(#guid == 16 or #guid == 18)
    end
    
    local unit_type = guid:sub(-14, -14)
    if unit_type ~= "3" and unit_type ~= "B" and unit_type ~= "b" then
        return nil
    end
    
    return tonumber(guid:sub(-10, -7), 16)
end
ScriptEnv.GetModIDFromGuid = PluginUtils.GetMobIDFromGuid

--- Return the unit classification of the given unit.
-- This acts like UnitClassification(unit), but returns "worldboss" for bosses that match LibBossIDs-1.0
-- @param unit The unit to check the classification of.
-- @return one of "worldboss", "elite", "rareelite", "rare", or "normal"
function PluginUtils.BetterUnitClassification(unit)
    local classification = UnitClassification(unit)
    
    if not LibBossIDs or classification == "worldboss" or classification == "normal" then
        return classification
    end
    local guid = UnitGUID(unit)
    if not guid then
        return classification
    end
    
    local mob_id = PluginUtils.GetMobIDFromGuid(guid)
    if not mob_id then
        return classification
    end
    
    if LibBossIDs.BossIDs[mob_id] then
        return "worldboss"
    end
    
    return classification
end

local function deep_copy(data)
	local t = {}
	for k, v in pairs(data) do
		if type(v) == "table" then
			t[k] = deep_copy(v)
		else
			t[k] = v
		end
	end
	setmetatable(t,getmetatable(data))
	return t
end
PluginUtils.deep_copy = deep_copy

function PluginUtils.ResizeText(str, size)
	if strlen(str) < size then
		for i = strlen(str), size do
			str = str .. " "
		end
	end
	return str:sub(1, size)
end
ScriptEnv.ResizeText = PluginUtils.ResizeText

function PluginUtils.ReplaceText(text1, pos1, text2, pos2)
	local char = text2:sub(pos2, pos2)
	
	if char == "" then char = ' ' end
	
	local left = text1:sub(1, pos1 - 1)
	local right = text1:sub(pos1 + 1)
	
	return left .. char .. right
end
ScriptEnv.ReplaceText = PluginUtils.ReplaceText

function PluginUtils.ResizeList(tbl, size)
	if #tbl < size then
		for i = #tbl + 1, size do
			tinsert(tbl, " ")
		end
	end
end

function PluginUtils.ReplaceTable(tbl1, pos1, tbl2, pos2)
	
end

function PluginUtils.Memcopy(to, from, size)
	for i = 0, size - 1 do
		to[i] = from[i]
	end
end
ScriptEnv.Memcopy = PluginUtils.Memcopy

--- Retrieve the column and row coordinates for the provided index and pitch
-- @usage GetCoords(n, pitch)
-- @param n An index within a buffer
-- @param pitch Your surface's column width
-- @return The column and row representing the provided data
function PluginUtils.GetCoords(n, pitch)				
	local col = n % pitch
	local row = (n - col) / pitch
	return col, row
end					
ScriptEnv.GetCoords = PluginUtils.GetCoords

--- Split a string using the delimiter provided
-- @usage Split(str, delim)
-- @param str The string to split
-- @param delim The delimiter should be a single character
-- @return A new table populated with the split substrings
function PluginUtils.Split(str, delim)
	local start = 1
	local tbl = {}
	for i = 2, strlen(str) do
		if str:sub(i, i) == delim then
			tinsert(tbl, str:sub(start, i - 1))
			start = i + 1
		end
	end

	if start < strlen(str) then
		tinsert(tbl, str:sub(start, strlen(str)))
	end

	return tbl
end
ScriptEnv.Split = PluginUtils.Split
 
--- Determine if the number provided is a power of 2
-- @usage IsPowerOf2(n)
-- @param n A number value
-- @return A boolean indicating whether the value is a power of 2 or not
function PluginUtils.IsPowerOf2(n)
	local bits_found = false
	
	if (n < 1) then
		return false
	end

	repeat
		if bit.band(n, 1) ~= 0 then
			if (bits_found) then
				return FALSE;
			end

			bits_found = true;
		end

		n = bit.rshift(n, 1)

	until (n <= 0);

	return true
end
ScriptEnv.IsPowerOF2 = PluginUtils.IsPowerOf2

local NOCOORD = -1
--- Intersect - Find out if two frames intersect, adjusted by paddings.
-- usage Intersect(frame1, frame2, frame1xPad1, frame1yPad1, frame1xPad2, frame1yPad2, frame2xPad1, frame2yPad1, frame2xPad2, frame2yPad2)
-- @param frame1 The first frame to compare.
-- @param frame2 The second frame to compare.
-- @param frame1xPad1 Padding for left side of frame1
-- @param frame1yPad1 Padding for top side of frame1
-- @param frame1xPad2 Padding for right side of frame1
-- @param frame1yPad2 Padding for bottom of frame1
-- @param frame2xPad1 Padding for left side of frame2
-- @param frame2yPad1 Padding for top side of frame2
-- @param frame2xPad2 Padding for right side of frame2
-- @param frame2yPad2 Padding for bottom of frame2
-- @return True if the two frames intersect, false otherwise
function PluginUtils.Intersect(frame1, frame2, frame1xPad1, frame1yPad1, frame1xPad2, frame1yPad2, frame2xPad1, frame2yPad1, frame2xPad2, frame2yPad2)
	if type(frame1) ~= "table" or type(frame2) ~= "table" then LibError:Print("Intersect received invalid frame parameter."); return false end
	
	if frame1 == frame2 then return true end
		
	frame1xPad1 = frame1xPad1 or 0
	frame1yPad1 = frame1yPad1 or 0
	frame1xPad2 = frame1xPad2 or frame1xPad1
	frame1yPad2 = frame1yPad2 or frame1yPad1
	frame2xPad1 = frame2xPad1 or 0
	frame2yPad1 = frame2yPad1 or 0
	frame2xPad2 = frame2xPad2 or frame2xPad1
	frame2yPad2 = frame2yPad2 or frame2yPad1
		
	frame1.col = -1
	frame1.x1, frame1.y1, frame1.x2, frame1.y2 = -1, -1, -1, -1
	if frame1:GetCenter() then
		local frame = frame1:GetParent()
		local scale = frame1:GetScale()
		local x, y = frame1:GetCenter()
		local width = frame1:GetWidth()
		local height = frame1:GetHeight()
		x = x * scale
		y = y * scale
		width = width * scale
		height = height * scale
		while frame and frame ~= UIParent do
			scale = frame:GetScale()
			x = x * scale
			y = y * scale
			width = width * scale
			height = height * scale
			frame = frame:GetParent()
		end
		frame1.width = width
		frame1.height = height
		frame1.col = x - width / 2
		frame1.row = y - height / 2
		frame1.x1 = frame1.col
		frame1.y1 = frame1.row
		frame1.x2 = frame1.col + frame1.width
		frame1.y2 = frame1.row + frame1.height
	end
	
	frame2.col = -1
	frame2.x1, frame2.y1, frame2.x2, frame2.y2 = -1, -1, -1, -1
	if frame2:GetCenter() then
		local frame = frame2:GetParent()
		local scale = frame2:GetScale()
		local x, y = frame2:GetCenter()
		local width = frame2:GetWidth()
		local height = frame2:GetHeight()
		x = x * scale
		y = y * scale
		width = width * scale
		height = height * scale
		while frame and frame ~= UIParent do
			scale = frame:GetScale()
			x = x * scale
			y = y * scale
			width = width * scale
			height = height * scale
			frame = frame:GetParent()
		end
		frame2.width = width
		frame2.height = height
		frame2.col = x - width / 2
		frame2.row = y - height / 2
		
		frame2.x1 = frame2.col
		frame2.y1 = frame2.row
		frame2.x2 = frame2.col + width
		frame2.y2 = frame2.row + height
	end

    local x1w1, y1w1, x2w1, y2w1;	--/* 1st rectangle */
    local x1w2, y1w2, x2w2, y2w2;	--/* 2nd rectangle */

    if (frame1.x2 == NOCOORD or frame1.y2 == NOCOORD or frame2.x2 == NOCOORD or frame2.y2 == NOCOORD) then
		--/* w1 or w2 is no display widget: no intersection */
		return false;
    end
	
    x1w1 = min(frame1.x1 - frame1xPad1, frame1.x2 + frame1xPad2);
    x2w1 = max(frame1.x1 - frame1xPad1, frame1.x2 + frame1xPad2);
    y1w1 = min(frame1.y1 - frame1yPad1, frame1.y2 + frame1yPad2);
    y2w1 = max(frame1.y1 - frame1yPad1, frame1.y2 + frame1yPad2);
    x1w2 = min(frame2.x1 - frame2xPad1, frame2.x2 + frame2xPad2);
    x2w2 = max(frame2.x1 - frame2xPad1, frame2.x2 + frame2xPad2);
    y1w2 = min(frame2.y1 - frame2yPad1, frame2.y2 + frame2yPad2);
    y2w2 = max(frame2.y1 - frame2yPad1, frame2.y2 + frame2yPad2);
	
    if (x1w2 < x2w1 and x2w2 > x1w1 and y1w2 < y2w1 and y2w2 > y1w1) then
		--/* true: Intersection */
		return true;
    else
		return false;
    end

end

ScriptEnv.Intersect = PluginUtils.Intersect

