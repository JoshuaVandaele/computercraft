drives = {}
blocksize = 200 -- blocksize, in mb

local function serialize(data, name)  -- Store data
    if not fs.exists('/.data/') then
        fs.makeDir("/.data/")
    end
    local f = fs.open('/.data/'..name, 'w')
    f.write(textutils.serialize(data))
    f.close()
end

local function seekDrives() 
    drives = {}
    for k, v in pairs(peripheral.getNames()) do
        if v:match("drive") then
            local per = peripheral.wrap(v)
            local path = per.getMountPath()
            if per.hasData() then
                blocks = {}
                for i = 1,oldfs.getCapacity()/blocksize do
                    blocks[i] = ""
                end
                drives[#drives + 1] = {["peripheral"] = per , ["n"] = path, ["blocks"] = {}}
            end
        end
    end
end

seekDrives()
serialize(drives)