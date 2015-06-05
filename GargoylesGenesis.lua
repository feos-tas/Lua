-- Gargoyles, Genesis
-- feos, 2015

rb = memory.readbyte
rw = memory.readword
rl = memory.readlong
XposLast = 0
YposLast = 0
size     = 16
GlobalBase  = 0xff1c76
GolBase     = 0xff2c76
MapA_Buff   = 0xff4af0
mapline_tab = 0xff0244
LevelFlr    = 0xff00c0
LevelCon    = 0xff00c4
levnum      = 0xff00ba

gui.register(function()
	camx = rw(0xff010c)+16
	camy = rw(0xff010e)+16	
	Xpos = rw(0xff0106)
	Ypos = rw(0xff0108)
	run = rb(0xff1699)
	inv = rw(0xff16d2)
	Xspd = Xpos-XposLast
	Yspd = Ypos-YposLast
	XposLast = Xpos
	YposLast = Ypos
	if rw(0xFF2CC6)~=0 then
		for i=-1,20 do
			for j=-1,15 do		
				GetBlock(i,j)
			end
		end
	end
	Objects()	
	xx = Xpos-camx
	yy = Ypos-camy
	gui.box(xx     -1,yy-0x2c-1,xx     +1,yy-0x2c+1,"#00ffff33","#00ffffff") -- top
	gui.box(xx-0xf -1,yy-0x1f-1,xx-0xf +1,yy-0x1f+1,"#00ffff33","#00ffffff") -- left
	gui.box(xx+0x10-1,yy-0x1f-1,xx+0x10+1,yy-0x1f+1,"#00ffff33","#00ffffff") -- right
	gui.box(xx     -1,yy+   0-1,xx     +1,yy+   0+1,"#ffff0033","#ffff00ff") -- bottom
	gui.text(0,0,string.format(
		"pos: %3d %4d\nspd: %3d %4d\nrun: %3d\ninv: %3d",
		Xpos,Ypos,Xspd,Yspd,run,inv
	))
end)

function Objects()
	for i=0,63 do
		local base = GlobalBase+i*128
--		local xpos = rw(base+0x00)
--		local ypos = rw(base+0x02)
--		local st   = rw(base+0x0c)
		local dmg  = rb(base+0x10)
		local hp   = rw(base+0x50)
--		local mast = rw(base+0x72)
		local cRAM = rl(base+0x74) -- pointer to 4 collision boxes per object
		local col  = 0 -- collision color
		local opac = 0xff -- box fill opacity
--		local xscr = xpos-camx
--		local yscr = ypos-camy
		for box=0,4 do
			local x1 = rw(cRAM+box*8+0)-camx
			local y1 = rw(cRAM+box*8+2)-camy
			local x2 = rw(cRAM+box*8+4)-camx
			local y2 = rw(cRAM+box*8+6)-camy
			if box==0 then 
				col = 0x00ff0000 -- body
				if hp>0 then
					gui.text(x1+2,y1+1,string.format("%d",hp),col+opac)
				end
			elseif box==1 then
				col = 0xffff0000 -- floor
			elseif box==2 then
				if dmg>0 then
					col = 0xff000000 -- projectile
				else
					col = 0xff00ff00 -- item
				end
				if dmg>0 then
					gui.text(x1+2,y2+1,string.format("%d",dmg),col+opac)
				end
			else
				col = 0xffffff00 -- other
			end
			if x1~=0x8888 then
				gui.box(x1,y1,x2,y2,col)
			end
		end
	end
end

function GetBlock(x,y)
	x = camx+x*size-AND(camx,0xF)
	y = camy+y*size-AND(camy,0xF)
	if x<0 then x=0 end
	if y<0 then y=0 end
	local x1    = x-camx
	local x2    = x1+size  
	local y1    = y-camy
	local y2    = y1+size
	local d4    = rw(mapline_tab+SHIFT(y,4)*2)
	local a1    = rl(LevelFlr)
	local d1    = SHIFT(rw(MapA_Buff+d4+SHIFT(x,4)*2),1)
	local ret   = rb(a1+d1+2) -- block
	local col   =    0 -- block color
	local opin  = 0x33 -- inner opacity
	local opout = 0x88 -- outer opacity
	if ret>0 then		
		if     ret>=0x80 and ret<=0x81 then col = 0xffffff00
		elseif ret>=0x82 and ret<=0x85 then col = 0x00ffff00
		elseif ret==0xd0  or ret==0xd1 
		    or ret==0xa0  or ret==0xa1 then col = 0xff000000
		elseif ret==0x7f               then col = 0xffff0000
		elseif ret==0x70               then col = 0xff00ff00
		else                                col = 0xff880000
		end
		if ret>=0x82 and ret<=0x85 then
			opout = 0xff
		else
			opout = 0x88
		end
		gui.box(x1,y1,x2,y2,col+opin,col+opout)
