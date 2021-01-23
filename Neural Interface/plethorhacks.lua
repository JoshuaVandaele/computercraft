print('Plethorhacks by Folfy_Blue')
local neural = peripheral.wrap("back")

local modules = {"plethora:kinetic","plethora:scanner","plethora:introspection","plethora:sensor","plethora:laser"}
local modules = neural.listModules()

if neural.canvas3d then canvas = neural.canvas3d() end

local targetBlacklist = {
  ["LeashKnot"] = true,
  ["Arrow"] = true,
  ["Item"] = true,
  ["XPOrb"] = true,
  ["Folfy_Blue"] = true,
}



local function ReverseTable(t)
    local reversedTable = {}
    local itemCount = #t
    for k, v in ipairs(t) do
        reversedTable[v] = true
    end
    return reversedTable
end

local function strsplit(str,split)
  if not str then return end
  local array = {}
  for w in (str .. split):gmatch("([^" .. split .. "]*)" .. split) do
     table.insert(array, w)
  end 
  return array
end


modules = ReverseTable(modules)

local hacks = {}
local refresh = 0
local refreshMax = 3

local function killaura(yaw,pitch)
  neural.look(yaw,pitch)
  neural.swing()
end

local function laseraura(yaw,pitch)
  neural.fire(yaw,pitch,hacks.laseraura.settings.power)
end

local function tracers(x,y,z)
  if not canvas then canvas = neural.canvas3d() end
  canvas.create().addLine({0,0,0},{x,y,z}).setScale(3)
end

-- hackz = {[1] = {func = killaura, targets = {}, args = {}, yawpitch = true }}

local function targetEntity(hackz)
  if not hackz or not hackz[1] then return end
  local entities = neural.sense()
  for _,entity in pairs(entities) do
    if targetBlacklist[entity.name] then break end
    for _,hack in ipairs(hackz) do
      if hack["targets"] and hack["targets"][1] then
        for _, target in pairs(hack["targets"]) do
          if entity.name == target then
            local x, y, z = entity.x, entity.y, entity.z
            if hack.yawpitch then
              local pitch = -math.atan2(y, math.sqrt(x * x + z * z))
              local yaw = math.atan2(-x, z)
              yaw,pitch = math.deg(yaw),math.deg(pitch)
              hack.func(yaw,pitch,hackz.args)
            else
              hack.func(x,y,z,hackz.args)
            end
          end
        end
      else
        local x, y, z = entity.x, entity.y, entity.z
        if hack.yawpitch then
          local pitch = -math.atan2(y, math.sqrt(x * x + z * z))
          local yaw = math.atan2(-x, z)
          yaw,pitch = math.deg(yaw),math.deg(pitch)
          hack.func(yaw,pitch,hackz.args)
        else
          hack.func(x,y,z,hackz.args)
        end
      end
    end
  end
end

hacks.killaura = {
  ["requirements"] = {["plethora:scanner"] = true, ["plethora:kinetic"] = true},
  ["enabled"] = false,
  ["settings"] = {},
  ["func"] = "targetEntity",
  ["args"] = { ["func"] = killaura, ["targets"] = {}, ["yawpitch"] = true },
}

hacks.laseraura = {
  ["requirements"] = {["plethora:scanner"] = true, ["plethora:laser"] = true},
  ["enabled"] = false,
  ["settings"] = {["power"] = 1},
  ["func"] = "targetEntity",
  ["args"] = { ["func"] = laseraura, ["targets"] = {}, ["yawpitch"] = true }
}

hacks.tracers = {
  ["requirements"] = {["plethora:scanner"] = true, ["plethora:glasses"] = true},
  ["enabled"] = false,
  ["settings"] = {},
  ["func"] = "targetEntity",
  ["args"] = { ["func"] = tracers, ["targets"] = {} }
}

