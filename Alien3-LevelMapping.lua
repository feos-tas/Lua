-- feos, 2012
-- script for ripping level maps
-- drag Ripley to areas you can't access normally
-- cheats on timer & HP

prev_keys = input.get()

function hack()

	keys = input.get()
	
	loXcam = 0x1a
	hiXcam = 0x1b
	loYcam = 0x1c
	hiYcam = 0x1d
	
	loXlev = 0x420
	hiXlev = 0x440
	loYlev = 0x460
	hiYlev = 0x480
	
	Xscr = memory.readbyte(0x5c)
	Yscr = memory.readbyte(0x5d)
	
	Xcam = memory.readbyte(loXcam) + memory.readbyte(hiXcam)*256
	Ycam = memory.readbyte(loYcam) + memory.readbyte(hiYcam)*256
	
	if keys["leftclick"] then
		memory.writebyte(hiXlev, (Xcam/256))
		memory.writebyte(loXlev, (Xcam%256) + keys.xmouse)
		memory.writebyte(hiYlev, (Ycam/256))
		memory.writebyte(loYlev, (Ycam%256) + keys.ymouse - 16)
	end
	
	memory.writebyte(0x748, 50) -- freeze timer
	memory.writebyte(0x74a, 24) -- freeze HP
	
	prev_keys = keys
end
emu.registerbefore(hack)