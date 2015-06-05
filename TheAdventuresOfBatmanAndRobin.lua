-- The Adventures of Batman and Robin
-- 2013, feos and r57shell

MsgTable  = {}
MsgTime   = 30
MsgOffs   = 16
MsgCutoff = 60
RNGcount  = 0

function GetCam()
	xcam = memory.readwordsigned(0xFFDFC4)
	if memory.readbyte(0xFFFFF6) == 50 then
		ycam2= memory.readwordsigned(0xFFDFE0)-20
	else
		ycam2 = 0
	end
--	ycam = memory.readwordsigned(0xFFCD70)
end

function EnemyPos(Base)
	GetCam()
	x1 = memory.readwordsigned(Base + 0x12) - xcam
	y1 = memory.readwordsigned(Base + 0x14) - ycam2
	x2 = memory.readwordsigned(Base + 0x16) - xcam
	y2 = memory.readwordsigned(Base + 0x18) - ycam2
	hp = memory.readwordsigned(Base + 0x1E)
end

function PlayerPos()
	local sbase1 = memory.readword(0xFFAD5C) + 0xFF0000
	local sbase2 = memory.readword(0xFFADB6) + 0xFF0000
	p1speedx = memory.readlongsigned(sbase1 + 0x18) / 0x10000
	p1speedy = memory.readlongsigned(sbase1 + 0x1C) / 0x10000
	p2speedx = memory.readlongsigned(sbase2 + 0x18) / 0x10000
	p2speedy = memory.readlongsigned(sbase2 + 0x1C) / 0x10000
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
			gui.line(i * MsgOffs + 3, MsgY2, MsgTable[i].x_ - xcam, MsgTable[i].y_, "#ff0000c0")
			gui.text(i * MsgOffs    , MsgY1, MsgTable[i].damage_, "red")
			if (MsgTable[i].timer_ < gens.framecount()) then
				MsgTable[i] = nil
			end
		end
	end
end

function HandleDamage()
	local damage = AND(memory.getregister("d0"),   0xFFFF)
	local base   = AND(memory.getregister("a2"), 0xFFFFFF)	
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
	local a0 = AND(memory.getregister("a0"), 0xFFFF)
	local a6 = AND(memory.getregister("a6"), 0xFFFF)
	local damage = memory.readword(a6 + 0xFF0012)
	local wx2 = memory.getregister("d6") - xcam
	local wy2 = memory.getregister("d7") - ycam2
	local wx1 = memory.getregister("d4") - xcam
	local wy1 = memory.getregister("d5") - ycam2
	--gui.text(wx2 + 2, wy1 + 1, string.format("%X",a6))
	if (damage == 0) then
		damage = memory.readword(a0 + 0xFF0034)
	end
	if (DamageHitbox) then
		gui.box(wx1, wy1, wx2, wy2, "#ff000000")
		gui.text(wx1 + 2, wy1 + 1, damage)
	else
		gui.box(wx1, wy1, wx2, wy2, "#ffff0000")		
	end
end

function InRange(var, num1, num2)
	if (var >=  num1) and (var <= num2)
	then return true
	end
end

function Item()
	GetCam()
	local a6 = AND(memory.getregister("a6"), 0xFFFF)
	local x = memory.readword(a6 + 0xFF003E) - xcam
	local y = memory.readword(a6 + 0xFF0042)
	local code = memory.readbyte(a6 + 0xFF0019)
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
	local base = memory.readword(address)	
	while (base ~= 0) do
		base = base + 0xFF0000
		if (memory.readword(base + 2) == 0) then break end
		EnemyPos(base)
		if (address == 0xFFDEB2) then
			gui.box(x1, y1, x2, y2, "#00ff0000")
		elseif (address == 0xFFDEBA) then
			gui.box(x1, y1, x2, y2, "#00ffff00")
			gui.text(x1 + 2, y1 + 1, hp, "#ff00ff")
			--if (x2 <    0) then gui.text(x1 + 2, y2 - 7, "x:" .. x1      ) end
			--if (x1 >= 320) then gui.text(x1 + 2, y2 - 7, "x:" .. x1 - 320) end
			--if (y2 <    0) then gui.text(x2 + 2, y2 - 7, "y:" .. y2      ) end
			local offtext = ""
			if (x2 <    0) then offtext = offtext .. "x:" .. x1 end
			if (x1 >= 320) then offtext = offtext .. "x:" .. x1 - 320 end
			if (y2 <    0) then offtext = offtext .. "y:" .. y2 end
			if offtext ~= "" then
				gui.text(x1 + 2, y2 - 7, offtext)
			end
		end
