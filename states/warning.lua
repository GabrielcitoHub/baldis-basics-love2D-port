local state = {}
local self = state
self.gotoState = "menu"

local function continue()
    SoundManager:playSound("baldi/Welcome to Baldi's Basics in Education and Learning! That's me!", "wav")
    SoundManager:playSound("baldi_menu_intro")
    _G.skip_intro = true
    stateManager:loadState(self.gotoState)
end

function self:load()
    if skip_intro then
        continue()
        return
    end
    sprm:makeLuaSprite("warning", "warning", 0, 0)
end

function self:keypressed(key)
    continue()
end

function self:mousepressed(x,y,button)
    continue()
end

return self