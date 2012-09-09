-- feos and TheZlomuS, 2012
-- Battletoads Object RAM Viewer

require 'auxlib'

Root = 0x3C0	-- Objects start address
Offs = 0xF		-- Number of slots
lastID,lastSlot,lasti = 0,0,0

-- Instert anything to check
-- You can check for single bit matches applying AND masks
Highlight = {
	{0x22, "VarFlg", 0x55, "0 0 150"},	-- Warp object
	{0x7E, "Cntr2",  0x7F, "0 0 150"},	-- ?
	{0x7F, "VarFlg", 0x7F, "150 0 0"}	-- Level End
}

-- Whole Object RAM block
Attribs = {
--  "Name", offset
	"ID",     -- 0
	"Anim_1", -- 1
	"Cntr_1", -- 2
	"Xpos_H", -- 3
	"Xpos_L", -- 4
	"Ypos_H", -- 5
	"Ypos_L", -- 6
	"Zpos_H", -- 7
	"Zpos_L", -- 8
	"Xsub",   -- 9
	"Ysub",   -- 10
	"Zsub",   -- 11
	"Zshad",  -- 12
	"Xshad",  -- 13
	"Yshad",  -- 14
	"Flag",   -- 15
	"State",  -- 16
	"Zspd",   -- 17
	"Unk_1",  -- 18
	"Cntr_2", -- 19
	"Unk_2",  -- 20 
	"HitID",  -- 21
	"HitTmr", -- 22
	"HP",     -- 23
	"Linked", -- 24
	"Linker", -- 25
	"AnmTmr", -- 26
	"Unk_3",  -- 27
	"Xspd",   -- 28
	"DthTmr", -- 29
	"Anim_2", -- 30
	"Target", -- 31
	"VarFlg", -- 32
	"Unk_4",  -- 33
	"EndTmr", -- 34
}

-- Matrix
mat = iup.matrix {
	lastCol=0, lastLin = 0,
	readonly="YES", hidefocus="YES",
	numcol=Offs, numlin=#Attribs,
	numcol_visible=Offs, numlin_visible=Offs,
	width0="30", widthDef="10", heightDef="7"
}

-- Headers BG color
for c=0,#Attribs do
	for l=0,Offs do
		mat["bgcolor".. 0 ..":".. l] = "80 0 0"
		mat["bgcolor".. c ..":".. 0] = "80 0 0"
	end
end

-- Line headers
for i,v in pairs(Attribs) do
	mat:setcell(i,0,v)
end;

-- Column headers
for i=1, Offs do
	mat:setcell(0,i,i)
end;

-- Table colors
mat.bgcolor = "0 0 0"
mat.fgcolor = "255 255 255"

-- Dialog name and pos
dialogs = dialogs + 1
handles[dialogs] = iup.dialog{
	iup.vbox{mat,iup.fill{}},
	title="Battletoads - Object Attribute Viewer",
	size="295x443"
}
handles[dialogs]:showxy(iup.CENTER, iup.CENTER)

-- Select line/column
function mat:click_cb(lin,col,r)
	if lin == 0 then
		self["fgcolor*:"..self.lastCol] = "255 255 255"
		self["fgcolor"..self.lastLin..":*"] = "255 255 255"
		self.lastCol = col
		self["fgcolor*:"..col] = "255 180 0"
	elseif col == 0 then
		self["fgcolor"..self.lastLin..":*"] = "255 255 255"
		self["fgcolor*:"..self.lastCol] = "255 255 255"
		self.lastLin = lin
		self["fgcolor"..lin..":*"] ="255 180 0"		
	end
	mat.redraw = "ALL"
	return IUP_DEFAULT
end

function ToBin8(Num,Switch)
-- 1 byte to binary converter by feos, 2012
-- Switch: "s" for string, "n" for number
	if Num > 0 then 
		Bin = ""
		while Num > 0 do
			Bin = (Num % 2)..Bin
			Num = math.floor(Num / 2)
		end
		Low = string.format("%04d",(Bin % 10000))
		High = string.format("%04d",math.floor(Bin / 10000))
		
		if Switch == "s" then return High.." "..Low
		elseif Switch == "n" then return Bin
		else return "Wrong Switch parameter!\nUse \"s\" or \"n\"."
		end
	else
		if Switch == "s" then return "0000 0000"
		elseif Switch == "n" then return 0
		else return "Wrong Switch parameter!\nUse \"s\" or \"n\"."
		end
	end
end

-- Values calculation
function DrawMatrix()
	for Slot = 1, Offs do
		ID = memory.readbyte(0x3c1+Slot-1)
		for i,v in ipairs(Attribs) do			
			Address = (Root+(i-1)*Offs+Slot)
			Val = memory.readbyte(Address)
			mat:setcell(i,Slot,string.format("%02X",Val))
			
			-- Highlight the cell and print debug info on matches
			-- You can add virtual breakpoints with memory.register library
			for _,param in ipairs(Highlight) do
				if ID == param[1] and v == param[2] then
					mat["bgcolor*:"..Slot] = param[4]
					mat["bgcolor"..i..":*"] = param[4]
					gui.text(1, 1, string.format(
						"ID%d: $%2X %s: $%2X = $%02X : %s",
						Slot,ID,v,Address,Val,ToBin8(Val,"s")
					))
					lastID = ID
					lastSlot = Slot
					lasti = i
					if Val == param[3] then emu.pause() end
				end
				if memory.readbyte(0x3c1+lastSlot-1) ~= lastID then
					mat["bgcolor*:"..lastSlot] = "0 0 0"
					mat["bgcolor"..lasti..":*"] = "0 0 0"
					lastID = 0
				end
			end
		end
	end

	mat.redraw = "ALL"
end

emu.registerafter(DrawMatrix)