local ni = peripheral.wrap("back")
local trigger = "minecraft:wooden_pickaxe"
local targets = {...}

function table_invert(t)
   local s={}
   for k,v in pairs(t) do
     s[v]=k
   end
   return s
end

targets = table_invert(targets)

while true do
  holding = ni.getEquipment().list()[1]
  if holding and holding.name == trigger or trigger == "" then
  	local yaw,pitch
  	if #targets>0 then

  		local blocks = ni.scan()
  		local stop = false

  		for _,block in pairs(blocks) do
  			if targets(block.name) then
  				local x, y, z = block.x, block.y, block.z
				yaw = math.deg(math.atan2(-x, z))
				pitch = math.deg(-math.atan2(y, math.sqrt(x * x + z * z)))
				stop = true
				break
  			end
  		end
  	else
    	owner = ni.getMetaOwner()
    	yaw,pitch = owner.yaw,owner.pitch
    end
    if yaw and pitch then
    	ni.fire(yaw,pitch,3)
    end
  end
end