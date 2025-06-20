-- CONSTANTS
local null_object   = 0x88888888 -- no object at that index
local out_of_bounds = 0xFFFFFFFF -- no such index
local zoomFactor    = 0.02
local minZoom       = 0.0001 -- ???
local panFactor     = 10
local charWidth     = 10
local charHeight    = 16
local maxBoundPos   = 0x7fffffffffffffff
local maxBoundNeg   = 0x8000000000000000
-- sizes in bytes
local short         = 2
local int           = 4
local pointer       = 8
local mobj_t        = 512 -- sizeof(mobj_t) is 464, but we padded it for niceness
local line_t        = 256 -- sizeof(mobj_t) is 232, but we padded it for niceness
-- shortcuts
local rl            = memory.read_u32_le
local rw            = memory.read_u16_le
local rb            = memory.read_u8_le
local rls           = memory.read_s32_le
local rws           = memory.read_s16_le
local rbs           = memory.read_s8_le
local text          = gui.text
local box           = gui.drawBox
local line          = gui.drawLine
--local text        = gui.pixelText -- INSANELY SLOW

-- VARIABLES
local zoom      = 1
local last_size = 0
local init      = true
-- tables
local off       = {} -- mobj member offsets in bytes
local mobjtype  = {}
local spritenum = {}
local objects   = {}
-- view offset
local pan = {
	x = 0,
	y = 0
}
-- object positions bounds
local OB = {
	top    = maxBoundPos,
	left   = maxBoundPos,
	bottom = maxBoundNeg,
	right  = maxBoundNeg
}
local lastScreenSize = {
	w = client.screenwidth(),
	h = client.screenheight()
}

gui.defaultPixelFont("fceux")
gui.use_surface("client")

local function mapify_x(coord)
	return math.floor(((coord / 0xffff)+pan.x)*zoom)
end

local function mapify_y(coord)
	return math.floor(((coord / 0xffff)+pan.y)*zoom)
end

local function in_range(var, minimum, maximum)
	return var >= minimum and var <= maximum
end

local function reset_view()
	init = true
	update_zoom()
end

local function zoom_out()
	local newZoom = zoom * (1 - zoomFactor)
	if newZoom < minZoom then return end
	zoom = newZoom
end

local function zoom_in()
	zoom = zoom * (1 + zoomFactor)
end

local function pan_left()
	pan.x = pan.x + panFactor/zoom/2
end

local function pan_right()
	pan.x = pan.x - panFactor/zoom/2
end

local function pan_up()
	pan.y = pan.y + panFactor/zoom/2
end

local function pan_down()
	pan.y = pan.y - panFactor/zoom/2
end

local function add_offset(size, name)
	off[name] = last_size
--	print(name, string.format("%X \t\t %X", size, last_size))
	last_size = size + last_size
end

function maybe_swap(left, right)
	if left > right then
		local smallest = right
		right = left
		left = smallest
	end
end

local function get_line_count(str)
	local lines = 1
	local longest = 0
	local size = 0
	for i = 1, #str do
		local c = str:sub(i, i)
		if c == '\n' then
			lines = lines + 1
			if size > longest then
				longest = size
				size = -1
			end
		end
		size = size + 1
	end
	if size > longest then longest = size end
	return lines, longest
end

local function iterate()
	if init then return end
	
	for _, addr in ipairs(objects) do
		local x      = rls(addr + off.x)
		local y      = rls(addr + off.y) * -1
		local health = rls(addr + off.health)
		local radius = math.floor((rls(addr + off.radius) >> 16) * zoom)
		local sprite = spritenum[rls(addr + off.sprite)]
		local type   = rl(addr + off.type)
		local pos    = { x = mapify_x(x), y = mapify_y(y) }
		local color  = "white"
			
		if type == 0
		then type = "PLAYER" print("PLAYER")
		else type = mobjtype[type]
		end
		if health <= 0 then color = "red" end
		--[[--
		local z      = rls(addr + off.z) / 0xffff
		local index  = rl (addr + off.index)
		local tics   = rl (addr + off.tics)
		--]]--
		if  in_range(pos.x, 0, client.screenwidth())
		and in_range(pos.y, 0, client.screenheight())
		then
		--	text(pos.x, pos.y, string.format("%s", type), color)
			box(pos.x - radius, pos.y - radius, pos.x + radius, pos.y + radius, color)
		end
	end
	
	for i = 0, 100000 do
		local addr = i * line_t
		if addr > 0xFFFFFF then break end
		
		local id = rl(addr, "Lines") & 0xFFFFFFFF
		if id == out_of_bounds then break end
		
		if id ~= null_object then
			local vertices_offset = 0xe8
			local v1 = { x =  rls(addr+vertices_offset   , "Lines"),
						 y = -rls(addr+vertices_offset+ 4, "Lines") }
			local v2 = { x =  rls(addr+vertices_offset+ 8, "Lines"),
						 y = -rls(addr+vertices_offset+12, "Lines") }
			line(
				mapify_x(v1.x),
				mapify_y(v1.y),
				mapify_x(v2.x),
				mapify_y(v2.y),
				0xffcccccc
			)
		end
	end
