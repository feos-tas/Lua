lastxposAbsolute = 0
local function NGRAMview()
	for i = 4, 7 do
		id		= memory.readbyte(0x400+i)
		some	= memory.readbyte(0x420+i)
		mov		= memory.readbyte(0x438+i)
		xsub	= memory.readbyte(0x458+i)
		x		= memory.readbyte(0x460+i)
		ysub	= memory.readbyte(0x478+i)
		y		= memory.readbyte(0x480+i)
		yspeed	= memory.readbytesigned(0x470+i)
		ysubspd = memory.readbyte(0x468+i)
--[[		gui.text(x, y-20, i) -- .."\n"..yspeed.."."..ysubspd)
		gui.text(1, 1, "slot:\nid:\nx:\ny:")
		gui.text(i*60-205, 224, string.format(
			"%d: %02X.%02X",i,x,xsub
		))]]
	end

	xpos = memory.readbyte(0x86) + (memory.readbyte(0x85)/256)
	ypos = memory.readbyte(0x8A)
	yspd = memory.readbytesigned(0x89) + (memory.readbyte(0x87)/256)
	scrnpos = memory.readbyte(0xA3); scrnsub = memory.readbyte(0xA2)
	xposAbsolute = scrnpos+xpos+(scrnsub/256)+(memory.readbytesigned(0x52)*256)
	xspd = xposAbsolute - lastxposAbsolute
	timerf = memory.readbyte(0x62); timer = memory.readbyte(0x63)
	rnga = memory.readbyte(0xB5); rngb = memory.readbyte(0xBF)
	ninpo = memory.readbyte(0x64)
	bosshp = memory.readbyte(0x497); abosshp = memory.readbyte(0x496)
	inv = memory.readbyte(0x95)
	gui.text(xpos,ypos-20,string.format("%3.1f",xspd))
	gui.text(25,9,string.format("Yspd: %6.3f",yspd))	
	gui.text(25,17,string.format("Position: %5.1f, %3d",xposAbsolute,ypos))
	gui.text(129,17,string.format("[%05.1f+%02X,%02X]",xpos,scrnpos,scrnsub))
	gui.text(73,33,string.format("%3d:%02d",timer,timerf))
	if bosshp > 0 then
		if bosshp > 16
			then gui.text(177,41,string.format("%02d",abosshp))
			else gui.text(177,41,string.format("%02d",bosshp))
		end
	end
	if inv > 0 then gui.text(241,33,string.format("%02d",inv)) end
	gui.text(208,17,string.format("B5:%3d ",rnga))
	gui.text(208,25,string.format("BF:%3d ",rngb))
	gui.text(81,41,string.format("[%02d]",ninpo))
	lastxposAbsolute = xposAbsolute
end
emu.registerafter(NGRAMview);