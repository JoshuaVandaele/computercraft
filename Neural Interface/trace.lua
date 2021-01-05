
local canvas = neural.canvas3d()
function trace(entity)
  coords = {entity.x,entity.y,entity.z}
  canvas.create().addLine({0,0,0},coords).setScale(3)
end
        trace(entity)
    canvas.clear()