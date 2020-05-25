-- feos, 2017
-- DK64 resync workflow
-- props to thecoreyburton and Isotarge

-- init on script launch
logfile = io.open("log.txt", "w")
logfile:close()

u32 = mainmemory.read_u32_be -- handy shortcut

function GetData()
	-- get pointers
	local player = u32(0x7FBB4C)
	local camera = u32(0x7FB968)
	
	-- the actual values are floats
	-- but let's just use their raw hex view for simplicity
	if player >= 0x80000000 and player < 0x80800000 then
		player = player - 0x80000000
		pos = string.format("%08X%08X%08X",
			u32(player + 0x7C), -- x
			u32(player + 0x80), -- y
			u32(player + 0x84)) -- z
	else
		pos = "000000000000000000000000"
	end
	
	if camera >= 0x80000000 and camera < 0x80800000 then
		camera = camera - 0x80000000
		cam = string.format("%08X%08X%08X\n",
			u32(camera + 0x1FC), -- x
			u32(camera + 0x200), -- y
			u32(camera + 0x204)) -- z
	else
		cam = "000000000000000000000000\n"
	end
	
	-- conbined string
	return pos..cam
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
	-- if it starts from 0, remove the confition
	if emu.framecount() > 0 then
		logfile:write(GetData())
	end
	
	-- flush and move on
	logfile:close()
	emu.frameadvance()
end