--		gui.text(x1 + 2, y1 + 1, string.format("\n%X", base - 0xFF0000), "#ff00ff")
		base = memory.readword(base + 2)
		i = i + 1
		if (i > 400) then break end
	end
end

function Main()
	local color1  = "yellow"
	local color2  = "yellow"
	local color0  = "yellow"
--	local hp1     = memory.readword(0xFFF650) / 0x10
--	local life1   = memory.readword(0xFFF644)
	local base1   = 0xFFAD54
	local base2   = 0xFFADAE
	local X1      = memory.readword(base1 + 0x3E)
	local X1sub   = memory.readbyte(base1 + 0x40)
	local Y1      = memory.readwordsigned(base1 + 0x42)
	local Y1sub   = memory.readbyte(base1 + 0x44)
	local X2      = memory.readword(base2 + 0x3E)
	local X2sub   = memory.readbyte(base2 + 0x40)
	local Y2      = memory.readwordsigned(base2 + 0x42)
	local Y2sub   = memory.readbyte(base2 + 0x44)
	local RNG1    = memory.readword(0xFFF5FC)
--	local RNG2    = memory.readlong(0xFFF5FE)
	local Weapon1 = memory.readbyte(0xFFF67B)
	local Weapon2 = memory.readbyte(0xFFF6BB)
	local Charge1 = (memory.readword(0xFFF658) - 0x2800) / -0x80
	local Charge2 = (memory.readword(0xFFF698) - 0x2800) / -0x80
	local ScreenLock = memory.readword(0xFFDFC0)
	if Charge1 <= 0 then Charge1 = 0; color1 = "red" end
	if Charge2 <= 0 then Charge2 = 0; color2 = "red" end
	if RNGcount > 1 then              color0 = "red" end
	HandleMsgTable()
	PlayerPos()
	Hitbox(0xFFDEB2)
	Hitbox(0xFFDEBA)
	gui.text(  0, 210, string.format("\nRNG:%X" , RNG1))
	gui.text( 40, 210, string.format("\nLock:%d", ScreenLock))
	gui.text( 34, 210, string.format("\n%d"     , RNGcount), color0)
	gui.text(80, 20, string.format("%2d"      , Charge1),  color1)
	gui.text(235, 20, string.format("%2d"      , Charge2),  color2)
	--gui.text(180, 210, string.format("%2d"      , Charge1),  color1)
	--gui.text(300, 210, string.format("%2d"      , Charge2),  color2)
	gui.text(180, 210, string.format("\n%2d"    , Weapon1+1),  "yellow")
	gui.text(300, 210, string.format("\n%2d"    , Weapon2+1),  "yellow")
	gui.text( 81, 210, string.format("Pos: %d.%d\nSpd: %.5f", X1, X1sub, p1speedx), "#AAAAAA")
	gui.text(137, 210, string.format("/ %d.%d\n/ %.5f"      , Y1, Y1sub, p1speedy), "#AAAAAA")
	gui.text(203, 210, string.format("Pos: %d.%d\nSpd: %.5f", X2, X2sub, p2speedx), "#00BB00")
	gui.text(260, 210, string.format("/ %d.%d\n/ %.5f"      , Y2, Y2sub, p2speedy), "#00BB00")
	RNGcount  = 0
end

gui.register(Main)
savestate.registerload(function() return HandleMsgTable(1) end)
memory.registerexec(0x375A,  function() DamageHitbox = false end)
memory.registerexec(0x375E,  function() DamageHitbox = true  end)
memory.registerexec(0x3768,  function() DamageHitbox = false end)
memory.registerexec(0x376C,  function() DamageHitbox = true  end)
memory.registerexec(0x65C4,  function() DamageHitbox = false end)
memory.registerexec(0x65C8,  function() DamageHitbox = true  end)
memory.registerexec(0x995C,  function() RNGcount = RNGcount + 1 end)
memory.registerexec(0x4738,  Item)
memory.registerexec(0x4534,  Item)
memory.registerexec(0x8C9A,  Collision)
memory.registerexec(0x1085A, HandleDamage) -- meelee
memory.registerexec(0x10CBA, HandleDamage) -- weapon
memory.registerexec(0x10CC4, HandleDamage) -- weapon