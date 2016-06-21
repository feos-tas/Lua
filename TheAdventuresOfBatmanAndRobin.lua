-- The Adventures of Batman and Robin
-- 2013-2016, feos and r57shell

-- GLOBALS --
MsgTable  = {}
MsgTime   = 30
MsgOffs   = 16
MsgCutoff = 60
RNGcount  = 0
SpawnCount= 0
SpawnOpac = 192
SpawnX    = 0
SpawnY    = 0
Enemies   = 0
Items     = 0
Hearts    = 0

-- SHORTCUTS --
rb  = memory.readbyte
rbs = memory.readbytesigned
rw  = memory.readword
rws = memory.readwordsigned
rl  = memory.readlong
rls = memory.readlongsigned
rex = memory.registerexec
getr= memory.getregister

function GetCam()
	xcam = rws(0xFFDFC4)
	if rb(0xFFFFF6) == 50 then
		ycam= rws(0xFFDFE0)-20
	else
		ycam = 0
	end
end

function EnemyPos(Base)
	GetCam()
	x1 = rws(Base + 0x12) - xcam
	y1 = rws(Base + 0x14) - ycam
	x2 = rws(Base + 0x16) - xcam
	y2 = rws(Base + 0x18) - ycam
	hp = rws(Base + 0x1E)
end

function PlayerPos()
	local sbase1 = rw(0xFFAD5C) + 0xFF0000
	local sbase2 = rw(0xFFADB6) + 0xFF0000
	p1speedx = rls(sbase1 + 0x18) / 0x10000
	p1speedy = rls(sbase1 + 0x1C) / 0x10000
	p2speedx = rls(sbase2 + 0x18) / 0x10000
	p2speedy = rls(sbase2 + 0x1C) / 0x10000
end

function HandleMsgTable(clear)
	for i = 1, #MsgTable do
		if (clear) then
			MsgTable[i] = nil
		end		
		if (MsgTable[i]) then
			GetCam()
			if (MsgTable[i].y_ > MsgCutoff) then
				MsgY1 = 0
				MsgY2 = 6
			else
				MsgY1 = 203
				MsgY2 = 203				
			end
			local opacity = AND((MsgTable[i].timer_ - gens.framecount() + 2)*7, 0xFF)
			gui.line(i * MsgOffs + 3, MsgY2, MsgTable[i].x_ - xcam, MsgTable[i].y_, 0xFF000000+opacity)
			gui.text(i * MsgOffs    , MsgY1, MsgTable[i].damage_, "red")
			if (MsgTable[i].timer_ < gens.framecount()) then
				MsgTable[i] = nil
			end
		end
	end
end

function HandleDamage()
	local damage = AND(getr("d0"),   0xFFFF)
	local base   = AND(getr("a2"), 0xFFFFFF)	
	EnemyPos(base)
	unit = {
		timer_ = gens.framecount() + MsgTime,
		damage_ = damage,
		x_ = x1 + xcam,
		y_ = y1
	}
	for i = 1, 200 do
		if MsgTable[i] == nil then
			MsgTable[i] = unit
			break
		end
	end
end

function Collision()
	GetCam()
	local a0 = AND(getr("a0"), 0xFFFFFF)
	local a6 = AND(getr("a6"), 0xFFFFFF)
	local damage = rw(a6 + 0x12)
	local id  = rw(a6 + 2)
	local wx2 = getr("d6") - xcam
	local wy2 = getr("d7") - ycam
	local wx1 = getr("d4") - xcam
	local wy1 = getr("d5") - ycam
--	gui.text(wx2 + 2, wy1 + 1, string.format("%X",a6))
	if (damage == 0) then
		damage = rw(a0 + 0x34)
	end
	if (DamageHitbox) then
		gui.box(wx1, wy1, wx2, wy2, "#FF000000")
		gui.text(wx1 + 2, wy1 + 1, damage)
	else
		gui.box(wx1, wy1, wx2, wy2, "#FFFF0000")
		if id == 0x53B4 then Hearts = Hearts + 1 end
	end
end

function InRange(var, num1, num2)
	if (var >=  num1) and (var <= num2)
	then return true
	end
end

