function ToBin8(Num,Switch)
-- 1 byte to binary converter by feos, 2012
-- Switch: "s" for string, "n" for number
	Bin = ""
	while Num > 0 do
		Bin = (Num % 2)..Bin
		Num = math.floor(Num / 2)
	end
	Low = string.format("%04d",(Bin % 10000))
	High = string.format("%04d",math.floor(Bin / 10000))
	
	if Switch == "s" then return High.." "..Low
	elseif Switch == "n" then return Bin
	else return "Wrong Switch parameter!\nUse \"s\" or \"n\"."
	end
end