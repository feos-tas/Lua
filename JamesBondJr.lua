-- The game counts actual speed of the object,
-- but the sprite speed calculated separately
-- is more precise and considers BG ejections

LastX = 0
LastY = 0

function Bond()
   
	ScreenX = memory.readbyte(0x12)
	ScreenY = memory.readbyte(0x13)
	X = memory.readbyte(0xf) + ScreenX
	Y = memory.readbyte(0x10) + ScreenY
   
	gui.text(1, 9, "X=" .. X)
	gui.text(1, 18, "Y=" .. Y)
	gui.text(ScreenX+3, ScreenY+24, X-LastX)
	gui.text(ScreenX+3, ScreenY+33, LastY-Y)
	gui.text(115, 9, "HP=" .. memory.readbyte(0x42a))
   
	LastX = X
	LastY = Y
   
end

emu.registerafter(Bond);