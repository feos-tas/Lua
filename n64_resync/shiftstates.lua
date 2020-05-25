-- feos, 2017
-- resync workflow
-- props to thecoreyburton

t = {}            -- array of state names found
count = 0         -- total states found, just for print()
offset = 2        -- av delay after stated frame

-- scan the script dir for states and store their names to array
function scandir()
	local popen = io.popen          -- use cmd
	local pfile = popen('dir . /b') -- cmd arguments
	local i = 0
	local index = 0
	local name = ""
	for filename in pfile:lines() do
		i = i + 1
		
		-- skip all but state files
		if filename:find(".State") then
			-- strip frame numbers
			name = string.gsub(filename, ".State", "")
			index = tonumber(name)
			t[index] = filename
			count = count + 1
		end
	end
	pfile:close()
end

scandir()
print("States found: " .. count) -- #t doesn't work for some reason (gaps in the table?)
os.execute("mkdir " .. offset)

while true do
	if movie.isloaded() then
		local name = t[emu.framecount() + offset]
		local newname = string.format("./%s/%s.State", offset, emu.framecount())
		
		if name then
			savestate.save(newname)
			print(name .. " turned into " .. newname)
		end
	end
	emu.frameadvance()
end