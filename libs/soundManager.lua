local soundManager = {}
soundManager.sounds = {}
soundManager.folders = {}

function soundManager:setFolder(folder, path)
    self.folders[folder] = path
end

function soundManager:playSound(id, ext)
    if ext then
        ext = "." .. ext
    else
        ext = ".ogg"
    end
    self.sounds["sounds"] = self.sounds["sounds"] or {}

    local path = self.folders["sounds"] .. "/" .. id .. ext
    local sound = self.sounds["sounds"][id] or love.audio.newSource(path, "stream")
    sound:play()

    if not self.sounds["sounds"][id] then
        self.sounds["sounds"][id] = sound
    end
end

function soundManager:stopAllSounds()
    for _, sound in pairs(self.sounds["sounds"]) do
        sound:stop()
    end
end

function soundManager:playMusic(id, ext)
    if ext then
        ext = "." .. ext
    else
        ext = ".ogg"
    end
    self.sounds["music"] = self.sounds["music"] or {}
    local path = self.folders["music"] .. "/" .. id .. ext

    local sound = self.sounds["music"][id] or love.audio.newSource(path, "static")
    sound:setLooping(true)
    sound:play()

    if not self.sounds["music"][id] then
        self.sounds["music"][id] = sound
    end
end

function soundManager:stopAllMusics()
    for _, music in pairs(self.sounds["music"]) do
        music:stop()
    end
end

function soundManager:stopAll()
    for _, soundsTable in pairs(self.sounds) do
        for _, sound in pairs(soundsTable) do
            sound:stop()
        end
    end
end

return soundManager