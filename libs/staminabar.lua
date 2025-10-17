local staminaBar = {}
local self = staminaBar
self.__index = self

self.assetsFolder = "assets"
self.staminabarFolder = "staminabar"
self.skin = "default"
self.staminabarFilenameExtension = ".png"

function self:setAssetsFolder(path)
    self.assetsFolder = path
end

function self:new(extra)
    extra = extra or {}
    self.maxstamina = extra.maxstamina or 100
    self.stamina = extra.stamina or 100
    self.staminabar = {
        stamina = self:getStamina(),
        maxstamina = self:getMaxStamina(),
        sprites = {
            back = love.graphics.newImage(
                self.assetsFolder .. "/images/" .. self.staminabarFolder .. "/" .. self.skin .. "/" .. "back" .. self.staminabarFilenameExtension
            ),
            front = love.graphics.newImage(
                self.assetsFolder .. "/images/" .. self.staminabarFolder .. "/" .. self.skin .. "/" .. "front" .. self.staminabarFilenameExtension
            )
        }
    }

    local staminaBar = setmetatable({}, self)

    return staminaBar
end

function self:draw()
    local scale = 3
    local offset = 8 * scale
    local back, front = self.staminabar.sprites.back, self.staminabar.sprites.front
    local width, height = back:getDimensions()

    local x = offset / 4
    local y = love.graphics.getHeight() - back:getHeight() * scale - offset

    -- Draw background (full width)
    love.graphics.draw(back, x, y, 0, scale, scale)

    -- Calculate visible width for front bar
    local barWidth = (self.stamina / self.maxstamina) * width
    if barWidth < 0 then barWidth = 0 end
    if barWidth > width then barWidth = width end

    -- Create a quad for the visible portion
    local quad = love.graphics.newQuad(0, 0, barWidth, height, width, height)

    -- Draw the front bar using the quad (only shows the part corresponding to stamina)
    love.graphics.draw(front, quad, x, y, 0, scale, scale)
end

-- Utils

function self:getStamina()
    return self.stamina
end

function self:getMaxStamina()
    return self.maxstamina
end

function self:resetStamina()
    self.stamina = self.maxstamina
end

return self