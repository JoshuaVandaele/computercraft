local drives = 0
local capacity = fs.getCapacity("/")
local freespace = fs.getFreeSpace("/")

local units = {
    ["kb"] = 1e3,
    ["mb"] = 1e6,
    ["gb"] = 1e9,
    ["tb"] = 1e12,
}

function seekDrives() 
    for k, v in pairs(peripheral.getNames()) do
        if v:match("drive") then
            drives= drives + 1
        end
    end
end

seekDrives()

for i = 1,drives do
    if i == 1 then i = "" end
    capacity = capacity + fs.getCapacity("/disk"..i)
    freespace = freespace + fs.getFreeSpace("/disk"..i)
end

local used = capacity-freespace
local SI = ""
local lastvalue = 0

for unit,value in pairs(units) do
    if capacity/value >= 1 and value>lastvalue then
        lastvalue = value
        SI = unit
    end
end

print("-+======== "..drives.." Drives Connected ========+- ")
print("Capacity: " .. capacity/units[SI]..SI)
print("Used: " .. used/units[SI]..SI .. " (" .. used/capacity*100 .. "%)")
print("Free space:" .. freespace/units[SI]..SI)