end

local function init_objects()
	for i = 0, 100000 do
		local addr = i * mobj_t
		if addr > 0xFFFFFF then break end
		
		local thinker = rl(addr) & 0xFFFFFFFF -- just to check if mobj is there
		if thinker == out_of_bounds then break end
		
		if thinker ~= null_object then
			local x    = rls(addr + off.x) / 0xffff
			local y    = rls(addr + off.y) / 0xffff * -1
			local type = rl(addr + off.type)
			
			if type == 0
			then type = "PLAYER" print("PLAYER")
			else type = mobjtype[type]
			end
		--	print(string.format("%d %f %f %02X", index, x, y, type))
			if type
			and not string.find(type, "MISC")
			then
				if x < OB.left   then OB.left   = x end
				if x > OB.right  then OB.right  = x end
				if y < OB.top    then OB.top    = y end
				if y > OB.bottom then OB.bottom = y end
				-- cache the objects we need
				table.insert(objects, addr)
			end
		end
	end
end

function update_zoom()
	if not init
	and lastScreenSize.w == client.screenwidth()
	and lastScreenSize.h == client.screenheight()
	then return end
	
	if  OB.top    ~= maxBoundPos
	and OB.left   ~= maxBoundPos
	and OB.right  ~= maxBoundNeg
	and OB.bottom ~= maxBoundNeg
	and not emu.islagged()
	then
		maybe_swap(OB.right, OB.left)
		maybe_swap(OB.top,   OB.bottom)
		local span        = { x = OB.right-OB.left+200, y = OB.bottom-OB.top+200 }
		local scale       = { x = client.screenwidth()/span.x, y = client.screenheight()/span.y }
		local spanCenter  = { x = OB.left+span.x/2, y = OB.top+span.y/2 }
		      zoom        = math.min(scale.x, scale.y)
		local sreenCenter = { x = client.screenwidth()/zoom/2, y = client.screenheight()/zoom/2 }
		      pan.x       = -math.floor(spanCenter.x - sreenCenter.x)
		      pan.y       = -math.floor(spanCenter.y - sreenCenter.y)
		      init        = false
	end
end

local function make_button(x, y, name, func)
	local boxWidth   = charWidth
	local boxHeight  = charHeight
	local lineCount,
	      longest    = get_line_count(name)
	local textWidth  = longest  *charWidth
	local textHeight = lineCount*charHeight
	local colors     = { 0x66bbddff, 0xaabbddff, 0xaa88aaff }
	local colorIndex = 1
	
	if textWidth  + 10 > boxWidth  then boxWidth  = textWidth  + 10 end
	if textHeight + 10 > boxHeight then boxHeight = textHeight + 10 end
	
	local textX    = x + boxWidth /2 - textWidth /2
	local textY    = y + boxHeight/2 - textHeight/2 - boxHeight
	local mouse    = input.getmouse()
	local mousePos = client.transformPoint(mouse.X, mouse.Y)
	
	if  in_range(mousePos.x, x, x+boxWidth)
	and in_range(mousePos.y, y-boxHeight, y) then
		if mouse.Left then
			colorIndex = 3
			func()
		else colorIndex = 2 end
	end
	
	box(x, y, x+boxWidth, y-boxHeight, 0xaaffffff, colors[colorIndex])
	text(textX, textY, name, colors[colorIndex] | 0xff000000) -- full alpha
end

--[[--
thinker		30 0
x			4 30
y			4 34
z			4 38
snext		8 3C
sprev		8 44
angle		4 4C
sprite		4 50
frame		4 54
bnext		8 58
bprev		8 60
subsector	8 68
floorz		4 70
ceilingz	4 74
dropoffz	4 78
radius		4 7C
height		4 80
momx		4 84
momy		4 88
momz		4 8C
validcount	4 90
type		4 94
info		8 98
tics		4 A0
state		8 A4
flags		8 AC
intflags	4 B4
health		4 B8
movedir		2 BC
movecount	2 BE
strafecount	2 C0
target		8 C2
reactiontime 2 CA
threshold	2 CC
pursuecount	2 CE
gear		2 D0
player		8 D2
lastlook	2 DA
spawnpoint	3A DC
tracer		8 116
lastenemy	8 11E
friction	4 126
movefactor	4 12A
touching_sectorlist	8 12E
PrevX		4 136
PrevY		4 13A
PrevZ		4 13E
pitch		4 142
index		4 146
patch_width	2 14A
iden_nums	4 14C
--]]--

