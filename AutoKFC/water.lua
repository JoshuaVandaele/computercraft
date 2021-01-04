self = "turtle_3749"

local storage,storageSlots = dofile("disk/storage.lua")
storage = peripheral.wrap(storage)

while true do
  	stored = storage.list()
	if not stored[ storageSlots["water"] ] and not turtle.getItemDetail() then
	    sleep(0.5)
	    storage.pushItems(self,storageSlots["minecraft:bucket"],1,1)
 	end
 	if turtle.getItemDetail() then
	 	if turtle.getItemDetail().name == "minecraft:bucket" then
	    turtle.place()
	 	end
	 	if turtle.getItemDetail().name == "minecraft:water_bucket" then
		    storage.pullItems(self,1,1,storageSlots["minecraft:water_bucket"])
	 	end
	 end
end

