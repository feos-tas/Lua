-- Enemies' slots, HP and invulnerability timers

function info()
	for i = 0, 7 do
		x     = memory.readbyte(0x47b+i)
		y     = memory.readbyte(0x499+i) - memory.readbyte(0x4b7+i)
		hp    = memory.readbyte(0x622+i)
		timer = memory.readbyte(0x68a+i)
		id    = memory.readbyte(0x52a+i)
		if x<6 then x=6 elseif x>250 then x=250 end
		if id>0 then
			gui.text(x-6, y-18, string.format("S%d\n%d\n%d",i+1,hp,timer))
		end
	end
end
emu.registerafter(info);