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

function self:newMap(id, mapid)
    id = id or ("world" .. (#self.maps + 1))
    mapid = mapid or id
    local map = {
        id = id,
        sti = nil,      -- the STI map instance
        mapid = mapid,
        walls = {},
        floors = {},
        objects = {}
    }
    self.maps[id] = map
    return map
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
        print(layer.type .. " / ".. layer.name)
        if layer.type == "tilelayer" then
            -- Example: use layer names to decide what to spawn
            if layer.name == "Floor" then
                for y = 1, layer.height do
                    for x = 1, layer.width do
                        local tile = layer.data[y][x]
                        if tile and tile.id ~= 0 then
                            -- Convert tile grid coordinates into world space
                            local wx = (x - 1) * stiMap.tilewidth
                            local wy = (y - 1) * stiMap.tileheight
                            print("tile position = " .. wx .. "," .. wy)

                            -- Create your 3D floor object
                            local floor = TDObjects:new(
                                "assets/3D/amogus_fixed.obj",                -- model
                                "assets/images/floors/floor.png",            -- texture
                                {wx, 0, wy},                                  -- world position (x = east-west, y = height, z = north-south)
                                {0,0,0},
                                1 * stiMap.tilewidth
                            )
                            floor.data.mode = "gui"

                            -- Store for later drawing/updating
                            table.insert(map.floors, floor)
                        end
                    end
                end
            elseif layer.name == "Walls" then
                for y = 1, layer.height do
                    for x = 1, layer.width do
                        local tile = layer.data[y][x]
                        if tile and tile.id ~= 0 then
                            local wx = (x - 1) * stiMap.tilewidth
                            local wy = (y - 1) * stiMap.tileheight
                            print("tile position = " .. wx .. "," .. wy)

                            -- Create a wall object (facing forward for now)
                            local wall = TDObjects:new(
                                "assets/3D/amogus_fixed.obj",
                                "assets/images/walls/wall.png",
                                {wx, 0, wy},
                                {45,0,0},
                                1 * stiMap.tilewidth
                            )

                            wall.data.mode = "gui"

                            table.insert(map.walls, wall)
                        end
                    end
                end
            end
        elseif layer.type == "objectgroup" then
            for _, obj in ipairs(layer.objects) do
                if obj.name == "spawn" then
                    g3d.camera.position[1] = obj.x
                    g3d.camera.position[3] = obj.y
                end
                table.insert(map.objects, {
                    name = obj.name,
                    x = obj.x,
                    y = obj.y,
                    width = obj.width,
                    height = obj.height,
                    properties = obj.properties or {}
                })
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

function self:update(dt)
    self:forLoadedMaps(function(map)
        if map.sti then
            map.sti:update(dt)
        end
        if map.objects then
            for _, obj in pairs(map.objects) do
                if obj.update then
                    obj:update(dt)
                end
            end
        end
    end)
end

function self:draw()
    self:forLoadedMaps(function(map)
        -- Optional: draw STI background
        if map.sti then
            map.sti:draw()
        end

        -- Draw floors/walls if you’re using 3D models instead of STI tiles
        if map.floors then
            for _, floor in pairs(map.floors) do
                if floor.draw then
                    floor:draw()
                end
            end
        end

        if map.walls then
            for _, wall in pairs(map.walls) do
                if wall.draw then
                    wall:draw()
                end
            end
        end
    end)
end

return self