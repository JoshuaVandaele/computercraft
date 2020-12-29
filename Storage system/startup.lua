local deposit_chest = "quark:quark_chest_1630"
  
local mon = peripheral.wrap("top")
local storage = {}
local i = 0


local width,height = mon.getSize()
local itemDisplay = window.create(mon,3,2,width-4,height)
local topBar = window.create(mon,1,1,width,2)
local sideBar = window.create(mon,width-1,2,width-4,height)



mon.setBackgroundColor(colors.lightGray)
mon.clear()

topBar.setBackgroundColor(colors.black)
topBar.clear()

sideBar.setBackgroundColor(colors.lightGray) -- width-2, top = 0 & bottom = height
sideBar.clear()
sideBar.setCursorPos(1,height)
sideBar.write("v")
sideBar.setCursorPos(1,height-2)
sideBar.write("^")


itemDisplay.setBackgroundColor(colors.white)
itemDisplay.setTextColor(colors.black)
itemDisplay.clear()

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
                    ["count"] = (items[item.displayName] or 0) + (item.count or 0),
                    ["maxDamage"] = item.maxDamage,
                }
 
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

seekChests()

items, slotCount, usedSlots = getItems()

topBar.clear()
topBar.setCursorPos(1,1)
topBar.write(usedSlots.."/"..slotCount.." Slots Used")

itemDisplay.clear()
itemDisplay.setCursorPos(1,1)
for k,v in pairs(items) do
        local x,y = itemDisplay.getCursorPos()
        itemDisplay.setCursorPos(1,y+1)
        itemDisplay.write(v.count.." "..k)
        print(v.count.." "..k)
end