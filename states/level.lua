local state = {}
local self = state
self.debug = true

local earth = TDObjects:new("assets/3D/sphere.obj", "assets/3D/earth.png", {4,0,0})
earth.data.mode = "gui"
local amogus = TDObjects:new("assets/3D/amogus_fixed.obj", "assets/3D/amogus.png", {4,5,0})
amogus.data.mode = "gui"
local background = TDObjects:new("assets/3D/sky_fixed.obj", "assets/3D/sky.png", nil, nil, 500)
local moon = TDObjects:new("assets/3D/sphere.obj", "assets/3D/moon.png", {4,5,0}, nil, 0.5)
-- mapLoader:newMap("school","schoolhouse")
-- mapLoader:newMap("test","testplace")

local function updateSkybox()
    local camPos = {}
    camPos[1] = g3d.camera.position[1]
    camPos[2] = g3d.camera.position[2]
    camPos[3] = g3d.camera.position[3]
    camPos[2] = camPos[2] - 300
    background.collider:setTranslation(camPos[1],camPos[2],camPos[3])
end

local timer = 0
-- local cameraHUDRot = {}

function self:load()
    SoundManager:stopAll()
    mapLoader:loadMap("testplace")
    -- mapLoader:loadMap("test")
    SoundManager:playMusic("school", "wav")
    g3d.camera.firstPersonLook(0,0)
end

function self:keypressed(key)
    itemslot:keypressed(key)
    if key == "escape" then
        mapLoader:clearMapObjects()
        SoundManager:stopAll()
        stateManager:loadState("warning")
    end
end

function self:mousemoved(x,y,dx,dy)
    dy = 0
    g3d.camera.firstPersonLook(dx,dy)
end

function self:mousepressed(x, y, button)
    g3d.camera.firstPersonLook(0,0)
    mapLoader:mousepressed(x, y, button)
end

function self:regainStamina(dt, staminabar, tireness, moving)
    if staminabar.stamina < staminabar.maxstamina and not moving then
        staminabar.stamina = staminabar.stamina + tireness * dt
    end
end

function self:update(dt)
    mapLoader:update(dt)
    amogus:update(dt)
    earth:update(dt)
    moon:update(dt)
    cameraHUDRot = amogus.data.r
    timer = timer + dt
    moon.collider:setTranslation(math.cos(timer)*5 + 4, math.sin(timer)*5, 0)
    -- moon.collider:setRotation(0, 0, timer - math.pi/2)
    -- amogus.collider:setTranslation(math.cos(timer)*5 + 4, math.sin(timer)*5, 0)
    g3d.camera.firstPersonMovement(dt)
    updateSkybox()

    local tireness = 12
    local running = love.keyboard.isDown("lshift")
    local moving = g3d.camera.moving
    local speeds = {
        walk = 4,
        run = 9
    }
    if self.debug then
        for k,v in pairs(speeds) do
            speeds[k] = v * 10
        end
    end

    self:regainStamina(dt, staminabar, tireness, moving)
    if not running then
        if staminabar.stamina < staminabar.maxstamina and not moving then
            g3d.camera.speed = speeds.walk
        else
            g3d.camera.speed = speeds.walk
        end
    else
        if staminabar.stamina > 0 and moving then
            staminabar.stamina = staminabar.stamina - tireness * dt
            g3d.camera.speed = speeds.run
        else
            g3d.camera.speed = speeds.walk
        end
    end
end

function self:draw()
    mapLoader:draw()

    earth:draw()
    amogus:draw()
    earth:draw()
    moon:draw()
    --background:draw()
    
    itemslot:draw()
    staminabar:draw()
    notebooks:draw()
   
    -- love.graphics.print("rotation x: " .. cameraHUDRot[1] .. "\nrotation y: " .. cameraHUDRot[2] .. "\nrotation z: " .. cameraHUDRot[3])
end

return self