local deposit_chest = "quark:quark_chest_1630"
 
local mon = peripheral.wrap("top")
local storage = {}
local i = 0
 
print("Searching for chests..")
for k,v in pairs(peripheral.getNames()) do
  if v:match("chest") and not v:match(deposit_chest) then
    print("Found "..v)
    storage[#storage+1] = peripheral.wrap(v)
  end
end

print("Starting.")
while true do
  sleep(1)
  items = {}

  for _,chest in pairs(storage) do
    for slot = 1,#chest.list() do
      for _,item in pairs(chest.getItemMeta(slot)) do
        if item.displayName ~= nil then
          items[item.displayName] = (items[item.displayName] or 0) + (item.count or 0)
        end
      end
    end
  end

  for k,v in pairs(items) do
    print(k,v)
  end

end