local object = {}

function object:load(obj)
    g3d.camera.position[1] = obj.x
    g3d.camera.position[2] = obj.y
    g3d.camera.position[3] = 10
end

return object