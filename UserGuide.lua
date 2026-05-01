-- SPDX-License-Identifier: GPL-2.0-or-later
---------------------------------------------------------------------------
-- BazMapPortals User Guide
---------------------------------------------------------------------------

if not BazCore or not BazCore.RegisterUserGuide then return end

BazCore:RegisterUserGuide("BazMapPortals", {
    title = "BazMapPortals",
    intro = "Adds clickable portal and teleport spell icons directly to the world map for mages.",
    pages = {
        {
            title = "Welcome",
            blocks = {
                { type = "lead", text = "BazMapPortals (BMP) places a pin icon on the world map at every destination a mage can teleport or portal to. Click a pin to cast the spell directly from the map - no need to dig through the spellbook." },
                { type = "note", style = "warning", text = "Mage-only. Pins simply don't appear on other classes." },
            },
        },
        {
            title = "How to Use",
            blocks = {
                { type = "paragraph", text = "Open the world map (default key M) and the pins appear at their destinations." },
                { type = "table",
                  columns = { "Action", "Cast" },
                  rows = {
                      { "Left-Click",  "Teleport - moves you alone" },
                      { "Right-Click", "Portal - opens a portal that group members can step through" },
                  },
                },
                { type = "h3", text = "Filtering" },
                { type = "list", items = {
                    "Pins only appear for spells you actually know",
                    "As you learn new teleports through leveling and rep, more pins appear automatically",
                    "Faction-restricted destinations only show on the appropriate faction",
                }},
            },
        },
        {
            title = "Destinations",
            blocks = {
                { type = "lead", text = "All current mage teleports and portals are supported." },
                { type = "collapsible", title = "Capital Cities", style = "h3", blocks = {
                    { type = "list", items = {
                        "Stormwind, Orgrimmar",
                        "Ironforge, Undercity",
                        "Darnassus, Thunder Bluff",
                        "Exodar, Silvermoon (Midnight)",
                    }},
                }},
                { type = "collapsible", title = "Expansion Hubs", style = "h3", blocks = {
                    { type = "list", items = {
                        "Shattrath, Dalaran",
                        "Stormshield, Warspear",
                        "Boralus, Dazar'alor",
                        "Oribos, Valdrakken",
                    }},
                }},
                { type = "collapsible", title = "Legendary Zones", style = "h3", blocks = {
                    { type = "paragraph", text = "Theramore, Hyjal, and other lore destinations." },
                }},
            },
        },
        {
            title = "Map Overrides",
            blocks = {
                { type = "paragraph", text = "Some teleport destinations are on continent-level maps where pin placement would be ambiguous. BMP includes manual coordinate overrides for tricky cases like Silvermoon City, Quel'Thalas, and the Midnight Eastern Kingdoms zones." },
                { type = "note", style = "tip", text = "If a pin appears in the wrong place on a particular map, you can save a custom coordinate override. See Slash Commands." },
            },
        },
        {
            title = "Slash Commands",
            blocks = {
                { type = "table",
                  columns = { "Command", "Effect" },
                  rows = {
                      { "/mp",            "Open the BazMapPortals settings page" },
                      { "/mp set <city>", "Save a custom coord override for that destination at your current map position" },
                      { "/mp clear",      "Clear a single custom override (`/mp clear <city>`) or all (`/mp clear all`)" },
                      { "/mp dump",       "Print the current overrides for inspection" },
                      { "/mp info",       "Show diagnostic info about the current map" },
                      { "/mapportals",    "Alias for /mp - every subcommand works on either form" },
                  },
                },
            },
        },
    },
})
