ni = peripheral.wrap("back")
 
while true do
  owner = ni.getMetaOwner()
  if owner.isSneaking then
    yaw,pitch = owner.yaw,owner.pitch
    ni.launch(yaw,pitch,4)
  end
  sleep(0.5)
end