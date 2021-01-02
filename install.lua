-- pastebin get nAxHsL89 install.lua

local request = http.get("https://api.github.com/repos/FolfyBlue/computercraft/git/trees/master?recursive=1")
local contents = json.parse(request.readAll())
request.close()

for _, file in ipairs(contents.tree) do
  local request = http.get("https://raw.githubusercontent.com/FolfyBlue/computercraft/master/" .. file.path)
  local handle = fs.open(file.path, "w")
  handle.write(request.readAll())
  handle.close()
  request.close()
end 