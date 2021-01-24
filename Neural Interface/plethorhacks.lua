--[[
TODO:
No fall
XRay
Autotravel
Better targetting
follow
]]

print('Plethorhacks by Folfy_Blue')
local neural = peripheral.wrap("back")

local modules = {"plethora:kinetic","plethora:scanner","plethora:introspection","plethora:sensor","plethora:laser"}
local modules = neural.listModules()

if neural.canvas3d then canvas = neural.canvas3d() end

local function unserialize(name)  -- Get data
  local data
    if fs.exists('/.plethorhacks/'..name) then
        local f = fs.open('/.plethorhacks/'..name, 'r')
        data = textutils.unserialize(f.readAll())
        f.close()
    end
    return data
end

local function serialize(data, name)  -- Store data
    if not fs.exists('/.plethorhacks') then
        fs.makeDir('/.plethorhacks')
    end
    local f = fs.open('/.plethorhacks/'..name, 'w')
    f.write(textutils.serialize(data))
    f.close()
    return data
end

local config = {}

config.blacklist = unserialize("blacklist") or serialize({
  ["LeashKnot"] = true,
  ["Arrow"] = true,
  ["Item"] = true,
  ["XPOrb"] = true,
  ["Folfy_Blue"] = true,
},"blacklist")

config.laseraura = unserialize("laseraura") or serialize({["power"]=1},"laseraura")
config.miner = unserialize("miner") or serialize({["trigger"] = "minecraft:wooden_pickaxe"},"miner")
config.fly = unserialize("fly") or serialize({["delay"] = 0.25,["power"] = 4},"fly")
config.walk = unserialize("walk") or serialize({["delay"] = 0,["power"] = 1.25},"walk")

local history = unserialize("history") or serialize({"Easter egg!"},"history")

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
local cooldowns = {
  ["fly"] = 0,
  ["walk"] = 0,
  ["refresh"] = 0,
}

-- hackz = {[1] = {func = killaura, targets = {}, args = {}, yawpitch = true }}

local function targetEntity(hackz)
  if not hackz or not hackz[1] then return end
  local entities = neural.sense()
  for _,entity in pairs(entities) do
    for _,hack in ipairs(hackz) do
      if hack["targets"] and hack["targets"][1] and not config.blacklist[entity.name] then
        for _, target in pairs(hack["targets"]) do
          if entity.name == target then
            local x, y, z = entity.x, entity.y, entity.z
            if hack.yawpitch then
              local pitch = -math.atan2(y, math.sqrt(x * x + z * z))
              local yaw = math.atan2(-x, z)
              yaw,pitch = math.deg(yaw),math.deg(pitch)
              if hack.func(yaw,pitch,hackz.args) then return end
            else
              if hack.func(x,y,z,hackz.args) then return end
            end
          end
        end
      elseif not config.blacklist[entity.name] then
        local x, y, z = entity.x, entity.y, entity.z
        if hack.yawpitch then
          local pitch = -math.atan2(y, math.sqrt(x * x + z * z))
          local yaw = math.atan2(-x, z)
          yaw,pitch = math.deg(yaw),math.deg(pitch)
          if hack.func(yaw,pitch,hackz.args) then return end
        else
          if hack.func(x,y,z,hackz.args) then return end
        end
      end
    end
  end
end

local function targetBlock(hackz)
  if not hackz or not hackz[1] then return end
  local blocks = neural.scan()
  for _,block in pairs(blocks) do
    for _,hack in ipairs(hackz) do
      if hack["targets"] and hack["targets"][1] and not config.blacklist[block.name] then
        for _, target in pairs(hack["targets"]) do
          if block.name == target then
            local x, y, z = block.x, block.y, block.z
            if hack.yawpitch then
              local pitch = -math.atan2(y, math.sqrt(x * x + z * z))
              local yaw = math.atan2(-x, z)
              yaw,pitch = math.deg(yaw),math.deg(pitch)
              hack.func(yaw,pitch,hack.args)
            else
              hack.func(x,y,z,hack.args)
            end
          end -- Plethorhacks made by Folfy_Blue
        end   -- Hidden here for code stealers
      elseif not config.blacklist[block.name] then
        local owner = neural.getMetaOwner()
        local yaw,pitch = owner.yaw,owner.pitch
        local x,y,z = owner.x,owner.y,owner.z
        if hack.yawpitch then
          hack.func(yaw,pitch,hack.args)
        else
          hack.func(x,y,z,hack.args)
        end
      end
    end
  end
