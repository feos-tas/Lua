-- Super Mario Bros / Super Mario Bros 2 Japan
-- item display script
-- feos, 2023

local SMB   = false
local SMB2J = false

function CheckBlock(block)
	if SMB then
		if block == 0x55 or block == 0x5A or block == 0xC1 then return "MF" end
		if block == 0x57 or block == 0x5C                  then return "ST" end
		if block == 0x59 or block == 0x5E or block == 0x60 then return "1U" end
		if block == 0                                      then return ""   end
	--	return string.format("%X", block)
	elseif SMB2J then
		if block == 0x52 or block == 0x58 or block == 0x61 or block == 0xC1 then return "MF" end
		if block == 0x53 or block == 0x59 or block == 0x60 or block == 0xC2 then return "PO" end
		if block == 0x55 or block == 0x5B                                   then return "ST" end
		if block == 0x57 or block == 0x5D or block == 0x5F                  then return "1U" end
		if block == 0                                                       then return ""   end
	--	return string.format("%X", block)
	end
	return ""
end

gui.register(function()
	SMB   = memory.readbyte(0x8000) == 0x78
	SMB2J = memory.readbyte(0x8000) == 0xAD or memory.readbyte(0x8000) == 0
	local scroll = memory.readbyte(0x73f)+0x100*(memory.readbyte(0x71a)%2)
	for column = 0, 47 do
		local offset = 0x500 + column + (math.floor(column / 16) * 0xc0)
		if column > 31 then offset = offset - 0xd0*2 end		
		for row = 0, 12 do
			local address  = offset + row * 16
			local block    = memory.readbyte(address)
			local mnemonic = CheckBlock(block)
			if mnemonic ~= "" then
				gui.text(
					column * 16 + 2 - scroll,
					row    * 16 + 2 + 32,
					mnemonic)
				gui.drawbox(
					column * 16 - scroll,
					row    * 16 + 32,
					column * 16 - scroll + 15,
					row    * 16 + 32     + 15,
					0x00ff0000)
			end
		end
	end
end)

--[[--


--]]--