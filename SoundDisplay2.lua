-- feos, 2012

print("Leftclick over the displays:")
print("channel names to hide the volumes,")
print("notes to hide the keyboard.")
print(" ")
print("And praise Gocha!")

iterator = 15
prev_iterator = iterator
kb = {x=9, y=155, on=true}
prev_kb = kb.on
prev_keys = input.get()
semitones = {"A-", "A#", "B-", "C-", "C#", "D-", "D#", "E-", "F-", "F#", "G-", "G#"}
message = " Presss here to  \n               \n dump notes to file"
filenum = 1
dumping = false
header = true

volumes = {
	S1V = {0}, S1C = {},
	S2V = {0}, S2C = {},
	TV = {0},
	NV = {0},
	DPCMV = {0}
}

function Draw()
	snd = sound.get()
	keys = input.get()
	
	-- do only at the first frame
	if #volumes.S1V == 1 then
		channels = {
			Square1  = {x=1,      y=9, vol=volumes.S1V, color=volumes.S1C, duty=0, midi=0, semitone=0, octave=0},
			Square2  = {x=1+45*1, y=9, vol=volumes.S2V, color=volumes.S2C, duty=0, midi=0, semitone=0, octave=0},
			Triangle = {x=1+45*2, y=9, vol=volumes.TV, midi=0, semitone=0, octave=0},
			Noise    = {x=1+45*3, y=9, vol=volumes.NV, midi=0, semitone=0, octave=0},
			DPCM     = {x=1+45*4, y=9, vol=volumes.DPCMV}
		}
	end

	-- update the first indices for volume tables
	-- shift the previous ones farther
	table.insert(channels.Square1.vol, 1, snd.rp2a03.square1.volume*15)
	table.insert(channels.Square2.vol, 1, snd.rp2a03.square2.volume*15)
	table.insert(channels.Triangle.vol, 1, snd.rp2a03.triangle.volume*15)
	table.insert(channels.Noise.vol, 1, snd.rp2a03.noise.volume*15)
	table.insert(channels.DPCM.vol, 1, snd.rp2a03.dpcm.volume*15)

	-- get duty and midikey for proper channels
	channels.Square1.duty = snd.rp2a03.square1.duty
	channels.Square2.duty = snd.rp2a03.square2.duty
	channels.Square1.midi = snd.rp2a03.square1.midikey
	channels.Square2.midi = snd.rp2a03.square2.midikey
	channels.Triangle.midi = snd.rp2a03.triangle.midikey
	channels.Noise.midi = snd.rp2a03.noise.midikey

	-- guess notes
	for name, chan in pairs(channels) do
		if name == "Square1" or name == "Square2" or name == "Triangle" or name == "Noise" then
			if chan.vol[1] > 0 then
				chan.octave = math.floor((chan.midi - 12) / 12)
				chan.semitone = tostring(semitones[math.floor((chan.midi - 21) % 12) + 1])
			else chan.semitone = "--"; chan.octave = "-"
			end
			if string.len(chan.octave) < 2 then chan.octave = chan.octave.." " end
			if chan.vol[1] < 10 then chan.vol[1] = " "..chan.vol[1] end
		end
	end
	
	-- notes display
	color = "#ff0000ff"
	gui.text(kb.x+203, kb.y-1,  "S1: "..channels.Square1.semitone..channels.Square1.octave, color, "#000000ff")
	gui.text(kb.x+203, kb.y+8,  "S2: "..channels.Square2.semitone..channels.Square2.octave, color, "#000000ff")
	gui.text(kb.x+204, kb.y+17, "Tr: "..channels.Triangle.semitone..channels.Triangle.octave, "#00aaffff", "#000000ff")
	gui.text(kb.x+204, kb.y+26, "Ns: "..channels.Noise.semitone..channels.Noise.octave, "ffffffff", "#000000ff")