end

local function dummy(hackz)
  if not hackz or not hackz[1] then return end
    for _,hack in ipairs(hackz) do
      hack.func(hack.args)
    end
end

local function killaura(yaw,pitch)
  neural.look(yaw,pitch)
  return neural.swing()
end

local function laseraura(yaw,pitch)
  neural.fire(yaw,pitch,hacks.laseraura.settings.power)
end

local function tracers(x,y,z)
  if not canvas then canvas = neural.canvas3d() end
  canvas.create().addLine({0,0,0},{x,y,z}).setScale(3)
end

local function miner(yaw,pitch)
  local holding = neural.getEquipment().list()[1]
  if holding and holding.name == config.miner.trigger or config.miner.trigger == "" then
    neural.fire(yaw,pitch,3)
  end
end

local function fly()
  local owner = neural.getMetaOwner()
  if owner.isSneaking and (os.clock()-cooldowns.fly > hacks.fly.settings.delay) then
    yaw,pitch = owner.yaw,owner.pitch
    neural.launch(yaw,pitch,hacks.fly.settings.power)
    cooldowns.fly = os.clock()
  end
end

local function walk(owner)
  if not owner then owner = neural.getMetaOwner() end
  if not owner.isSneaking and (os.clock()-cooldowns.walk > hacks.walk.settings.delay) then
    neural.launch(owner.yaw,0,hacks.walk.settings.power)
    cooldowns.walk = os.clock()
  end
end

hacks.killaura = {
  ["requirements"] = {["plethora:sensor"] = true, ["plethora:kinetic"] = true},
  ["enabled"] = false,
  ["settings"] = {},
  ["func"] = "targetEntity",
  ["args"] = { ["func"] = killaura, ["targets"] = {}, ["yawpitch"] = true },
}

hacks.laseraura = {
  ["requirements"] = {["plethora:sensor"] = true, ["plethora:laser"] = true},
  ["enabled"] = false,
  ["settings"] = config.laseraura,
  ["func"] = "targetEntity",
  ["args"] = { ["func"] = laseraura, ["targets"] = {}, ["yawpitch"] = true }
}

hacks.tracers = {
  ["requirements"] = {["plethora:sensor"] = true, ["plethora:glasses"] = true},
  ["enabled"] = false,
  ["settings"] = {},
  ["func"] = "targetEntity",
  ["args"] = { ["func"] = tracers, ["targets"] = {} }
}

hacks.miner = {
  ["requirements"] = {["plethora:scanner"] = true, ["plethora:laser"] = true, ["plethora:introspection"] = true},
  ["enabled"] = false,
  ["settings"] = config.miner,
  ["func"] = "targetBlock",
  ["args"] = { ["func"] = miner, ["targets"] = {}, ["yawpitch"] = true }
}

hacks.fly = {
  ["requirements"] = {["plethora:kinetic"] = true, ["plethora:sensor"] = true, ["plethora:introspection"] = true},
  ["enabled"] = false,
  ["settings"] = config.fly,
  ["func"] = "dummy",
  ["args"] = { ["func"] = fly }
}

hacks.walk = {
  ["requirements"] = {["plethora:kinetic"] = true, ["plethora:sensor"] = true, ["plethora:introspection"] = true},
  ["enabled"] = false,
  ["settings"] = config.walk,
  ["func"] = "dummy",
  ["args"] = { ["func"] = walk }
}

