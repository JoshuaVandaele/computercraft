self = "turtle_3749"

storage = "minecraft:ironchest_gold_458"
 
storage = peripheral.wrap(storage)
storageSlots = {
  ["water"] = 9,
  ["bucket"] = 8
}

while true do
  	stored = storage.list()
	if not stored[ storageSlots["water"] ] and not turtle.getItemDetail() then
	    sleep(0.5)
	    storage.pushItems(self,storageSlots["bucket"],1,1)
 	end
 	if turtle.getItemDetail() then
	 	if turtle.getItemDetail().name == "minecraft:bucket" then
	    turtle.place()
	 	end
	 	if turtle.getItemDetail().name == "minecraft:water_bucket" then
		    storage.pullItems(self,1,1,storageSlots["water"])
	 	end
	 end
end

