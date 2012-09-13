last_timer = 0
last_framecount = 0
markerIndex = 0
function draw()
	Xspd = memory.readbytesigned(0x3a)
	Yspd = memory.readbytesigned(0x3b)
	timer= memory.readbyte(0x322)
	X    = memory.readbyte(0x58f)
	Y    = memory.readbyte(0x59b)
	camX = memory.readbyte(0x31c)
	camY = memory.readbyte(0x31b)
	frameCount = movie.framecount()
	
	if (frameCount - last_framecount) == 1 and (timer - last_timer) == 0 then
		gui.text(100,100,"\n LAG!!! ","#ff0000ff")
		if (taseditor.engaged()) then
			markerIndex = taseditor.setmarker(frameCount-1)
			taseditor.setnote(markerIndex, "LAG "..markerIndex)
		end
	elseif (taseditor.engaged()) and (taseditor.markedframe(frameCount-1)) then
		taseditor.removemarker(frameCount-1)
	end
	
	gui.text(1,1,"X: "..X+camX.."\nY: "..Y+camY)
	gui.text(50,1,"Xspd: "..Xspd.."\nYspd: "..Yspd)
	gui.text(100,1,"Tmr: "..timer.."\nLag: ".. markerIndex)
	last_timer = timer
	last_framecount = frameCount
end
emu.registerafter(draw);