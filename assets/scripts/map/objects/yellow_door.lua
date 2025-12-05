local object = {}

function object:load(obj, stiMap)
    local yellowDoor = TDObjects:new(
        "assets/3D/amogus_fixed.obj",
        "assets/images/objects/wood.png",
        {obj.x, obj.y, 5},
        {0,0,0},
        1 * stiMap.tilewidth
    )
    yellowDoor.data.mode = "gui"
    return yellowDoor
end

return object