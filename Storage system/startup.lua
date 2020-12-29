local deposit_chest = "quark:quark_chest_1630"
  
local mon = peripheral.wrap("top")
local storage = {}
local i = 0
local position = 0
local search = ""

local width,height = mon.getSize()
local itemDisplay = window.create(mon,3,2,width-4,height-1)
local topBar = window.create(mon,1,1,width,1)
local sideBar = window.create(mon,width-1,2,width-4,height)
local searchBar = window.create(mon,3,height,width-4,1)

local _={}
for k,v in pairs(keys) do
 _[v]=k
end
keys = _

mon.setBackgroundColor(colors.lightGray)
mon.clear()

topBar.setBackgroundColor(colors.black)
topBar.clear()

sideBar.setBackgroundColor(colors.lightGray) -- width-2, top = 0 & bottom = height
sideBar.clear()
sideBar.setCursorPos(1,height-1)
sideBar.write("\\/")
sideBar.setCursorPos(1,height-4)
sideBar.write("/\\")


itemDisplay.setBackgroundColor(colors.white)
itemDisplay.setTextColor(colors.black)
itemDisplay.clear()

searchBar.setBackgroundColor(colors.lightBlue)
searchBar.clear()

function seekChests()
    storage = {}
    for k,v in pairs(peripheral.getNames()) do
        if v:match("chest") and not v:match(deposit_chest) then
            storage[#storage+1] = peripheral.wrap(v)
        end
    end
end

function getItems()
    local items = {}
    local slotCount = 0
    local usedSlots = 0
    for _,chest in pairs(storage) do
        for slot = 1,chest.size() do
            slotCount = slotCount + 1
            item = chest.getItemMeta(slot)
            if item ~= nil then
                usedSlots = usedSlots + 1
                items[item.displayName] = { 
                    ["maxDamage"] = item.maxDamage,
                }
 
                if items[item.displayName]["count"] then
                    items[item.displayName]["count"] = items[item.displayName]["count"] + item.count
                else
                    items[item.displayName]["count"] = item.count
                end

                if items[item.displayName]["damage"] then
                    table.insert(items[item.displayName]["damage"],item.damage)
                else
                    items[item.displayName]["damage"] = {item.damage}
                end
            end
        end
    end
    return items, slotCount, usedSlots
end

function DrawItems(items, offset)
    position = offset
    itemDisplay.clear()
    itemDisplay.setCursorPos(1,0)
    local i = 0
    for itemName,itemData in pairs(items) do
        i = i+1
        if i > offset and itemName:lower():find(search) then
            local x,y = itemDisplay.getCursorPos()
            itemDisplay.setCursorPos(1,y+1)
            if itemData.maxDamage ~= 0 then
                itemName = itemName.." ("..((itemData.maxDamage-itemData.damage[1])/itemData.maxDamage*100).."%)"
            end
            itemDisplay.write(itemData.count.." "..itemName)
        end
    end
end

seekChests()

items, slotCount, usedSlots = getItems()

topBar.clear()
topBar.setCursorPos(1,1)
topBar.write(usedSlots.."/"..slotCount.." Slots Used")

function clickHandler()
    _,_,x,y = os.pullEvent("monitor_touch")
end

function keyHandler()
    _,key = os.pullEvent("key")
end

while true do
  DrawItems(items, position)
  x, y, key = 0,0,0
  parallel.waitForAny(clickHandler,keyHandler)
  if x>0 then
      if x >= width-2 then
        if y >= height-2 then --down
            print("down")
            position =  position+3
        elseif y >= height-5 then --up
            position = position-3
            print("up")
        end
      end
  else
    key = keys[key]
    x,y = searchBar.getCursorPos()
    if key == "enter" then
        search = ""
        key = ""
    end
    if key == "backspace" then
        search = search:sub(1, -2)
        key = ""
    end
    if key == "space" then key = ' ' end
    search = search..key

    searchBar.clear()
    searchBar.setCursorPos(1,1)
    searchBar.write(search)
  end
end