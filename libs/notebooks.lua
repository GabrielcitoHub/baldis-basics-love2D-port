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
    self.maxnotebooks = extra.maxnotebooks or 7
    self.notebooks = extra.notebooks or 0
    self.notebooksObj = {
        notebooks = self:getNotebooks(),
        maxnotebooks = self:getMaxNotebooks(),
        text = "test"
    }

    local notebooksObj = setmetatable({}, self)

    return notebooksObj
end

function self:draw()
    local notebookstext = self.notebooksObj
    if notebookstext then
        local text = "Notebooks " .. self.notebooks .. "/" .. self.maxnotebooks

        love.graphics.setColor(0,0,0,1)
        love.graphics.print(text)
        love.graphics.setColor(1,1,1,1)
    end
end

-- Utils

function self:getMaxNotebooks()
    return self.maxnotebooks
end

function self:getNotebooks()
    return self.notebooks
end

function self:getNotebooksLeft()
    return self.maxnotebooks - self.notebooks
end

function self:resetNotebooks()
    self.notebooks = 0
end

return self