--------------------
-- Keyboard stuff --
--------------------

	if (kb.on) then
		-- capture leftclicks
		if keys.xmouse <= 256 and keys.xmouse >= 205 and keys.ymouse >= 154 and keys.ymouse <= 181 then
			if keys["leftclick"] and not prev_keys["leftclick"] then kb.on = false end
		end		
		-- draw the kayboard
		gui.box(kb.x-8, kb.y, kb.x+200, kb.y+16, "#ffffffff") -- white solid box
		for a = -2, 49 do gui.box(kb.x+4*a, kb.y, kb.x+4*a, kb.y+16, "#00000000") end -- black lines
		for name, chan in pairs(channels) do
			-- draw colored boxes as clean notes
			if name == "Square1" or name == "Square2" or name == "Triangle" then
				if name == "Triangle" then color = "#00aaffff" else color = "#ff0000ff" end
				if     chan.semitone == "C-" then gui.box (kb.x+1 +28*(chan.octave-1), kb.y, kb.x+3 +28*(chan.octave-1), kb.y+16, color)
				elseif chan.semitone == "D-" then gui.box (kb.x+5 +28*(chan.octave-1), kb.y, kb.x+7 +28*(chan.octave-1), kb.y+16, color)
				elseif chan.semitone == "E-" then gui.box (kb.x+9 +28*(chan.octave-1), kb.y, kb.x+11+28*(chan.octave-1), kb.y+16, color)
				elseif chan.semitone == "F-" then gui.box (kb.x+13+28*(chan.octave-1), kb.y, kb.x+15+28*(chan.octave-1), kb.y+16, color)
				elseif chan.semitone == "G-" then gui.box (kb.x+17+28*(chan.octave-1), kb.y, kb.x+19+28*(chan.octave-1), kb.y+16, color)
				elseif chan.semitone == "A-" then gui.box (kb.x+21+28*(chan.octave-1), kb.y, kb.x+23+28*(chan.octave-1), kb.y+16, color)
				elseif chan.semitone == "B-" then gui.box (kb.x+25+28*(chan.octave-1), kb.y, kb.x+27+28*(chan.octave-1), kb.y+16, color)
				end
			end
		end		
		-- draw accidental keys
		gui.box(kb.x-3, kb.y, kb.x-5, kb.y+10, "#00000000")
		gui.text(kb.x+1+28*7, kb.y+17, "8")
		for oct = 0, 6 do
			gui.text(kb.x+1+28*oct, kb.y+17, oct+1) -- draw octave number at the proper place
			gui.box(kb.x+3+28*oct, kb.y, kb.x+5+28*oct, kb.y+10, "#00000000")
			gui.box(kb.x+7+28*oct, kb.y, kb.x+9+28*oct, kb.y+10, "#00000000")
			gui.box(kb.x+15+28*oct, kb.y, kb.x+17+28*oct, kb.y+10, "#00000000")
			gui.box(kb.x+19+28*oct, kb.y, kb.x+21+28*oct, kb.y+10, "#00000000")
			gui.box(kb.x+23+28*oct, kb.y, kb.x+25+28*oct, kb.y+10, "#00000000")
		end
		for name, chan in pairs(channels) do
			-- draw colored boxes over accidental keys
			if name == "Square1" or name == "Square2" or name == "Triangle" then
				if name == "Triangle" then color = "#00aaffff" else color = "#ff0000ff" end
				if     chan.semitone == "C#" then gui.box (kb.x+3 +28*(chan.octave-1), kb.y, kb.x+5 +28*(chan.octave-1), kb.y+10, color)
				elseif chan.semitone == "D#" then gui.box (kb.x+7 +28*(chan.octave-1), kb.y, kb.x+9 +28*(chan.octave-1), kb.y+10, color)
				elseif chan.semitone == "F#" then gui.box (kb.x+15+28*(chan.octave-1), kb.y, kb.x+17+28*(chan.octave-1), kb.y+10, color)
				elseif chan.semitone == "G#" then gui.box (kb.x+19+28*(chan.octave-1), kb.y, kb.x+21+28*(chan.octave-1), kb.y+10, color)
				elseif chan.semitone == "A#" then gui.box (kb.x+23+28*(chan.octave-1), kb.y, kb.x+25+28*(chan.octave-1), kb.y+10, color)
				end
			end
		end		
		gui.box(kb.x-8, kb.y, kb.x+200, kb.y+16, "#00000000")
	else
		-- capture leftclicks
		if keys.xmouse <= 256 and keys.xmouse >= 205 and keys.ymouse >= 154 and keys.ymouse <= 181 then
			if keys["leftclick"] and not prev_keys["leftclick"] then kb.on = true end
		end
	end
	
