local chest = "minecraft:chest_4325"
local drives = {}

function seekDrives() 
    drives = {}
    for k, v in pairs(peripheral.getNames()) do
        if v:match("drive") then
            drives[#drives + 1] = {["peripheral"] = peripheral.wrap(v), ["id"] = #drives}
        end
    end
end

seekDrives()

x = 0
for _,drive in pairs(drives) do
	if #drive["peripheral"].list()<1 then
		x = x+1
		drive["peripheral"].pullItems(chest,x,1)
	end
end

print("Filled "..x.." drives.")