local neural = peripheral.wrap("back")
local canvas = neural.canvas3d()
local trigger = "minecraft:wooden_pickaxe"

local args = {...}
if #args>0 then
  targets = args
else
  targets = {
    "Zombie",
    "Creeper",
    "Spider",
    "Enderman",
    "Skeleton",
    "Evoker",
    "Vindicator",
    "Pillager",
    "Ravager",
    "Vex",
    "Guardian",
    "Endermite",
    "Shulker",
    "Husk",
    "Stray",
    "Blaze",
    "Ghast",
    "Slime",
    "Silverfish",
    "Wither",
    "Wither Skeleton",
    "Enderdragon"
  }
end
print("Targeting em")

function trace(entity)
  coords = {entity.x,entity.y,entity.z}
  canvas.create().addLine({0,0,0},coords).setScale(3)
end

function shoot()
  local entities = neural.sense()
  for _,entity in pairs(entities) do
    for _, target in pairs(targets) do
      if entity.name == target then
        trace(entity)
        local x, y, z = entity.x, entity.y, entity.z
        local pitch = -math.atan2(y, math.sqrt(x * x + z * z))
        local yaw = math.atan2(-x, z)
        neural.fire(math.deg(yaw),math.deg(pitch),5)
      end
    end
    canvas.clear()
  end
end

while true do
  holding = ni.getEquipment().list()[1]
  if holding and holding.name == trigger then
    pcall(shoot)
  end
end