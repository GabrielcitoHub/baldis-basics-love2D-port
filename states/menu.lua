local state = {}
local self = state

local function continue()
    stateManager:loadState("level")
end

function self:load()
    sprm:makeLuaSprite("title_screen", "title_screen", 0, 0)
    love.mouse.setRelativeMode(false)
end

function self:keypressed(key)
    if key == "p" or key == "return" then
        continue()
    elseif key == "h" then
        stateManager:loadState("help")
    elseif key == "escape" then
        love.event.push "quit"
    end
end

function self:mousepressed(x,y,button)
    continue()
end

return self