function Item()
	GetCam()
	local a6   = AND(getr("a6"), 0xFFFFFF)
	local x    = rw(a6 + 0x3E) - xcam
	local y    = rw(a6 + 0x42)
	local code = rb(a6 + 0x19)
	if     InRange(code,  0,  1) then return
	elseif InRange(code,  7, 19) then item = "Amo" -- ammo
	elseif InRange(code, 21, 23) then item = "Cha" -- fast charge
	elseif InRange(code, 24, 26) then item = "Bom" -- bomb
	elseif InRange(code, 27, 29) then item = "Lif" -- life
	elseif InRange(code, 30, 47) then item = "HiP" -- hearts
	else                              item = tostring(code)
	end
	gui.text(x-7, y, string.format("%s"  , item   ), "yellow")
--	gui.text(x-7, y, string.format("\n%X", a6+0x19), "yellow")
end

function Hitbox(address)
	local i = 0
	local base = rw(address)	
	while (base ~= 0) do
		base = base + 0xFF0000
		if (rw(base + 2) == 0) then break end
		EnemyPos(base)
		if (address == 0xFFDEB2) then
			gui.box(x1, y1, x2, y2, "#00FF0000")
		elseif (address == 0xFFDEBA) then
			gui.box(x1, y1, x2, y2, "#00FFFF00")
			gui.text(x1 + 2, y1 + 1, hp, "#FF00FF")
		--	if (x2 <    0) then gui.text(x1 + 2, y2 - 7, "x:" .. x1      ) end
		--	if (x1 >= 320) then gui.text(x1 + 2, y2 - 7, "x:" .. x1 - 320) end
		--	if (y2 <    0) then gui.text(x2 + 2, y2 - 7, "y:" .. y2      ) end
			local offtext = ""
			if (x2 <    0) then offtext = offtext .. "x:" .. x1       end
			if (x1 >= 320) then offtext = offtext .. "x:" .. x1 - 320 end
			if (y2 <    0) then offtext = offtext .. "y:" .. y2       end
			if (y2 >= 224) then offtext = offtext .. "y:" .. y2 - 224 end
			if offtext ~= "" then
				gui.text(x1 + 2, y2 - 7, offtext)
			end
		end
		base = rw(base + 2)
		i = i + 1
		if (i > 400) then break end
	end
end

function Objects()
	if rb(0xFFFFF6) ~= 50 then return end
	Enemies = 0
	Items   = 0
	GetCam()
	local base = 0xFFAD54
	for i=0,100 do
		local link = rw (base+   6)
		local ptr1 = rw (base+0x0A)+0xFF0000
		local x    = rws(base+0x3E)
		local xsub = rb (base+0x40)
		local y    = rws(base+0x42)
		local ysub = rb (base+0x44)
		local hp   = rw (base+0x52)
		local ptr2 = rl (ptr1+0x2A)
		local code = rw (ptr2)
		if base > 0 then
			if ptr2 == 0x27DEE -- helicopter black
			or ptr2 == 0x27F9C -- helicopter red
			or ptr2 == 0x2804E -- plane black
			or ptr2 == 0x28134 -- helicopter green
			or ptr2 == 0x282B8 -- plane red
			or ptr2 == 0x2860A -- missile
			or ptr2 == 0x28DD2 -- helicopter red phase 1
			or ptr2 == 0x28E08 -- helicopter red phase 2
			then
				Enemies = Enemies + 1
			elseif ptr2 == 0x13326
			or     ptr2 == 0x13BDE
			then
				Items = Items + 1
			else
			--	gui.text(x - xcam, y - ycam, string.format("%X", ptr2), "green")
			end
		end
		base = link + 0xFF0000
		local a5   = rl (base)
		if a5 == 0x88BE then return end
	end
end

function Spawns()
	if rb(0xFFFFF6) ~= 50 then return end
	local base = AND(getr("a6"), 0xFFFFFF)
	local ptr1 = rw(base+0x0A) + 0xFF0000
	local ptr2 = rl(ptr1+0x2A)
	local code = rw(ptr2)
	SpawnX = rws(base+0x3E) - xcam
	SpawnY = rws(base+0x42) - ycam
	if  code ~= 0xAE6  -- drone
	and code ~= 0xAF2  -- mini-missile
	and code ~= 0x2384 -- item
	then
		SpawnOpac  = 192
		SpawnCount = SpawnCount + 1
	end
end

