local object = {}

function object:load(obj, stiMap)
    local table = TDObjects:new(
        "assets/3D/amogus_fixed.obj",
        "assets/images/walls/window.png",
        {obj.x, obj.y, 5},
        {0,0,0},
        1 * stiMap.tilewidth
    )
    table.data.mode = "gui"
    return table
end

return object