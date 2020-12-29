local output_inventory = "quark:quark_chest_1630"
local input_inventory = "minecraft:ironchest_iron_2052"

local mon = peripheral.wrap("top")
local storage = {}
local i = 0
local position = 0
local search = ""

local width, height = mon.getSize()
local itemDisplay = window.create(mon, 3, 2, width - 4, height - 2)
local topBar = window.create(mon, 1, 1, width, 1)
local sideBar = window.create(mon, width - 1, 2, width - 4, height)
local searchBar = window.create(mon, 3, height, width - 4, 1)
local requestBar = window.create(mon, 1, 2, 2, height-2)
local items = {}
local request = {}
local drawnItems = {}

local _ = {}
for k, v in pairs(keys) do
    _[v] = k
end
keys = _

mon.setBackgroundColor(colors.lightGray)
mon.clear()

topBar.setBackgroundColor(colors.black)
topBar.clear()

requestBar.setBackgroundColor(colors.lightGray)
requestBar.clear()

sideBar.setBackgroundColor(colors.lightGray) -- width-2, top = 0 & bottom = height
sideBar.clear()
sideBar.setCursorPos(1, height - 1)
sideBar.write("\\/")
sideBar.setCursorPos(1, height - 4)
sideBar.write("/\\")
sideBar.setCursorPos(1, height - 7)
sideBar.write("RE")

itemDisplay.setBackgroundColor(colors.white)
itemDisplay.setTextColor(colors.black)
itemDisplay.clear()

searchBar.setBackgroundColor(colors.lightBlue)
searchBar.clear()

function seekChests()
    storage = {}
    for k, v in pairs(peripheral.getNames()) do
        if v:match("chest") and not v:match(output_inventory) then
            storage[#storage + 1] = {["peripheral"] = peripheral.wrap(v), ["id"] = #storage}
        end
    end
end

function storeItem()
    for _, chest in pairs(storage) do
        for slot = 1, peripheral.wrap(input_inventory).size() do
            if #peripheral.wrap(input_inventory).list() < 1 then
                return
            end
            if addItem(peripheral.wrap(input_inventory).getItemMeta(slot), chest, slot) then
                hasItems = true
                chest["peripheral"].pullItems(input_inventory, slot, peripheral.wrap(input_inventory).size() * 64)
            end
        end
    end
end

function addItem(item, chest, slot)
    if item ~= nil then
        usedSlots = usedSlots + 1
        if items[item.displayName] == nil then 
            items[item.displayName] = {}
            items[item.displayName]["damage"] = {}
            items[item.displayName]["count"] = 0
        end
        if items[item.displayName][chest.id] == nil then
            items[item.displayName][chest.id] = {}
        end

        items[item.displayName]["maxDamage"] = item.maxDamage
        items[item.displayName]["count"] = items[item.displayName]["count"] + item.count
        items[item.displayName][chest.id][slot] = item.count
        table.insert(items[item.displayName]["damage"], item.damage)
        table.sort(items)
    else
        return false
    end
end

function getItem(item, count)
    for key,value in pairs(items[item]) do
        if type(key) == "number" then
            for _,chest in pairs(storage) do
                if chest["id"] == key then
                    for slot,cnt in pairs(value) do
                        chest["peripheral"].pushItems(output_inventory, slot, count)
                        items[item]["count"] = items[item]["count"] - cnt
                        table.remove(items[item][key], 1)
                        count = count-cnt
                        if count < 1 then return end
                    end
                end
            end
        end
    end
end

function addItems()
    itemDisplay.clear()
    items = {}
    slotCount = 0
    usedSlots = 0
    for _, chest in pairs(storage) do
        for slot = 1, chest["peripheral"].size() do
            slotCount = slotCount + 1
            addItem(chest["peripheral"].getItemMeta(slot),chest,slot)
        end
    end
    return items, slotCount, usedSlots
end

function DrawItems(items, offset)
    drawnItems = {}
    position = offset
    itemDisplay.clear()
    requestBar.clear()
    itemDisplay.setCursorPos(1, 0)
    local i = 0
    for itemName, itemData in pairs(items) do
        i = i + 1
        if i > offset and itemName:lower():find(search) then
            drawnItems[i-offset] = itemName
            local x, y = itemDisplay.getCursorPos()
            requestBar.setCursorPos(1,y+1)
            itemDisplay.setCursorPos(1, y + 1)
            if itemData.maxDamage ~= 0 then
                itemName = itemName .." (" .. math.floor((itemData.maxDamage - itemData.damage[1]) / itemData.maxDamage * 100) .. "%)"
            end
            if itemData.count < 10 then
                itemName = " " .. itemName
            end
            itemDisplay.write(itemData.count .. " " .. itemName)
            requestBar.write(" +")
        end
    end
end

seekChests()
addItems()

topBar.clear()
topBar.setCursorPos(1, 1)
topBar.write(usedSlots .. "/" .. slotCount .. " Slots Used")

while true do
    DrawItems(items, position)
    event, _, x, y, key = os.pullEvent()
    storeItem()

    if event == "monitor_touch" then
        if x >= width - 2 then
            if y >= height - 2 then --down
                print("down")
                position = position + 3
            elseif y >= height - 5 then --up
                position = position - 3
                print("up")
            elseif y >= height - 7 then --up
                seekChests()
                addItems()
                print("refresh")
            end  --x, y, width, height 1, 2, 2, height-2)
        end

        if x <= 2 then
            getItem(drawnItems[y-1],64)
        end
    elseif event == "key" then
        key = keys[key] or ""
        x, y = searchBar.getCursorPos()
        if key == "enter" then
            search = ""
            key = ""
        end
        if key == "backspace" then
            search = search:sub(1, -2)
            key = ""
        end
        if key == "space" then
            key = " "
        end
        if #key > 1 then
            key = ""
        end
        search = search .. key

        searchBar.clear()
        searchBar.setCursorPos(1, 1)
        searchBar.write(search)
    end
end