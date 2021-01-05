local neural = peripheral.wrap("back")
local trigger = ""

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


function shoot()
  local entities = neural.sense()
  for _,entity in pairs(entities) do
    for _, target in pairs(targets) do
      if entity.name == target then
        local x, y, z = entity.x, entity.y, entity.z
        local pitch = -math.atan2(y, math.sqrt(x * x + z * z))
        local yaw = math.atan2(-x, z)
        neural.fire(math.deg(yaw),math.deg(pitch),5)
      end
    end
  end
end

while true do
  holding = neural.getEquipment().list()[1]
  if holding and holding.name == trigger or trigger == "" then
    pcall(shoot)
    sleep(0)
  end
end