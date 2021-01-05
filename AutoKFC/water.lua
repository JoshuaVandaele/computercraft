self = "turtle_3749"

local storage,storageSlots = dofile("disk/storage.lua")
storage = peripheral.wrap(storage)


while true do
	local stored = nil
 	local item = turtle.getItemDetail() or {}
 	if not item.name then 
 		stored = storage.list()
		if not stored[ storageSlots["minecraft:water_bucket"] ] and not item then
		    storage.pushItems(self,storageSlots["minecraft:bucket"],1,1)
		    item.name = "minecraft:bucket"
	 	end	
 	end

 	if item.name == "minecraft:bucket" then
	    if not turtle.place() then
	    	print("Something went wrong, sleeping to avoid server lag!")
	    	sleep(120)
	    else
	    	item.name = "minecraft:water_bucket"
	    end
	end

	if item.name == "minecraft:water_bucket" then
	    storage.pullItems(self,1,1,storageSlots["minecraft:water_bucket"])
	  	sleep(1)
	else
	   	sleep(10)
	end
end

