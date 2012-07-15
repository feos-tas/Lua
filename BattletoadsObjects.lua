-- feos, 2012
-- Object ID and position display script for NES Batletoads.
-- Developed with 256x240 screen in mind.
-- Toads objects are omitted.
-- Objects' Y positions repeat during each high byte.
-- This way you can see which of them exist in RAM.
-- 0x4 stands for a blow. When a normal enemy turns into a blow,
-- it means you're moving the right way, i. e. scrolling enemies out.
-- This way you can find checkpoints used for enemies spawns and deletion.
-- 0x42 - restart point.
-- 0x41 - checkpoint to activate.

function info()
	CamX = memory.readbyte(0x87) + 256*memory.readbyte(0x88)
	CamY = memory.readbyte(0x89) + 256*memory.readbyte(0x8A)

	LevelCheckpointVal = memory.readbyte(0x585)	
	gui.text(1,10, "ChP: "..LevelCheckpointVal, "#00ff00ff")
	
	for i = 2, 14 do
		x  = memory.readbyte(0x3FD+i) + 256*memory.readbytesigned(0x3EE +i) - CamX
		y  = memory.readbyte(0x493+i) - memory.readbyte(0x475+i)
		hp = memory.readbyte(0x51a+i)
		id = memory.readbyte(0x3c1+i)
		
		if x<0 then x=0 elseif x>242 then x=242 end	
		gui.text(1+i*18-35, 1, string.format("%X",id))
		if id>0 then
			gui.text(x, y, string.format("%X",id))			
		end
	end
end
emu.registerafter(info);