local self = peripheral.wrap("bottom").getNameLocal()
local mon = peripheral.wrap("top")
local sensor = peripheral.find("manipulator")
local banned = {}

local function unserialize(name)  -- Get data
	local data
    if fs.exists('/.data/'..name) then
        local f = fs.open('/.data/'..name, 'r')
        data = textutils.unserialize(f.readAll())
        f.close()
    end
    return data
end

mon.setTextScale(0.5)
local config = unserialize("config") or {}
local w,h = mon.getSize()

local function serialize(data, name)  -- Store data
    if not fs.exists('/.data') then
        fs.makeDir('/.data')
    end
    local f = fs.open('/.data/'..name, 'w')
    f.write(textutils.serialize(data))
    f.close()
end

if not config.name then
	print("What would you want displayed on the above monitor?")
	config.name = read()
end
if not config.wait then
	print("How much time in seconds should players wait to get this item?")
	config.wait = tonumber(read())
end
if not config.stock then
	print("What is the name of the chest the turtle will use?")
	config.stock = read()
end
if not config.drop then
	print("How much items do you wanna drop per use?")
	config.drop = tonumber(read())
	if config.drop > 64 then config.drop = 64 end
	if config.drop < 1 then config.drop = 1 end
end
if not config.facing then
	print("What direction is the turtle facing? (east, north..)")
	config.facing = read()
end

serialize(config,"config")

config.stock = peripheral.wrap(config.stock)
local maxSize = config.stock.size()

local function writeCentered(txt)
	mon.setCursorPos(math.floor(w/2-txt:len()/2 + 0.5), math.floor(h/2 + 0.5))
	mon.write(txt)
end

local function writeBottomCentered(txt)
	mon.setCursorPos( math.floor(w/2-txt:len()/2 + 0.5), h)
	mon.write(txt)
end

local function serialize(data, name)  -- Store data
    local f = fs.open('/disk/'..name, 'w')
    f.write(textutils.serialize(data))
    f.close()
end

function unserialize(name)  -- Get data
	local data
    if fs.exists('/disk/'..name) then
        local f = fs.open('/disk/'..name, 'r')
        data = textutils.unserialize(f.readAll())
        f.close()
    end
    return data
end

local function log(...)
	local txt = os.date("[%Y-%m-%d %H:%M:%S] ")..config.name.."> "..unpack({...})
    print(txt)
    local f = fs.open("/disk/logs/"..self..".txt", "a")
    f.writeLine(txt)
    f.close()
end

local function getPlayers()
	local entities = sensor.sense()
	local players = {}
	for _,e in pairs(entities) do
		if e.name == e.displayName then
			local req = http.get("https://api.mojang.com/user/profiles/" .. e.id .. "/names")
			local j = req.readAll()
			req.close()
			if #j>0 then
				j = json.decode(j)
				if not j.error then
					local username = j[#j].name
					if e.name == username then
						table.insert(players,e)
					end
				end
			end
		end
	end
	return players
end

local function getNearestPlayer()
	players = getPlayers()
	local x,z = 0,0
	local player
	for _,e in pairs(players) do
		if config.facing == "north" then
			if e.z < z then
				player = e
			end
		elseif config.facing == "east" then
			if e.x > x then
				player = e
			end
		elseif config.facing == "south" then
			if e.z > z then
				player = e
			end
		elseif config.facing == "west" then
			if e.x < x then
				player = e
			end
		end
	end
	return player
end


local function giveItems(player,slot,amount)
	if not slot then slot = 1 end
	if not amount then amount = config.drop end
	if not player then player = getNearestPlayer() end
	if not player.name then return end
	if slot > maxSize then turtle.drop() return false,player,"Out Of Stock" end

	if banned[player.name] then return false,player,"Banned!" end

	local pushed = config.stock.pushItems(self,slot,amount,1)
	if pushed < amount then
		local remain = config.drop-pushed
		return giveItems(player,slot+1,remain)
	end
	turtle.drop()
	return true,player,pushed-amount+config.drop
end

banned = unserialize("banned.luajson")
if not banned then
	banned = {["rtlsdr"] = true,}
	serialize(banned,"banned.luajson")
end
sleep(1)

while true do
	mon.setBackgroundColor(colors.green)
	mon.clear()

	writeCentered(config.name)

	writeBottomCentered(" Click here!")

	_,direction = os.pullEvent("monitor_touch","top")
	if direction == "top" then
		mon.setBackgroundColor(colors.red)
		mon.clear()
		local success, player,errormsg = giveItems()
		if success then
			writeCentered(" Please wait...")
			log(player.name..": dropped "..errormsg.." items")
		elseif errormsg then
			writeCentered(errormsg)
			log(player.name..": "..errormsg)
		else
			writeCentered(" Error!")
			log("Couldn't drop items")
		end
			writeBottomCentered(config.wait.." seconds")
		sleep(config.wait)
	end
end