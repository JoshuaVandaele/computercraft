-- Made to work with sticks
self = "turtle_3871"  

local furnaces = {}
for _,machine in pairs(peripheral.getNames()) do
	if string.match(machine,"furnace") then
		table.insert(furnaces,peripheral.wrap(machine))
	end
end

local function emptyFurnaces()
	for i = 1,#furnaces do
		furnaces[i].pushItems(self,1,64)
		furnaces[i].pushItems(self,2,64)
		furnaces[i].pushItems(self,3,64)
	end
end

emptyFurnaces()
turtle.select(1)
turtle.dropUp(64)
turtle.select(2)
turtle.dropUp(64)
turtle.select(3)
turtle.dropUp(64)

turtle.select(16)
turtle.dropUp(64)

while true do
	local items = turtle.getItemCount(1)
	if items > 0 then
		local working = {}
		for _,machine in pairs(furnaces) do
			if machine.pullItems(self,1,1,1) > 0 then
				machine.pullItems(self,2,2,2)
				table.insert(working,machine)
			else
				break	
			end
		end
		print("Waiting "..((items*10.1)/#working).." secs for the items to smelt..")
		sleep((items*10.1)/#working)
		for _, machine in pairs(working) do
			machine.pushItems(self,3,64,16)
		end
		turtle.dropUp(64)
	else
		sleep(20)
	end
end