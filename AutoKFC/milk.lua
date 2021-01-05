self = "turtle_3767"

local storage,storageSlots = dofile("disk/storage.lua")
storage = peripheral.wrap(storage)


while true do
	local stored = nil
 	local item = turtle.getItemDetail() or {}
 	if not item then 
 		stored = storage.list()
		if not stored[ storageSlots["minecraft:milk_bucket"] ] and not item then
		    storage.pushItems(self,storageSlots["minecraft:bucket"],1,1)
		    item.name = "minecraft:bucket"
	 	end	
 	end

 	if item.name == "minecraft:bucket" then
	    if not turtle.place() then
	    	print("Something went wrong, sleeping to avoid server lag!")
	    	sleep(120)
	    else
	    	item.name = "minecraft:milk_bucket"
	    end
	end

	if item.name == "minecraft:milk_bucket" then
	    storage.pullItems(self,1,1,storageSlots["minecraft:milk_bucket"])
	  	sleep(1)
	else
	   	sleep(10)
	end
end

