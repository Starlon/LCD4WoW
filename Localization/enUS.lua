local L = LibStub("AceLocale-3.0"):NewLocale("LibScriptable-1.0", "enUS", true, true)
if not L then return end

-- Widgets
L["Add Point"] = true
L["Add a new point"] = true
L["Frame Name"] = true
L["This is the frame's global name. Follow all rules for naming in Lua."] = true
L["Frame Parent"] = true
L["Frame Strata"] = true
L["Frame Level"] = true
L["Always Shown"] = true
L["Point # %d"] = true
L["Text anchor"] = true
L["Relative Frame"] = true
L["Relative Point"] = true
L["X Offset"] = true
L["Y Offset"] = true
L["Delete"] = true

-- WidgetTimer
L["Enabled"] = true
L["Whether this timer is enabled or not"] = true
L["Update Rate"] = true
L["Enter the timer's refresh rate"] = true
L["Repeating"] = true
L["Toggle whether to repeat this timer"] = true
L["Expression"] = true
L["Enter this widget's expression"] = true

-- WidgetBar
L["West"] = true
L["East"] = true
L["Normal"] = true
L["Hollow"] = true
L["Horizontal"] = true
L["Vertical"] = true
L["Enabled"] = true
L["Whether the histogram's enabled or not"] = true
L["Bar length"] = true
L["Enter the bar's length"] = true
L["Bar height"] = true
L["Enter the bar's height"] = true
L["Bar update rate"] = true
L["Enter the bar's refresh rate"] = true
L["Direction"] = true
L["Style"] = true
L["Orientation"] = true
L["Shown Always"] = true
L["Whether the frame should be shown always or not"] = true
L["Minimum Expression"] = true
L["Enter the bar's minimum value expression"] = true
L["Maximum Expression"] = true
L["Enter the bar's maximum value expression"] = true
L["Bar #1 Expression"] = true
L["This widget's first bar expression"] = true
L["Bar #1 Color Script"] = true
L["Enter the bar's color script"] = true
L["Bar #2 Expression"] = true
L["This widget's second bar expression."] = true
L["Bar #2 Color Script"] = true
L["Enter the bar's color script"] = true

-- WidgetColor
L["Enabled"] = true
L["Whether this timer is enabled or not"] = true
L["Update Rate"] = true
L["Enter the timer's refresh rate"] = true
L["Repeating Timer"] = true
L["Whether the timer associated with this widget repeats or not"] = true
L["Expression"] = true
L["This widget's Lua script"] = true

-- WidgetGesture
L["Left"] = true
L["Right"] = true
L["Up"] = true
L["Down"] = true
L["Diagonally left and up"] = true
L["Diagonally right and up"] = true
L["Diagonally right and down"] = true
L["Diagonally left and down"] = true
L["Diagonally left and up"] = true
L["Clockwise"] = true
L["Counter-clockwise"] = true
L["Line"] = true
L["Circle"] = true

L["Enabled"] = true
L["Whether this timer is enabled or not"] = true
L["Update Rate"] = true
L["Enter the timer's refresh rate"] = true
L["Draw Layer"] = true
L["Start Button"] = true
L["A description of the mouse action that will trigger the start of the gesture recording. Possibly values are: LeftButtonUp, LeftButtonDown, RightButtonUp, RightButtonDown, MiddleButtonUp, MiddleButtonDown, Freehand"] = true
L["Stop Button"] = true
L["A description of the mouse action that will stop (finish) the gesture recording. Possible values are: LeftButtonUp, LeftButtonDown, RightButtonUp, RightButtonDown, MiddleButtonUp, MiddleButtonDown"] = true
L["Next Button"] = true
L["A description of the optional mouse action that will trigger nextFunc and start a new recording if defined. This can be used to simultaneously recording multiple gestures at once. Possible values are: LeftButtonUp, LeftButtonDown, RightButtonUp, RightButtonDown, MiddleButtonUp, MiddleButtonDown"] = true
L["Cancel Button"] = true
L["A description of the optional mouse action that will cancel the recording and call cancelFunc instead of stopFunc. Possible values are: LeftButtonUp, LeftButtonDown, RightButtonUp, RightButtonDown, MiddleButtonUp, MiddleButtonDown"] = true
L["Show Trail"] = true
L["If set to true, a cursor trail will be shown while the gesture takes place. (can be used for debugging and whatnot)"] = true
L["Max Gestures"] = true
L["If startButton is set to Freehand, maxGestures can be used to set a hard cap on the number of gestures the user can make before the recording stops. Please note, that this will only work on linear gestures. If you need to record circular gestures, leave out this field and the library will sort it for you instead."] = true
L["Repeating"] = true
L["Whether to keep repeating the recording or not"] = true
L["Error Threshhold"] = true
L["The gesture will automatically fail if you make more than this many errors"] = true
L["Expression"] = true
L["Enter this widget's expression"] = true
L["Start Function"] = true
L["An optional function that will be called on the first start of a gesture recording. This can be used to initializing values and so on. startFunc will only be called at the start of a capture, and not after a nextButton has fired. Callback values: recorder, x1, y1, x2, y2 : The recorder object as well as the initial coordinates where the mouse triggered startFunc and the current cursor coordinates (which should be the same in this case)"] = true
L["Update Function"] = true
L["A function that will be called after each OnUpdate event on the recording frame. Callback values: recorder, x1, y1, x2, y2 : The recorder object as well as the initial coordinates where the mouse triggered startFunc (or the last called nextFunc) and the current cursor coordinates"] = true
L["Stop Function"] = true
L["A function that will be called when stopButton has triggered the end of a recording. Callback values: recorder, x1, y1, x2, y2 : The recorder object as well as the initial coordinates where the mouse triggered startFunc (or the last called nextFunc) and the current cursor coordinates"] = true
L["Next Function"] = true
L["A function that will be called when nextButton has triggered the stop of the current recording and immediate start of a new from the current position. Callback values: recorder, x1, y1, x2, y2 : The recorder object as well as the initial coordinates where the mouse triggered startFunc (or the last called nextFunc) and the current cursor coordinates."] = true
L["Cancel Function"] = true
L["A function that will be called when cancelButton has triggered the termination of a recording. Callback values: recorder, x1, y1, x2, y2 : The recorder object as well as the initial coordinates where the mouse triggered startFunc (or the last called nextFunc) and the current cursor coordinates"] = true
L["Tooltip"] = true
L["If set to either a string value or a table with multiple strings, a tooltip will be displayed next to the cursor when positioned over the recording frame. This can be used to provides tips on how to use the mouse gestures."] = true
L["Gestures"] = true
L["Add Gesture"] = true
L["Gesture "] = true
L["Type"] = true
L["Pattern"] = true
L["Delete"] = true

