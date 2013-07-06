-- feos, 2012
-- Duck Tales 2 lag counter and HUD

lagged = false
lastXpos = 0
lastYpos = 0
lastXcam = 0
lastYcam = 0

function Stuff()
	Xpos = memory.readbyte(0x96) + (memory.readbyte(0x97)*0x100) + (memory.readbyte(0x95)/400)
	Ypos = memory.readbyte(0x99) + (memory.readbyte(0x9A)*0x100) + (memory.readbyte(0x98)/400)
	Xcam = memory.readbyte(0x17) + memory.readbyte(0x18)*0x100
	Ycam = memory.readbyte(0x1A) + memory.readbyte(0x1B)*0x100
	timer = memory.readbyte(0x8F)
	RNG = memory.readbyte(0x90)
	bossHP = memory.readbyte(0xB9)
	bossInv = memory.readbyte(0xB8)
	
	Xspd = Xpos - lastXpos
	Yspd = Ypos - lastYpos
	Xcamspd = Xcam - lastXcam
	Ycamspd = Ycam - lastYcam
	
	gui.text( 0, 8, string.format("X: %.2f\nY: %.2f",Xpos,Ypos))
	gui.text(170, 8, string.format("Xcam: %4d\nYcam: %4d",Xcam,Ycam))
	gui.text(115, 8, string.format("Tmr: %d\nRNG: %X\nHP: %d\nInv: %d",timer,RNG,bossHP,bossInv))
	
	lastXpos = Xpos
	lastYpos = Ypos
	lastXcam = Xcam
	lastYcam = Ycam
	
	for i = 0, 8 do
		id		= memory.readbyte(0x405+i)
		xSub	= memory.readbyte(0x4A5+i)/400
		x		= memory.readbyte(0x4B5+i) + memory.readbyte(0x4C5+i)*0x100 - Xcam
		ySub	= memory.readbyte(0x4D5+i)/400
		y		= memory.readbyte(0x4E5+i) + memory.readbyte(0x4F5+i)*0x100 - Ycam		
		state	= memory.readbyte(0x415+i)
		speed	= memory.readbyte(0x465+i)
		
		if x<0 then x=0 elseif x>242 then x=242 end
		if id>0 then
			gui.text(x, y, string.format("%X\n%X",id,state))
		end
	end
	
	gui.text(Xpos-Xcam, Ypos-Ycam, string.format("%.2f\n%.2f",Xspd,Yspd), "#00ff00ff")
end

function DetectLag()
	lagged = (memory.readbyte(0x88) == 0)
end

function SetLag()
	emu.setlagflag(lagged)
end

memory.registerexecute(0xC780, DetectLag)
memory.registerexecute(0xD362, SetLag)
emu.registerafter(Stuff)