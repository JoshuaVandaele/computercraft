drives = {}
blocksize = 200 -- blocksize, in b
blocks = {}



local function serialize(data, name)  -- Store data
    if not fs.exists('/.data/') then
        fs.makeDir("/.data/")
    end
    data = textutils.serialize(data)
    sleep(0.2)
    local f = fs.open('/.data/'..name, 'w')
    f.write(data)
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
                block = {}
                for i = 1,oldfs.getCapacity(path)/blocksize do
                    block[i] = {}
                end
                drives[#drives + 1] = {["n"] = path, ["blocks"] = #drives+1}
                blocks[#drives+1] = block
                print("Found "..#drives.." drives.")
                sleep(0.2)
            end
        end
    end
end

seekDrives()
serialize(drives,"drives")
for i = 1,#blocks do
    serialize(blocks,i)
end