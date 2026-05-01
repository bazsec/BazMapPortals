-- SPDX-License-Identifier: GPL-2.0-or-later
-- Copyright (C) 2025 Baz4k

local _, MP = ...

MP.CITIES = {
  { city="Stormwind", x=0.53, y=0.68, mapID=84, teleport=3561, portal=10059 },
  { city="Ironforge", x=0.47, y=0.27, mapID=87, teleport=3562, portal=11416 },
  { city="Darnassus", x=0.19, y=0.13, mapID=89, teleport=3565, portal=11419 },
  { city="Exodar",    x=0.08, y=0.18, mapID=103, teleport=32271, portal=32266 }, -- Azuremyst Isle
  { city="Theramore", x=0.62, y=0.64, mapID=70, teleport=49359, portal=49360 }, -- Dustwallow Marsh
  { city="Shattrath", x=0.46, y=0.42, mapID=111, teleport=33690, portal=33691 }, -- Terokkar Forest
  { city="Dalaran", x=0.49, y=0.26, mapID=125, teleport=53140, portal=53142 }, -- Northrend Dalaran

  
  -- Faction Specific: Tol Barad (Same ID, Different Location)
  { city="Tol Barad", x=0.46, y=0.49, mapID=241, teleport=88342, portal=88345, faction="Alliance" }, 
  { city="Tol Barad (Horde)", x=0.46, y=0.49, mapID=241, teleport=88344, portal=88345, faction="Horde" }, 
  
  -- Faction Specific: Pandaria (Different IDs, Different Location)
  { city="Pandaria",  x=0.64, y=0.26, mapID=390, teleport=132621, portal=132627, faction="Alliance" }, -- Seven Stars
  { city="Pandaria (Horde)",  x=0.64, y=0.26, mapID=390, teleport=132627, portal=132626, faction="Horde" }, -- Two Moons
  
  { city="Stormshield", x=0.55, y=0.32, mapID=588, teleport=176248, portal=176246 }, -- Ashran
  { city="Stormshield", x=0.55, y=0.32, mapID=588, teleport=176248, portal=176246 }, -- Ashran
  { city="Broken Isles", x=0.61, y=0.45, mapID=627, teleport=224869, portal=224871 }, -- Legion Dalaran
  { city="Boralus",   x=0.61, y=0.50, mapID=895, teleport=281403, portal=281400 }, -- Tiragarde Sound
  { city="Oribos",    x=0.49, y=0.51, mapID=1550, teleport=344587, portal=344597 }, -- Shadowlands
  { city="Valdrakken",x=0.57, y=0.48, mapID=2022, teleport=395277, portal=395289 }, -- Dragon Isles (Thaldraszus)
  { city="Dornogal",  x=0.48, y=0.46, mapID=2248, teleport=446540, portal=446534 }, -- Khaz Algar (Isle of Dorn)
  { city="Hall of Guardian", x=0.61, y=0.45, mapID=627, teleport=193759, portal=nil }, -- Broken Isles Dalaran (Class Hall)
  { city="Ancient Dalaran", x=0.45, y=0.58, mapID=267, teleport=120145, portal=120146 }, -- Hillsbrad Foothills (Crater)
  { city="Undercity", x=0.84, y=0.44, mapID=947, teleport=3563, portal=11418 }, -- Azeroth (Ruins of Lordaeron)
  { city="Thunder Bluff", x=0.16, y=0.56, mapID=947, teleport=3566, portal=11420 }, -- Azeroth
  { city="Thunder Bluff", x=0.16, y=0.56, mapID=947, teleport=3566, portal=11420 }, -- Azeroth
  { city="Orgrimmar", x=0.22, y=0.51, mapID=947, teleport=3567, portal=11417 }, -- Azeroth
  { city="Stonard", x=0.90, y=0.68, mapID=947, teleport=49358, portal=49361 }, -- Azeroth
  { city="Warspear", x=0.72, y=0.39, mapID=572, teleport=176242, portal=176274 }, -- Draenor
  { city="Dazar'alor", x=0.58, y=0.62, mapID=875, teleport=281404, portal=281402 }, -- Zandalar
  { city="Silvermoon", x=0.53, y=0.65, mapID=2393, teleport=1259190, portal=1259194 }, -- Silvermoon City (Midnight)
  { city="Silvermoon (BC)", x=0.92, y=0.31, mapID=947, teleport=32272, portal=32267, faction="Horde" }, -- Old Silvermoon (Burning Crusade)
}

