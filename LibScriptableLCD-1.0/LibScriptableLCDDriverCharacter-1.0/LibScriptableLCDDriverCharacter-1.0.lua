local MAJOR = "LibScriptableLCDDriverCharacter-1.0"
local MINOR = 18
assert(LibStub, MAJOR.." requires LibStub") 
local DriverCharacter = LibStub:NewLibrary(MAJOR, MINOR)
if not DriverCharacter then return end
local LibError = LibStub("LibScriptableUtilsError-1.0", true)
assert(LibError, MAJOR .. " requires LibScriptableUtilsError-1.0")
local LibCore = LibStub("LibScriptableLCDCore-1.0", true)
assert(LibCore, MAJOR .. " requires LibScriptableLCDCore-1.0")
local LCDText = LibStub("LibScriptableLCDText-1.0", true)
assert(LCDText, MAJOR .. " requires LibScriptableLCDText-1.0")
local LibFont = LibStub("LibScriptableLCDFont-1.0", true)
assert(LibFont, MAJOR .. " requires LibScriptableLCDFont-1.0")
local LibTimer = LibStub("LibScriptableUtilsTimer-1.0", true)
assert(LibTimer, MAJOR .. " requires LibScriptableUtilsTimer-1.0")
local LibBuffer = LibStub("LibScriptableUtilsBuffer-1.0", true)
assert(LibBuffer, MAJOR .. " requires LibScriptableUtilsBuffer-1.0")
local PluginUtils = LibStub("LibScriptablePluginUtils-1.0", true)
assert(PluginUtils, MAJOR .. " requires LibScriptablePluginUtils-1.0")
local PluginResources = LibStub("LibScriptablePluginResourceTools-1.0", true)
assert(PluginResources, MAJOR .. " requires LibScriptablePluginResourceTools-1.0")
PluginResources = PluginResources:New(PluginResources)
local PluginString = LibStub("LibScriptablePluginString-1.0", true)
assert(PluginString, MAJOR .. " requires LibScriptablePluginString-1.0")
PluginString = PluginString:New(PluginString)

local pool = setmetatable({}, {__mode = "k"})

local options
local frame = CreateFrame("Frame")

local DEFAULT_LIMIT = 50

local stratas = {
	"BACKGROUND",
	"LOW",
	"MEDIUM",
	"HIGH",
	"DIALOG",
	"FULLSCREEN",
	"FULLSCREEN_DIALOG",
	"TOOLTIP"
}
	
local anchors = {
	"TOP",
	"TOPRIGHT",
	"TOPLEFT",
	"BOTTOM",
	"BOTTOMRIGHT",
	"BOTTOMLEFT",
	"RIGHT",
	"LEFT",
	"CENTER"
}

if not DriverCharacter.__index then
	DriverCharacter.__index = DriverCharacter
end

local new, del
do
	local pool = {}
	function new(frame)
		local obj = next(pool)
		
		if obj then
			pool[obj] = nil
		else
			obj = frame:CreateTexture()
		end
		
		return obj
	end
	function del(frame)
		pool[frame] = true
	end
end
--- Create a new DriverCharacter object
-- @usage :New(visitor, environment, name, config, errorLevel)
-- @param visitor Core object
-- @param environment Execution environment
-- @param name A name for this LCD.
-- @param config The configuration
-- @param errorLevel Error verbosity
-- @return A new DriverCharacter object

