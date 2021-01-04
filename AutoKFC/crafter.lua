local self = "turtle_3750"

local craftSlot = {1,2,3,5,6,7,9,10,11}

local storage,storageinvSlots,trash,crafts = dofile("disk/storage.lua")
local storageinv = peripheral.wrap(storage)
local trash = peripheral.wrap(trash)

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
		if storageinvSlots[item.name] then
			storageinv.pullItems(self,slot,64,storageinvSlots[item.name])
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

local function make(craft)
	local stored = storageinv.list()
	if not stored or not craft then return end
	if stored[ storageinvSlots[ craft["output"] ] ] and stored[ storageinvSlots[ craft["output"] ] ].count == 64 then
		print("We already have too much of this item, aborting")
		storeItems()
		return
	end

	local doubles = {}

	for i = 1,#craft-1 do
		if craft[i] == craft[i+1] then
			doubles[craft[i]] = (doubles[craft[i]] or 2)+1
		end
	end


	local needs = ""

	for slot, ingredient in ipairs(craft) do
		if slot ~= "output" then
			if not stored[storageinvSlots[ingredient]] or not stored[storageinvSlots[ingredient]].name == ingredient or (stored[storageinvSlots[ingredient]].count < (doubles[ingredient] or 1)) then
				print("Missing "..ingredient.." in slot "..storageinvSlots[ingredient])
				needs = ingredient
				break
			end
		end
	end 

	if needs ~= "" then
		print("Missing items to make "..craft["output"]..", trying to make them..")
		storeItems()
		possible = false
		for name,c in pairs(crafts) do
			if c["output"] == needs then
				possible = true
				make(crafts[name])
			end
		end
		if not possible then
			print("Failed")
			storeItems()
			sleep(10)
			return false
		end
		make(craft)
		storeItems()
		return
	end

	local pulled = 0
	print("Crafting "..craft["output"].."..")
	for slot, item in ipairs(craft) do
		pulled = storageinv.pushItems(self,storageinvSlots[item],1,craftSlot[slot])
		if pulled == 0 then
			print("Something wrong happened, aborting!")
			storeItems()
			return
		end
	end
	
	turtle.craft()

	storeItems()

	sleep(1)
end

local function sortChest()
	local count = 1
	while count ~= 0 do
		count = 0
		for slot, item in pairs(storageinv.list()) do
			for sortedItem,sortedSlot in pairs(storageinvSlots) do
				if item.name == sortedItem and slot ~= sortedSlot then
					count = 1
					storageinv.pushItems(self,slot,64,1)
					storageinv.pullItems(self,1,64,sortedSlot)
				end
			end
		end
	end
end

storeItems()
sortChest()

while true do
  make(crafts.breakfast)
end