local function hack()
  while true do
    local functions = {
      ["targetEntity"] = {},
      ["targetBlock"] = {},
      ["dummy"] = {},
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
    targetBlock(functions.targetBlock)
    dummy(functions.dummy)
    if 3<cooldowns.refresh then
      if canvas then canvas.clear() end
      cooldowns.refresh = 0
    end
    cooldowns.refresh=cooldowns.refresh+1
    sleep(0)
  end
end

local commands = {
  ["killaura"] = {},
  ["laseraura"] = {},
  ["tracers"] = {},
  ["miner"] = {},
  ["fly"] = {},
  ["autowalk"] = {},
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

commands.panic = function()
  for k in pairs(hacks) do
    if hacks[k].enabled then
      hacks[k].enabled = false
      print("Disabled "..k)
    end
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
    "power <0.5-5> (default 1)",
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
  serialize(hacks.laseraura.settings,"laseraura")

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

commands.miner.help = function()
  help("miner",{
    "target <blocks>",
    "toggle"
  })
end

commands.miner.toggle = function()
  toggleHack("miner")
end

commands.miner.target = function(targets)
  target("miner",targets)
end

commands.miner.settrigger = function(args)
  hacks.miner.settings.trigger = args[1]
  serialize(hacks.miner.settings,"miner")
end

commands.fly.help = function()
  help("fly",{
    "setDelay <time in seconds> (default 0.25)",
    "setPower <0-4> (default 1)",
    "toggle"
  })
end

commands.fly.toggle = function()
  toggleHack("fly")
end

commands.fly.setDelay = function(args)
  hacks.fly.settings.delay = tonumber(args[1]) or 0
  serialize(hacks.fly.settings,"fly")
end


commands.fly.setPower = function(args)
  hacks.fly.settings.power = tonumber(args[1]) or 4
  serialize(hacks.fly.settings,"fly")
end

commands.autowalk.help = function()
  help("autowalk",{
    "setDelay <time in seconds> (default 0)",
    "setPower <0-4> (default 1.25)",
    "toggle"
  })
end

commands.autowalk.toggle = function()
  toggleHack("walk")
end

commands.autowalk.setDelay = function(args)
  hacks.walk.settings.delay = tonumber(args[1]) or 0
  serialize(hacks.walk.settings,"walk")
end


commands.autowalk.setPower = function(args)
  hacks.walk.settings.power = tonumber(args[1]) or 4
  serialize(hacks.walk.settings,"walk")
end



local function cmdShell()
  local historyPos = 0
  local input = ""
  term.setTextColor(colors.blue)
  io.write("> ")
  term.setTextColor(colors.lightBlue)
  while true do
      local event, key = os.pullEvent()
      local x,y = term.getCursorPos()
      if key == keys.rightCtrl then
        print("historyPos: "..historyPos)
        print("input: "..input)
        sleep(1)
      elseif event == "key" then
        if key == keys.up then
          if not history[0] then
            history[0] = input or ""
          end
          historyPos=historyPos+1
          if history[historyPos] then
            term.setCursorPos(1,y)
            for i = 1,#input+2 do
              io.write(" ")
            end
            input = history[historyPos]
            term.setCursorPos(1,y)
            term.setTextColor(colors.blue)
            io.write("> ")
            term.setTextColor(colors.lightBlue)
            io.write(input)
          else
            historyPos = historyPos-1
          end
        elseif key == keys.down then
          historyPos=historyPos-1
          if history[historyPos] then
            term.setCursorPos(1,y)
            for i = 1,#input+2 do
              io.write(" ")
            end
            input = history[historyPos]
            term.setCursorPos(1,y)
            term.setTextColor(colors.blue)
            io.write("> ")
            term.setTextColor(colors.lightBlue)
            io.write(input)
          else
            historyPos = historyPos+1
          end

        elseif key == keys.backspace and #input > 0 then
          input = input:sub(1, -2)
          term.setCursorPos(x-1,y)
          io.write(" ")
          term.setCursorPos(x-1,y)
        elseif key == keys.enter then
          history[0] = nil
          for i = 10,1,-1 do
            history[i+1] = history[i]
          end
          history[1] = input
          serialize(history,"history")
          term.setTextColor(colors.yellow)
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
          term.setTextColor(colors.blue)
          io.write("> ")
          term.setTextColor(colors.lightBlue)
        end
      elseif event == "char" then
        input = input..key
        io.write(key)
      end
    end
end

parallel.waitForAny(hack,cmdShell)