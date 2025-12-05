local projectile = {}

function projectile:spawned()
    SoundManager:playSound("soda_spray")
end

return projectile