local object = {}

function object:load(obj, stiMap)
    local exitDoor = TDObjects:new(
        "assets/3D/amogus_fixed.obj",
        "assets/images/exits/exit_1.png",
        {obj.x, obj.y, 5},
        {0,0,0},
        1 * stiMap.tilewidth
    )
    exitDoor.data.mode = "gui"
    return exitDoor
end

return object