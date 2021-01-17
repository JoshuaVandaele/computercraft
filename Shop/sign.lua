local mon = peripheral.wrap("top")
mon.setBackgroundColor(colors.white)
mon.setTextColor(650)
mon.setTextScale(2)
mon.clear()
mon.setCursorPos(0,0)

local w,h = mon.getSize()

local function centeredX(txt)
	local _,y = mon.getCursorPos()
	mon.setCursorPos( math.ceil(w/2-txt:len()/2 + 0.5), y+1)
	mon.write(txt)
end

centeredX("-= Special Merch =-")
centeredX("x3 Ocean Monuments")
centeredX("x1 Village")

centeredX("")

centeredX("-= Software =-")
centeredX("Tree farm software")
centeredX("Turtle drop software")
