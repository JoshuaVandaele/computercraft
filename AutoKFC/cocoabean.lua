local finalAge = 2

self = "turtle_3830"

local storage,storageSlots,trash = dofile("disk/storage.lua")
local position = {["x"] = 0, ["y"] = 0, ["z"] = 0}
local rotation = 0

if not storage then
	local function unserialize(name)  -- Get data
	    if fs.exists('/.data/'..name) then
	        local f = fs.open('/.data/'..name, 'r')
	        data = textutils.unserialize(f.readAll())
	        f.close()
	    end
	    return data
	end

	position = unserialize("pos") or {["x"] = 0, ["y"] = 0, ["z"] = 0}
	rotation = unserialize("rotation") or 0
	if position.x  ~= position.y and position.x ~= position.z and position.x~= 0 then
		while rotation ~= 2 do
			turnR()
		end
		while position.x ~= 0 do
			if not forward() then
				turtle.dig()
			end
		end
		while rotation ~= 3 do
			turnR()
		end
		while position.z ~= 0 do
			if not forward() then
				turtle.dig()
			end
		end
		while rotation ~= 0 do
			turnR()
		end
		while position.y > 0 do
			if not down() then
				turtle.dig()
			end
		end
		while position.y < 0 do
			if not up() then
				tutylr.dig()
			end
		end
	end
end

local storage,storageSlots,trash = dofile("disk/storage.lua")
storage = peripheral.wrap(storage)
trash = peripheral.wrap(trash)

local length = 32

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
			serialize(position,"pos")
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
			if rotation > 3 then rotation = 0 end
			serialize(rotation,"rotation")
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
			if rotation > 0 then rotation = 0 end
			serialize(rotation,"rotation")
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
	sleep(10)
end

function farm(force)
	turtle.select(1)
	local crop, inspect = turtle.inspect()
	if not crop or crop and inspect["state"] and inspect["state"].age == finalAge or force then
		turtle.dig()
		turtle.place()
	end
end

function serialize(data, name)  -- Store data
    if not fs.exists('/disk') then
        return
    end
    if not fs.exists('/.data') then
        fs.makeDir('/.data')
    end
    local f = fs.open('/.data/'..name, 'w')
    f.write(textutils.serialize(data))
    f.close()
end
 
function trashItems()
	for i = 1,16 do
		trash.pullItems(self,i,64)
	end
end

while true do
	crop, inspect = turtle.inspect()
	if not crop or inspect["state"].age >= finalAge then 
		refuel()
		trashItems()

		while turtle.getFuelLevel() < length*4 do
			refuel()
			sleep(120)
		end
		for i = 1,length/2 do
			farm()
			for i = 1,2 do
				while not up() do
					refuel()
				end
				farm()
			end
			turnR()
			while not forward() do
				refuel()
			end
			turnL()
				farm()
			for i = 1,2 do
				while not down() do
					refuel()
				end
				farm()
			end
			turnR()
			while not forward() do
				refuel()
			end
			turnL()
		end
		turnL()
		for i = 1,length do
			while not forward() do
				refuel()
			end
		end
		turnR()
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