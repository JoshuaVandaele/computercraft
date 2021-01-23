if fs.exists('/disk/storage.lua') then
	storage,storageSlots,trash = dofile("disk/storage.lua")
end

local position = {["x"] = 0, ["y"] = 0, ["z"] = 0}
local rotation = 0
local debug = false

function serialize(data, name)  -- Store data
    if not fs.exists('/.data') then
        fs.makeDir('/.data')
    end
    local f = fs.open('/.data/'..name, 'w')
    f.write(textutils.serialize(data))
    f.close()
end

local function unserialize(name)  -- Get data
	local data
    if fs.exists('/.data/'..name) then
        local f = fs.open('/.data/'..name, 'r')
        data = textutils.unserialize(f.readAll())
        f.close()
    end
    return data
end

local self, farmX, farmZ, finalAge = unpack(unserialize("info") or {})
if not finalAge then
	print("Welcome to the setup wizard! We need to ask a few questions for you to start.")
	print("What is the number of the turtle on the local network?")
	print("Hint: It should be turtle_XXX..")
	self = "turtle_"..read()
	print("Great! So it should be "..self)
	print("Now, how big is the farm on the X axis?")
	farmX = tonumber(read())
	print("On the Z axis?")
	farmZ = tonumber(read())
	print(farmX.."x"..farmZ.." Gotcha. And now, at what age are the crops done growing?")
	finalAge = tonumber(read())
	print("Great! Your turtle should work now.")
	serialize({self,farmX,farmZ, finalAge},"info")
end

function up(x)
	if not x then x = 1 end
	for i = 1,x do
		if turtle.up() then
			position.y = position.y + 1
			serialize(position,"pos")
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
			serialize(position,"pos")
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
			if rotation <0 then rotation = 3 end
			serialize(rotation,"rotation")
		else
			return false
		end
	end
	return true
end

function refuel()
	storage.pushItems(self, storageSlots["minecraft:coal"], 64)
	print("Refueling..")
	for i = 1,16 do
		turtle.select(i)
		turtle.refuel(64)
	end
	sleep(10)
end

function farm(force)
	crop, inspect = turtle.inspectDown()
	turtle.select(1)
	if crop and inspect["state"].age == finalAge or force then
		turtle.digDown()
		turtle.placeDown()
	else
		turtle.placeDown()
	end
end

function trashItems()
	for i = 1,16 do
		trash.pullItems(self,i,64)
	end
end

if not storageSlots then
	print('Going home')
	position = unserialize("pos") or {["x"] = 0, ["y"] = 0, ["z"] = 0}
	rotation = unserialize("rotation") or 0
	print("We are at "..position.x.." "..position.y.." "..position.z.." at rotation "..rotation)
	if position.x  ~= 0 or position.z ~= 0 or position.y~= 0 then
		while rotation ~= 2 do
			turnR()
		end
		while position.x ~= 0 do
			if not forward() then
				print("Stuck at "..position.x.." "..position.y.." "..position.z.." at rotation "..rotation)
				sleep(60)
			end
		end
		while rotation ~= 3 do
			turnR()
		end
		while position.z ~= 0 do
			if not forward() then
				print("Stuck at "..position.x.." "..position.y.." "..position.z.." at rotation "..rotation)
				sleep(60)
			end
		end
		while rotation ~= 0 do
			turnR()
		end
		while position.y > 0 do
			if not down() then
				turtle.digDown()
			end
		end
		while position.y < 0 do
			if not up() then
				turtle.digUp()
			end
		end
	end
end

storage,storageSlots,trash = dofile("disk/storage.lua")
storage = peripheral.wrap(storage)
trash = peripheral.wrap(trash)

while true do
	crop, inspect = turtle.inspect()
	if not crop or inspect["state"].age >= math.ceil(finalAge/2) or debug then 
		refuel()
		trashItems()
		while turtle.getFuelLevel() < farmZ*farmX*2 do
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

		for i = 1,farmX do
			xpos = farmZ
			
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

			while (position.z ~= i) and (i ~= farmX) do
				if forward() then
					farm()
				end
			end

			if xpos == farmZ then
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

