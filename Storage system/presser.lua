self = "turtle_3933"  

local pressers = {}
for _,machine in pairs(peripheral.getNames()) do
	if string.match(machine,"pampresser") then
		print(machine)
		table.insert(pressers,peripheral.wrap(machine))
	end
end

local function emptyPressers()
	for i = 1,#pressers do
		pressers[i].pushItems(self,1,64)
		pressers[i].pushItems(self,2,64)
		pressers[i].pushItems(self,3,64)
	end
end

local function getUsedSlots()
	local t = {}
	for i = 1,16 do
		if turtle.getItemCount(i) > 0 then
			t[i] = true
		end
	end
	return t
end


local function emptySelf()
	for slot,_ in pairs(getUsedSlots()) do
		turtle.select(slot)
		turtle.dropUp(64) 
	end
end


emptyPressers()
emptySelf()

while true do
	local slots = getUsedSlots()
	if #slots > 0 then
		local working = {}
		for slot,_ in pairs(slots) do
			print(self,slot,64,1)
			for _,machine in pairs(pressers) do
				if machine.pullItems(self,slot,64,1) > 0 then
					working[slot] = machine
				end
			end
		end 
		print("Waiting "..(64*6.5).." secs for the items to press..")
		sleep(64*6.5)
		for slot, machine in pairs(working) do
			turtle.select(slot)
			machine.pushItems(self,3,64,slot)
			turtle.dropUp()
			machine.pushItems(self,2,64,slot)
			turtle.dropUp()
		end
	else
		sleep(20)
	end
end