---------------------------------------------------------------------------
-- BazMapPortals: Map Data Provider
-- Handles pin creation and coordinate projection
---------------------------------------------------------------------------

local ADDON_NAME, MP = ...

MP.Provider = CreateFromMixins(MapCanvasDataProviderMixin)

function MP.Provider:OnShow()
    self:RefreshAllData()
end

function MP.Provider:OnHide()
    if MP.pinPool then
        MP.pinPool:ReleaseAll()
    end
end

function MP.Provider:RemoveAllData()
    if MP.pinPool then
        MP.pinPool:ReleaseAll()
    end
end

function MP.Provider:GetPinPosition(city, targetMapID)
    local addon = BazCore:GetAddon(ADDON_NAME)

    -- 1. Check if user has specific overrides for this map
    local coords = addon and addon:GetSetting("coords") or {}
    local db = coords[city.city]
    if db and db[targetMapID] and db[targetMapID].x then
        return db[targetMapID].x, db[targetMapID].y
    end

    -- 2. Check for Manual Map Overrides (Global Addon Overrides)
    if MP.MAP_OVERRIDES and MP.MAP_OVERRIDES[city.city] and MP.MAP_OVERRIDES[city.city][targetMapID] then
        local data = MP.MAP_OVERRIDES[city.city][targetMapID]
        return data.x, data.y
    end

    -- 3. Try to project from the default source map
    if city.mapID and city.x and city.y then
        if city.mapID == targetMapID then
            return city.x, city.y
        end

        local continentID, worldPos = C_Map.GetWorldPosFromMapPos(city.mapID, CreateVector2D(city.x, city.y))
        if continentID and worldPos then
            local _, mapPos = C_Map.GetMapPosFromWorldPos(continentID, worldPos, targetMapID)
            if mapPos then
                local tempX, tempY = mapPos:GetXY()
                if tempX >= 0 and tempX <= 1 and tempY >= 0 and tempY <= 1 then
                    return tempX, tempY
                end
            end
        end
    end

    return nil, nil
end

function MP.Provider:RefreshAllData(fromOnShow)
    if not MP.pinPool then return end
    MP.pinPool:ReleaseAll()

    local addon = BazCore:GetAddon(ADDON_NAME)
    if not addon or addon:GetSetting("showPortals") == false then return end

    local mapID = WorldMapFrame:GetMapID()
    if not mapID then return end

    -- Update HUD
    if MP.MapIDLabel then
        MP.MapIDLabel:SetText("ID: " .. mapID)
    end

    local faction = UnitFactionGroup("player")
    for _, city in ipairs(MP.CITIES or {}) do
        if not (city.faction and city.faction ~= faction) then
            local hasTeleport = city.teleport and IsSpellKnown(city.teleport)
            local hasPortal = city.portal and IsSpellKnown(city.portal)

            if hasTeleport or hasPortal then
                local x, y = self:GetPinPosition(city, mapID)
                if x and y then
                    MP:CreatePortalPin({
                        x = x,
                        y = y,
                        teleport = city.teleport,
                        portal = city.portal,
                        city = city.city,
                    })
                end
            end
        end
    end
end