-- WidgetHIstogram
L["East"] = true
L["West"] = true
L["Enabled"] = true
L["Whether the histogram's enabled or not"] = true
L["Histogram length"] = true
L["Enter the histogram's length"] = true
L["Histogram height"] = true
L["Enter the histogram's height"] = true
L["Histogram update rate"] = true
L["Enter the histogram's refresh rate"] = true
L["Histogram direction"] = true
L["Always Shown"] = true
L["Whether the frame should be shown always or not"] = true
L["Backdrop Color"] = true
L["Histogram expression"] = true
L["Enter this histogram's expression."] = true
L["Histogram min expression"] = true
L["Enter the histogram's minimum expression"] = true
L["Histogram max expression"] = true
L["Enter the histogram's maximum expression"] = true
L["Histogram color expression"] = true
L["Enter the histogarm's color script"] = true

-- WidgetImage
L["Enabled"] = true
L["Whether this icon is enabled or not"] = true
L["Update"] = true
L["This widget's refresh rate"] = true
L["Width"] = true
L["This widget's width"] = true
L["Height"] = true
L["This widget's height"] = true
L["Pixel Size"] = true
L["This widget's pixel size"] = true
L["Foreground"] = true
L["This widget's foreground color"] = true
L["Foreground"] = true
L["This widget's background color"] = true
L["Prescript"] = true
L["This widget's prescript"] = true
L["Script"] = true
L["This widget's script"] = true

-- WidgetText
L["Left"] = true
L["Center"] = true
L["Right"] = true
L["Marquee"] = true
L["Automatic"] = true
L["Pingpong"] = true
L["Enable"] = true
L["Enable text widget"] = true
L["Precision"] = true
L["Alignment"] = true
L["Update"] = true
L["Scroll Speed"] = true
L["Direction"] = true
L["Columns"] = true
L["Bold"] = true
L["Background Color"] = true
L["This will be the widget's backdrop color."] = true
L["Value"] = true
L["Enter this widget's Lua script"] = true
L["Prefix"] = true
L["Enter this widget's prefix script"] = true
L["Postfix"] = true
L["Enter this widget's postfix script"] = true
L["Color"] = true
L["Enter this widget's color script"] = true

-- WidgetTimer
L["Enabled"] = true
L["Whether this timer is enabled or not"] = true
L["Update Rate"] = true
L["Enter the timer's refresh rate"] = true
L["Repeating"] = true
L["Toggle whether to repeat this timer"] = true
L["Expression"] = true
L["Enter this widget's expression"] = true

-- PluginLuaTexts
L["Player"] = true
L["Target"] = true
L["%s's pet"] = true
L["Player"] = true
L["Focus"] = true
L["Mouse-over"] = true

L["Mana"] = true
L["Rage"] = true
L["Focus"] = true
L["Energy"] = true
L["Happiness"] = true
L["Runes"] = true
L["Runic Power"] = true
L["Soul Shards"] = true
L["Eclipse"] = true
L["Holy Power"] = true
L["Rare"] = true
L["Rare-Elite"] = true
L["Elite"] = true
L["Boss"] = true

