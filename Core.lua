---------------------------------------------------------------------------
-- BazMapPortals Core
-- BazCore integration, settings, slash commands, map hooks
---------------------------------------------------------------------------

local ADDON_NAME = "BazMapPortals"
local _, MP = ...

local addon = BazCore:RegisterAddon(ADDON_NAME, {
    title = "BazMapPortals",
    savedVariable = "BazMapPortalsDB",
    profiles = true,
    defaults = {
        showPortals = true,
        showDebug = false,
        coords = {},
    },

    slash = { "/mp", "/mapportals" },
    commands = {
        set = {
            desc = "Save current position for a city: /mp set <city>",
            handler = function(args)
                local a = BazCore:GetAddon(ADDON_NAME)
                local rest = args:trim():lower()
                if rest == "" then
                    a:Print("Usage: /mp set <city>")
                    return
                end
                local city
                for _, c in ipairs(MP.CITIES) do
                    if c.city:lower() == rest then
                        city = c
                        break
                    end
                end
                if not city then
                    a:Print("Unknown city: " .. rest)
                    return
                end
                local map = C_Map.GetBestMapForUnit("player")
                if not map then
                    a:Print("No map info available.")
                    return
                end
                local coords = a:GetSetting("coords") or {}
                coords[city.city] = coords[city.city] or {}
                local parentMaps = MP.GetPlayerParentMaps(map)
                for _, id in ipairs(parentMaps) do
                    local pos = C_Map.GetPlayerMapPosition(id, "player")
                    if pos then
                        local x, y = pos:GetXY()
                        coords[city.city][id] = { x = x, y = y }
                        a:Print(("Saved %s for map %d: %.4f %.4f"):format(city.city, id, x, y))
                    end
                end
                a:SetSetting("coords", coords)
                if MP.Provider then MP.Provider:RefreshAllData() end
            end,
        },
        clear = {
            desc = "Clear saved coords: /mp clear <city|all>",
            handler = function(args)
                local a = BazCore:GetAddon(ADDON_NAME)
                local rest = args:trim():lower()
                if rest == "all" then
                    a:SetSetting("coords", {})
                    a:Print("Cleared all saved portal locations.")
                else
                    local coords = a:GetSetting("coords") or {}
                    coords[rest] = nil
                    a:SetSetting("coords", coords)
                    a:Print("Cleared " .. rest)
                end
                if MP.Provider then MP.Provider:RefreshAllData() end
            end,
        },
        dump = {
            desc = "Print all saved portal locations",
            handler = function()
                local a = BazCore:GetAddon(ADDON_NAME)
                local coords = a:GetSetting("coords") or {}
                for city, maps in pairs(coords) do
                    print(city)
                    for id, pos in pairs(maps) do
                        print(("  %d -> %.4f, %.4f"):format(id, pos.x, pos.y))
                    end
                end
            end,
        },
        info = {
            desc = "Show current map ID and player coordinates",
            handler = function()
                local mapID = WorldMapFrame:GetMapID()
                if not mapID then
                    print("No map visible.")
                    return
                end
                local pos = C_Map.GetPlayerMapPosition(mapID, "player")
                local x, y = 0, 0
                if pos then x, y = pos:GetXY() end
                print(("|cff3399ff[BazMapPortals]|r MapID: |cffffd100%d|r"):format(mapID))
                print(("Player Coords: |cffffd100%.4f, %.4f|r"):format(x, y))
                print("Copy-Paste for Data.lua:")
                print(("|cff00ffff[%d] = { x=%.2f, y=%.2f },|r"):format(mapID, x, y))
            end,
        },
    },
    defaultHandler = function()
        BazCore:OpenOptionsPanel(ADDON_NAME)
    end,

    minimap = {
        label = "BazMapPortals",
    },

    onLoad = function(self)
        -- Migrate flat SavedVariable structure to profile format
        local sv = _G["BazMapPortalsDB"]
        if sv and sv.profiles and sv.profiles["Default"] then
            local profile = sv.profiles["Default"]
            local flatKeys = { "showPortals", "showDebug" }
            for _, key in ipairs(flatKeys) do
                if sv[key] ~= nil and profile[key] == nil then
                    profile[key] = sv[key]
                    sv[key] = nil
                end
            end
            if sv.coords and not profile.coords then
                profile.coords = sv.coords
                sv.coords = nil
            end
        end
    end,

    onReady = function(self)
        MP.addon = self
        MP.InitMapHooks()
    end,
})

---------------------------------------------------------------------------
-- Helper: Walk parent map chain
---------------------------------------------------------------------------

function MP.GetPlayerParentMaps(startMap)
    local ids, info = {}, C_Map.GetMapInfo(startMap)
    while info do
        table.insert(ids, info.mapID)
        if not info.parentMapID or info.mapType <= 2 then break end
        info = C_Map.GetMapInfo(info.parentMapID)
    end
    return ids
end

---------------------------------------------------------------------------
-- Map Tracking Dropdown + Debug HUD
---------------------------------------------------------------------------

local function IsEnabled()
    return addon:GetSetting("showPortals") ~= false
end

local function ToggleEnabled()
    addon:SetSetting("showPortals", not IsEnabled())
    if MP.Provider then MP.Provider:RefreshAllData() end
