--[[
    Baz Map Portals
    Copyright (C) 2025 Baz4k

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.
]]

local ADDON_NAME, MP = ...

------------------------------------------------------------
-- Safe helper for spell icon lookup
------------------------------------------------------------
local function GetSpellIcon(spellID)
    if not spellID then return 134400 end -- generic portal icon
    local info = C_Spell.GetSpellInfo(spellID)
    if info and info.iconID then
        return info.iconID
    end
    return 134400
end

local function GetSpellName(spellID)
    if not spellID then return nil end
    local info = C_Spell.GetSpellInfo(spellID)
    if info and info.name then
        return info.name
    end
    return nil
end

------------------------------------------------------------
-- Tooltip Helper
------------------------------------------------------------
------------------------------------------------------------
-- Tooltip Helper
------------------------------------------------------------
local function ShowPinTooltip(self)
    if not self.data then return end
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:ClearLines()
    -- Clean the name (Remove " (Horde)" or " (Alliance)" suffixes)
    local cleanName = self.data.city:gsub(" %(.+%)", "")
    GameTooltip:AddLine(cleanName, 1, 1, 1)
    
    local tName = GetSpellName(self.data.teleport)
    local pName = GetSpellName(self.data.portal)
    
    local hasTeleport = self.data.teleport and IsSpellKnown(self.data.teleport)
    local hasPortal = self.data.portal and IsSpellKnown(self.data.portal)
    
    if hasTeleport and tName then 
        GameTooltip:AddLine("Left-Click: " .. tName, 0.6, 0.8, 1) 
    end
    
    if hasPortal and pName then 
        GameTooltip:AddLine("Right-Click: " .. pName, 0.6, 0.8, 1) 
    end
    
    GameTooltip:Show()
end

------------------------------------------------------------
-- Secure Clicker Singleton
------------------------------------------------------------
local SecureClicker = CreateFrame("Button", "MapPortalsSecureClicker", UIParent, "SecureActionButtonTemplate")
SecureClicker:SetFrameStrata("TOOLTIP") -- Highest standard strata
SecureClicker:SetFrameLevel(10000)      -- Above the visual pin (9999)
SecureClicker:RegisterForClicks("AnyUp", "AnyDown")
SecureClicker:Hide()

-- Visual Feedback
-- Highlight (Hover glow)
SecureClicker:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square")
SecureClicker:GetHighlightTexture():SetBlendMode("ADD")
SecureClicker:GetHighlightTexture():SetAllPoints()

-- Pushed (Darkened press)
SecureClicker:SetPushedTexture("Interface\\Buttons\\UI-Quickslot-Depress")
SecureClicker:GetPushedTexture():SetAllPoints()

-- Mask styling for Round shape
local clickerMask = SecureClicker:CreateMaskTexture()
clickerMask:SetTexture("Interface\\CharacterFrame\\TempPortraitAlphaMask")
clickerMask:SetAllPoints(SecureClicker)
SecureClicker:GetHighlightTexture():AddMaskTexture(clickerMask)
SecureClicker:GetPushedTexture():AddMaskTexture(clickerMask)

-- ... (Visual Feedback removed for brevity in snippet, check context) ...

------------------------------------------------------------
-- MapPortals Pin Mixin
------------------------------------------------------------
MP.PinMixin = CreateFromMixins(MapCanvasPinMixin)

function MP.PinMixin:OnLoad()
    -- "TOOLTIP" is the highest strata available to standard XML frames.
    self:SetFrameStrata("TOOLTIP")
    self:SetFrameLevel(9999)
    self:SetFixedFrameStrata(true) -- Try to lock it
    self:SetFixedFrameLevel(true)
    
    self:SetFixedFrameLevel(true)
    
    -- Icon sits slightly inside
    -- We put icon on ARTWORK
    self.icon = self:CreateTexture(nil, "ARTWORK") 
    self.icon:SetPoint("TOPLEFT", 0, 0)
    self.icon:SetPoint("BOTTOMRIGHT", 0, 0)
    self.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)

    -- Mask for Round Icon
    self.mask = self:CreateMaskTexture()
    self.mask:SetTexture("Interface\\CharacterFrame\\TempPortraitAlphaMask")
    self.mask:SetAllPoints(self.icon)
    self.icon:AddMaskTexture(self.mask)
    
    self:EnableMouse(true)
    self:SetMouseClickEnabled(true)
end

function MP.PinMixin:OnAcquired(data)
    self.data = data
    self.icon:SetTexture(GetSpellIcon(data.teleport))
    
    local mapID = WorldMapFrame:GetMapID()
    
    local sizeOverride = MP.LARGE_ICON_MAPS and MP.LARGE_ICON_MAPS[mapID]
    if type(sizeOverride) == "number" then
        self:SetSize(sizeOverride, sizeOverride)
    elseif sizeOverride then
        self:SetSize(60, 60)
    else
        self:SetSize(30, 30)
    end

    -- Ensure we stay on top
    self:SetFrameLevel(9900)
