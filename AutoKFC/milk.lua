self = "turtle_3767"

storage = "minecraft:ironchest_iron_2071"
 
storage = peripheral.wrap(storage)
storageSlots = {
  ["milk"] = 22,
  ["bucket"] = 8
}

while true do
  	stored = storage.list()
	
	if not stored[ storageSlots["milk"] ] and not turtle.getItemDetail() then
	    sleep(0.5)
	    storage.pushItems(self,storageSlots["bucket"],1,1)
 	end

 	if turtle.getItemDetail() then
	 	if turtle.getItemDetail().name == "minecraft:bucket" then
	    turtle.place()
	 	end
	 	if turtle.getItemDetail().name == "minecraft:milk_bucket" then
		    storage.pullItems(self,1,1,storageSlots["milk"])
	 	end
	 end
end