local self = "turtle_3874"

local base = "minecraft:emerald_block"
local entitySensorSlot = 8

local storage
local scanner = peripheral.wrap("left")
local scanner_radius = 8
local scanner_width = scanner_radius * 2 + 1
local directions = {
	["north"] = 0, -- -z
	["east"] = 1, -- +x 
	["south"] = 2, -- +z 
	["west"] = 3, -- -x 
}
local rotation = 0
local position = {["x"] = 0, ["y"] = 0, ["z"] = 0}

local function round(n)
  return math.floor(n + 0.5)
end

local function scannedAt(scan, x, y, z) --x,y,z unrelative to the turtle, relative to the world
  return scan[scanner_width ^ 2 * (x + scanner_radius) + scanner_width * (y + scanner_radius) + (z + scanner_radius) + 1]
end

local function facing(scanned)
	if type(scanned) == "number" then
		return scanned
	elseif type(scanned) == "string" then
		return directions[scanned]
	end
	local facing = scannedAt(scanned,0,0,0)["state"].facing
	return directions[facing]
end

local function face(x,z) --x,z to face
	local toface
	if x>0 then toface = directions.east
	elseif x<0 then toface = directions.west
	elseif z>0 then toface = directions.south
	elseif z<0 then toface = directions.north
	else toface = rotation end
	print(rotation,"TURNING TOWARDS",toface)
	for i = 1,math.abs(toface-rotation) do
		if toface > rotation then
			turtle.turnRight()
		elseif toface < rotation then
			turtle.turnLeft()
		end
	end
	rotation = toface
end

local function refuel()
	storage.pushItems(self, 26, 64, 16)
	turtle.select(16)
	turtle.refuel()
	turtle.select(1)
	return turtle.getFuelLevel()
end

local function go_to(x,y,z,yLast)
	x = (x-position.x)
	y = (y-position.y)
	z = (z-position.z)
	print(position.x,position.y,position.z,"GOING TO",x,y,z)

	if not yLast then
		if y < 0 then
			for i = 1,math.abs(y) do
				if not turtle.down() then
					turtle.digDown()
					turtle.down()
				end
			end
		elseif y > 0 then
			for i = 1,math.abs(y) do
				if not turtle.up() then
					turtle.digUp()
					turtle.up()
				end
			end
		end
	end

	face(x,0)
	for i = 1,math.abs(x) do
		if not turtle.forward() then
			turtle.dig()
			turtle.forward()
		end
	end

	face(0,z)
	for i = 1,math.abs(z) do
		if not turtle.forward() then
			turtle.dig()
			turtle.forward()
		end
	end

	if yLast then
		if y < 0 then
			for i = 1,math.abs(y) do
				if not turtle.down() then
					turtle.digDown()
					turtle.down()
				end
			end
		elseif y > 0 then
			for i = 1,math.abs(y) do
				if not turtle.up() then
					turtle.digUp()
					turtle.up()
				end
			end
		end
	end

	position.x = position.x+x
	position.y = position.y+y
	position.z = position.z+z
end

local function findBlocks(scanned,block,doY,once)
	local found = false
	local target = {} -- {["x"] = 0, ["y"] = 0, ["z"] = 0}
	local i = 0
	for x = -scanner_radius,scanner_radius do
		for z = -scanner_radius,scanner_radius do
			if doY then
				for y = -scanner_radius,scanner_radius do
					local SAt = scannedAt(scanned, x,y,z)
					if SAt and SAt.name == block then
						i = i+1
						target[i] = {}
						target[i].x = x
						target[i].y = y
						target[i].z = z
						found = true
						if once then
							break
						end
					end
				end
			else
				local SAt = scannedAt(scanned, x,-1,z)
				if SAt and SAt.name == block then
					i = i+1
					target[i] = {}
					target[i].x = x
					target[i].y = -1
					target[i].z = z
					found = true
					if once then
						break
					end
				end
			end
		end
		if found and once then
			break
		end
	end
	return found, target
end

local function fucktrees()
	turtle.digDown()
	local t, inspect = turtle.inspectUp()
	local ups = 0
	while t and inspect.name == "minecraft:log" do
		turtle.digUp()
		turtle.up()
		ups = ups+1
		t, inspect = turtle.inspectUp()
	end
	for i = 1,ups do
		turtle.down()
	end
end

local function update()
	print("Updating location..")
	scanned = scanner.scan()
	rotation = facing(scanned)
	local oldPos = position
	position = {["x"] = 0, ["y"] = 0, ["z"] = 0}
	local _, target = findBlocks(scanned,base,true,true)
	if target[1] then
		go_to(target[1].x,target[1].y+1,target[1].z)
	else
		print("Emergency return home, something went wrong")
		position = oldPos
		go_to(0,0,0)
	end
	scanned = scanner.scan()
	position = {["x"] = 0, ["y"] = 0, ["z"] = 0}
end

local function replant(scanned)
	local _, targets = findBlocks(scanned,"minecraft:air")
	local plantable = {}
	for _,coords in pairs(targets) do
		if scannedAt(scanned,coords.x,coords.y-1,coords.z).name == "minecraft:dirt" then
			table.insert(plantable,{["x"] = coords.x, ["y"] = coords.y, ["z"] = coords.z})
		end
	end
	
	local pushed = storage.pushItems(self,27,#plantable,1)
	if not pushed or pushed == 0 then return end
	print(#plantable.." sapplings missing, got "..pushed)
	print("FUEL OK")

	for _, coords in pairs(plantable) do
		go_to(coords.x,0,coords.z)
		if not turtle.placeDown() then
			break
		end
	end
end
 
local function switchScanners(which)
	if scanner.listModules()[1] ~= "plethora:"..which then
		turtle.select(8)
		turtle.equipLeft()
		scanner = peripheral.wrap("left")
		turtle.select(1)
	end
	return scanner.listModules()[1]
end

local function giveMeTheSaplings(bitch)
	switchScanners("sensor")
	
	local entities = scanner.sense()
	for _,entity in pairs(entities) do
		if entity.displayName == "item.tile.sapling.oak" and entity.y < 3 and entity.z > -scanner_radius and entity.z < scanner_radius and entity.x > -scanner_radius and entity.x < scanner_radius then
			go_to(round(entity.x),round(entity.y+1),round(entity.z),true)
			go_to(round(entity.x),0,round(entity.z),true)
			turtle.suckDown()
			turtle.suckUp()
		end
	end

	switchScanners("scanner")
	storage.pullItems(self,1,64)
	storage.pullItems(self,2,64)
end

switchScanners("scanner")
update()
storage = peripheral.wrap("minecraft:chest_4381")
local repeats = 0

while true do
	sleep(1)
	while turtle.getFuelLevel() < 17*17*2 do
		print("Fuel level too low! Refueling..")
		if refuel() < 17*17*6 then
			print("Fuel: " .. tostring( turtle.getFuelLevel() ).."/"..tostring(17*17*6) )
			sleep(60)
		end
	end
	local found, targets = findBlocks(scanned,"minecraft:log")
	if found  and repeats < 5 then
		repeats = repeats+1
		print("Trees found")
		for _,target in pairs(targets) do
			go_to(target.x,0,target.z)
			fucktrees()
		end
		update()
		storage.pullItems(self,1,64)
		storage.pullItems(self,2,64)
		storage.pullItems(self,3,64)
		storage.pullItems(self,4,64)
		storage.pullItems(self,5,64)
		storage.pullItems(self,6,64)
	else
		repeats = 0
		giveMeTheSaplings()
		update()
		replant(scanned)
		update()
		sleep(60)
	end
end