local function hack()
  while true do
    local functions = {
      ["targetEntity"] = {}
    }
    local missing
    for name,hack in pairs(hacks) do
      if hack.enabled then
        for module in pairs(hack.requirements) do
          if modules[module] then
            table.insert(functions[hack.func],hack.args)
          else
            print("Missing "..module.." for "..name)
            hacks[name].enabled = false
            functions = {}
            break
          end
        end
      end
    end
    targetEntity(functions.targetEntity)
    if refreshMax<refresh then
      if canvas then canvas.clear() end
      refresh = 0
    end
    refresh=refresh+1
    sleep(0)
  end
end

local commands = {
  ["killaura"] = {},
  ["laseraura"] = {},
  ["tracers"] = {}
}

local function help(cmd,subcmds)
  print("Usage:")
  for _,sub in pairs(subcmds) do
    print("- " .. cmd .. " " .. sub)
  end
end

local function toggleHack(name)
  neural = peripheral.wrap("back")
  modules = ReverseTable(neural.listModules())
  hacks[name].enabled = not hacks[name].enabled
  print(name..": "..(hacks[name].enabled and "enabled" or "disabled"))
end

local function target(hack,targets)
  for k,target in pairs(hacks[hack].args.targets) do
    for newk,newTarget in pairs(targets) do
      if target == newTarget then
        hacks[hack].args.targets[k] = nil
        targets[newk] = nil
      end
    end
  end
  for _,target in pairs(targets) do
    table.insert(hacks[hack].args.targets,target)
  end
  print(hack.." targets:")
  for _,target in pairs(hacks[hack].args.targets,target) do
    print("- "..target)
  end
end

commands.help = function()
  print("Commands:")
  for name in pairs(commands) do
    print("- "..name)
  end
end

commands.entities = function()
  print("Nearby entities:")
  for k,v in pairs(neural.sense()) do
    print("- "..v.name)
  end
end

commands.killaura.help = function()
  help("killaura",{
    "target <entities>",
    "toggle"
  })
end

commands.killaura.toggle = function()
  toggleHack("killaura")
end

commands.killaura.target = function(targets)
  target("killaura",targets)
end

commands.laseraura.help = function()
  help("laseraura",{
    "target <entities>",
    "power <0.5-5>",
    "toggle"
  })
end

commands.laseraura.toggle = function()
  toggleHack("laseraura")
end

commands.laseraura.target = function(targets)
  target("laseraura",targets)
end

commands.laseraura.power = function(args)
  if not tonumber(args[1]) or tonumber(args[1])>5 or tonumber(args[1])<0.5 then
    print("Bad arguments: Number between 0.5 and 5 required")
    return
  end
  hacks.laseraura.settings.power = tonumber(args[1])
end

commands.tracers.help = function()
  help("tracers", {
    "target <entities>",
    "toggle",
  })
end

commands.tracers.toggle = function()
  toggleHack("tracers")
end

commands.tracers.target = function(targets)
  target("tracers",targets)
end

local function cmdShell()
  local input = ""
  io.write("> ")
  while true do
      local event, key = os.pullEvent()
      if event == "key" then
        if key == keys.backspace then
          input = input:sub(1, -2)
          local x,y = term.getCursorPos()
          term.setCursorPos(x-1,y)
          io.write(" ")
          term.setCursorPos(x-1,y)
        elseif key == keys.enter then
          print()
          cmd = strsplit(input, " ")
          if commands[cmd[1]] then
            local args = {table.unpack(cmd)}
            table.remove(args,1)
            if type(commands[cmd[1]]) == "function" then
              commands[cmd[1]](args)
            else
              if not cmd[2] then cmd[2] = "" end
              if commands[cmd[1]][cmd[2]] then
                table.remove(args,1)
                commands[cmd[1]][cmd[2]](args)
              else
                print(cmd[1]..": \""..cmd[2].."\" is not a recognised subcommand")
              end
            end
          else
            print(cmd[1]..": Command not found!")
          end
          input = "" 
          print()
          io.write("> ")
        end
      elseif event == "char" then
        input = input..key
        io.write(key)
      end
    end
end

parallel.waitForAny(hack,cmdShell)