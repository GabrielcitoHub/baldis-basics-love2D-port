local notebooks = {}
local self = notebooks
self.__index = self

self.assetsFolder = "assets"
self.notebooksFolder = "staminabar"
self.skin = "default"
self.notebooksFilenameExtension = ".png"

function self:setAssetsFolder(path)
    self.assetsFolder = path
end

function self:new(extra)
    extra = extra or {}
    self.maxnotebooks = extra.max or 7
    self.notebooks = extra.amount or 0
    self.obj = {
        notebooks = self:get(),
        maxnotebooks = self:getMax(),
        text = "test"
    }

    local notebooksObj = setmetatable({}, self)

    return notebooksObj
end

function self:draw()
    local notebookstext = self.obj
    if notebookstext then
        local text = "Notebooks " .. self:get() .. "/" .. self:getMax()

        love.graphics.setColor(0,0,0,1)
        love.graphics.print(text)
        love.graphics.setColor(1,1,1,1)
    end
end

-- Utils

function self:getMax()
    return self.maxnotebooks
end

function self:get()
    return self.notebooks
end

function self:getLeft()
    return self.maxnotebooks - self.notebooks
end

function self:reset()
    self.notebooks = 0
end

function self:grab(noteboos)
    noteboos = noteboos or 1
    self.notebooks = self.notebooks + noteboos
end

function self:add(notebooks)
    self:grab(notebooks)
end

return self