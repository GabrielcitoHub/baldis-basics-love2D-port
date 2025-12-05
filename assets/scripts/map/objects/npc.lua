local object = {}

function object:load(obj, stiMap)
    local npc = TDObjects:new(
        "assets/3D/amogus_fixed.obj",
        "assets/images/characters/NULL.png",
        {obj.x, obj.y, 5},
        {0,0,0},
        1 * stiMap.tilewidth
    )
    npc.data.mode = "gui"
    return npc
end

return object