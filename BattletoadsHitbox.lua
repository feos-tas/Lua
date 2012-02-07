-- Battletoads NES
-- Positions, speeds and hitboxes (not actual bounding boxes, just object frames)
-- The onscreen data is placed above 8th scanline not to cover the lifebars much

LastCamX = 0

function ShowBoxes()

	-- Camera position and display
	CamX = memory.readbyte(0x87) + 256*memory.readbyte(0x88)
	CamY = memory.readbyte(0x89) + 256*memory.readbyte(0x90)
   
	gui.text(170,  1, "CamX " .. CamX)
	gui.text(170,  9, "CamY " .. CamY)
	gui.text(170, 17, "CamS " .. CamX - LastCamX) -- X scrolling speed
   
	-- Player 1 position
	X1 = memory.readbyteunsigned(0x3FD) + 256*memory.readbytesigned(0x3EE)
	Y1 = memory.readbyteunsigned(0x439) + 256*memory.readbytesigned(0x42A)
	Z1 = memory.readbyteunsigned(0x493) + 256*memory.readbytesigned(0x40C)
   
	ScrX1 = X1 - CamX
	ScrY1 = memory.readbyteunsigned(0x493) - memory.readbyteunsigned(0x475)+8
   
	-- Player 2 position   
	X2 = memory.readbyteunsigned(0x3FE) + 256*memory.readbytesigned(0x3EF)
	Y2 = memory.readbyteunsigned(0x43A) + 256*memory.readbytesigned(0x42B)
	Z2 = memory.readbyteunsigned(0x494) + 256*memory.readbytesigned(0x40D)
   
	ScrX2 = X2 - CamX
	ScrY2 = memory.readbyteunsigned(0x494) - memory.readbyteunsigned(0x476)+8

	-- Player 1 display (with subpixels)
	gui.text(  1,  1, "1X " .. X1 .. "." .. memory.readbyteunsigned(0x448), "#00ff00ff")
	gui.text(  1,  9, "1Y " .. Y1 .. "." .. memory.readbyteunsigned(0x4CF), "#00ff00ff")
	gui.text(  1, 17, "1Z " .. Z1 .. "." .. memory.readbyteunsigned(0x457), "#00ff00ff")
	gui.text(237,  1, ScrY1-8, "#00ff00ff") -- When it is 255, jump from the void

	-- Player 2 display (with subpixels)
	gui.text( 85,  1, "2X " .. X2 .. "." .. memory.readbyteunsigned(0x449), "#ffcc00ff")
	gui.text( 85,  9, "2Y " .. Y2 .. "." .. memory.readbyteunsigned(0x4D0), "#FFcc00ff")
	gui.text( 85, 17, "2Z " .. Z2 .. "." .. memory.readbyteunsigned(0x458), "#FFcc00ff")
	gui.text(237,  9, ScrY2-8, "#FFdd00ff") -- When it is 255, jump from the void
   
	-- Player 1 hitbox, shadow and horizontal speed
	gui.box( ScrX1-10, ScrY1-30, ScrX1+10, ScrY1, "#00FF0000")
	gui.box( ScrX1-10, memory.readbyteunsigned(0x493)+8, ScrX1+10,
	memory.readbyteunsigned(0x493)+10, "#00FF0000")
	gui.text(ScrX1- 9, ScrY1-16,  memory.readbyteunsigned(0x565), "#00ff00ff")
   
	-- Player 2 hitbox, shadow and horizontal speed
	gui.box( ScrX2-10, ScrY2-30, ScrX2+10, ScrY2, "#FFCCaa00")
	gui.box( ScrX2-10, memory.readbyteunsigned(0x494)+8, ScrX2+10,
	memory.readbyteunsigned(0x494)+10, "#FFCCaa00")  
	gui.text(ScrX2- 9, ScrY2-8, memory.readbyteunsigned(0x566), "#FFddaaff")
   
	LastCamX = CamX

end

emu.registerafter(ShowBoxes);