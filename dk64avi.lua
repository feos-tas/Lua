-- feos, 2017
-- DK64 resync workflow
-- props to thecoreyburton

t = {}            -- array of state names found
count = 0         -- total states found, just for print()
av_paused = false -- pretend we have that info from the emu
offset = 5        -- av delay after stated frame

-- scan the script dir for states and store their names to array
function scandir()
	local popen = io.popen          -- use cmd
	local pfile = popen('dir . /b') -- cmd arguments
	local i = 0
	local index = 0
	local name = ""
	for filename in pfile:lines() do
		i = i + 1
		
		-- strip frame numbers
		name = string.gsub(filename, ".State", "")
		index = tonumber(name)
		
		-- skip all but state files
		if index then
			t[index] = filename
			count = count + 1
		end
	end
	pfile:close()
end

scandir()
print("States found: " .. count) -- #t doesn't work for some reason (gaps in the table?)

while true do
	if movie.isloaded() then
		-- check if there's a state of "offset" frames back
		local name = t[emu.framecount() - offset]
		
		-- basic report you'd barely see
		if av_paused then
			gui.text(0, 40, "AV paused")
		end
		
		-- suspend av and load the state, with a delay
		if name and not av_paused then
			client.pause_av()
			av_paused = true
			savestate.load(name)
			print("Loaded " .. name)
		end
		
		-- resume av when that frame occurs again
		if t[emu.framecount() - offset] and av_paused then
			client.unpause_av()
			av_paused = false
		end
	end
	emu.frameadvance()
end