--		gui.text(x1,y1,string.format("%X",ret))
	end
	d1 = rw(a1+d1)
	a1 = AND(rl(LevelCon),0xffffff)+d1
	for pixel=0,15 do
		ret = rb(a1+pixel) -- contour
		if ret>0 then
			gui.pixel(x1+pixel,y1+ret-1,"#ffff00ff")
--			gui.text(x1,y1,string.format("%X",ret))		
		end
	end
end

--[[--
function DebugStuff()
	showObj = 1
	
	base     = GolBase
	posXoffs = 6
	posYoffs = 8
	Xoffs    = 104
	Yoffs    = 8
	pageSize = 24
--	ObjectMap(base)
	
	base     = 0xff0de2
	posXoffs = 0
	posYoffs = 8 
	Xoffs    = 120
	Yoffs    = 7
	pageSize = 16
--	ObjectDetecion(base)
	
	base     = 0xff0de4
	posXoffs = 260
	posYoffs = 8 
	Xoffs    = 120
	Yoffs    = 7
	pageSize = 16
--	ObjectDetecionContour(base)
end

function ReadObjMem(size,base,name)
	count = count+1
	local val = 0
	local addr = base+nextoffset	
	if     size == 1 then val = rb(addr)
	elseif size == 2 then val = rw(addr)
	elseif size == 4 then val = rl(base+nextoffset)
	else                  val = 0xCAFEBABE end -- error
	if showObj == 1 then
		gui.text(
			posXoffs+math.floor(count/pageSize)*Xoffs,
			posYoffs+count%pageSize*Yoffs,
			string.format("%02X %s.%X",nextoffset,name,val)
		)
	end
	nextoffset = nextoffset+size
	return val
end

function ReadDetectMem(size,base,name,pointer)
	count = count+1
	local val = 0
	local addr = base+nextoffset	
	if     size == 1 then val = rb(addr)
	elseif size == 2 then val = rw(addr)
	elseif size == 4 then val = rl(base+nextoffset)
	else                  val = size end -- error
	if pointer==1 then
		val = memory.readbyte(val)
	end
	if showObj == 0 then
		gui.text(
			posXoffs+math.floor(count/pageSize)*Xoffs,
			posYoffs+count%pageSize*Yoffs,
			string.format("%04X %s.%X",addr-0xff0000,name,val)
		)
	end
	nextoffset = nextoffset+6
	return val
end

function ObjectMap(base)
	if showObj == 1 then
		gui.text(posXoffs,0,string.format("RAM map for object $%X",base),"yellow")
	end
	nextoffset = 0
	count = -1
	Xpos		 	= ReadObjMem(2,base,"Xpos........") -- x position
	Ypos		 	= ReadObjMem(2,base,"Ypos........") -- y position
	Zpos		 	= ReadObjMem(2,base,"Zpos........") -- z position
	WXpos		 	= ReadObjMem(2,base,"WXpos.......") -- World x position
	WYpos		 	= ReadObjMem(2,base,"WYpos.......") -- World y position
	WZpos		 	= ReadObjMem(2,base,"WZpos.......") -- World z position
	State		 	= ReadObjMem(2,base,"State.......") -- Logic state
	LastState	 	= ReadObjMem(2,base,"LastState...") -- Last Logic state (used for restore)
	HitPower	 	= ReadObjMem(1,base,"HitPower....") -- Power of Objects attack
	HitWait	 		= ReadObjMem(1,base,"HitWait.....") -- universal being hit delay
	padpad	 		= ReadObjMem(1,base,"padpad......") -- 
	MoveFlags	 	= ReadObjMem(1,base,"MoveFlags...") -- Movement flags
	Xspd		 	= ReadObjMem(2,base,"Xspd........") -- X speed
	Yspd		 	= ReadObjMem(2,base,"Yspd........") -- Y speed
	Xacc		 	= ReadObjMem(2,base,"Xacc........") -- X ac/decceleration
	Yacc		 	= ReadObjMem(2,base,"Yacc........") -- Y ac/decceleration
	AnChrData	 	= ReadObjMem(4,base,"AnChrData...") -- Raw Char data
	AnSequence 		= ReadObjMem(4,base,"AnSequence..") -- Animation sequence
	NewAnFrm	 	= ReadObjMem(2,base,"NewAnFrm....") -- Current animation frame
	OldAnFrm	 	= ReadObjMem(2,base,"OldAnFrm....") -- Last animation frame
	AnPatch	 		= ReadObjMem(4,base,"AnPatch.....") -- Animation patch
	AnDex		 	= ReadObjMem(2,base,"AnDex.......") -- Animation index
	AnFlags	 		= ReadObjMem(1,base,"AnFlags.....") -- Animation flags
	AnCnt		 	= ReadObjMem(1,base,"AnCnt.......") -- Counter
	AnCmp		 	= ReadObjMem(1,base,"AnCmp.......") -- Counter compare
	AnLoop	 		= ReadObjMem(1,base,"AnLoop......") -- loop counter
	AnSeqTemp	 	= ReadObjMem(4,base,"AnSeqTemp...") -- Temp storage for Ajsr
	AnDexTemp	 	= ReadObjMem(2,base,"AnDexTemp...") -- Temp storage for Ajsr
	AnSeqLab	 	= ReadObjMem(4,base,"AnSeqLab....") -- stor for label	
	RefAnRam	 	= ReadObjMem(4,base,"RefAnRam....") -- Objects W/VRAM reference table
	Type		 	= ReadObjMem(2,base,"Type........") -- Type
	ObNum		 	= ReadObjMem(2,base,"ObNum.......") -- Object # (from 4th layer trigger)
	EventVar1	 	= ReadObjMem(1,base,"EventVar1...") -- event variable			
	EventVar2	 	= ReadObjMem(1,base,"EventVar2...") -- event variable			
	EventVar3	 	= ReadObjMem(1,base,"EventVar3...") -- event variable			
	EventVar4	 	= ReadObjMem(1,base,"EventVar4...") -- event variable
	Flag1		 	= ReadObjMem(1,base,"Flag1.......") -- General purpose flags	
	Flag2		 	= ReadObjMem(1,base,"Flag2.......") -- General purpose flags	
	Flag3		 	= ReadObjMem(1,base,"Flag3.......") -- General purpose flags	
	Flag4		 	= ReadObjMem(1,base,"Flag4.......") -- General purpose flags	
	Flag5		 	= ReadObjMem(1,base,"Flag5.......") -- General purpose flags	
	Flag6		 	= ReadObjMem(1,base,"Flag6.......") -- General purpose flags	
	Flag7		 	= ReadObjMem(1,base,"Flag7.......") -- General purpose flags	
	Flag8		 	= ReadObjMem(1,base,"Flag8.......") -- General purpose flags	
	Nrg		 		= ReadObjMem(2,base,"Nrg.........") -- Health	
	Pal		 		= ReadObjMem(2,base,"Pal.........") -- palette overide
	Task		 	= ReadObjMem(4,base,"Task........") -- Special task patch
	Var1		 	= ReadObjMem(1,base,"Var1........") -- general purpose variable
	Var1a		 	= ReadObjMem(1,base,"Var1a.......") -- general purpose variable
	Var2		 	= ReadObjMem(1,base,"Var2........") -- general purpose variable
	Var2a		 	= ReadObjMem(1,base,"Var2a.......") -- general purpose variable
	Var3		 	= ReadObjMem(1,base,"Var3........") -- general purpose variable
	Var3a		 	= ReadObjMem(1,base,"Var3a.......") -- general purpose variable
	Var4		 	= ReadObjMem(1,base,"Var4........") -- general purpose variable
	Var4a		 	= ReadObjMem(1,base,"Var4a.......") -- general purpose variable
	Var5		 	= ReadObjMem(1,base,"Var5........") -- general purpose variable
	Var5a		 	= ReadObjMem(1,base,"Var5a.......") -- general purpose variable
	Var6		 	= ReadObjMem(1,base,"Var6........") -- general purpose variable
	Var6a		 	= ReadObjMem(1,base,"Var6a.......") -- general purpose variable
	Var7		 	= ReadObjMem(1,base,"Var7........") -- general purpose variable
	Var7a		 	= ReadObjMem(1,base,"Var7a.......") -- general purpose variable
	Var8		 	= ReadObjMem(1,base,"Var8........") -- general purpose variable
	Var8a		 	= ReadObjMem(1,base,"Var8a.......") -- general purpose variable
	Var9		 	= ReadObjMem(1,base,"Var9........") -- general purpose variable
	Var9a		 	= ReadObjMem(1,base,"Var9a.......") -- general purpose variable
	Interact	 	= ReadObjMem(4,base,"Interact....") -- general purpose ob # passing var
	Interact2	 	= ReadObjMem(4,base,"Interact2...") -- general purpose ob # passing var
	MasterMode 		= ReadObjMem(2,base,"MasterMode..") -- flags to say exactly what the object is doing
	CollisionRAM	= ReadObjMem(4,base,"CollisionRAM") -- pointer to collision database
	OffRoutine		= ReadObjMem(4,base,"OffRoutine..") -- Routine called when object is turned off by scrolling
	HitRoutine		= ReadObjMem(4,base,"HitRoutine..") -- Routine called when object takes a hit
end

function ObjectDetecion(base)
	if showObj == 0 then
		gui.text(posXoffs,0,"Object detection","yellow")
	end
	nextoffset = 0
	count = -1
	UnderHEAD			= ReadDetectMem(1,base,"M.Head..",0)
	UnderTOP			= ReadDetectMem(1,base,"M.Top...",0)
	Under				= ReadDetectMem(1,base,"M.Center",0)
	UnderBOT			= ReadDetectMem(1,base,"M.Bottom",0)
	UnderFEET			= ReadDetectMem(1,base,"M.Feet..",0)
	UnderLEFTHEAD		= ReadDetectMem(1,base,"L.Head..",0)
	UnderLEFTTOP		= ReadDetectMem(1,base,"L.Top...",0)
	UnderLEFT			= ReadDetectMem(1,base,"L.Center",0)
	UnderLEFTBOT		= ReadDetectMem(1,base,"L.Bottom",0)
	UnderLEFTFEET		= ReadDetectMem(1,base,"L.Feet..",0)
	UnderRIGHTHEAD		= ReadDetectMem(1,base,"R.Head..",0)
	UnderRIGHTTOP		= ReadDetectMem(1,base,"R.Top...",0)
	UnderRIGHT			= ReadDetectMem(1,base,"R.Center",0)
	UnderRIGHTBOT		= ReadDetectMem(1,base,"R.Bottom",0)
	UnderRIGHTFEET		= ReadDetectMem(1,base,"R.Feet..",0)
end

function ObjectDetecionContour(base)
	if showObj == 0 then
		gui.text(posXoffs,0,"Object contour","yellow")
	end
	nextoffset = 0
	count = -1
	UnderHEAD_c			= ReadDetectMem(4,base,"M.Head..",1)
	UnderTOP_c			= ReadDetectMem(4,base,"M.Top...",1)
	Under_c				= ReadDetectMem(4,base,"M.Center",1)
	UnderBOT_c			= ReadDetectMem(4,base,"M.Bottom",1)
	UnderFEET_c			= ReadDetectMem(4,base,"M.Feet..",1)
	UnderLEFTHEAD_c		= ReadDetectMem(4,base,"L.Head..",1)
	UnderLEFTTOP_c		= ReadDetectMem(4,base,"L.Top...",1)
	UnderLEFT_c			= ReadDetectMem(4,base,"L.Center",1)
	UnderLEFTBOT_c		= ReadDetectMem(4,base,"L.Bottom",1)
	UnderLEFTFEET_c		= ReadDetectMem(4,base,"L.Feet..",1)
	UnderRIGHTHEAD_c	= ReadDetectMem(4,base,"R.Head..",1)
	UnderRIGHTTOP_c		= ReadDetectMem(4,base,"R.Top...",1)
	UnderRIGHT_c		= ReadDetectMem(4,base,"R.Center",1)
	UnderRIGHTBOT_c		= ReadDetectMem(4,base,"R.Bottom",1)
	UnderRIGHTFEET_c	= ReadDetectMem(4,base,"R.Feet..",1)
end
--]]--