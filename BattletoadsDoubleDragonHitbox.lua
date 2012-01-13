-- Battletoads and Double Dragon NES
-- Positions, speeds and hitboxes (not actual bounding boxes, just object frames)
-- feos, 2011

LastCamX = 0

function show_boxes()

   -- Camera position and display
   CamX = memory.readbyte(0x8D) + 256*memory.readbyte(0x8E)
   CamY = memory.readbyte(0x89) + 256*memory.readbyte(0x90)
   
   gui.text(170,  1,"CamX " .. CamX)
   gui.text(170, 9,"CamY " .. CamY)
   gui.text(170, 17,"CamS " .. CamX - LastCamX) -- X scrolling speed
   
   -- Player 1 position
   X1 = memory.readbyteunsigned(0x3FE) + 256*memory.readbytesigned(0x3EF)
   Y1 = memory.readbyteunsigned(0x43A) + 256*memory.readbytesigned(0x42B)
   Z1 = memory.readbyteunsigned(0x494) + 256*memory.readbytesigned(0x40D)
   
   ScrX1 = X1 - CamX
   ScrY1 = memory.readbyteunsigned(0x494) - memory.readbyteunsigned(0x476)+8
   
   -- Player 2 position   
   X2 = memory.readbyteunsigned(0x3FF) + 256*memory.readbytesigned(0x3F0)
   Y2 = memory.readbyteunsigned(0x43B) + 256*memory.readbytesigned(0x42C)
   Z2 = memory.readbyteunsigned(0x495) + 256*memory.readbytesigned(0x40E)
   
   ScrX2 = X2 - CamX
   ScrY2 = memory.readbyteunsigned(0x495) - memory.readbyteunsigned(0x477)+8

   -- Player 1 display (with subpixels)
   gui.text(  1,  1,  "1X " .. X1 .. "." .. memory.readbyteunsigned(0x449))
   gui.text(  1, 9,  "1Y " .. Y1 .. "." .. memory.readbyteunsigned(0x4D0))
   gui.text(  1, 17,  "1Z " .. Z1 .. "." .. memory.readbyteunsigned(0x458))

   -- Player 2 display (with subpixels)
   gui.text( 85,  1,  "2X " .. X2 .. "." .. memory.readbyteunsigned(0x44A))
   gui.text( 85, 9,  "2Y " .. Y2 .. "." .. memory.readbyteunsigned(0x4D1))
   gui.text( 85, 17,  "2Z " .. Z2 .. "." .. memory.readbyteunsigned(0x459))
   
   -- Player 1 hitbox, shadow and horizontal speed
   gui.box( ScrX1-10, ScrY1-30, ScrX1+10, ScrY1, "#FFAA0000")
   gui.box( ScrX1-10, memory.readbyteunsigned(0x494)+8, ScrX1+10, memory.readbyteunsigned(0x494)+10, "#FFAA0000")
   gui.text(ScrX1- 9, ScrY1-8,  memory.readbyteunsigned(0x566))
   
   -- Player 2 hitbox, shadow and horizontal speed
   gui.box( ScrX2-10, ScrY2-30, ScrX2+10, ScrY2, "#0000FF00")
   gui.box( ScrX2-10, memory.readbyteunsigned(0x495)+8, ScrX2+10, memory.readbyteunsigned(0x495)+10, "#0000FF00")  
   gui.text(ScrX2- 9, ScrY2-8, memory.readbyteunsigned(0x567))
   
   LastCamX = CamX

end

emu.registerafter(show_boxes);