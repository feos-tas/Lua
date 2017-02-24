-- feos, 2017
-- DK64 resync workflow
-- props to thecoreyburton and Isotarge

u32 = mainmemory.read_u32_be -- handy shortcut
tab = {}                     -- entire parsed file broken into lines
desynced = false             -- internal trigger

function ParseFile()
	-- in case it takes more that a moment
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
		cam = string.format("%08X%08X%08X",
			u32(camera + 0x1FC), -- x
			u32(camera + 0x200), -- y
			u32(camera + 0x204)) -- z
	else
		cam = "000000000000000000000000"
	end
	
	-- conbined string
	return pos..cam
end

ParseFile() -- bare call

while true do
	local frame = emu.framecount()
	local original = GetData()
	local yours = tab[frame]
	
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