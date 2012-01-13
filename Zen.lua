LastX = 0
LastY = 0

function stuff()

   CamX = memory.readbyteunsigned(0x5CC) + 256 * memory.readbyteunsigned(0x5D0)
   CamY = memory.readbyteunsigned(0x5CE) + 256 * memory.readbyteunsigned(0x5D2)

   SprX = memory.readbyteunsigned(0x3A0)
   SprY = memory.readbyteunsigned(0x3B0)

   X = CamX + SprX
   Y = CamY + SprY

   gui.text(SprX-6, SprY,   X-LastX)
   gui.text(SprX-6, SprY+9, LastY-Y)
   gui.text(  1,  1, "X=" .. X .. "." .. memory.readbyteunsigned(0x3D0))
   gui.text(  1, 10, "Y=" .. Y .. "." .. memory.readbyteunsigned(0x440))
   gui.text( 70,  1, "CamX=" .. CamX)
   gui.text( 70, 10, "CamY=" .. CamY)
   gui.text(140,  1, "CamSpdX=" .. memory.readbytesigned(0x5d6))
   gui.text(140, 10, "CamSpdY=" .. -memory.readbytesigned(0x5d7))
   gui.text(210,  1, memory.readbyteunsigned(0x522)) -- Boss HP
   
   LastX = X
   LastY = Y

end

emu.registerafter(stuff)