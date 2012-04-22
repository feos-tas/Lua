LastX1 = 0
LastX2 = 0

function draw()

	CamX = memory.readbyte(0x10) + memory.readbyte(0x13)*256
	CamY = memory.readbyte(0x16) + memory.readbyte(0x19)*256

	Xscr1 = memory.readbyte(0xc0)
	Yscr1 = memory.readbyte(0xc2)
	Xscr2 = memory.readbyte(0xc1)
	Yscr2 = memory.readbyte(0xc3)

	Xlev1 = CamX + Xscr1
	Ylev1 = CamY + Yscr1
	Xlev2 = CamX + Xscr2
	Ylev2 = CamY + Yscr2

	Xspd1 = Xlev1 - LastX1
	Xspd2 = Xlev2 - LastX2

	gui.text(1, 1, "X1: "..Xlev1.."\nY1: "..Ylev1.."\nspd1: "..Xspd1)
	gui.text(100, 1, "X2: "..Xlev2.."\nY2: "..Ylev2.."\nspd2: "..Xspd2)
	gui.text(200, 1, "HP: "..memory.readbyte(0x3d7).."\nInv: "..memory.readbyte(0x3fb))	
	gui.text(180, 200, "Tmr: "..memory.readbyte(0x2e)..":"..memory.readbyte(0x2d).."\nRNG: "..memory.readbyte(0x6b))
	

	LastX1 = Xlev1
	LastX2 = Xlev2

end

emu.registerafter(draw);