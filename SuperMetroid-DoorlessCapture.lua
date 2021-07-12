while true do
	-- Items, Doors, Elevators
	istop = memory.readbyte(0x7E0009)
	dstop = memory.readbyte(0x7E05F5)
	estop = memory.readbyte(0x7E0E18)
	
	if istop+dstop+estop == 0 or istop+dstop+estop == 0x6F then client.unpause_av()
	else client.pause_av()
	end
	emu.frameadvance()
end