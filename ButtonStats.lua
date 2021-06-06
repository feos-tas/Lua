 -- feos, 2021
 -- parses movie file and collects various stats on the specified input button
 -- no need to load the movie into emulator, just provide its path and run the script
 
 local filename = "happylee-supermariobros,warped.fm2"
 local mnemonic = "A"
 local separator = "|"
 
 local currentItemStart = 0
 local inputs = 0
 local sequences = 0
 local inputsCheck = 0
 local sequencesCheck = 0
 local inputsCheckPassed = false
 local sequencesCheckPassed = false
 
 local frames = {}
 local durations = {}
 
 local movie = io.open(filename, "r")
 
 for line in movie:lines() do
 	if string.find(line, separator) == 1 then
 		table.insert(frames, line)
 	end
 end
 
 movie:close()
 
 print(" " .. filename)
 print(" Parsed " .. #frames .. " frames")
 print(" ")
 
 for frame = 1, #frames+1 do
 	if frames[frame] and string.find(frames[frame], mnemonic) then
 		inputs = inputs+1
 		
 		if frame == 1 or string.find(frames[frame-1], mnemonic) == nil then
 			currentItemStart = frame
 		end
 		
 		if currentItemStart > 0
 		and (not frames[frame+1] or not string.find(frames[frame+1], mnemonic)) then
 			sequences = sequences + 1			
 			local duration = frame+1 - currentItemStart
 			
 			if duration > 0 then			
 				if not durations[duration] then
 					durations[duration] = 1
 				else
 					durations[duration] = durations[duration] + 1
 				end
 			end
 			
 			currentItemStart = 0
 		end
 	end
 end
 
 print(" Total " .. mnemonic .. " input count: " .. inputs)
 print(" Ratio: " .. #frames / inputs)
 print(" ")
 print(" Total consequtive " .. mnemonic .. " sequences: " .. sequences)
 print(" Ratio: " .. #frames / sequences)
 print(" ")
 print(" Sequence durations")
 
 for duration, count in pairs(durations) do
 	inputsCheck = inputsCheck + duration * count
 	sequencesCheck = sequencesCheck + count
 	print(" " .. duration .. "-frame: " .. count)
 end
 
 print("")
 print("Debug checks")
 
 if inputs    == inputsCheck    then inputsCheckPassed    = true end
 if sequences == sequencesCheck then sequencesCheckPassed = true end
 
 print("Inputs check passed (" .. inputs .. " == " .. inputsCheck .. "): "
 	.. tostring(inputsCheckPassed))
 print("Sequences check passed (" .. sequences .. " == " .. sequencesCheck .. "): "
 	.. tostring(sequencesCheckPassed))