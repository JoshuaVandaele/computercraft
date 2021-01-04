self = "turtle_3771"

local storage,storageSlots = dofile("disk/storage.lua")
storage = peripheral.wrap(storage)

local farmwidth = 20
local farmheight = 3


function unserialize(name)  -- Get data
    if fs.exists('/.data/'..name) then
        local f = fs.open('/.data/'..name, 'r')
        data = textutils.unserialize(f.readAll())
        f.close()
    end
    return data
end

local position = unserialize("pos") or {["x"] = 0, ["y"] = 0, ["z"] = 0}
local rotation = unserialize("rotation") or 0

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
end

function farm()
	_, inspect = turtle.inspect()
	if _ and inspect.name == "minecraft:reeds" then
		turtle.dig()
	end
	_, inspect = turtle.inspectDown()
	if _ and inspect.name == "minecraft:reeds" then
		turtle.digDown()
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
 


if position.x  ~= position.y and position.x ~= position.z and position.x~= 0 then
	while rotation ~= 2 do
		turnR()
	end
	while position.x ~= 0 do
		if not forward() then
			dig()
		end
	end
	while rotation ~= 3 do
		turnR()
	end
	while position.z ~= 0 do
		if not forward() then
			dig()
		end
	end
	while rotation ~= 0 do
		turnR()
	end
end

while true do
	if turtle.inspect() then
		refuel()
		for i = 1,16 do
			turtle.select(i)
			local slot = turtle.getItemDetail()
			if slot then
				turtle.dropDown(64)
			end
		end

		while turtle.getFuelLevel() < farmwidth*farmheight*2 do
			sleep(10)
			refuel()
		end

		turtle.dig()


		while position.x ~= farmwidth-1 do
			if forward() then
				farm()
			else
				refuel()
			end
		end
		turnR()
		turtle.dig()
		while position.z ~= farmheight-1 do
			if forward() then
				farm()
			else
				refuel()
			end
		end
		turnR()
		turtle.dig()
		while position.x ~= 0 do
			if forward() then
				farm()
			else
				refuel()
			end
		end
		turnR()
		turtle.dig()
		while position.z ~= 0 do
			if forward() then
				farm()
			else
				refuel()
			end
		end
		turnR()
		turtle.dig()
	end
	for i = 1,16 do
		turtle.select(i)
		local slot = turtle.getItemDetail()
		if slot and storageSlots[slot.name] then
			storage.pullItems(self,i,64,storageSlots[slot.name])
		end
	end
	position = {["x"] = 0, ["y"] = 0, ["z"] = 0}
	sleep(60)
end