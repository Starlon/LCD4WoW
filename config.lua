local TRANSITION_RIGHT = 0
local TRANSITION_LEFT = 1
local TRANSITION_BOTH = 2
local TRANSITION_UP = 3
local TRANSITION_DOWN = 4
local TRANSITION_TENTACLE = 5
local TRANSITION_ALPHABLEND = 6
local TRANSITION_CHECKERBOARD = 7

local ALIGN_LEFT, ALIGN_CENTER, ALIGN_RIGHT, ALIGN_MARQUEE, ALIGN_AUTOMATIC, ALIGN_PINGPONG = 1, 2, 3, 4, 5, 6
local SCROLL_RIGHT, SCROLL_LEFT = 1, 2

local foo = 500

LCD4WoW.config = {
    ["display_startip"] = {
		["addon"] = "LCD4WoW",
		["enabled"] = true,
		["driver"] = "qtip",
		["layers"] = 2,
		["background"] = "d9ccf16f",
		["row"] = 500,
		["col"] = 0,
		["rows"] = 6,
		["cols"] = 30,
		["update"] = 100,
		["timeout"] = 2000,
		["transition_speed"] = 50,
		["widgets"] = {"widget_key_up", "widget_key_down", "widget_resources_timer"},
		["layouts"] = {"layout_lcd4wow", "layout_histogram_cpu", "layout_histogram_mem"},
		["font"] = {normal="Interface\\AddOns\\LCD4WoW\\Fonts\\ttf-bitstream-vera-1.10\\VeraMo.ttf", bold="Interface\\AddOns\\LCD4WoW\\Fonts\\ttf-bitstream-vera-1.10\\VeraMoBd.ttf", size=12},
    },
    ["display_character"] = {
		["addon"] = "LCD4WoW",
		["enabled"] = false,
		["driver"] = "character",
		["layers"] = 2,
		["background"] = "d9ccf16f",
		["pixel"] = 2,
		["row"] = -50,
		["col"] = 0,
		["rows"] = 4,
		["cols"] = 30,
		["update"] = 100,
		["timeout"] = 7000,
		["transition_speed"] = 50,
		["widgets"] = {"widget_key_up", "widget_key_down", "widget_resources_timer"},
		["layouts"] = {"layout_histogram_mem", "layout_histogram_cpu"},
    },
	["widget_resources_timer"] = {
        type = "timer",
		update = 1000,
		repeating = true,
		expression = [[
if ResourceServer then self.timer:Stop(); return end
Update()
]]
	},
	["layout_tiny"] = {
		[1] = {
			[1] = {
				[1] = "widget_name"
			}
		}
	},
	["layout_blank"] = {
		["keyless"] = 1,
		["layout-timeout"] = 0
    },
	["layout_lcd4wow"] = {
		[1] = {
			[1] = { -- row
				[1] = "widget_name_label", -- column
				[10] = "widget_name"
			},
			[2] = {
				[1] = "widget_class_label",
				[10] = "widget_class"
			},
			[3] = {
				[1] = "widget_race_label",
				[10] = "widget_race",
			},
			[4] = {
				[1] = "widget_level_label",
				[10] = "widget_level",
			},
			[5] = {
				[1] = "widget_mem_label",
				[10] = "widget_mem",
				[20] = "widget_mem_bar"
			},
			[6] = {
				[1] = "widget_cpu_label",
				[10] = "widget_cpu",
				[20] = "widget_cpu_bar"
			},
		},
		["transition"] = TRANSITION_TENTACLE,
    },
	["layout_histogram_cpu"] = {
		[2] = {
			[1] = {
				[1] = "widget_cpu_histogram"
			},
		},
		[1] = {
			[3] = {
				[1] = "widget_cpu_perc"
			}
		},
		["transition"] = TRANSITION_BOTH,
		["timeout"] = 2000
	},
	["layout_histogram_mem"] = {
		[2] = {
			[1] = {
				[1] = "widget_mem_histogram"
			},
		},
		[1] = {
			[3] = {
				[1] = "widget_mem_perc"
			}
		},
		["transition"] = TRANSITION_CHECKERBOARD,
		["timeout"] = 2000
	},
	["widget_name_label"] = {
		type = "text",
		value = 'return "Name:"',
		precision = 0xbabe,
		align = ALIGN_RIGHT,
		cols = 9,
		color = "return 0xffffffff"
	},
	["widget_name"] = {
		type = "text",
		value = "return '--' .. select(1, UnitName('player')) .. '--'",
		cols = 20,
		align = ALIGN_PINGPONG,
		update = 1000,
		speed = 100,
		direction = SCROLL_LEFT,
		dontRtrim = true
	},
	["widget_class_label"] = {
		type = "text",
		value = 'return "Class:"',
		cols = 9,
		align = ALIGN_RIGHT
	},
	["widget_class"] = {
		type = "text",
		value = "return UnitClass('player')",
		cols = 10
	},
	["widget_race_label"] = {
		type = "text",
		value = 'return "Race:"',
		cols = 9,
		align = ALIGN_RIGHT
	},
	["widget_race"] = {
		type = "text",
		value = "return UnitRace('player')",
		cols = 10
	},
	["widget_level_label"] = {
		type = "text",
		value = 'return "Level:"',
		cols = 9,
		align = ALIGN_RIGHT,
	},
	["widget_level"] = {
		type = "text",
		value = "return UnitLevel('player')",
		cols = 10
	},
	["widget_mem_label"] = {
		type = "text",
		value = "return 'Memory:'",
		cols = 9,
		align = ALIGN_RIGHT
	},
	["widget_mem"] = {
		type = "text",
		value = [[
mem = GetMemUsage("LCD4WoW")
--do return random(100) .. "%" end
if mem then
    return memshort(tonumber(format("%.2f", mem)))
end
]],
		cols = 10,
		update = 1000,
		dontRtrim = true
	},
	["widget_mem_perc"] = {
		type = "text",
		value = [[
--do return random(100) .. "%" end
mem, percent, memdiff, totalMem, totaldiff = GetMemUsage("LCD4WoW")

if mem then
    if totaldiff == 0 then totaldiff = 1 end
    return '-==MEM:: ' .. format("%.2f", memdiff / totaldiff * 100) .. "%" .. "::MEM==-"
end
]],
		align = ALIGN_PINGPONG,
		direction = SCROLL_RIGHT,
		cols = 30,
		update = 1000,
		speed = 100,
		dontRtrim = true
	},
	["widget_mem_bar"] = {
		type = "bar",
		expression = [[
--do return random(100) end
mem, percent, memdiff, totalMem, totaldiff = GetMemUsage("LCD4WoW")

if mem then
    if totaldiff == 0 then return 0 end
    return memdiff / totaldiff * 100
end
]],
		min = "return 0",
		max = "return 100",
		length = 10
	},
	["widget_mem_histogram"] = {
		type = "histogram",
		expression = [[
--do return random(100) end
mem, percent, memdiff, totalMem, totaldiff = GetMemUsage("LCD4WoW")

if mem then
    if totaldiff == 0 then totaldiff = 1 end
    return memdiff / totaldiff * 100
end
]],
		min = "return 0",
		max = "return 100",
		reversed = true,
		char = "0",
		width = 30,
		height = 6,
		layer = 1
	},
	["widget_cpu_label"] = {
		type = "text",
		value = "return 'CPU:'",
		cols = 9,
		align = ALIGN_RIGHT
	},
	["widget_cpu"] = {
		type = "text",
		value = [[
--do return timeshort(random(10000)) end
cpu = GetCPUUsage("LCD4WoW")

if cpu then
    return timeshort(cpu)
end
]],
		cols = 10,
		update = 1000,
		dontRtrim = true
	},
	["widget_cpu_bar"] = {
		type = "bar",
		expression = [[
--do return random(100) end
cpu, percent, cpudiff, totalCPU, totaldiff = GetCPUUsage("LCD4WoW")

if cpu then
    if totaldiff == 0 then return 0 end
    return cpudiff / totaldiff * 100
end
]],
		min = "return 0",
		max = "return 100",
		length = 10
	},
	["widget_cpu_histogram"] = {
		type = "histogram",
		expression = [[
if not scriptProfile then return random(100) end
cpu, percent, cpudiff, totalCPU, totaldiff = GetCPUUsage("LCD4WoW")

if cpu then
    if totaldiff == 0 then return 0 end
    return cpudiff / totaldiff * 100
end
]],
		min = "return 0",
		max = "return 100",
		width = 30,
		height = 6
	},
	["widget_cpu_perc"] = {
		type = "text",
		value = [[
--do return format("------%d%%-------", random(100)) end
cpu, percent, cpudiff, totalCPU, totaldiff = GetCPUUsage("LCD4WoW")

if cpu then
    if totaldiff == 0 then totaldiff = 1 end
    return '-==CPU::' .. format("%.2f", cpudiff / totaldiff * 100) .. "%" .. "::CPU==-"
end
]],
		align = ALIGN_PINGPONG,
		direction = SCROLL_RIGHT,
		cols = 30,
		update = 1000,
		speed = 100,
		dontRtrim = true
	},
	["widget_icon_blob"] = {
		["bitmap"] = {
    		["row1"] = ".....|.....|.....",
    		["row2"] = ".....|.....|.***.",
    		["row3"] = ".....|.***.|*...*",
    		["row4"] = "..*..|.*.*.|*...*",
    		["row5"] = ".....|.***.|*...*",
    		["row6"] = ".....|.....|.***.",
    		["row7"] = ".....|.....|.....",
    		["row8"] = ".....|.....|....."
        },
		["speed"] = "return foo",
		["type"] = "icon"
    },
	["widget_icon_ekg"] = {
		["bitmap"] = {
    		["row1"] = ".....|.....|.....|.....|.....|.....|.....|.....",
    		["row2"] = ".....|....*|...*.|..*..|.*...|*....|.....|.....",
    		["row3"] = ".....|....*|...*.|..*..|.*...|*....|.....|.....",
    		["row4"] = ".....|....*|...**|..**.|.**..|**...|*....|.....",
    		["row5"] = ".....|....*|...**|..**.|.**..|**...|*....|.....",
    		["row6"] = ".....|....*|...*.|..*.*|.*.*.|*.*..|.*...|*....",
    		["row7"] = "*****|*****|****.|***..|**..*|*..**|..***|.****",
    		["row8"] = ".....|.....|.....|.....|.....|.....|.....|....."
        },
		["speed"] = "return foo",
		["type"] = "icon"
    },
	["widget_icon_heart"] = {
		["bitmap"] = {
    		["row1"] = ".....|.....|.....|.....|.....|.....",
    		["row2"] = ".*.*.|.....|.*.*.|.....|.....|.....",
    		["row3"] = "*****|.*.*.|*****|.*.*.|.*.*.|.*.*.",
    		["row4"] = "*****|.***.|*****|.***.|.***.|.***.",
    		["row5"] = ".***.|.***.|.***.|.***.|.***.|.***.",
    		["row6"] = ".***.|..*..|.***.|..*..|..*..|..*..",
    		["row7"] = "..*..|.....|..*..|.....|.....|.....",
    		["row8"] = ".....|.....|.....|.....|.....|....."
        },
		["speed"] = "return foo",
		["type"] = "icon"
    },
	["widget_icon_heartbeat"] = {
		["bitmap"] = {
    		["row1"] = ".....|.....",
    		["row2"] = ".*.*.|.*.*.",
    		["row3"] = "*****|*.*.*",
    		["row4"] = "*****|*...*",
    		["row5"] = ".***.|.*.*.",
    		["row6"] = ".***.|.*.*.",
    		["row7"] = "..*..|..*..",
    		["row8"] = ".....|....."
        },
		["speed"] = "return foo",
		["type"] = "icon"
    },
	["widget_icon_karo"] = {
		["bitmap"] = {
    		["row1"] = ".....|.....|.....|.....|..*..|.....|.....|.....",
    		["row2"] = ".....|.....|.....|..*..|.*.*.|..*..|.....|.....",
    		["row3"] = ".....|.....|..*..|.*.*.|*...*|.*.*.|..*..|.....",
    		["row4"] = ".....|..*..|.*.*.|*...*|.....|*...*|.*.*.|..*..",
    		["row5"] = ".....|.....|..*..|.*.*.|*...*|.*.*.|..*..|.....",
    		["row6"] = ".....|.....|.....|..*..|.*.*.|..*..|.....|.....",
    		["row7"] = ".....|.....|.....|.....|..*..|.....|.....|.....",
    		["row8"] = ".....|.....|.....|.....|.....|.....|.....|....."
        },
		["speed"] = "return foo",
		["type"] = "icon"
    },
	["widget_icon_rain"] = {
		["bitmap"] = {
    		["row1"] = "...*.|.....|.....|.*...|....*|..*..|.....|*....",
    		["row2"] = "*....|...*.|.....|.....|.*...|....*|..*..|.....",
    		["row3"] = ".....|*....|...*.|.....|.....|.*...|....*|..*..",
    		["row4"] = "..*..|.....|*....|...*.|.....|.....|.*...|....*",
    		["row5"] = "....*|..*..|.....|*....|...*.|.....|.....|.*...",
    		["row6"] = ".*...|....*|..*..|.....|*....|...*.|.....|.....",
    		["row7"] = ".....|.*...|....*|..*..|.....|*....|...*.|.....",
    		["row8"] = ".....|.....|.*...|....*|..*..|.....|*....|...*."
        },
		["speed"] = "return foo",
		["type"] = "icon"
    },
	["widget_icon_squirrel"] = {
		["bitmap"] = {
    		["row1"] = ".....|.....|.....|.....|.....|.....",
    		["row2"] = ".....|.....|.....|.....|.....|.....",
    		["row3"] = ".....|.....|.....|.....|.....|.....",
    		["row4"] = "**...|.**..|..**.|...**|....*|.....",
    		["row5"] = "*****|*****|*****|*****|*****|*****",
    		["row6"] = "...**|..**.|.**..|**...|*....|.....",
    		["row7"] = ".....|.....|.....|.....|.....|.....",
    		["row8"] = ".....|.....|.....|.....|.....|....."
        },
		["speed"] = "return foo",
		["type"] = "icon"
    },
	["widget_icon_timer"] = {
		["bitmap"] = {
    		["row1"] = ".....|.....|.....|.....|.....|.....|.....|.....|.....|.....|.....|.....|.....|.....|.....|.....|.....|.....|.....|.....|.....|.....|.....|.....|",
    		["row2"] = ".***.|.*+*.|.*++.|.*++.|.*++.|.*++.|.*++.|.*++.|.*++.|.*++.|.*++.|.*++.|.+++.|.+*+.|.+**.|.+**.|.+**.|.+**.|.+**.|.+**.|.+**.|.+**.|.+**.|.+**.|",
    		["row3"] = "*****|**+**|**++*|**+++|**++.|**++.|**+++|**+++|**+++|**+++|**+++|+++++|+++++|++*++|++**+|++***|++**.|++**.|++***|++***|++***|++***|++***|*****|",
    		["row4"] = "*****|**+**|**+**|**+**|**+++|**+++|**+++|**+++|**+++|**+++|+++++|+++++|+++++|++*++|++*++|++*++|++***|++***|++***|++***|++***|++***|*****|*****|",
    		["row5"] = "*****|*****|*****|*****|*****|***++|***++|**+++|*++++|+++++|+++++|+++++|+++++|+++++|+++++|+++++|+++++|+++**|+++**|++***|+****|*****|*****|*****|",
    		["row6"] = ".***.|.***.|.***.|.***.|.***.|.***.|.**+.|.*++.|.+++.|.+++.|.+++.|.+++.|.+++.|.+++.|.+++.|.+++.|.+++.|.+++.|.++*.|.+**.|.***.|.***.|.***.|.***.|",
    		["row7"] = ".....|.....|.....|.....|.....|.....|.....|.....|.....|.....|.....|.....|.....|.....|.....|.....|.....|.....|.....|.....|.....|.....|.....|.....|",
    		["row8"] = ".....|.....|.....|.....|.....|.....|.....|.....|.....|.....|.....|.....|.....|.....|.....|.....|.....|.....|.....|.....|.....|.....|.....|.....|"
        },
		["speed"] = "return foo",
		["type"] = "icon"
    },
	["widget_icon_wave"] = {
		["bitmap"] = {
    		["row1"] = "..**.|.**..|**...|*....|.....|.....|.....|.....|....*|...**",
    		["row2"] = ".*..*|*..*.|..*..|.*...|*....|.....|.....|....*|...*.|..*..",
    		["row3"] = "*....|....*|...*.|..*..|.*...|*....|....*|...*.|..*..|.*...",
    		["row4"] = "*....|....*|...*.|..*..|.*...|*....|....*|...*.|..*..|.*...",
    		["row5"] = "*....|....*|...*.|..*..|.*...|*....|....*|...*.|..*..|.*...",
    		["row6"] = ".....|.....|....*|...*.|..*..|.*..*|*..*.|..*..|.*...|*....",
    		["row7"] = ".....|.....|.....|....*|...**|..**.|.**..|**...|*....|.....",
    		["row8"] = ".....|.....|.....|.....|.....|.....|.....|.....|.....|....."
        },
		["speed"] = "return foo",
		["type"] = "icon"
    },
	["widget_key_down"] = {
		["expression"] = "lcd.Transition(-1)",
		["key"] = 2,
		["type"] = "key"
    },
	["widget_key_up"] = {
		["expression"] = "lcd.Transition(1)",
		["key"] = 1,
		["type"] = "key"
    },
	["widget_percent"] = {
		["expression"] = "'%'",
		["type"] = "text"
    }
}