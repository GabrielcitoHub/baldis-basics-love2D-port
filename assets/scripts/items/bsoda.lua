local item = {}
item.name = "Bsoda"

function item:used()
    TDObjects:spawnProjectile("bsoda")
    item:remove()
end

return item