end

-- Override MapCanvasPinMixin's auto-leveling
function MP.PinMixin:ApplyFrameLevel()
    self:SetFrameLevel(9900)
end



-- Sync position/size on update so it follows the pin during map zoom/pan
SecureClicker:SetScript("OnUpdate", function(self)
    local pin = MP.hoverPin
    -- If pin is gone or hidden, hide clicker
    if not pin or not pin:IsVisible() then
        self:Hide()
        return
    end
    
    -- Check if mouse is still conceivably over the pin/clicker area
    -- Actually, if we are shown, we consume mouse. 
    -- We just strictly follow the pin.
    
    local scale = pin:GetEffectiveScale() / UIParent:GetEffectiveScale()
    self:SetPoint("CENTER", pin, "CENTER", 0, 0)
    self:SetSize(pin:GetWidth() * scale, pin:GetHeight() * scale)
end)

function MP.PinMixin:OnMouseEnter()
    if InCombatLockdown() then
        ShowPinTooltip(self)
        return
    end

    -- Track current pin
    MP.hoverPin = self

    -- Move SecureClicker to OVERLAY this pin
    SecureClicker:ClearAllPoints()
    SecureClicker:SetParent(UIParent) -- Back to UIParent for safety
    SecureClicker:SetFrameStrata("TOOLTIP")
    
    -- Initial Sync
    local scale = self:GetEffectiveScale() / UIParent:GetEffectiveScale()
    SecureClicker:SetPoint("CENTER", self, "CENTER", 0, 0)
    SecureClicker:SetSize(self:GetWidth() * scale, self:GetHeight() * scale)
    
    local teleportName = GetSpellName(self.data.teleport)
    local portalName = GetSpellName(self.data.portal)
    
    if teleportName and IsSpellKnown(self.data.teleport) then
        SecureClicker:SetAttribute("type1", "macro")
        SecureClicker:SetAttribute("macrotext1", "/cast " .. teleportName .. "\n/run WorldMapFrame:Hide()")
    else
        SecureClicker:SetAttribute("type1", nil)
        SecureClicker:SetAttribute("macrotext1", nil)
    end
    
    if portalName and IsSpellKnown(self.data.portal) then
        SecureClicker:SetAttribute("type2", "macro")
        SecureClicker:SetAttribute("macrotext2", "/cast " .. portalName .. "\n/run WorldMapFrame:Hide()")
    else
        SecureClicker:SetAttribute("type2", nil)
        SecureClicker:SetAttribute("macrotext2", nil)
    end
    
    -- Pass data for tooltip
    SecureClicker.data = self.data
    SecureClicker.tooltipFunc = ShowPinTooltip
    
    SecureClicker:Show()
    ShowPinTooltip(SecureClicker)
end

function MP.PinMixin:OnMouseLeave()
    -- We don't clear MP.hoverPin immediately because the mouse moves *into* the SecureClicker.
    -- The SecureClicker's OnLeave will handle hiding itself?
    -- Wait. If we move from Pin -> Clicker (which is instant because Clicker pops up),
    -- Pin:OnMouseLeave fires.
    -- If we clear MP.hoverPin here, the OnUpdate will Hide() the clicker immediately!
    -- PROBLEM: We need the clicker to stay shown while we are over IT.
    
    if InCombatLockdown() then
        GameTooltip_Hide()
    end
end

-- SecureClicker OnLeave: Hide if we leave the clicker
SecureClicker:SetScript("OnLeave", function(self)
    -- If we left the clicker, we are done.
    self:Hide()
    MP.hoverPin = nil
    GameTooltip_Hide()
end)

-- SecureClicker OnEnter: Refreshes tooltip
SecureClicker:SetScript("OnEnter", function(self)
    if self.tooltipFunc then
        self.tooltipFunc(self)
    end
end)





------------------------------------------------------------
-- Custom pin pool
------------------------------------------------------------
if not MP.pinPool then
    MP.pinPool = CreateFramePool("BUTTON", WorldMapFrame.ScrollContainer.Child, nil, function(pool, pin)
        pin:Hide()
        pin:SetParent(nil)
        pin.data = nil
    end)
end

------------------------------------------------------------
-- CreatePortalPin
------------------------------------------------------------
function MP:CreatePortalPin(data)
    local pin = MP.pinPool:Acquire()
    
    if not pin.isInitialized then
        Mixin(pin, MP.PinMixin)
        pin:OnLoad()
        pin.isInitialized = true
    end
    
    pin:OnAcquired(data)

    -- Hook interactions
    pin:SetScript("OnEnter", pin.OnMouseEnter)
    pin:SetScript("OnLeave", pin.OnMouseLeave)
    
    -- Place it
    local map = WorldMapFrame.ScrollContainer.Child
    pin:SetParent(map)
    pin:ClearAllPoints()
    pin:SetPoint("CENTER", map, "TOPLEFT",
        data.x * map:GetWidth(),
        -data.y * map:GetHeight()
    )
    pin:Show()
end
