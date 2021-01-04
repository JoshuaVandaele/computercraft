local finalAge = 3

self = "turtle_3768"

local storage,storageSlots,trash = dofile("disk/storage.lua")
storage = peripheral.wrap(storage)
trash = peripheral.wrap(trash)

local position = {["x"] = 0, ["y"] = 0, ["z"] = 0}
local rotation = 0
local debug = false
local farmwidth = 9
local farmheight = 9


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

function refuel()
	print("Refueling..")
	for i = 1,16 do
		turtle.select(i)
		turtle.refuel(64)
	end
end

function farm(force)
	crop, inspect = turtle.inspectDown()
	turtle.select(1)
	if crop and inspect["state"].age == finalAge or force then
		turtle.digDown()
		if turtle.craft then
			turtle.select(16)
			turtle.craft(1)
		end
		turtle.placeDown()
	end
	if not crop then
		if turtle.craft then
			turtle.select(16)
			turtle.craft(1)
		end
		turtle.placeDown()
	end
end

function trashItems()
	for i = 1,16 do
		trash.pullItems(self,i,64)
	end
end

while true do
	crop, inspect = turtle.inspect()
	if not crop or inspect["state"].age >= math.ceil(finalAge/2) or debug then 
		refuel()
		trashItems()
		while turtle.getFuelLevel() < farmwidth*farmheight*2 do
			sleep(120)
			refuel()
		end
		while position.y ~= 1 do
			up()
		end

		while position.x ~= 1 do
			if forward() then
				farm(true)
			end
		end

		for i = 1,farmheight do
			xpos = farmwidth
			
			if rotation == 2 then
				xpos = 1
			end

			while position.x ~= xpos do
				if forward() then
					farm()
				end
			end

			if rotation == 0 then
				turnR()
			else
				turnL()
			end

			while position.z ~= i do
				if forward() then
					farm()
				end
			end

			if xpos == farmwidth then
				turnR()
			else
				turnL()
			end
		end
		turnR()
		while position.z ~= 0 do
			if forward() then
				farm()
			end
		end
		turnL()
		while position.x ~= 0 do
			if forward() then
				farm()
			end
		end
		
		while position.y ~= 0 do
			if down() then
				farm()
			end
		end
		turnL()
		turnL()
	end
	for i = 1,16 do
		turtle.select(i)
		local slot = turtle.getItemDetail()
		if slot and storageSlots[slot.name] then
			storage.pullItems(self,i,64,storageSlots[slot.name])
		end
	end
	sleep(60)
	
end

