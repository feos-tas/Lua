no_lag = false
function draw()
	Xspd = memory.readbytesigned(0x53b)
	Yspd = memory.readbytesigned(0x53c)
	X    = memory.readbyte(0x58f)
	Y    = memory.readbyte(0x59b)
	camX = memory.readbyte(0x31f) + memory.readbyte(0x320)*0x100
	camY = memory.readbyte(0x31b)
	InvTmr=memory.readbyte(0x4b2)
	gui.text(1,1,"X: "..X+camX.."\nY: "..Y+camY)
	gui.text(50,1,"InvTmr:\n"..InvTmr)
end

function set_nolag()
  no_lag = true;
  draw()
end
memory.registerexecute(0xC6E9, set_nolag);  -- 07:C6E9 INC $0322

function determine_lagflag()
  if (no_lag) then
    emu.setlagflag(false);
    no_lag = false;     -- no_lag only affects once
  else
    emu.setlagflag(true);
  end
end
memory.registerexecute(0xDE58, determine_lagflag);  -- 07:DE58 End of the cycle of reading from $4016-4017 (the point where FCEUX sets lagFlag to 0)

emu.registerafter(draw);