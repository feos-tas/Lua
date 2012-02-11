-- Old version

function ShowNotes() 
	note = taseditor.getnote(taseditor.getmarker(movie.framecount()))
	if string.len (note) >= 50
	then 
		text1 = string.reverse(string.gsub(string.reverse(string.sub(note, 1, 50)), " ", "\n", 1))
		text2 = string.sub (note, 51)
		gui.text(1, 9, text1..text2)
	else gui.text(1, 9, note)
	end
end
emu.registerafter(ShowNotes)