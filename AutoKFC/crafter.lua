local self = "turtle_3750"

local craftSlot = {1,2,3,5,6,7,9,10,11}

local storage,storageinvSlots,trash,crafts = dofile("disk/storage.lua")
local storageinv = peripheral.wrap(storage)
local trash = peripheral.wrap(trash)
local selfinv = peripheral.wrap("right")

if not selfinv or not selfinv.hasModule or not selfinv.hasModule("plethora:introspection") then
	print("Introspection module not found, using fallback function (Might be laggier)")
	selfinv = {}
	selfinv.getInventory = function ()-- Not used, I have the module, can't be source of lag
		return {                      -- Also it's ugly, soz
			["list"] =	function()	
							local inventory = {}
							for i = 1,16 do
								inventory[i] = turtle.getItemDetail(i)
							end
							return inventory
						end
		}
	end
end

local function storeItems()  -- main (?) source of peripheral calls, optimisation must be high
	local stored = selfinv.getInventory().list()
	for slot,item in pairs(stored) do
		if storageinvSlots[item.name] then
			storageinv.pullItems(self,slot,64,storageinvSlots[item.name])
		else
			print("Trashing "..item.name)
			trash.pullItems(self,slot,64)
		end
	end
end

local function make(craft,stored)
	if not stored then stored = storageinv.list() end
	if not craft then return end
	if stored[ storageinvSlots[ craft["output"] ] ] and stored[ storageinvSlots[ craft["output"] ] ].count == 64 then
		print("We already have too much of this item, aborting")
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
				if not make(crafts[name],stored) then return end
			end
		end
		if not possible then
			print("Failed")
			sleep(10)
			return false
		end
		make(craft)
		return true
	end

	local pulled = 0
	print("Crafting "..craft["output"].."..")
	for slot, item in ipairs(craft) do
		pulled = storageinv.pushItems(self,storageinvSlots[item],1,craftSlot[slot])  -- Might also be a cause of lag, trying to make the less calls here
		if pulled == 0 then
			print("Something wrong happened, aborting!")
			storeItems()
			return
		end
	end
	
	turtle.craft()
	storeItems()
	sleep(1)
	return true
end

local function sortChest()  -- only used once, optimisation urgency is low
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
  if make(crafts.breakfast) then
  	print("Made one!")
  	sleep(10)
  else
  	print("Failed, waiting 120s")
  	sleep(120)
  end
end
