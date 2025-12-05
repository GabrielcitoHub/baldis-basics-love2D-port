local item = {}
item.name = "Zesty Bar"

function item:used()
    -- stamina:set(200)
    item:remove()
end

return item