add_offset(48,      "thinker")
add_offset(int,     "x")
add_offset(int,     "y")
add_offset(int,     "z")
add_offset(int,     "padding1")
add_offset(pointer, "snext")
add_offset(pointer, "sprev")
add_offset(int,     "angle")
add_offset(int,     "sprite")
add_offset(int,     "frame")
add_offset(int,     "padding2")
add_offset(pointer, "bnext")
add_offset(pointer, "bprev")
add_offset(pointer, "subsector")
add_offset(int,     "floorz")
add_offset(int,     "ceilingz")
add_offset(int,     "dropoffz")
add_offset(int,     "radius")
add_offset(int,     "height")
add_offset(int,     "momx")
add_offset(int,     "momy")
add_offset(int,     "momz")
add_offset(int,     "validcount")
add_offset(int,     "type")
add_offset(pointer, "info")
add_offset(int,     "tics")
add_offset(int,     "padding3")
add_offset(pointer, "state")
add_offset(8,       "flags")
add_offset(int,     "intflags")
add_offset(int,     "health")
add_offset(short,   "movedir")
add_offset(short,   "movecount")
add_offset(short,   "strafecount")
add_offset(short,   "padding4")
add_offset(pointer, "target")
add_offset(short,   "reactiontime")
add_offset(short,   "threshold")
add_offset(short,   "pursuecount")
add_offset(short,   "gear")
add_offset(pointer, "player")
add_offset(short,   "lastlook")
add_offset(58,      "spawnpoint")
add_offset(int,     "padding5") -- unsure where this one should be exactly
add_offset(pointer, "tracer")
add_offset(pointer, "lastenemy")
add_offset(int,     "friction")
add_offset(int,     "movefactor")
add_offset(pointer, "touching_sectorlist")
add_offset(int,     "PrevX")
add_offset(int,     "PrevY")
add_offset(int,     "PrevZ")
add_offset(int,     "pitch")
add_offset(int,     "index")
add_offset(short,   "patch_width")
add_offset(int,     "iden_nums")
-- the rest are non-doom
-- print(off)

mobjtype = {
--	"NULL" = -1,
--	"ZERO",
--	"PLAYER = ZERO",
	"POSSESSED",
	"SHOTGUY",
	"VILE",
	"FIRE",
	"UNDEAD",
	"TRACER",
	"SMOKE",
	"FATSO",
	"FATSHOT",
	"CHAINGUY",
	"TROOP",
	"SERGEANT",
	"SHADOWS",
	"HEAD",
	"BRUISER",
	"BRUISERSHOT",
	"KNIGHT",
	"SKULL",
	"SPIDER",
	"BABY",
	"CYBORG",
	"PAIN",
	"WOLFSS",
	"KEEN",
	"BOSSBRAIN",
	"BOSSSPIT",
	"BOSSTARGET",
	"SPAWNSHOT",
	"SPAWNFIRE",
	"BARREL",
	"TROOPSHOT",
	"HEADSHOT",
	"ROCKET",
	"PLASMA",
	"BFG",
	"ARACHPLAZ",
	"PUFF",
	"BLOOD",
	"TFOG",
	"IFOG",
	"TELEPORTMAN",
	"EXTRABFG",
	"MISC0",
	"MISC1",
	"MISC2",
	"MISC3",
	"MISC4",
	"MISC5",
	"MISC6",
	"MISC7",
	"MISC8",
	"MISC9",
	"MISC10",
	"MISC11",
	"MISC12",
	"INV",
	"MISC13",
	"INS",
	"MISC14",
	"MISC15",
	"MISC16",
	"MEGA",
	"CLIP",
	"MISC17",
	"MISC18",
	"MISC19",
	"MISC20",
	"MISC21",
	"MISC22",
	"MISC23",
	"MISC24",
	"MISC25",
	"CHAINGUN",
	"MISC26",
	"MISC27",
	"MISC28",
	"SHOTGUN",
	"SUPERSHOTGUN",
	"MISC29",
	"MISC30",
	"MISC31",
	"MISC32",
	"MISC33",
	"MISC34",
	"MISC35",
	"MISC36",
	"MISC37",
	"MISC38",
	"MISC39",
	"MISC40",
	"MISC41",
	"MISC42",
	"MISC43",
	"MISC44",
	"MISC45",
	"MISC46",
	"MISC47",
	"MISC48",
	"MISC49",
	"MISC50",
	"MISC51",
	"MISC52",
	"MISC53",
	"MISC54",
	"MISC55",
	"MISC56",
	"MISC57",
	"MISC58",
	"MISC59",
	"MISC60",
	"MISC61",
	"MISC62",
	"MISC63",
	"MISC64",
	"MISC65",
	"MISC66",
	"MISC67",
	"MISC68",
	"MISC69",
	"MISC70",
	"MISC71",
	"MISC72",
	"MISC73",
	"MISC74",
	"MISC75",
	"MISC76",
	"MISC77",
	"MISC78",
	"MISC79",
	"MISC80",
	"MISC81",
	"MISC82",
	"MISC83",
	"MISC84",
	"MISC85",
	"MISC86",
	"PUSH",
	"PULL",
	"DOGS",
	"PLASMA1",
	"PLASMA2"
}

