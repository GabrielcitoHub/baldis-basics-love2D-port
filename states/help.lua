local state = {}
local self = state

function self:load()
    sprm:makeLuaSprite("help", "help", 0, 0)
end

function self:keypressed(key)
    if key == "escape" or key == "backspace" then
        stateManager:loadState("menu")
    end
end

return self