self = "turtle_3783"

storage = "minecraft:ironchest_gold_458"
 
storage = peripheral.wrap(storage)
storageSlots = {
  ["harvestcraft:peppercornitem"] = 36,
}

treestorage = "minecraft:chest_4319"
treestorage = peripheral.wrap(treestorage)
treestorageSlots = {
	["minecraft:sapling"] = 1,
	["harvestcraft:peppercornitem"] = 2,
	["minecraft:log"] = 3,
}

local position = {["x"] = 0, ["y"] = 0, ["z"] = 0}
local rotation = 0
local crop = "harvestcraft:pampeppercorn"
local finalAge = 2

function up(x)
	if not x then x = 1 end
	for i = 1,x do
		if turtle.up() then
			position.y = position.y + 1
		else
			return false
		end
	end
	return true
end

function down(x)
	if not x then x = 1 end
	for i = 1,x do
		if turtle.down() then
			position.y = position.y - 1
		else
			return false
		end
	end
	return true
end

function forward(x)
	if not x then x = 1 end
	for i = 1,x do
		if turtle.forward() then
			if rotation == 0 then
				position.x = position.x +1
			elseif rotation == 1 then
				position.z = position.z+1
			elseif rotation == 2 then
				position.x = position.x-1
			elseif rotation == 3 then
				position.z = position.z-1
			end
		else
			return false
		end
	end
	return true
end

function turnR(x)
	if not x then x = 1 end
	for i = 1,x do
		if turtle.turnRight() then
			rotation = rotation + 1
		else
			return false
		end
	end
	return true
end

function turnL(x)
	if not x then x = 1 end
	for i = 1,x do
		if turtle.turnLeft() then
			rotation = rotation - 1
		else
			return false
		end
	end
	return true
end

function scanInventory()
	local inventory = {}
	for i = 1,16 do
		inventory[i] = turtle.getItemDetail(i)
	end
	return inventory
end

function storeItems()
	local stored = scanInventory()
	for slot,item in pairs(stored) do
		if treestorageSlots[item.name] then
			treestorage.pullItems(self,slot,64,treestorageSlots[item.name])
		end
	end

	local stored = scanInventory()
	for slot,item in pairs(stored) do
		if storageSlots[item.name] then
			storage.pullItems(self,slot,64,storageSlots[item.name])
		end
	end

	local stored = scanInventory()
	for _,_ in pairs(stored) do
		print("Stocking overflowed items")
		for i = 1,16 do
			turtle.select(i)  -- I hate this, but #stored doesn't work because lua's stupid
			turtle.dropUp()
		end
		break
	end
end

function refuel()
	print("Refueling..")
	storeItems()
	treestorage.pushItems(self,treestorageSlots["minecraft:log"],64)
	turtle.craft()
	for i = 1,16 do
		turtle.select(i)
		turtle.refuel(64)
	end
end

function pepperWait(direction)
	if direction == "up" then
		local _, block = turtle.inspectUp()
		while block["state"].age ~= finalAge do
			sleep(60)
		end
		return true
	end
	local _, block = turtle.inspect()
	while block["state"].age ~= finalAge do
			sleep(60)
	end
	print("Tree ready")
	return true
end

function checkAround()
	for i = 1,4 do
		local _, block = turtle.inspect()
		if block and block.name == crop then
			return true
		end
		turnL()
	end
end

function craftSapling()
	storeItems()
	sortChest()
	treestorage.pushItems(self,1,1,treestorageSlots["minecraft:sapling"])
	treestorage.pushItems(self,2,3,treestorageSlots["harvestcraft:peppercornitem"])
	turtle.select(2)
	turtle.transferTo(5,1)
	turtle.transferTo(6,1)

	turtle.select(16)
	turtle.craft()
	local status = turtle.place()
	turtle.select(1)
	storeItems()
	return status
end

function sortChest()
	local count = 1
	while count ~= 0 do
		count = 0
		for slot, item in pairs(treestorage.list()) do
			for sortedItem,sortedSlot in pairs(treestorageSlots) do
				if item.name == sortedItem and slot ~= sortedSlot then
					count = 1
					treestorage.pushItems(self,slot,64,1)
					treestorage.pullItems(self,1,64,sortedSlot)
				end
			end
		end
	end
end

local sapling = turtle.inspect()
while true do
	sortChest()
	local blockPresent, block = turtle.inspect()
	if blockPresent and block["name"] == "minecraft:log" then
		refuel()
		print("Found tree")
		local direction = ""
		while not turtle.inspectUp() do
			up()
		end
		local _, above = turtle.inspectUp()
		if above.name == crop then
			direction = "up"
		elseif checkAround() then
		else
			print("dead")
			exit()
		end
		if pepperWait(direction) then
			sapling = false
			while rotation ~= 0 do
				turnR()
			end
			local blockPresent, block = turtle.inspect()
			while blockPresent and block["name"] == "minecraft:log" do
				blockPresent, block = turtle.inspect()
				turtle.dig()
				turtle.digUp()
				up()
			end
			while position.y ~= 0 do
				down()
				turtle.dig()
			end
		end
	end
	if #scanInventory() > 0 then
		storeItems()
	end
	if not sapling then 
		print("No sapling found attempting to craft one..")
		sapling = craftSapling()
	end
	turtle.suck()
	sleep(60)
end