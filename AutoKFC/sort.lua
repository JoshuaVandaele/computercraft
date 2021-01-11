local self = "turtle_3778"

local output = peripheral.wrap("bottom")
local input,slots = dofile("disk/storage.lua")
input = peripheral.wrap(input)

while true do
	if output.size() > #output.list() then
		for i = 97,108 do
			input.pushItems(self,i,64)
			turtle.dropDown()
		end
	end
	sleep(120)
end