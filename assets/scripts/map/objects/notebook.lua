local object = {}
local self = object
self.notebooks = {
    "black",
    "blue",
    "cyan",
    "green",
    "red",
    "salmon",
    "yellow"
}
self.up = true
self.y = 15
self.startY = self.y
self.speedY = 0
self.timer = 0
self.reachTimer = 0.6

function object:load(obj, stiMap)
    obj.properties = obj.properties or {}
    local notebookID = obj.properties.id or "red"
    notebookID = object.notebooks[tonumber(notebookID)] or notebookID
    print(notebookID)
    local notebook = TDObjects:new(
        "assets/3D/amogus_fixed.obj",
        "assets/images/notebooks/" .. notebookID .. ".png",
        {obj.x, obj.y, self.y},
        {0,0,0},
        0.4 * stiMap.tilewidth
    )
    notebook:setMode("gui")
    self.obj = notebook
    return notebook
end

function object:update(dt)
    if self.up then
        self.speedY = self.speedY + 1 * dt
    else
        self.speedY = self.speedY - 1 * dt
    end
    self.y = self.y + self.speedY
    self.timer = self.timer + 1 * dt
    if self.timer > self.reachTimer then
        self.up = not self.up
        if self.up then
            self.y = self.startY
        end
        self.timer = 0 - self.reachTimer
    end
    
    self.obj:setPosition(nil, nil, self.y)
end

function object:onInteract(button)
    if button ~= 1 then return end
    -- print("interacted")
    notebooks:grab()
    self.obj:remove()
    object:remove()
end

return object