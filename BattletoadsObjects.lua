-- feos, 2012
-- Object IDs and atributes display script for NES Batletoads.
-- Developed with 256x240 screen in mind.
lastVal = 0

function info()
	CamX = memory.readbyte(0x87) + 256*memory.readbyte(0x88)
	CamY = memory.readbyte(0x89) + 256*memory.readbyte(0x8A)
--	LevelCheckpointVal = memory.readbyte(0x585)
	ObjectPointerLo = memory.readbyte(0xB7)
	ObjectPointerHi = memory.readbyte(0xB8)
	newVal = ObjectPointerHi*0x100+ObjectPointerLo
	PointedAddr = memory.readbyte(lastVal)
--	AAA = memory.readbyte(0x2a)
	CCC = memory.readbyte(0x2c)
--	gui.box(0,0,256,40,"#000000ff")
--	gui.text(130,231, "ChP: "..string.format("%02X",LevelCheckpointVal), "#00ff00ff")
	gui.text(95,17, string.format("Cur:%04X=%02X\nNew:%04X",lastVal,PointedAddr,newVal), "#00ff00ff")
	gui.text(200,17, string.format("2C=%02X",CCC), "#00ff00ff")
	gui.text(1, 1, "slot:\nid:")
	
	for i = 0, 14 do
		id		= memory.readbyte(0x3c1+i)
		x		= memory.readbyte(0x3FD+i) + 256*memory.readbytesigned(0x3EE +i) - CamX
		y		= memory.readbyte(0x493+i) - memory.readbyte(0x475+i)
		xSH		= memory.readbyte(0x484+i)
		ySH		= memory.readbyte(0x493+i)
		move	= memory.readbyte(0x4A2+i)
		state	= memory.readbyte(0x4B1+i)
		hp		= memory.readbyte(0x51a+i)
		linked	= memory.readbyte(0x529+i)
		linker	= memory.readbyte(0x538+i)
		dthTmr	= memory.readbyte(0x574+i)
		follow	= memory.readbyte(0x592+i)
		
		if id>0 then
			gui.text(x, y, string.format("%2X",id))			
		end		
		if x<0 then x=0 elseif x>242 then x=242 end	
		gui.text(1+i*16+18, 1, string.format("%2d\n%2X\n\n\n%2X",i+1,id,dthTmr))
--		gui.text(xSH,ySH,"Sh")
	end
	
	lastVal = newVal
end
emu.registerafter(info);