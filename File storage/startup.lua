local paths
local name = "Raid"
local drives = {}
local paths = {}

local function serialize(data, name)  -- Store data
    if not fs.exists('/.data/') then
        fs.makeDir("/.data/")
    end
    local f = fs.open('/.data/'..name, 'w')
    f.write(textutils.serialize(data))
    f.close()
end
 
--[[
local function unserialize(name)  -- Get data
    if fs.exists('/.data/'..name) then
        local f = fs.open('/.data/'..name, 'r')
        data = textutils.unserialize(f.readAll())
        f.close()
    end
    return data
end

paths = unserialize("paths") or {}
]]

local function seekDrives() 
    drives = {}
    for k, v in pairs(peripheral.getNames()) do
        if v:match("drive") then
            local per = peripheral.wrap(v)
            if per.hasData() then
                drives[#drives + 1] = {["peripheral"] = per , ["n"] = per.getMountPath()}
            end
        end
    end
end

local function plog( ... )
    print(table.concat({...}," | "))
end

function tree(path,depth)
    if not depth then 
        depth = "" 
    end
    path = path.."/"
    local dirTree = {}
    
    local entry = fs.list(path)
    for i = 1,#entry do
        local fullpath = path..entry[i]
        if fs.isDir(fullpath) then
            dirName = string.gsub(fullpath,path,"")
            dirTree[dirName] = tree(fullpath,path)
        else
            table.insert(dirTree,entry[i]) 
        end
    end
    return dirTree
end

if not fs.exists('/'..name) then
    fs.makeDir("/"..name)
end

seekDrives()

for _,drive in pairs(drives) do
    paths[drive.n] = tree(drive.n)
end

serialize(paths,"paths")
shell.dir(name)