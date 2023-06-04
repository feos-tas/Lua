-- feos, 2023

-- addresses
local addr_base   = 0xD000
local addr_mode   = 0xD04B
local addr_cam1   = 0xF700
local addr_cam3   = 0xFDB8
local addr_cam4   = 0xF616
local addr_time   = 0xFE22

-- offsets
local offs_flags  = 1
local offs_posX   = 0x8
local offs_posY   = 0xC

-- constants
local SCREEN_W    = 320
local SCREEN_H    = 224
local LEVEL_H     = 2047
local SCROLLRATE  = 16
local FREEZE_SIZE = 16
local MAX_FRAMES  = 100

-- aliases
local rb   = mainmemory.readbyte
local rs16 = mainmemory.read_s16_be
local rs32 = mainmemory.read_s32_be
local ru32 = mainmemory.read_u32_be
local ws16 = mainmemory.write_s16_be
local ws32 = mainmemory.write_s32_be
local wu32 = mainmemory.write_u32_be

-- buffers
local freezebuffer = {}
local memorystate

gui.defaultPixelFont("gens") 

local function CamHack()
	client.invisibleemulation(false)
	
	local x      = rs16(addr_base + offs_posX)   -- character x position
	local y      = rs16(addr_base + offs_posY)   -- character y position
	local origx  = rs16(addr_cam1)               -- initial camera x position
	local origy  = rs16(addr_cam1 + 4)           -- initial camera y position
	local xx     = math.max(0, x - SCREEN_W / 2) -- desired camera x position
	local yy     =             y - SCREEN_H / 2  -- desired camera y position
	local flags  = rb(addr_base + offs_flags)
	local timer  = rs32(addr_time)
	local deltaX = SCROLLRATE
	
--	if flags && 0x80 ~= 0
	if bit.band(flags, 0x80) ~= 0
	or rb(0xF7CD) ~= 0
	or (x - origx <= SCREEN_W
	and (y - origy <= 240
	-- going downward through level-wraps
	or (y + LEVEL_H - origy <= SCREEN_H and origy >= LEVEL_H - SCREEN_H)
	-- going upward through level-wraps
	or (origy < 0 and (y >= LEVEL_H + origy or y <= origy + SCREEN_H)))
	or rb(addr_mode) == 0)
	then return end
	
	-- set the camera no more than 640 pixels distant
	if math.abs(xx - origx) > SCREEN_W * 2 then
		origx = math.max(0, xx - SCREEN_W * 2)
	end
	
	-- and always above target, because Sonic doesn't like externally forced upward scrolling
	if origy > yy then
		origy = yy - SCREEN_H * 2
	else
		origy = math.max(yy - SCREEN_H * 2, origy)
	end
	
	if xx < origx then
		deltaX = -deltaX
	end
	
	local numframes = 1 + math.floor(math.max(
		math.abs(xx - origx) / SCROLLRATE,
		math.abs(yy - origy) / SCROLLRATE))
	
	if numframes > MAX_FRAMES then
		numframes = MAX_FRAMES
	end
	
	memorystate = memorysavestate.savecorestate()
	
	for i = 1, FREEZE_SIZE do
		freezebuffer[i] = ru32(addr_base + i*4)
	end
	
	client.invisibleemulation(true)
	
	for i = 0, MAX_FRAMES * 2 do
		if i > numframes then break end
		
		if origy < -SCROLLRATE then origy = -SCROLLRATE end
		
		ws16(addr_cam1,     origx)
		ws16(addr_cam1 + 4, origy)
		ws32(addr_cam3,     origx)
		ws32(addr_cam4,     origy)
		ws32(addr_cam4 + 4, origx)
		ws32(addr_time, timer)
		
		for i = 1, FREEZE_SIZE do
			wu32(addr_base + i*4, freezebuffer[i])
		end
		
		client.seekframe(emu.framecount() + 1)
		
		if numframes < MAX_FRAMES and emu.islagged() then
			numframes = numframes + 1
		else
			-- the game doesn't like being forced to scroll up
			if yy > origy then
				origy = origy + math.min(SCROLLRATE, yy - origy)
			end
			
			if xx ~= origx then
				if math.abs(xx - origx) <= SCROLLRATE then
					origx = xx
				else
					origx = origx + deltaX
				end
			end
		end
	end
	
	--[[--
	gui.pixelText(10, 100, string.format(
		" pos: %4d x %4d\n"..
		"orig: %4d | %4d x %4d | %4d\n"..
		" cam: %4d %4d %4d\n"..
		"  xx: %4d | %4d yy: %4d | %4d",
		x, y,
		origx, rs16(addr_cam1),
		origy, rs16(addr_cam1+4),
		rs32(addr_cam3), rs32(addr_cam4), rs32(addr_cam4+4),
		xx, math.max(0, x - SCREEN_W / 2),
		yy, y - SCREEN_H / 2))
	--]]--
	
	client.invisibleemulation(false)
	client.seekframe(emu.framecount() + 1)
	client.invisibleemulation(true)
	memorysavestate.loadcorestate(memorystate)
	memorysavestate.removestate(memorystate)
	--client.invisibleemulation(false)
end
	
while true do
	CamHack()
	emu.frameadvance()
	gui.clearGraphics()
end