function DriverCharacter:New(visitor, environment, name, config, errorLevel)
	
	assert(type(name) == "string", MAJOR .. ": Invalid name")
	assert(type(config[name]) == "table", MAJOR .. ": " .. name .. ": Invalid config")
	assert(type(config[name].addon) == "string", format("%s : %s: Missing %s.addon", MAJOR, name, name))
	
	local obj = next(pool)

	if obj then
		pool[obj] = nil
	else
		obj = {}		
		obj.specialChars = {}
	end
	
	PluginResources.Update()
	local mem1, mempercent1, memdiff1, totalmem1, totalmemdiff1 = PluginResources.GetMemUsage(config[name].addon)
	local cpu1, cpupercent1, cpudiff1, totalcpu1, totalcpudiff1 = PluginResources.GetCPUUsage(config[name].addon)
	
	setmetatable(obj, self)
	
	obj.environment = environment
	obj.core = LibCore:New(obj, obj.environment, name, config, "text", errorLevel)
	obj.error = LibError:New(MAJOR, errorLevel)
	obj.error:Print("New", 2)
	--local rows, cols = config[name].rows, config[name].cols
	obj.rows, obj.cols, obj.yres, obj.xres, obj.layers = config[name].rows or 1, config[name].cols or 16, config[name].yres or 8, config[name].xres or 6, config[name].layers or 1
	obj.lcd = LCDText:New(obj.core, obj.rows, obj.cols, obj.yres, obj.xres, obj.layers, errorLevel, obj.Blit, obj, config[name].update)
	obj.core.lcd = obj.lcd -- You must provide a LibCore object with an LCD object.
	obj.pixel = config[name].pixel or 3
	obj.parent = config[name].parent or "UIParent"
	obj.strata = config[name].strata or #stratas
	
	obj.background = config.background
	
	obj.points = {}
	for i, point in ipairs(config[name].points or {}) do
		tinsert(obj.points, point)
	end
	
	obj.core:CFGSetup()
	obj.core:BuildLayouts()

	local frame = CreateFrame("Frame")
	obj.frame = frame
	frame:SetParent(obj.parent)
	frame:SetFrameStrata("BACKGROUND")
	frame:SetFrameStrata(stratas[obj.strata])
	frame:SetBackdrop({
		bgFile = "Interface\\ChatFrame\\ChatFrameBackground", 
		tile = true, 
		tileSize = obj.pixel,
		insets = {left = 0, right = 0, top = 0, bottom = 0},
	})
	frame:SetWidth(obj.lcd.DCOLS * obj.lcd.XRES * obj.pixel)
	frame:SetHeight(obj.lcd.DROWS * obj.lcd.YRES * obj.pixel)
	frame:ClearAllPoints()
	--frame:SetPoint("TOPLEFT", config[name].row, config[name].col or 0)
	frame:SetAlpha(1)
	frame:Hide()
	frame:Show()
	
	obj.textures = {}
	
	for i = 0, obj.lcd.DCOLS * obj.lcd.DROWS * obj.lcd.XRES * obj.lcd.YRES - 1 do		
		local col, row = PluginUtils.GetCoords(i, obj.lcd.DCOLS * obj.lcd.XRES)
		local texture = new(frame)
		texture:SetParent(frame)
		texture:ClearAllPoints()
		texture:SetPoint("TOPLEFT", col * obj.pixel, (row * obj.pixel) - (obj.lcd.DROWS * obj.lcd.YRES * obj.pixel) + obj.pixel)
		texture:SetTexture(random(2) - 1, random(2) - 1, random(2) - 1)
		texture:SetWidth(obj.pixel)
		texture:SetHeight(obj.pixel)
		texture:Show()
		obj.textures[i] = texture
	end

	obj.buffer = LibBuffer:New(MAJOR .. " " .. name .. " buffer", obj.lcd.DCOLS * obj.lcd.XRES * obj.lcd.DROWS * obj.lcd.YRES, 0, errorLevel)
	
	obj.timer = LibTimer:New(MAJOR .. " " .. name, 100, true, obj.Update, obj, errorLevel)
	obj:Clear()
	
	PluginResources.Update()
	local mem2, mempercent2, memdiff2, totalmem2, totalmemdiff2 = PluginResources.GetMemUsage(config[name].addon)
	local cpu2, cpupercent2, cpudiff2, totalcpu2, totalcpudiff2 = PluginResources.GetCPUUsage(config[name].addon)
	
	obj.error:Print(format("%s load stats: Memory at start: %s, Memory at finish: %s, Difference: %s", name, PluginString.memshort(mem1), PluginString.memshort(mem2), PluginString.memshort(memdiff2)), 1)
	obj.error:Print(format("%s load stats: CPU at start: %s, CPU at finish: %s, Difference: %s", name, PluginString.timeshort(cpu1), PluginString.timeshort(cpu2), PluginString.timeshort(cpudiff2)), 1)
	
	return obj
