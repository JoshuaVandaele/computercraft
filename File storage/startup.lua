local drives = {}

function seekDrives() 
    for k, v in pairs(peripheral.getNames()) do
        if v:match("drive") then
            drives= drives + 1
        end
    end
end

function serialize(data, name)  -- Store data
    if not fs.exists('/disk') then
        return
    end
    if not fs.exists('/.data') then
        fs.makeDir('/.data')
    end
    local f = fs.open('/.data/'..name, 'w')
    f.write(textutils.serialize(data))
    f.close()
end
 
function unserialize(name)  -- Get data
    if fs.exists('/.data/'..name) then
        local f = fs.open('/.data/'..name, 'r')
        data = textutils.unserialize(f.readAll())
        f.close()
    end
    return data
end

local players = unserialize("players") or {}
seekDrives()