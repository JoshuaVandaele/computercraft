self = "turtle_3773"

storage = "minecraft:ironchest_gold_458"
storage = peripheral.wrap(storage)
storageSlots = {
  ["minecraft:egg"] = 33,
  ["minecraft:chicken"] = 68,
}

function store()
	stored = 0
	for i = 1,16 do
		local slot = turtle.getItemDetail(i)
		if slot and storageSlots[slot.name] then
			stored = stored + storage.pullItems(self,i,64,storageSlots[slot.name])
		end
	end
	return stored ~= 0
end

function yeet()
	for i = 1,16 do
		turtle.select(i)
		turtle.dropDown()
	end
end

while true do
	turtle.suckUp()
	turtle.suck()

	if not store() then
		yeet()
	end
	while #peripheral.wrap("bottom").list() > 0 do
		print("beep")
		redstone.setOutput("bottom",true)
		sleep(0.25)
		redstone.setOutput("bottom",false)
		sleep(0.25)
	end
	sleep(10)
end