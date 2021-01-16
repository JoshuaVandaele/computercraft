local self = peripheral.wrap("bottom").getNameLocal()
local mon = peripheral.wrap("top")

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

if not config.stock then
	local function serialize(data, name)  -- Store data
	    if not fs.exists('/.data') then
	        fs.makeDir('/.data')
	    end
	    local f = fs.open('/.data/'..name, 'w')
	    f.write(textutils.serialize(data))
	    f.close()
	end

	print("Set up this turtle!")
	print("What would you want displayed on the above monitor?")
	config.name = read()
	print("How much time in seconds should players wait to get this item?")
	config.wait = tonumber(read())
	print("What is the name of the chest the turtle will use?")
	config.stock = read()
	print("How much items do you wanna drop per use?")
	config.drop = tonumber(read())
	if config.drop > 64 then config.drop = 64 end
	if config.drop < 1 then config.drop = 1 end
	serialize(config,"config")
	print("All set up!")
end

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

local function log(...)
	local txt = os.date("[%c]").." "..unpack({...})
    print(txt)
    local f = fs.open("/disk/logs/"..self..".txt", "a")
    f.writeLine(txt)
    f.close()
end

local function giveItems(slot,amount)
	if not slot then slot = 1 end
	if not amount then amount = config.drop end
	if slot > maxSize then turtle.drop() return false end

	local pushed = config.stock.pushItems(self,slot,amount,1)
	if pushed < amount then
		local remain = config.drop-pushed
		log("Missing "..remain.. " items in slot "..slot.."! Seeking in next slot..")
		giveItems(slot+1,remain)
	end
	turtle.drop()
	return true
end

while true do
	mon.setBackgroundColor(colors.green)
	mon.clear()

	writeCentered(config.name)

	writeBottomCentered(" Click here!")

	os.pullEvent("monitor_touch")
	mon.setBackgroundColor(colors.red)
	mon.clear()
	if giveItems() then
		writeCentered(" Please wait...")
	else
		writeCentered(" Error!")
	end
		writeBottomCentered(config.wait.." seconds")
	sleep(config.wait)
end