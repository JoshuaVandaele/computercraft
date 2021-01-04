self = "turtle_3801"

--[[Furnace:
Slot 1: item input
Slot 2: fuel input
Slot 3: output
]]

local furnaces = {}
for _,machine in pairs(peripheral.getNames()) do
	if string.match(machine,"furnace") then
		table.insert(furnaces,peripheral.wrap(machine))
	end
end

local fuel = "minecraft:ender chest_353"
fuel = peripheral.wrap(fuel)

local trash = "minecraft:ender chest_352"
trash = peripheral.wrap(trash)

local storage,storageSlots = dofile("disk/storage.lua")
storageinv = peripheral.wrap(storage)

local function scanInventory()
	local inventory = {}
	for i = 1,16 do
		inventory[i] = turtle.getItemDetail(i)
	end
	return inventory
end

local function storeItems()
	local stored = scanInventory()
	for slot,item in pairs(stored) do
		if storageSlots[item.name] then
			storageinv.pullItems(self,slot,64,storageSlots[item.name])
		end
	end
	local stored = scanInventory()
	for _,_ in pairs(stored) do -- I hate this, but #stored doesn't work because lua's stupid
		print("Stocking overflowed items")
		for i = 1,16 do
			trash.pullItems(self,i,64)
		end
		break
	end
end

while true do
	storeItems()
	local work = 0
	local working = {}
	for ingredient, slot in pairs(storageSlots) do
		if string.match(ingredient,"raw") then
			work = storageinv.pushItems(self,storageSlots[ingredient],64,1)
			if work > 0 then
				for _ = 1,math.ceil(work/#furnaces) do
					for i = 1,#furnaces do
						working[i] = true
						furnaces[i].pullItems(self,1,1,1)
					end
				end
			end
		end
	end
	if work > 0 then
		fuel.pushItems(self,1,math.ceil(math.ceil(work/4)/1.5))
		turtle.select(16)
		turtle.craft()
		turtle.select(1)
		for _ = 1,math.ceil(work/#furnaces) do
			for i in pairs(working) do
				furnaces[i].pullItems(self,16,1,2)
			end
		end
		print("Waiting "..(10.1*math.ceil(work/#furnaces)).." seconds for the items to process..")
		sleep(10.1*math.ceil(work/#furnaces))
		for i = 1,#furnaces do
			furnaces[i].pushItems(self,3,64)
		end
		storeItems()
	end
	sleep(60)
end