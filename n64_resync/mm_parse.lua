-- feos, 2017
-- Majora's Mask resync workflow
-- props to thecoreyburton and Isotarge

u32 = mainmemory.read_u32_be -- handy shortcut
u16 = mainmemory.read_u16_be -- handy shortcut
tab = {}                     -- entire parsed file broken into lines
desynced = false             -- internal trigger

function ParseFile()
	-- in case it takes more than a moment
	print("Parsing file...")
	
	-- read the file
	local logfile = io.open("log.txt", "r")
	
	-- fetch all lines
	for line in logfile:lines() do
		table.insert(tab, line)
	end

	-- bye
	logfile:close()
	
	-- congrats!
	print("File parsed! Line count: "..#tab.."\n")
end

function GetData()
	pos = string.format("%08X%08X%08X",
		u32(0x3FFDD4), -- x pos
		u32(0x3FFDD8), -- y pos
		u32(0x3FFDDC)) -- z pos
	
	rot = string.format("%08X%08X%08X",
		u16(0x3FFE6C), -- x rotation
		u16(0x3FFE6E), -- facing
		u16(0x3FFE70)) -- y rotation
	
	-- combined string
	return pos..rot
end

ParseFile() -- bare call

-- reset the desync state
event.onloadstate(function()
	desynced = false
end)

while true do
	if emu.framecount() == 0 then
		emu.frameadvance()
	end
	
	local frame = emu.framecount()
	local original = GetData()
	local yours = tab[frame]
	
	if frame == #tab then
		print("Log ended at frame "..frame)
	elseif frame > #tab then
		return
	end
	
	-- repeat until desync occurs
	if not desynced then	
		-- print to screen
		gui.pixelText(0, 40, string.format(
			"%s - original\n%s - yours",
			original, yours))	
		
		-- first mismatch
		if yours ~= original then
		
			-- screen alarm
			gui.pixelText(0, 40, string.format(
				"%s - original\n%s - yours\ndesync at frame %d",
				original, yours, frame), "red")
				
			-- console alarm
			print(string.format(
				"desync at frame %d\n%s\n%s\n",
				frame, yours, original))
				
			-- skip next loops
			desynced = true
			
			-- make sure not to move
			client.pause()
		end
	end
	
	-- so far so good
	emu.frameadvance()
end