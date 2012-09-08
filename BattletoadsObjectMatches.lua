-- feos, 2012
-- NES Battletoads, object attributes checker

-- Virtual breakpoints table
-- Comment out the unused
-- Don't forget the comma when using >1
--	{  ID, "Attrib",Value}
Check = {
--	{   1, "Xspd",   0xC0},
	{0x22, "Target", 0x55},
	{0x7E, "Cntr2",  0x7F},
	{0x7F, "VarFlg", 0x7F}
}

Attribs = {
--  "Name", offset
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

function ToBin8(Num,Switch)
-- 1 byte to binary convertor by feos, 2012
-- Switch: "s" for string, "n" for number
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
end

function Draw()
	for Slot = 0, 14 do
		ID = memory.readbyte(0x3c1+Slot)
		gui.text(1, 1, "Slot:\nID:")
		gui.text(1+Slot*15+31, 1,  string.format("%2d",Slot+1))
		gui.text(1+Slot*15+31, 10, string.format("%2X",ID))		
		for i,v in ipairs(Check) do
			for offset,name in ipairs(Attribs) do
				if ID == v[1] and name == v[2] then
					gui.text(1, 8+10*i, v[2]..":")
					CheckAddr = 0x3c1+offset*15+Slot
					CheckVal = memory.readbyte(CheckAddr)
					gui.text(1+Slot*15+31, 8+10*i, string.format("%2X",CheckVal),"#00ff00ff")
					if CheckVal == v[3] then
						gui.text(40, 241-i*10, string.format(
							"ID:%d %s: $%2X = %2X : %s",
							Slot+1,v[2],CheckAddr,CheckVal,ToBin8(CheckVal,"s")
							))
						emu.pause()
					end
				end
			end
		end
	end
end

emu.registerafter(Draw);