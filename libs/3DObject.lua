local object = {}
local self = object
self.__index = self

function self:loadG3D(g3d)
    self.g3d = g3d
end

function self:new(mesh, texture, translation, rotation, scale)
    -- print(mesh)
    -- print(texture)
    translation = translation or {}
    rotation = rotation or {}
    scale = scale or nil
    assert(self.g3d, "No 3D Renderer loaded! Call Object:loadG3D(g3d) first.")
    local properties = {
        position = {translation[1] or 0, translation[2] or 0, translation[3] or 0},
        r = {rotation[1] or 0, rotation[2] or 0, rotation[3] or 0},
        s = {scale or 1, scale or 1, scale or 1},
        mode = "normal"
    }
    local collider = self.g3d.newModel(mesh, texture, properties.position, properties.r, properties.s)
    local object = setmetatable({
        collider = collider,
        data = properties
    }, self)

    return object
end

function self:remove()
    self.collider = nil
    self.data = nil
    self = nil
end

local function lookAtRotation(from, to)
    -- Returns rotation as {pitch, yaw, roll} so "from" faces "to"
    local dx = to[1] - from[1]
    local dy = to[2] - from[2]
    local dz = to[3] - from[3]

    -- Yaw: rotation around vertical axis (Y); atan2(dx, dz) gives angle in XZ plane
    local yaw = math.atan2(dx, dz)
    -- Distance horizontally (in XZ plane)
    local dist = math.sqrt(dx * dx + dz * dz)
    -- Pitch: rotation up/down: negative so that +pitch looks upward
    local pitch = -math.atan2(dy, dist)

    local roll = 0

    return {pitch, yaw, roll}
end

function self:update(dt)
    if not self.data then return end
    local pos = self.data.position
    local cameraPos = self.g3d.camera.position
    local scale = self.data.s
    local mode = string.lower(self.data.mode or "")

    if mode == "gui" or mode == "hud" then
        self.data.r = lookAtRotation(pos, cameraPos)
    end

    if not self.collider then return end
    self.collider:setTransform(pos, self.data.r, scale)
end

function self:mousepressed(x, y, button)
end

function self:draw()
    if not self.collider then return end
    self.collider:draw()
end

-- Utils
function self:setMode(mode)
    self.data.mode = mode
end

function self:setPosition(x, y, z)
    if not self.data then return end
    if x then
        self.data.position[1] = x
    end
    if y then
        self.data.position[2] = y
    end
    if z then
        self.data.position[3] = z
    end
end

return self