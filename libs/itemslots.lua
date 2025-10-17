local itemslots = {}
local self = itemslots
self.__index = self

self.assetsFolder = "assets"
self.itemSlotsFolder = "itemslots"
self.skin = "default"
self.slotFilenameExtension = ".png"

function self:setAssetsFolder(path)
    self.assetsFolder = path
end

-- function self:loadG3D(g3d)
--     self.g3d = g3d
-- end

local function createSlots(slots, extra)
    extra = extra or {}
    local itemSlotsFolder = extra.itemSlotsFolder or self.itemSlotsFolder
    local slotFilenameExtension = extra.slotFilenameExtension or self.slotFilenameExtension
    local skin = extra.skin or self.skin
    local resultSlots = {}

    local curimageslot = 1
    local currentX = love.graphics.getWidth()
    local currentY = 0
    local totalWidth = 0
    local leftmostX = currentX
    local imageHeight = 0

    -- Create normal slots (right to left)
    for i = 1, slots do
        local filename
        local slotSelected = false

        -- Use "slot_end" if it's the last slot or there's only one slot
        if i == slots or slots == 1 then
            filename = "slot_end"
            slotSelected = true
        else
            filename = "slot_" .. curimageslot

            -- Loop slot filenames if missing
            if not love.filesystem.getInfo(self.assetsFolder .. "/images/" .. itemSlotsFolder .. "/" .. skin .. "/" .. filename .. slotFilenameExtension) then
                curimageslot = 1
                filename = "slot_" .. curimageslot
            end
        end

        local slotimage = love.graphics.newImage(
            self.assetsFolder .. "/images/" .. itemSlotsFolder .. "/" .. skin .. "/" .. filename .. slotFilenameExtension
        )

        local imageWidth = slotimage:getWidth()
        imageHeight = slotimage:getHeight()

        -- Move X left by this slot's width
        currentX = currentX - imageWidth

        local slot = {
            id = i,
            selected = slotSelected,
            item = {},
            image = slotimage,
            x = currentX,
            y = currentY,
            r = 0
        }

        table.insert(resultSlots, slot)

        -- Track total width and leftmost X for the handle images
        totalWidth = totalWidth + imageWidth
        leftmostX = math.min(leftmostX, currentX)

        curimageslot = curimageslot + 1
    end

    local handleWidth

    -- Add slot_handle_end (to the left of the leftmost slot)
    local handleEndPath = self.assetsFolder .. "/images/" .. itemSlotsFolder .. "/" .. skin .. "/slot_handle_end" .. slotFilenameExtension
    if love.filesystem.getInfo(handleEndPath) then
        local handleImage = love.graphics.newImage(handleEndPath)
        handleWidth = handleImage:getWidth()
        local handleHeight = handleImage:getHeight()

        local slot = {
            id = "handle_end",
            image = handleImage,
            x = leftmostX - handleWidth,
            y = currentY,
            r = 0
        }

        table.insert(resultSlots, slot)
        totalWidth = totalWidth + handleWidth
        leftmostX = slot.x
    end

    -- Add slot_handle_bottom (under all slots)
    local handleBottomPath = self.assetsFolder .. "/images/" .. itemSlotsFolder .. "/" .. skin .. "/slot_handle_bottom" .. slotFilenameExtension
    if love.filesystem.getInfo(handleBottomPath) then
        local bottomImage = love.graphics.newImage(handleBottomPath)
        local bottomHeight = bottomImage:getHeight()

        local slot = {
            id = "handle_bottom",
            image = bottomImage,
            x = currentX,
            y = currentY + imageHeight,
            sx = totalWidth / bottomImage:getWidth(), -- scale horizontally to fit all slots
            sy = 1,
            r = 0,
            scale = true
        }

        table.insert(resultSlots, slot)
    end

    self.itemtext = {
        text = "None",
        x = leftmostX + 4,
        y = currentY + imageHeight + 16,
        r = 0,
        sx = 1,
        sy = 1
    }

    return resultSlots
end

function self:new(extra)
    extra = extra or {}
    local slotsCount = extra.slots or 3
    local slotsInv = createSlots(slotsCount, extra)

    local invSlots = setmetatable({
        slots = slotsInv
    }, self)

    return invSlots
end

function self:draw()
    if self.slots then
        for _, slot in ipairs(self.slots) do
            if slot.scale then
                love.graphics.draw(slot.image, slot.x, slot.y, slot.r, slot.sx, slot.sy)
            else
                local img = slot.image
                local x, y, r = slot.x, slot.y, slot.r

                -- If this slot is selected, draw a red background first
                if slot.selected then
                    love.graphics.setColor(1, 0, 0, 1) -- red with 40% opacity
                    love.graphics.rectangle("fill", x, y, img:getWidth(), img:getHeight())
                    love.graphics.setColor(1, 1, 1, 1) -- reset color
                end

                -- Draw the slot image (normal rendering)
                love.graphics.draw(img, x, y, r)
            end
        end
    end
    local itemtext = self.itemtext
    if itemtext then
        local slot = self:getSelectedSlot()
        slot = slot or {}
        slot.item = slot.item or {}
        itemtext.text = slot.item.name or "None"

        love.graphics.setColor(0,0,0,1)
        love.graphics.print(itemtext.text, itemtext.x, itemtext.y, itemtext.r, itemtext.sx, itemtext.sy)
        love.graphics.setColor(1,1,1,1)
    end
end

function self:getSlot(key)
    local keys = {"1","2","3","4","5","6","7","8","9"}
    if self.slots then
        if type(key) == "number" then
            return self.slots[key]
        end
        -- Match key to slot (right-to-left order)
        for i, num in ipairs(keys) do
            if key and key == num then
                local index = #self.slots - i - 1 -- reverse order
                local slot = self.slots[index]
                if slot and type(slot.id) == "number" then
                    return slot
                end
            elseif key == nil then
                local index = #self.slots - i - 1 -- reverse order
                local slot = self.slots[index]
                if slot and type(slot.id) == "number" and slot.selected then
                    return slot
                end
            end
        end
    end
end

function self:getSelectedSlot()
    return self:getSlot()
end

function self:resetSelected()
    if not self.slots then return end
    -- Unselect all
    for _, slot in ipairs(self.slots) do
        if not slot.scale then
            slot.selected = false
        end
    end
end

function self:keypressed(key)
    local slot = self:getSlot(key)
    if slot then
        print("SLOT" .. slot.id)
        self:resetSelected()
        slot.selected = true
    end
end

return self
