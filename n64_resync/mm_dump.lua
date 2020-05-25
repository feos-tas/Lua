-- feos, 2017
-- Majora's Mask resync workflow
-- props to thecoreyburton and Isotarge

-- init on script launch
logfile = io.open("log.txt", "w")
logfile:close()

u32 = mainmemory.read_u32_be -- handy shortcut
u16 = mainmemory.read_u16_be -- handy shortcut

function GetData()
	pos = string.format("%08X%08X%08X",
		u32(0x3FFDD4), -- x pos
		u32(0x3FFDD8), -- y pos
		u32(0x3FFDDC)) -- z pos
	
	rot = string.format("%08X%08X%08X\n",
		u16(0x3FFE6C), -- x rotation
		u16(0x3FFE6E), -- facing
		u16(0x3FFE70)) -- y rotation
	
	-- combined string
	return pos..rot
end

while true do
	-- init on movie reboot. can be removed
	if emu.framecount() == 0 then
		logfile = io.open("log.txt", "w")
		logfile:close()
	end
	
	-- open the file every frame
	logfile = io.open("log.txt", "a")
	
	-- if your text editor shows line numbers starting with 1, like notepad++,
	-- then line numbers will match frame numbers
	-- if it starts from 0, remove the condition
	if emu.framecount() > 0 then
		logfile:write(GetData())
	end
	
	-- flush and move on
	logfile:close()
	emu.frameadvance()
end