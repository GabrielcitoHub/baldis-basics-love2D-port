local sti = require("libs/sti")

local mapLoader = {}
local self = mapLoader
self.maps = {}
self.loadedMaps = {}
self.mapsFolder = "maps"

-- 💡 Helper: full map path
local function getMapPath(id)
    return self.mapsFolder .. "/" .. id .. ".lua"
end

function table.find(tbl, val)
    for _, v in ipairs(tbl) do
        if v == val then
            return true
        end
    end
    return false
end

-- =========================================================
-- Map retrieval and creation
-- =========================================================

function self:getMapByID(id)
    return self.maps[id]
end

function self:getDefaultMapID()
    return self.defaultMap.id
end

function self:clearMapObjects(id)
    if not id then id = self:getDefaultMapID() end
    local map = self:getMapByID(id)
    if not map then return end
    for i,_ in pairs(map.floors) do
        map.floors[i]:remove()
    end
    for i,_ in pairs(map.walls) do
        map.walls[i]:remove()
    end
    for i,_ in pairs(map.cellings) do
        map.cellings[i]:remove()
    end
    for i,_ in pairs(map.objects) do
        map.objects[i]:remove()
    end
    for i,_ in pairs(map.sObjects) do
        map.sObjects[i] = nil
    end
end

function self:newMap(id, mapid)
    id = id or ("world" .. (#self.maps + 1))
    local map = self:getMapByID(id)
    if map then
        self:clearMapObjects(map)
    end
    mapid = mapid or id
    local map = {
        id = id,
        sti = nil,      -- the STI map instance
        mapid = mapid,
        walls = {},
        floors = {},
        cellings = {},
        objects = {},
        sObjects = {}
    }
    self.defaultMap = map
    self.maps[id] = map
    
    return map
end

function self:getWallRotation(layer, x, y)
    local directions = {
        {dx = 0, dy = -1, rot = 0},            -- North
        {dx = 0, dy = 1,  rot = 5},      -- South
        {dx = -1, dy = 0, rot = 10},   -- West
        {dx = 1,  dy = 0, rot = 15},    -- East
    }

    local MAX_LOOKUP = 5 -- how far to search for air

    -- Find nearest air direction
    local bestDir = nil
    for _, dir in ipairs(directions) do
        for step = 1, MAX_LOOKUP do
            local nx = x + dir.dx * step
            local ny = y + dir.dy * step

            if nx < 1 or nx > layer.width or ny < 1 or ny > layer.height then
                break
            end

            -- print(step .. " ny: " .. ny .. " nx: " .. nx)
            local neighbor = layer.data[ny][nx]
            if not neighbor or neighbor.id < 0 then
                bestDir = dir
                -- print("bestDir = dx: " .. bestDir.dx .. " dy: " .. bestDir.dy .. " rot: " .. bestDir.rot)
                break
            end
        end
        if bestDir then break end
    end

    bestDir = bestDir or directions[1] -- fallback
    return bestDir
end

-- =========================================================
-- Load map via STI
-- =========================================================
function self:loadMap(id)
    local map = self:getMapByID(id)

    -- If the map doesn’t exist, try to create and load from file
    if not map then
        map = self:newMap(id)
    end

    local stiMap = sti(self.mapsFolder .. "/" .. map.mapid .. ".lua")

    -- Parse tile data into floors/walls/etc.
    for _, layer in ipairs(stiMap.layers) do
        -- print(layer.type .. " / ".. layer.name)
        if layer.type == "tilelayer" then
            -- Example: use layer names to decide what to spawn
            if layer.name == "Floor" then
                for y = 1, layer.height do
                    for x = 1, layer.width do
                        local tile = layer.data[y][x]
                        if tile and tile.id then
                            -- Convert tile grid coordinates into world space
                            local wx = (x - 1) * stiMap.tilewidth
                            local wy = (y - 1) * stiMap.tileheight

                            -- Create your 3D floor object
                            local floor = TDObjects:new(
                                "assets/3D/amogus_fixed.obj",                -- model
                                "assets/images/floors/floor.png",            -- texture
                                {wx, wy, 0},                                  -- world position (x = east-west, y = height, z = north-south)
                                {0,0,0},
                                1 * stiMap.tilewidth
                            )
                            floor.collider:compress()

                            -- Store for later drawing/updating
                            table.insert(map.floors, floor)
                        end
                    end
                end
            elseif layer.name == "Walls" then
                for y = 1, layer.height do
                    for x = 1, layer.width do
                        local tile = layer.data[y][x]
                        if tile and tile.id then
                            local wx = (x - 1) * stiMap.tilewidth
                            local wy = (y - 1) * stiMap.tileheight
                            -- print(x .. " " .. wx)
                            -- print(y .. " " .. wy)

                            local bestDir = self:getWallRotation(layer, x, y)

                            -- Spawn the wall with correct rotation
                            local wall = TDObjects:new(
                                "assets/3D/amogus_fixed.obj",
                                "assets/images/walls/wall.png",
                                {wx, wy, 0},       -- position
                                {0, bestDir.rot, 0},         -- any extra args you need
                                1 * stiMap.tilewidth
                            )
                            wall.collider:compress()

                            table.insert(map.walls, wall)
                        end
                    end
                end
            elseif layer.name == "Ceilling" then
                for y = 1, layer.height do
                    for x = 1, layer.width do
                        local tile = layer.data[y][x]
                        if tile and tile.id then
                            local wx = (x - 1) * stiMap.tilewidth
                            local wy = (y - 1) * stiMap.tileheight

                            -- Create a wall object (facing forward for now)
                            local celling = TDObjects:new(
                                "assets/3D/amogus_fixed.obj",
                                "assets/images/ceilings/ceiling.png",
                                {wx, wy, 30},
                                {0,0,0},
                                1 * stiMap.tilewidth
                            )
                            celling.collider:compress()

                            table.insert(map.cellings, celling)
                        end
                    end
                end
            end
        elseif layer.type == "objectgroup" then
            for i, obj in ipairs(layer.objects) do
                local rObjN = obj.name
                local sPath = "assets/scripts/map/objects/" .. rObjN
                package.loaded[sPath] = nil
                local sObj = require(sPath)
                function sObj:remove()
                    map.sObjects[i] = nil
                end
                table.insert(map.sObjects, sObj)
                local object = sObj:load(obj, stiMap)
                if object then
                    table.insert(map.objects, object)
                end
            end
        end
    end

    self.maps[id] = map

    -- Add to loaded list
    if map and not table.find(self.loadedMaps, map) then
        table.insert(self.loadedMaps, map)
    end
end

-- =========================================================
-- Iterators and updating/drawing
-- =========================================================
function self:forLoadedMaps(func)
    for index, map in ipairs(self.loadedMaps) do
        map.index = index
        func(map)
    end
end

function self:forTable(table, func)
    if table then
        for _,value in pairs(table) do
            func(value)
        end
    end
end

function self:mousepressed(x, y, button)
    self:forLoadedMaps(function(map)
        -- Trigger object script functions
        self:forTable(map.sObjects, function(obj)
            if obj.mousepressed then
                obj:mousepressed(x, y, button)
            end
            if obj.onInteract then
                obj:onInteract(button)
            end
        end)
    end)
end

function self:update(dt)
    self:forLoadedMaps(function(map)
        -- Update object models
        self:forTable(map.objects, function(obj)
            obj:update(dt)
        end)
        -- Update object script
        self:forTable(map.sObjects, function(obj)
            if obj.update then
                obj:update(dt)
            end
        end)
    end)
end

local function isInFrontOfCamera(obj)
    if not obj then return end
    if not obj.data then return end
    local camera = g3d.camera
    local camX = camera.position[1]
    local camY = camera.position[2]
    local camZ = camera.position[3]

    local dirX = camera.target[1] - camX
    local dirY = camera.target[2] - camY
    local dirZ = camera.target[3] - camZ

    -- normalize forward vector? not required for just sign check

    obj.x = obj.data.position[1]
    obj.z = obj.data.position[3]

    local toObjX = obj.x - camX
    local toObjZ = obj.z - camZ  -- ignoring Y height

    -- 2D dot product
    local dot = (dirX * toObjX) + (dirZ * toObjZ)

    return true or dot > 0
end

function self:draw()
    self:forLoadedMaps(function(map)
        local camera = g3d.camera
        local maxDist = camera.farClip * camera.farClip

        -- Draw floors/walls if you’re using 3D models instead of STI tiles
        local camera = {
            x = g3d.camera.position[1],
            z = g3d.camera.position[3]
        }
        -- Draw floors
        self:forTable(map.floors, function(floor)
            if isInFrontOfCamera(floor) then
                local dx = floor.data.position[1] - camera.x
                local dz = floor.data.position[3] - camera.z
                local distSq = dx*dx + dz*dz

                if distSq < maxDist then
                    floor:draw()
                end
            end
        end)
        -- Draw walls
        self:forTable(map.walls, function(wall)
            if isInFrontOfCamera(wall) then
                local dx = wall.data.position[1] - camera.x
                local dz = wall.data.position[3] - camera.z
                local distSq = dx*dx + dz*dz

                if distSq < maxDist then
                    wall:draw()
                end
            end
        end)
        -- Draw ceilling
        self:forTable(map.cellings, function(celling)
            if isInFrontOfCamera(celling) then
                local dx = celling.data.position[1] - camera.x
                local dz = celling.data.position[3] - camera.z
                local distSq = dx*dx + dz*dz

                if distSq < maxDist then
                    celling:draw()
                end
            end
        end)
        -- Draw objects
        self:forTable(map.objects, function(obj)
            obj:draw()
        end)
    end)
end

return self