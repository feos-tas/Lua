-- feos, 2012
-- Object IDs and atributes display script for NES Batletoads.
-- Developed with 256x240 screen in mind.

function info()
	CamX = memory.readbyte(0x8D) + 256*memory.readbyte(0x8E)
	CamY = memory.readbyte(0x89) + 256*memory.readbyte(0x8A)

	LevelCheckpointVal = memory.readbyte(0x586)
	ObjectPointerLo = memory.readbyte(0xB8)
	ObjectPointerHi = memory.readbyte(0xB9)
	gui.box(0,0,256,32,"#000000ff")
	gui.text(1, 1, "id:\nmv:\nlr:\nld:")
	
	for i = 0, 14 do
		id		= memory.readbyte(0x3c2+i)
		x		= memory.readbyte(0x3FE+i) + 256*memory.readbytesigned(0x3EF +i) - CamX
		y		= memory.readbyte(0x494+i) - memory.readbyte(0x476+i)
		move	= memory.readbyte(0x4A3+i)
		state	= memory.readbyte(0x4B2+i)
		hp		= memory.readbyte(0x51B+i)
		linked	= memory.readbyte(0x52A+i)
		linker	= memory.readbyte(0x539+i)
		follow	= memory.readbyte(0x593+i)
		
		if id>0 then
			gui.text(x, y, string.format("%2X",id))			
		end		
		if x<0 then x=0 elseif x>242 then x=242 end	
		gui.text(1+i*16+18, 1, string.format("%2X\n%2X\n%2X\n%2X",id,state,linker,linked))
	end
end
emu.registerafter(info);