---------------------
-- Volumes display --
---------------------

	for name, chan in pairs(channels) do
		if name == "Square1" or name == "Square2" then
			-- set color for each duty value
			if chan.duty == 0 then table.insert(chan.color,1,"#aaff00ff")
			elseif chan.duty == 1 then table.insert(chan.color,1,"#00ff00ff")
			elseif chan.duty == 2 then table.insert(chan.color,1,"#00bb00ff")
			else table.insert(chan.color,1,"#008800ff")
			end
		end
		-- capture leftclicks
		if iterator == 15 then
			if keys.ymouse <= 24 and keys.ymouse >= 0 then
				if keys["leftclick"] and not prev_keys["leftclick"] then iterator = 1 end
			end
		else
			if keys.ymouse <= 24 and keys.ymouse >= 0 then
				if keys["leftclick"] and not prev_keys["leftclick"] then iterator = 15 end
			end
		end
		-- draw volumes
		gui.text(chan.x, 9, name, "#ffffffff", "#000000ff")	
		if iterator <=14 then
			-- draw just first volume values
			gui.text(chan.x, chan.y+9+1, chan.vol[1])
			if tonumber(chan.vol[1]) > 0 then
				for j = 0, chan.vol[1]-1 do
					gui.box(chan.x+13+j*2, chan.y+9, chan.x+15+j*2, chan.y+8+9, "#000000ff")
					gui.line(chan.x+14+j*2, chan.y+1+9, chan.x+14+j*2, chan.y+7+9, "#00ff00ff")
					if name == "Square1" or name == "Square2" then
						-- color comes from duty
						gui.text(chan.x+38, chan.y, chan.duty, chan.color[1], "#000000ff")
						gui.line(chan.x+14+j*2, chan.y+1+9, chan.x+14+j*2, chan.y+7+9, chan.color[1])
					end
				end
			end
		else
			-- draw all 15 volume values
			for i = 1, #chan.vol do
				gui.text(chan.x, chan.y+i*9+1, chan.vol[i])
				if tonumber(chan.vol[i]) > 0 then
					for j = 0, chan.vol[i]-1 do
						gui.box(chan.x+13+j*2, chan.y+i*9, chan.x+15+j*2, chan.y+8+i*9, "#000000ff")
						gui.line(chan.x+14+j*2, chan.y+1+i*9, chan.x+14+j*2, chan.y+7+i*9, "#00ff00ff")
						if name == "Square1" or name == "Square2" then
							-- color comes from duty
							gui.text(chan.x+38, chan.y, chan.duty, chan.color[1], "#000000ff")
							gui.line(chan.x+14+j*2, chan.y+1+i*9, chan.x+14+j*2, chan.y+7+i*9, chan.color[i])
						end
					end
				end
			end
		end
		-- keep the table limited
		table.remove(chan.vol, 15)
		-- highlight the first values
		if tonumber(chan.vol[1]) > 0 then
			gui.box(chan.x+12, chan.y+8, chan.x+14+chan.vol[1]*2, chan.y+18, "#ffaaaa00")
		end
	end	
	
-------------------
-- Sound dumping --
-------------------

	gui.text(100, 185, message, "white", "black")
	if dumping == false then
		if keys.xmouse <= 200 and keys.xmouse >= 100 and keys.ymouse >= 185 and keys.ymouse <= 210 then
			if keys["leftclick"] and not prev_keys["leftclick"] then
				dumping = true
				header = true
				-- load the memory off a bit
				-- store the previous modes for volumes and keyboard
				if iterator == 15 then prev_iterator = 15; iterator = 1 else prev_iterator = 1 end
				if kb.on == true then prev_kb = true kb.on = false else prev_kb = false end
			end
		end
	else
		if keys.xmouse <= 200 and keys.xmouse >= 100 and keys.ymouse >= 185 and keys.ymouse <= 210 then
			if keys["leftclick"] and not prev_keys["leftclick"] then
				DumpFile = io.open("Music Dump - "..filenum..".txt" , "a+")
				DumpFile:write("||--------------||--------------||----------||----------||\n\n")
				DumpFile:write("End frame = "..emu.framecount()                                )
				DumpFile:close()
				dumping = false
				message = " Finished!       \n              \n Dump another file"
				if kb.on == true then kb.on = false end
				-- restore the previous modes for keyboard and volumes
				iterator = prev_iterator; kb.on = prev_kb
				filenum = filenum + 1
				header = true
			end
		end
	end
	
	if dumping == true then
		message = " Processing... \n           \n Stop dumping "
		if header == true then
			DumpFile = io.open("Music Dump - "..filenum..".txt" , "w+")
			DumpFile:write("Start frame = "..emu.framecount().."\n\n"                    )
			DumpFile:write("||--------------||--------------||----------||----------||\n")
			DumpFile:write("||   Square 1   ||   Square 2   || Triangle ||   Noise  ||\n")
			DumpFile:write("||--------------||--------------||----------||----------||\n")
			DumpFile:write("||Note |Vol |Dut||Note |Vol |Dut||Note |Vol ||Note |Vol ||\n")
			DumpFile:write("||-----|----|---||-----|----|---||-----|----||-----|----||\n")
			header = false
		else
			DumpFile = io.open("Music Dump - "..filenum..".txt" , "a+")
			DumpFile:write(emu.framecount().."|| "..channels.Square1.semitone..channels.Square1.octave.."| "..channels.Square1.vol[1].." | "..channels.Square1.duty.." ")
			DumpFile:write("|| "..channels.Square2.semitone..channels.Square2.octave.."| "..channels.Square2.vol[1].." | "..channels.Square2.duty.." ")
			DumpFile:write("|| "..channels.Triangle.semitone..channels.Triangle.octave.."| "..channels.Triangle.vol[1].." ")
			DumpFile:write("|| "..channels.Noise.semitone..channels.Noise.octave.."| "..channels.Noise.vol[1].." ||\n")
		end
	end
	prev_keys = keys
end
emu.registerafter(Draw);