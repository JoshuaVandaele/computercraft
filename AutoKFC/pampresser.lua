--[[pampresser:
Slot 1: Input
Slot 2,3: Ouput
]]

self = "turtle_3800"

local machines = {
   ["harvestcraft:soybeanitem"] = "minecraft:pampresser_15",
   ["harvestcraft:silkentofuitem"] = "minecraft:pampresser_16",
}

for k,machine in pairs(machines) do
	machines[k] = peripheral.wrap(machine)
end


local trash = "minecraft:ender chest_352"
local trash = peripheral.wrap(trash)

local storage,storageSlots = dofile("disk/storage.lua")
storageinv = peripheral.wrap(storage)

local fuel = "minecraft:ender chest_353"

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
	for ingredient,machine in pairs(machines) do
		if not turtle.getItemDetail(1) and storageinv.pushItems(self,storageSlots[ingredient],64,1) > 0 then
			local tmp = machine.pullItems(self,1,64,1)
			if tmp > work then work = tmp end
		end
	end
	if work > 0 then
		print("Waiting "..(6.5*work).." seconds for the items to press..")
		sleep(6.5*work)
		for ingredient,machine in pairs(machines) do
			machine.pushItems(self,2,64)
			machine.pushItems(self,3,64)
		end
		storeItems()
	else
		sleep(20)
	end
end