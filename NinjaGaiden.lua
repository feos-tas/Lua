lastxposAbs = 0
local function NGRAMview()
	for i = 0, 7 do
		id		= memory.readbyte(0x400+i)
		time	= memory.readbyte(0x408+i)
		some	= memory.readbyte(0x420+i)
		mov		= memory.readbyte(0x438+i)
		xsub	= memory.readbyte(0x458+i)
		x		= memory.readbyte(0x460+i)
		ysub	= memory.readbyte(0x478+i)
		y		= memory.readbyte(0x480+i)
		yspeed	= memory.readbytesigned(0x470+i)
		ysubspd = memory.readbyte(0x468+i)
		if time > 0 then color="#00ddffff" else color="#ffffffff" end		
		gui.text(x, y-20, string.format("%X",i),color,"#000000ff")
		gui.text(i*32+3, 1, string.format("%d:%3d",i,time),color,"#000000ff")		
		gui.text(i*32+3, 9, string.format(
			"%02X.%02X\n%02X.%02X",x,xsub,y,ysub
		),"#ffccaaff","#000000ff")	
	end

	xpos	= memory.readbyte(0x86) + (memory.readbyte(0x85)/256)
	ypos	= memory.readbyte(0x8A)
	scrnpos	= memory.readbyte(0xA3)
	scrnsub = memory.readbyte(0xA2)
	xposAbs	= scrnpos+xpos+(scrnsub/256)+(memory.readbytesigned(0x52)*256)
	xspd	= xposAbs - lastxposAbs
	rnga	= memory.readbyte(0xB5)
	rngb	= memory.readbyte(0xBF)
	bosshp	= memory.readbyte(0x497)
	abosshp = memory.readbyte(0x496)
	inv		= memory.readbyte(0x95)
	shifted = bit.rshift(rngb,1)
	
	gui.box(0,25,95,40,"#000000ff")
	gui.text(xpos,ypos-10,string.format("%2.1f",xspd))	
	gui.text(3,25,string.format("X: %.1f\nY: %03d",xposAbs,ypos),"#44ffffff","#000000ff")
	gui.text(67,25,string.format("BF: %3d.%3d\nB5: %d",rngb,shifted,rnga),"#44ffffff","#000000ff")
	lastxposAbs = xposAbs
	
	if inv > 0 then gui.text(241,33,string.format("%02d",inv)) end
	if bosshp > 0 then
		if bosshp > 16
			then gui.text(177,41,string.format("%02d",abosshp))
			else gui.text(177,41,string.format("%02d",bosshp))
		end
	end
end
emu.registerafter(NGRAMview);