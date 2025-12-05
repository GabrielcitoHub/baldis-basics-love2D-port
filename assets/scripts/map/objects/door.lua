local object = {}

function object:load(obj, stiMap)
    local door = TDObjects:new(
        "assets/3D/amogus_fixed.obj",
        "assets/images/objects/locker.png",
        {obj.x, obj.y, 5},
        {0,5,0},
        (1 * stiMap.tilewidth)
    )
    -- door.data.mode = "gui"
    return door
end

return object