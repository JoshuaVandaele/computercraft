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
local requestBar = window.create(mon, 1, 2, 2, height)
local items = {}
local request = {}

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
            addItem(peripheral.wrap(input_inventory).getItemMeta(slot), chest, slot)
            chest["peripheral"].pullItems(input_inventory, slot, peripheral.wrap(input_inventory).size() * 64)
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
    end
end

function getItem(item, count)
    for key,value in pairs(items[item]) do
        if type(key) == "number" then
            for _,chest in storage do
                if chest["id"] == key then
                    chest["peripheral"].pushItems(output_inventory, value[1], count)
                    items[item]["count"] = items[item]["count"] - count
                    table.remove(items[item][key], 1)
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
    table.sort(items)
    return items, slotCount, usedSlots
end

function DrawItems(items, offset)
    position = offset
    itemDisplay.clear()
    itemDisplay.setCursorPos(1, 0)
    local i = 0
    for itemName, itemData in pairs(items) do
        i = i + 1
        if i > offset and itemName:lower():find(search) then
            local x, y = itemDisplay.getCursorPos()
            itemDisplay.setCursorPos(1, y + 1)
            if itemData.maxDamage ~= 0 then
                itemName = itemName .." (" .. math.floor((itemData.maxDamage - itemData.damage[1]) / itemData.maxDamage * 100) .. "%)"
            end
            if itemData.count < 10 then
                itemName = " " .. itemName
            end
            itemDisplay.write(itemData.count .. " " .. itemName)
        end
    end
end

seekChests()
addItems()

topBar.clear()
topBar.setCursorPos(1, 1)
topBar.write(usedSlots .. "/" .. slotCount .. " Slots Used")

function clickHandler()
    _, _, x, y = os.pullEvent("monitor_touch")
end

function keyHandler()
    _, key = os.pullEvent("key")
end

while true do
    DrawItems(items, position)
    x, y, key = 0, 0, 0
    parallel.waitForAny(clickHandler, keyHandler, storeItem)

    if x > 0 then
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
            end
        end
    elseif key then
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