end

function MP.InitMapHooks()
    if not WorldMapFrame or not MP.Provider then
        C_Timer.After(1, MP.InitMapHooks)
        return
    end

    -- Map tracking dropdown
    if Menu and Menu.ModifyMenu then
        Menu.ModifyMenu("MENU_WORLD_MAP_TRACKING", function(owner, rootDescription, contextData)
            rootDescription:CreateDivider()
            rootDescription:CreateTitle("BazMapPortals")
            rootDescription:CreateCheckbox("Mage Portals", IsEnabled, ToggleEnabled)
        end)
    elseif WorldMapTrackingOptionsButtonMixin then
        hooksecurefunc(WorldMapTrackingOptionsButtonMixin, "GenerateMenu", function(self, dropdown, rootDescription)
            rootDescription:CreateCheckbox("Mage Portals", IsEnabled, ToggleEnabled)
        end)
    end

    -- Debug Map ID HUD
    local infoFrame = CreateFrame("Frame", nil, WorldMapFrame)
    infoFrame:SetFrameStrata("FULLSCREEN_DIALOG")
    infoFrame:SetPoint("TOPRIGHT", WorldMapFrame, "TOPRIGHT", -60, -25)
    infoFrame:SetSize(150, 20)

    local label = infoFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    label:SetPoint("RIGHT")
    label:SetTextColor(0, 1, 0, 1)
    label:SetShadowOffset(1, -1)
    label:SetShown(addon:GetSetting("showDebug") or false)
    if WorldMapFrame:GetMapID() then
        label:SetText("ID: " .. WorldMapFrame:GetMapID())
    end
    MP.MapIDLabel = label

    -- Register data provider
    WorldMapFrame:AddDataProvider(MP.Provider)

    -- Hook map change to update label
    hooksecurefunc(WorldMapFrame, "OnMapChanged", function()
        local mapID = WorldMapFrame:GetMapID()
        if MP.MapIDLabel and mapID then
            MP.MapIDLabel:SetText("ID: " .. mapID)
        end
    end)
end

---------------------------------------------------------------------------
-- Options Pages
---------------------------------------------------------------------------

local function GetLandingPage()
    return BazCore:CreateLandingPage(ADDON_NAME, {
        subtitle = "Mage portal pins on the world map",
        description = "Adds clickable portal and teleport spell icons directly to the world map for mages. " ..
            "Left-click to teleport, right-click to open a portal. " ..
            "Covers 25+ destinations across all expansions.",
        features = "Clickable spell icons on the world map for all mage teleports and portals. " ..
            "Automatic coordinate projection across map zoom levels. " ..
            "Faction-aware destination filtering. " ..
            "Custom coordinate overrides via slash commands.",
        guide = {
            { "Map Pins", "Open the world map to see portal destinations as spell icons" },
            { "Teleport", "Left-click a pin to cast the teleport spell" },
            { "Portal", "Right-click a pin to cast the portal spell" },
            { "Toggle", "Use the map tracking dropdown to show/hide portal pins" },
        },
        commands = {
            { "/mp", "Open settings" },
            { "/mp set <city>", "Save current position for a city" },
            { "/mp clear <city|all>", "Clear saved coordinates" },
            { "/mp dump", "Print all saved portal locations" },
            { "/mp info", "Show current map ID and player coordinates" },
        },
    })
end

local function GetSettingsPage()
    return {
        name = "Settings",
        type = "group",
        args = {
            intro = {
                order = 0.1,
                type = "lead",
                text = "Display options for the mage portal/teleport map pins. Pins only appear for mage characters and only for spells you know.",
            },
            displayHeader = {
                order = 1,
                type = "header",
                name = "Display",
            },
            showPortals = {
                order = 2,
                type = "toggle",
                name = "Show Portal Pins",
                desc = "Show mage portal and teleport icons on the world map",
                get = function() return addon:GetSetting("showPortals") ~= false end,
                set = function(_, val)
                    addon:SetSetting("showPortals", val)
                    if MP.Provider then MP.Provider:RefreshAllData() end
                end,
            },
            debugHeader = {
                order = 10,
                type = "header",
                name = "Debug",
            },
            showDebug = {
                order = 11,
                type = "toggle",
                name = "Show Map ID",
                desc = "Display the current map ID in the top-right corner of the world map",
                get = function() return addon:GetSetting("showDebug") or false end,
                set = function(_, val)
                    addon:SetSetting("showDebug", val)
                    if MP.MapIDLabel then
                        MP.MapIDLabel:SetShown(val)
                        if val and WorldMapFrame:GetMapID() then
                            MP.MapIDLabel:SetText("ID: " .. WorldMapFrame:GetMapID())
                        end
                    end
                end,
            },
        },
    }
end

BazCore:RegisterOptionsTable(ADDON_NAME, GetLandingPage)
BazCore:AddToSettings(ADDON_NAME, "BazMapPortals")

BazCore:RegisterOptionsTable(ADDON_NAME .. "-Settings", GetSettingsPage)
BazCore:AddToSettings(ADDON_NAME .. "-Settings", "General Settings", ADDON_NAME)