L["Rare_short"] = true
L["Rare-Elite_short"] = true
L["Elite_short"] = true
L["Boss_short"] = true

L["Priest_short"] = "Pr"
L["Mage_short"] = "Ma"
L["Shaman_short"] = "Sh"
L["Paladin_short"] = "Pa"
L["Warlock_short"] = "WL"
L["Druid_short"] = "Dr"
L["Rogue_short"] = "Rg"
L["Hunter_short"] = "Hu"
L["Warrior_short"] = "Wa"
L["Death Knight_short"] = "DK"

L["Offline"] = true

L["Ghost"] = true
L["Dead"] = true

L["Bear"] = true
L["Cat"] = true
L["Moonkin"] = true
L["Tree"] = true
L["Travel"] = true
L["Aquatic"] = true
L["Flight"] = true

L["Feigned Death"] = true



L["Player"] = true
L["Target"] = true
L["%s's pet"] = true
L["Player"] = true
L["Focus"] = true
L["Mouse-over"] = true
L["%s's pet"] = true
L["%s's target"] = true
L["Vehicle"] = true

L["Mana"] = true
L["Rage"] = true
L["Focus"] = true
L["Energy"] = true
L["Happiness"] = true
L["Runes"] = true
L["Runic Power"] = true
L["Soul Shards"] = true
L["Eclipse"] = true
L["Holy Power"] = true

L["Rare_short"] = "r"
L["Rare-Elite_short"] = "r+"
L["Elite_short"] = "+"
L["Boss_short"] = "b"

L["Priest"] = true
L["Mage"] = true
L["Shaman"] = true
L["Paladin"] = true
L["Warlock"] = true
L["Druid"] = true
L["Rogue"] = true
L["Hunter"] = true
L["Warrior"] = true
L["Death Knight"] = true
L["Priest_female"] = "Priest"
L["Mage_female"] = "Mage"
L["Shaman_female"] = "Shaman"
L["Paladin_female"] = "Paladin"
L["Warlock_female"] = "Warlock"
L["Warlock_short"] = "WL"
L["Druid_female"] = "Druid"
L["Rogue_female"] = "Rogue"
L["Hunter_female"] = "Hunter"
L["Warrior_female"] = "Warrior"
L["Death Knight_female"] = "Death Knight"

L["Blood Elf"] = true
L["Blood Elf_short"] = "BE"
L["Draenei"] = true
L["Draenei_short"] = "Dr"
L["Dwarf"] = true
L["Dwarf_short"] = "Dw"
L["Gnome"] = true
L["Gnome_short"] = "Gn"
L["Human"] = true
L["Human_short"] = "Hu"
L["Night Elf"] = true
L["Night Elf_short"] = "NE"
L["Orc"] = true
L["Orc_short"] = "Or"
L["Tauren"] = true
L["Tauren_short"] = "Ta"
L["Troll"] = true
L["Troll_short"] = "Tr"
L["Undead"] = true
L["Undead_short"] = "UD"
L["Blood Elf_female"] = "Blood Elf"
L["Blood Elf_short"] = "BE"
L["Draenei_female"] = "Draenei"
L["Dwarf_female"] = "Dwarf"
L["Gnome_female"] = "Gnome"
L["Human_female"] = "Human"
L["Night Elf_female"] = "Night Elf"
L["Orc_female"] = "Orc"
L["Tauren_female"] = "Tauren"
L["Troll_female"] = "Troll"
L["Undead_female"] = "Undead"

L["Offline"] = true

L["Ghost"] = true
L["Dead"] = true

L["Bear"] = true
L["Cat"] = true
L["Moonkin"] = true
L["Tree"] = true
L["Travel"] = true
L["Aquatic"] = true
L["Flight"] = true

L["Feigned Death"] = true

L["Fetching"] = true

-- PluginTalents

L["Melee"] = true
L["Ranged"] = true
L["Healer"] = true
L["Tank"] = true

L["Out of Range"] = true
L["Scanning"] = true


-- AVSSuperScope

L["Replace"] = true
L["Add"] = true
L["Max"] = true
L["Average"] = true
L["Subtractive (1-2)"] = true
L["Subtractive (2-1)"] = true
L["Multiplicative"] = true
L["Adjustable (cc=blend ratio)"] = true
L["XOR"] = true
L["Minimum"] = true
L["Enabled"] = true
L["Width"] = true
L["Height"] = true
L["Pixel"] = true
L["Size per pixel"] = true
L["Draw Layer"] = true
L["Draw Layer"] = true
L["Draw Mode"] = true
L["Blend Mode"] = true
L["The selected method of blending"] = true
L["Unit ID"] = true
L["Use this unit for noise input"] = true
L["Init Script"] = true
L["Called once to initialize the script environment."] = true
L["Beat Script"] = true
L["Called when hitting a critical strike."] = true
L["Frame Script"] = true
L["Called at each animation frame."] = true
L["Point Script"] = true
L["Called for each point."] = true