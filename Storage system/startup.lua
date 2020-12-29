local deposit_chest = "quark:quark_chest_1630"
  
local mon = peripheral.wrap("top")
local storage = {}
local i = 0


local width,height = mon.getSize()
local itemDisplay = window.create(mon,3,6,width-3,height)
mon.setBackgroundColor(colors.lightGray)
mon.clear()

itemDisplay.setBackgroundColor(colors.white)
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
    for _,chest in pairs(storage) do
        for slot = 1,chest.size() do
            item = chest.getItemMeta(slot)
            if item ~= nil then
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
    return items
end

seekChests()

items = getItems()

itemDisplay.setCursorPos(1,1)
for k,v in pairs(items) do
        local x,y = itemDisplay.getCursorPos()
        itemDisplay.setCursorPos(1,y+1)
        itemDisplay.clearLine()
        itemDisplay.write(v.count.." "..k)
end