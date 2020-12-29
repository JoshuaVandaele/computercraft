local deposit_chest = "quark:quark_chest_1630"
  
local mon = peripheral.wrap("top")
local storage = {}
local i = 0

local width,height = term.getSize()
local itemDisplay = window.create(mon.current(),3,1,width,height-6)

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

mon.setCursorPos(1,startPos)

for k,v in pairs(items) do
        local x,y = mon.getCursorPos()
        mon.setCursorPos(1,y+1)
        mon.clearLine()
        mon.write(v.count.." "..k.."\n")
end