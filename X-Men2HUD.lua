-- X-Men 2 for Genesis - HUD script
-- feos, 2012

gui.register(function()

	x    = memory.readwordunsigned(0xFFEAB1)
	y    = memory.readwordunsigned(0xFFEAB5)
	xvel = memory.readwordsigned  (0xFFEABE)
	yvel = memory.readwordsigned  (0xFFEAC0)
	xsub = memory.readbyteunsigned(0xFFEAB3)
	ysub = memory.readbyteunsigned(0xFFEAB7)
	xcam = memory.readwordunsigned(0xFFCD72)
	ycam = memory.readwordunsigned(0xFFCD70)
	xgui = 220
	ygui = 190
	xscr = x-xcam
	yscr = y-ycam

	gui.text(xgui+30, ygui,    "X        Y",  "green")
	gui.text(xgui,    ygui+8,  "Lev:",        "green")
	gui.text(xgui+23, ygui+8,  x.."."..xsub, "yellow")
	gui.text(xgui+60, ygui+8,  y.."."..ysub, "yellow")
	gui.text(xgui,    ygui+16, "Vel:",        "green")
	gui.text(xgui+23, ygui+16, xvel,         "yellow")
	gui.text(xgui+60, ygui+16, yvel,         "yellow")
	gui.text(xgui,    ygui+24, "Cam:",        "green")
	gui.text(xgui+23, ygui+24, xcam,         "yellow")
	gui.text(xgui+60, ygui+24, ycam,         "yellow")
	gui.text(xscr-18,  yscr-7, "I'm here!",   "green")

end)