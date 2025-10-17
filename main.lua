-- written by groverbuger for g3d
-- september 2021
-- MIT license

_G.g3d = require "libs/g3d"

local function setupStateManager(stsManager)
    if not stsManager then return end
    function stsManager:load(state)
        sprm:clearSprites() -- it was kind of interesting to see thing overlap over lol
        --i know lol
    end
end

_G.stateManager = require("libs/stateManager")
setupStateManager(stateManager)
_G.sprm = require("libs/sprite")
_G.json = require("libs/json")

TDObjects = require "libs/3DObject"
TDObjects:loadG3D(g3d)
SoundManager = require "libs/soundManager"
SoundManager:setFolder("sounds", "assets/sounds")
SoundManager:setFolder("music", "assets/music")

local itemslots = require "libs/itemslots"
_G.itemslot = itemslots:new()

local staminabars = require "libs/staminabar"
_G.staminabar = staminabars:new()

local notebooksManager = require "libs/notebooks"
_G.notebooks = notebooksManager:new()

_G.mapLoader = require "libs/mapLoader"

function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest")
    local font = love.graphics.newFont("assets/fonts/comic.ttf", 32)
    love.graphics.setFont(font)
    local handCursor = love.mouse.newCursor("assets/images/cursor.png", 0, 0)
    love.mouse.setCursor(handCursor)

    stateManager:loadState("level")
end

function love.update(dt)
    stateManager:update(dt)
end

function love.keypressed(key)
    stateManager:keypressed(key)
end

function love.draw()
    stateManager:draw()
    sprm:draw()
end

function love.mousemoved(x,y, dx,dy)
    stateManager:mousemoved(x,y,dx,dy)
end

function love.mousepressed(x, y, button)
    TDObjects:mousepressed(x, y, button)
    stateManager:mousepressed(x,y,button)
end