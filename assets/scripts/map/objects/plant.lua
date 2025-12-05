local object = {}

function object:load(obj, stiMap)
    local plant = TDObjects:new(
        "assets/3D/amogus_fixed.obj",
        "assets/images/objects/fence.png",
        {obj.x, obj.y, 5},
        {0,0,0},
        1 * stiMap.tilewidth
    )
    plant.data.mode = "gui"
    return plant
end

return object