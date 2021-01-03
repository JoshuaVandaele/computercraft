drives = {}
blocksize = 200 -- blocksize, in b

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
    local peri = peripheral.getNames()
    for k, v in pairs(peri) do
        if v:match("drive") then
            local per = peripheral.wrap(v)
            local path = per.getMountPath()
            if per.hasData() then
                blocks = {}
                for i = 1,oldfs.getCapacity()/blocksize do
                    blocks[i] = {}
                end
                drives[#drives + 1] = {["n"] = path, ["blocks"] = blocks}
                print("Found "..#drives.." drives.")
                sleep(0.2)
            end
        end
    end
end

seekDrives()
serialize(drives)