function Main()
	local color0  = "yellow"
	local color1  = "yellow"
	local color2  = "yellow"
	local base1   = 0xFFAD54
	local base2   = 0xFFADAE
--	local hp1     = rw (0xFFF654)
--	local life1   = rw (0xFFF644)
	local X1      = rw (base1 + 0x3E)
	local X1sub   = rb (base1 + 0x40)
	local Y1      = rws(base1 + 0x42)
	local Y1sub   = rb (base1 + 0x44)
	local X2      = rw (base2 + 0x3E)
	local X2sub   = rb (base2 + 0x40)
	local Y2      = rws(base2 + 0x42)
	local Y2sub   = rb (base2 + 0x44)
	local RNG1    = rw (0xFFF5FC)
--	local RNG2    = rl (0xFFF5FE)
	local Weapon1 = rb (0xFFF67B)
	local Weapon2 = rb (0xFFF6BB)
	local Charge1 = (rw(0xFFF658) - 0x2800) / -0x80
	local Charge2 = (rw(0xFFF698) - 0x2800) / -0x80
	local ScreenLock = rw(0xFFDFC0)
	if Charge1 <= 0 then Charge1 = 0; color1 = "red" end
	if Charge2 <= 0 then Charge2 = 0; color2 = "red" end
	if RNGcount > 1 then              color0 = "red" end
	HandleMsgTable()
	PlayerPos()
	Objects()
	if rb(0xFFFFF6) == 50 then
		gui.line( 34,  37, SpawnX, SpawnY, 0x00FF0000+ SpawnOpac)
		gui.text(  0,  30, string.format("Obj: %d"   , SpawnCount),"green")
		gui.text(  0,  38, string.format("%d %d %d"  , Enemies, Items, Hearts/2))
	end
	gui.text(  0, 210, string.format("\nRNG:%X"  , RNG1))
	gui.text( 40, 210, string.format("\nLock:%d" , ScreenLock))
	gui.text( 34, 210, string.format("\n%d"      , RNGcount),   color0)
	gui.text( 80,  20, string.format("%2d"       , Charge1),    color1)
	gui.text(235,  20, string.format("%2d"       , Charge2),    color2)
	gui.text(180, 210, string.format("\n%2d"     , Weapon1+1), "yellow")
	gui.text(300, 210, string.format("\n%2d"     , Weapon2+1), "yellow")
	gui.text( 81, 210, string.format("Pos: %d.%d\nSpd: %.5f", X1, X1sub, p1speedx), "#AAAAAA")
	gui.text(137, 210, string.format("/ %d.%d\n/ %.5f"      , Y1, Y1sub, p1speedy), "#AAAAAA")
	gui.text(203, 210, string.format("Pos: %d.%d\nSpd: %.5f", X2, X2sub, p2speedx), "#00BB00")
	gui.text(260, 210, string.format("/ %d.%d\n/ %.5f"      , Y2, Y2sub, p2speedy), "#00BB00")
	Hitbox(0xFFDEB2)
	Hitbox(0xFFDEBA)
	RNGcount  = 0
end

emu.registerafter(function()
	SpawnOpac = SpawnOpac - 4
	if SpawnOpac < 0 then SpawnOpac = 0 end
end)

emu.registerbefore(function()
	Hearts = 0
end)

savestate.registerload(function()
	SpawnCount = 0
	SpawnOpac  = 192
	Enemies    = 0
	Items      = 0
	Hearts     = 0
	return HandleMsgTable(1)
end)

gui.register(Main)
rex(0x375A,  function() DamageHitbox = false end)
rex(0x375E,  function() DamageHitbox = true  end)
rex(0x3768,  function() DamageHitbox = false end)
rex(0x376C,  function() DamageHitbox = true  end)
rex(0x65C4,  function() DamageHitbox = false end)
rex(0x65C8,  function() DamageHitbox = true  end)
rex(0x995C,  function() RNGcount = RNGcount + 1 end)
rex(0x4738,  Item)
rex(0x4534,  Item)
rex(0x8DE6,  Spawns)
rex(0x8DCE,  Spawns)
rex(0x8C9A,  Collision)
rex(0x1085A, HandleDamage) -- meelee
rex(0x10CBA, HandleDamage) -- weapon
rex(0x10CC4, HandleDamage) -- weapon