end

-- Delete an object
-- @name StarDriverCharacter:Del
-- @usage StarDriverCharacter:Del([lcd]) or object:Del()
-- @param lcd An optional lcd object
-- @return Nothing
function DriverCharacter:Del(lcd)
	if not lcd then
		lcd = self
	end
	pool[lcd] = true
	lcd.core:Del()
	lcd.error:Del()
	lcd.timer:Del()
	lcd.buffer:Del()
	for i = 0, self.lcd.DCOLS * self.lcd.DROWS * self.lcd.XRES * self.lcd.YRES - 1 do
		del(lcd.textures[i])
	end
	lcd:Hide()
end

-- Show the tooltip
-- @name StarDriverCharacter:Show
-- @usage StarDriverCharacter:Show()
-- @return Nothing
function DriverCharacter:Show()
	self.error:Print("DriverCharacter:Show", 2)
	self.frame:Show()
	self.core:Start()
	self.frame:ClearAllPoints()
	for i, point in pairs(self.points) do
		self.frame:SetPoint(unpack(point))
	end
	self.timer:Start()
end

-- Hide the display
-- @name :Hide
-- @usage :Hide()
-- @return Nothing
function DriverCharacter:Hide()
	self.core:Stop()
	self.frame:Hide()
	self.timer:Stop()
end

function DriverCharacter:Clear()
	self.lcd:Clear()
	self.lcd.DisplayFB:Fill("#")
	self.lcd:TextBlit(0, 0, self.lcd.DCOLS, self.lcd.DROWS)
end

--- Move the tooltip
-- @usage DriverCharacter:Move(arg1, arg2, arg3, arg4, arg5)
-- @param arg1 (et al) Same as SetPoint
-- @return Nothing
function DriverCharacter:Move(arg1, arg2, arg3, arg4, arg5)
	self.frame:SetPoint(arg1, arg2, arg3, arg4, arg5)
end

function DriverCharacter:Blit(obj, r, c, buffer, len, bold)
	for i = c, c + len - 1 do
		obj:SetCell((obj.lcd.LROWS - r - 1), i, (buffer[i - c] or ' '), bold and bold[i])
	end
end

function DriverCharacter:RebuildOpts(visitor, db)
	return LibCore:RebuildOpts(visitor, db)
end

function DriverCharacter:KeyEvent(modifier, up)
	self.core:KeyEvent(modifier, up)
end

function DriverCharacter:SetCell(row, col, char, bold)
	local chr
	if char == "" then char = " " end
	
	if type(char) == "number" then
		chr = self.lcd.specialChars[char]
	elseif(bold == 1) then
		chr = LibFont.Font_6x8_bold[strbyte(char) + 1];
	else
		chr = LibFont.Font_6x8[strbyte(char) + 1];
	end
		
	for y = 0 , self.lcd.YRES - 1 do
		local mask = bit.lshift(1, self.lcd.XRES)
		for x = 0, self.lcd.XRES - 1 do
			mask = bit.rshift(mask, 1)
			if bit.band(chr[self.lcd.YRES - y], mask) == 0 then
				self.buffer.buffer[(row * self.lcd.YRES + y) * self.lcd.LCOLS * self.lcd.XRES + col * self.lcd.XRES + x] = 1
			else
				self.buffer.buffer[(row * self.lcd.YRES + y) * self.lcd.LCOLS * self.lcd.XRES + col * self.lcd.XRES + x] = 0
			end
		end
	end
end

function DriverCharacter:Update()
	for i = 0, self.lcd.DROWS * self.lcd.DCOLS * self.lcd.YRES * self.lcd.XRES - 1 do
		if self.buffer.buffer[i] == 0 then
			--self.textures[i]:SetBackdropColor(1, 1, 1)
			self.textures[i]:SetTexture(1, 1, 1)
		else
			--self.textures[i]:SetBackdropColor(0, 0, 0)
			self.textures[i]:SetTexture(0, 0, 0)
		end
	end
end