-- Map-Specific Overrides
-- [City Name] = { [MapID] = {x, y} }
-- Use this to manually position icons on specific maps to prevent overlap or fix projection errors.
MP.MAP_OVERRIDES = {
    ["Warspear"] = {
        [572] = { x=0.72, y=0.39 }, -- Draenor: Correct location from user
        [588] = { x=0.45, y=0.15 }, -- Ashran: Correct location from user
        [624] = { x=0.59, y=0.52 }, -- Warspear City: Correct location from user
    },
    ["Dazar'alor"] = {
        [875] = { x=0.58, y=0.62 }, -- Zandalar: Correct location from user
        [862] = { x=0.58, y=0.44 }, -- Zuldazar: Correct location from user
        [1163] = { x=0.66, y=0.74 }, -- Dazar'alor City: Copy-Paste from user
        [1165] = { x=0.51, y=0.46 }, -- The Great Seal: Correct location from user
    },  
    ["Silvermoon"] = {
        [947] = { x=0.92, y=0.31 },  -- Azeroth
        [13] = { x=0.57, y=0.14 },   -- Eastern Kingdoms (old)
        [2537] = { x=0.28, y=0.38 }, -- Midnight Eastern Kingdoms
        [2395] = { x=0.53, y=0.26 }, -- Quel'Thalas parent zone
        [2393] = { x=0.53, y=0.65 }, -- Silvermoon City (Midnight)
    },
    ["Silvermoon (BC)"] = {
        [947] = { x=0.92, y=0.31 },  -- Azeroth
        [13] = { x=0.56, y=0.13 },   -- Eastern Kingdoms
        [94] = { x=0.53, y=0.31 },   -- Eversong Woods
        [110] = { x=0.58, y=0.19 },  -- Old Silvermoon City
    },
    ["Shattrath"] = {
        [101] = { x=0.43, y=0.66 }, -- Outland: Correct location
        [111] = { x=0.55, y=0.40 }, -- Shattrath City: Correct location
    },
    ["Theramore"] = { 
        [947] = { x=0.22, y=0.61 }, -- Azeroth: Correct location
        [12] = { x=0.58, y=0.65 }, -- Kalimdor: Correct location
        [70] = { x=0.65, y=0.48 }, -- Dustwallow Marsh: Correct location
    },
    ["Valdrakken"] = { 
        [947] = { x=0.78, y=0.21 }, -- Azeroth: Correct location
        [1978] = { x=0.57, y=0.48 }, -- Dragon Isles: Correct location
        [2025] = { x=0.41, y=0.58 }, -- Thaldrasus: Correct location
        [2112] = { x=0.60, y=0.37 }, -- Valdrakken City: Correct location
    },
    ["Boralus"] = { 
        [947] = { x=0.74, y=0.49 }, -- Azeroth: Correct location
        [876] = { x=0.61, y=0.50 }, -- Kul Tiras (Continent): Correct location
        [895] = { x=0.74, y=0.24 }, -- Tirigarde Sound: Correct location
        [1161] = { x=0.71, y=0.16 }, -- Boralus City: Correct location
    },
    ["Tol Barad"] = { 
        [947] = { x=0.80, y=0.52 }, -- Azeroth: Shared
        [13] = { x=0.35, y=0.49 },  -- Eastern Kingdoms: Shared
        [245] = { x=0.74, y=0.61 }, -- Tol Barad Map: Alliance (Baradin Base Camp)
    },
    ["Tol Barad (Horde)"] = {
        [947] = { x=0.80, y=0.52 }, -- Azeroth: Shared
        [13] = { x=0.35, y=0.49 },  -- Eastern Kingdoms: Shared
        [245] = { x=0.56, y=0.80 }, -- Tol Barad Map: Horde (Hellscream's Grasp)
    },
    ["Stormshield"] = {
        [572] = { x=0.71, y=0.48 }, -- Draenor: Correct location from user
        [588] = { x=0.44, y=0.87 }, -- Ashran: Correct location from user
        [622] = { x=0.63, y=0.35 }, -- Stormshield: Correct location from user
    },
    ["Oribos"] = {
        [1550] = { x=0.45, y=0.51 }, -- Shadowlands: Correct location from user
        [1670] = { x=0.20, y=0.49 }, -- Oribos City: Correct location from user
    },
    ["Dalaran"] = {
        [127] = { x=0.28, y=0.35 }, -- Crystalsong Forest: Correct location from user
        [113] = { x=0.49, y=0.41 }, -- Northrend: Correct location from user
        [947] = { x=0.49, y=0.13 }, -- Azeroth: Correct location from user
    },
    ["Pandaria"] = {
        [947] = { x=0.49, y=0.82 }, -- Azeroth: Correct location from user (Updated)
        [424] = { x=0.55, y=0.56 }, -- Pandaria: Correct location from user
        [390] = { x=0.86, y=0.61 }, -- Vale of Eternal Blossoms: Correct location from user (Seven Stars)
    },
    ["Pandaria (Horde)"] = {
        [947] = { x=0.48, y=0.81 }, -- Azeroth: Correct location from user (Horde)
        [424] = { x=0.50, y=0.49 }, -- Pandaria: Correct location from user (Horde)
        [390] = { x=0.63, y=0.22 }, -- Vale of Eternal Blossoms: Correct location from user (Two Moons)
    },
    ["Dornogal"] = {
        [947] = { x=0.29, y=0.82 }, -- Azeroth: Correct location from user
        [2274] = { x=0.71, y=0.18 }, -- Khaz Algar: Correct location from user
        [2248] = { x=0.48, y=0.39 }, -- Isle of Dorn: Correct location from user
    },
    ["Exodar"] = { 
        [12] = { x=0.30, y=0.26 },  -- Kalimdor: Azuremyst Isle
        [103] = { x=0.48, y=0.60 }, -- Exodar City: Correct location
    },
    ["Stormwind"] = { [947] = { x=0.84, y=0.65 } },
    ["Ironforge"] = { 
        [947] = { x=0.87, y=0.56 },
        [13] = { x=0.47, y=0.58 }, -- Eastern Kingdoms
        [87] = { x=0.26, y=0.08 }, -- Ironforge City: Correct location
    },
    ["Darnassus"] = { 
        [947] = { x=0.16, y=0.40 }, -- Azeroth: Darkshore location
        [12]  = { x=0.46, y=0.20 }, -- Kalimdor: Darkshore location
        [62]  = { x=0.46, y=0.19 }, -- Darkshore: Correct zone location
    },
    ["Orgrimmar"] = {
        [12] = { x=0.59, y=0.44 }, -- Kalimdor: Correct location from user
        [1] = { x=0.48, y=0.10 },  -- Durotar: Correct location from user
        [85] = { x=0.57, y=0.90 }, -- Orgrimmar City: Correct location from user
    },
    ["Stonard"] = {
        [13] = { x=0.53, y=0.80 }, -- Eastern Kingdoms: Correct location from user
        [51] = { x=0.50, y=0.56 }, -- Swamp of Sorrows: Correct location from user
    },
    
    -- Legion Separation
    ["Broken Isles"] = { 
        [947] = { x=0.59, y=0.46 }, -- Azeroth: User-provided exact spot
    }, 
    ["Hall of Guardian"] = { 
        [947] = { x=0.61, y=0.46 }, -- Azeroth: Shifted right (0.59 -> 0.61) to separate from Dalaran
        [619] = { x=0.50, y=0.644 }, -- Broken Isles: Adjusted Y (0.648 -> 0.644) for pixel-perfect alignment
        [627] = { x=0.65, y=0.45 }, -- Dalaran City: Shifted right (0.61 -> 0.65) to separate from Dalaran icon
    },
    ["Undercity"] = {
        [13] = { x=0.44, y=0.35 }, -- Eastern Kingdoms: Correct location from user
        [18] = { x=0.62, y=0.73 }, -- Tirisfal Glades: Correct location from user
        [2070] = { x=0.69, y=0.63 }, -- Tirisfal Glades (Ruins/Present): Correct location from user
    },
    ["Thunder Bluff"] = {
        [12] = { x=0.46, y=0.54 }, -- Kalimdor: Correct location from user
        [7] = { x=0.35, y=0.22 },  -- Mulgore: Correct location from user
        [88] = { x=0.22, y=0.17 }, -- Thunder Bluff City: Correct location from user
    },
}

-- Maps where we want Larger Icons (60x60) instead of normal (30x30)
MP.LARGE_ICON_MAPS = {
    [947] = true, -- Azeroth Cosmic
    [13]  = true, -- Eastern Kingdoms
    [12]  = true, -- Kalimdor
    [113] = true, -- Northrend
    [876] = true, -- Kul Tiras
    [895] = 90,   -- Tirigarde Sound (Extra Large)
    [875] = true, -- Zandalar
    [862] = 90,   -- Zuldazar (Extra Large)
    [101] = true, -- Outland
    [1161]= 90,   -- Boralus City (Extra Large)
    [1165]= true, -- The Great Seal (Large)
    [1550]= true, -- Shadowlands (Oribos map often acts as continent)
    [1978]= true, -- Dragon Isles
    [2025]= 90,   -- Thaldrasus (Extra Large)
    [2112]= 90,   -- Valdrakken City (Extra Large)
    [2274]= 90,   -- Khaz Algar (Extra Large)
    [2248]= 90,   -- Isle of Dorn (Extra Large)
    [2339]= 90,   -- Dornogal City (Extra Large)
    [2537]= true, -- Midnight Eastern Kingdoms (Large)
    [2395]= 90,   -- Quel'Thalas (Extra Large)
    [2393]= 90,   -- Silvermoon City (Extra Large)
}