spritenum = {
--	"TROO",
	"SHTG",
	"PUNG",
	"PISG",
	"PISF",
	"SHTF",
	"SHT2",
	"CHGG",
	"CHGF",
	"MISG",
	"MISF",
	"SAWG",
	"PLSG",
	"PLSF",
	"BFGG",
	"BFGF",
	"BLUD",
	"PUFF",
	"BAL1",
	"BAL2",
	"PLSS",
	"PLSE",
	"MISL",
	"BFS1",
	"BFE1",
	"BFE2",
	"TFOG",
	"IFOG",
	"PLAY",
	"POSS",
	"SPOS",
	"VILE",
	"FIRE",
	"FATB",
	"FBXP",
	"SKEL",
	"MANF",
	"FATT",
	"CPOS",
	"SARG",
	"HEAD",
	"BAL7",
	"BOSS",
	"BOS2",
	"SKUL",
	"SPID",
	"BSPI",
	"APLS",
	"APBX",
	"CYBR",
	"PAIN",
	"SSWV",
	"KEEN",
	"BBRN",
	"BOSF",
	"ARM1",
	"ARM2",
	"BAR1",
	"BEXP",
	"FCAN",
	"BON1",
	"BON2",
	"BKEY",
	"RKEY",
	"YKEY",
	"BSKU",
	"RSKU",
	"YSKU",
	"STIM",
	"MEDI",
	"SOUL",
	"PINV",
	"PSTR",
	"PINS",
	"MEGA",
	"SUIT",
	"PMAP",
	"PVIS",
	"CLIP",
	"AMMO",
	"ROCK",
	"BROK",
	"CELL",
	"CELP",
	"SHEL",
	"SBOX",
	"BPAK",
	"BFUG",
	"MGUN",
	"CSAW",
	"LAUN",
	"PLAS",
	"SHOT",
	"SGN2",
	"COLU",
	"SMT2",
	"GOR1",
	"POL2",
	"POL5",
	"POL4",
	"POL3",
	"POL1",
	"POL6",
	"GOR2",
	"GOR3",
	"GOR4",
	"GOR5",
	"SMIT",
	"COL1",
	"COL2",
	"COL3",
	"COL4",
	"CAND",
	"CBRA",
	"COL6",
	"TRE1",
	"TRE2",
	"ELEC",
	"CEYE",
	"FSKU",
	"COL5",
	"TBLU",
	"TGRN",
	"TRED",
	"SMBT",
	"SMGT",
	"SMRT",
	"HDB1",
	"HDB2",
	"HDB3",
	"HDB4",
	"HDB5",
	"HDB6",
	"POB1",
	"POB2",
	"BRS1",
	"TLMP",
	"TLP2",
	"TNT1",
	"DOGS",
	"PLS1",
	"PLS2",
	"BON3",
	"BON4",
	"BLD2"
}

while true do
	if init then init_objects() end
	iterate()	
	update_zoom()
	make_button( 10, client.screenheight()-70, "Zoom\nIn"   , zoom_in   )
	make_button( 10, client.screenheight()-10, "Zoom\nOut"  , zoom_out  )
	make_button( 80, client.screenheight()-40, "Pan\nLeft"  , pan_left  )
	make_button(150, client.screenheight()-70, "Pan \nUp"   , pan_up    )
	make_button(150, client.screenheight()-10, "Pan\nDown"  , pan_down  )
	make_button(220, client.screenheight()-40, "Pan\nRight" , pan_right )
	make_button(300, client.screenheight()-10, "Reset\nView", reset_view)
	text(10, client.screenheight()-170, string.format(
		"Zoom: %.4f\nPanX: %s\nPanY: %s", 
		zoom, pan.x, pan.y), 0xffbbddff)
	lastScreenSize.w = client.screenwidth()
	lastScreenSize.h = client.screenheight()
	emu.frameadvance()
end