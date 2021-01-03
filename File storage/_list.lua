local tArgs = { ... }

local function unserialize(name)  -- Get data
    if fs.exists('/.data/'..name) then
        local f = fs.open('/.data/'..name, 'r')
        data = textutils.unserialize(f.readAll())
        f.close()
    end
    return data
end
local path = unserialize("paths")

function split (inputstr, sep)
    if sep == nil then
            sep = "%s"
    end
    local t = {}

    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
        table.insert(t, str)
    end
    return t
end

--"Raid/uwu"
--{"Raid", "uwu"}
function list(dir)
    dir = split(dir,"/")
    for disk,storage in pairs(path) do
        for _,folder in pairs(dir) do
            if storage[folder] then
                storage = storage[folder]
            end
        end
    end
    
end