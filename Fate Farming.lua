  --[[

  ****************************************
  *            Fate Farming              * 
  ****************************************

  Created by: Prawellp, sugarplum done updates v0.1.8 to v0.1.9

  ***********
  * Version *
  *  1.0.7  *
  ***********
    -> 1.0.7    Added partial support for other areas
    -> 1.0.0    Code changes
                    added pathing priority to prefer bonus fates -> most progress -> fate time left -> by distance
                    added map flag for next fate
                    added prioirity targeting for forlorns
                    added settings for:
                        - WaitIfBonusBuff
                        - MinTimeLeftToIgnoreFate
                        - JoinBossFatesIfActive
                        - CompletionToJoinBossFate
                    enabled non-collection fates that require interacting with an npc to start
                    [dev] rework of internal fate lists, aetheryte lists, character statuses
    -> 0.2.4    Code changes
                    added revive upon death (requires "teleport" to be set in the settings)
                    added GC turn ins
                Setting changes
                    added the category Retainer
                    added 2 new settings for it in the Retainer settings
                Plugin changes
                    added Deliveroo in Optional Plugins for turn ins
    -> 0.2.3    Code changes
                    forgot the rotation settings in the last update to change it based on your job when entering a fate (thanks Caladbol)
                    Removed the numbers behind the wait because im to lazy to update them and check wich i need
                    added antistuck
    -> 0.2.2    Voucher exchange
                    Removed the target, lockon and move to Aetheryte. causing problems since the new spawn points in S9
                    Repaths if you get stuck at the counter
                Rotation Solver
                    turns auto on every time you enter a fate.
                Build in "[FATE]" before every echo in chat
    -> 0.2.1    Fixed game crash caused by checking for the Food status
    -> 0.2.0    Code changes
                    added auto snd property set (sets the snd settings so you don't have to)
                    sets the rsr settings to auto (and aoetype 2) when your on Tank (DRK not included), and on other classes to manual (and aoetype 1) 
                Plugin changes
                    removed the need of simple tweaks (plugin)
                    removed the need of yes already for the materia (plugin)
                    some bossmod settings will now be automatically set so no need to manually check for them (Requires version 7.2.0.22)
                        (Please make sure to change the Desired distance for Meeles manually tho)
                Setting changes
                    added fatewait for the amount it should wait before landing
                    removed Manualrepair setting
                    if RepairAmount is set to 0 it wont repair (to have less settings)
                    Reordert the settings and named some categorys
                    BMR will now be default set to true
                    added food usage


*********************
*  Required Plugins *
*********************

Plugins that are needed for it to work:

    -> Something Need Doing [Expanded Edition] : (Main Plugin for everything to work)   https://puni.sh/api/repository/croizat   
    -> VNavmesh :   (for Pathing/Moving)    https://puni.sh/api/repository/veyn       
    -> Pandora :    (for Fate targeting and auto sync [ChocoboS])   https://love.puni.sh/ment.json             
    -> RotationSolver Reborn :  (for Attacking enemys)  https://raw.githubusercontent.com/FFXIV-CombatReborn/CombatRebornRepo/main/pluginmaster.json       
        -> Target -> activate "Select only Fate targets in Fate" and "Target Fate priority"
        -> Target -> "Engage settings" set to "Previously engaged targets (enagegd on countdown timer)"
    -> TextAdvance : (for talking to the NPCs) https://github.com/NightmareXIV/MyDalamudPlugins/raw/main/pluginmaster.json

*********************
*  Optional Plugins *
*********************

This Plugins are Optional and not needed unless you have it enabled in the settings:

    -> Teleporter :  (for Teleporting to aetherytes [teleport][Exchange][Retainers])
    -> Lifestream :  (for chaning Instances [ChangeInstance][Exchange]) https://raw.githubusercontent.com/NightmareXIV/MyDalamudPlugins/main/pluginmaster.json
    -> AutoRetainer : (for Retainers [Retainers])   https://love.puni.sh/ment.json
    -> Deliveroo : (for gc turn ins [TurnIn])   https://plugins.carvel.li/
    -> Bossmod Reborn : (for AI dodging [BMR])  https://raw.githubusercontent.com/FFXIV-CombatReborn/CombatRebornRepo/main/pluginmaster.json
        -> make sure to set the Max distance in the AI Settings to the desired distance (25 is to far for Meeles)
    -> ChatCoordinates : (for setting a flag on the next Fate) available via base /xlplugins

--[[

**************
*  Settings  *
**************
]]

-- true = yes, false = no

-- Teleport and Voucher
EnableChangeInstance = true      -- Change Instance if no Fate (only DT fates)
Exchange = false                 -- Exchange Vouchers
OldV = false                     -- Exchange Old Vouchers

-- Fate settings
WaitIfBonusBuff = true           -- Stay if Twist of Fate bonus buff is active
CompletionToIgnoreFate = 80      -- Ignore fate if completion is above this percent
MinTimeLeftToIgnoreFate = 180    -- Ignore fate if less than 3 minutes left
JoinBossFatesIfActive = true     -- Join boss fates if others are participating
CompletionToJoinBossFate = 20    -- Join boss fate if progress is above this percent
fatewait = 0                     -- Wait time before dismounting (0 = start of fate, 3-5 = middle of fate)
useBMR = true                    -- Use BossMod dodge/follow mode

-- Utilities
RepairAmount = 20                -- Repair if durability drops below this percent (0 = no repair)
ExtractMateria = true            -- Extract Materia if available
Food = ""                        -- Food to use, leave blank if none. Include <hq> for HQ food.

-- Retainer
Retainers = false                -- Manage Retainers
TurnIn = false                   -- Turn in items at GC
slots = 5                        -- Inventory space threshold for turning in items

-- Other settings
ChocoboS = true                  -- Activate Chocobo settings in Pandora (auto-summon)
Announce = 2                     -- Fate and Bicolor gem announcements (2 = fate and gems, 1 = gems only, 0 = none)
UsePandoraSync = true            -- Enable auto-sync for FATEs

--[[

************
*  Script  *
*   Start  *
************

]]

-- Settings for character conditions and zones
CharacterCondition = {
    dead = 2,
    mounted = 4,
    inCombat = 26,
    casting = 27,
    occupied31 = 31,
    occupied32 = 32,
    occupied = 33,
    occupied39 = 39,
    transition = 45,
    jumping = 48,
    flying = 77
}

-- Define zones and FATEs data
FatesData = {
    {
        zoneName = "Coerthas Central Highlands",
        zoneId = 155,
        aetheryteList = {
            { aetheryteName = "Camp Dragonhead", x = 223.98718, y = 315.7854, z = -234.85168 }
        },
        fatesList = {
            collectionsFates = {},
            otherNpcFates = {},
            bossFates = {},
            blacklistedFates = {}
        }
    },
    {
        zoneName = "Coerthas Western Highlands",
        zoneId = 397,
        aetheryteList = {
            { aetheryteName = "Falcon's Nest", x = 474.87585, y = 217.94458, z = 708.5221 }
        },
        fatesList = {
            collectionsFates = {},
            otherNpcFates = {},
            bossFates = {},
            blacklistedFates = {}
        }
    },
    {
        zoneName = "Mor Dhona",
        zoneId = 156,
        aetheryteList = {
            { aetheryteName = "Revenant's Toll", x = 40.024292, y = 24.002441, z = -668.0247 }
        },
        fatesList = {
            collectionsFates = {},
            otherNpcFates = {},
            bossFates = {},
            blacklistedFates = {}
        }
    },
    {
        zoneName = "The Sea of Clouds",
        zoneId = 401,
        aetheryteList = {
            { aetheryteName = "Camp Cloudtop", x = -615.7473, y = -118.36426, z = 546.5934 },
            { aetheryteName = "Ok' Zundu", x = -613.1533, y = -49.485046, z = -415.03015 }
        },
        fatesList = {
            collectionsFates = {},
            otherNpcFates = {},
            bossFates = {},
            blacklistedFates = {}
        }
    },
    {
        zoneName = "Azys Lla",
        zoneId = 402,
        aetheryteList = {
            { aetheryteName = "Helix", x = -722.8046, y = -182.29956, z = -593.40814 }
        },
        fatesList = {
            collectionsFates = {},
            otherNpcFates = {},
            bossFates = {},
            blacklistedFates = {}
        }
    },
    {
        zoneName = "The Dravanian Forelands",
        zoneId = 398,
        aetheryteList = {
            { aetheryteName = "Tailfeather", x = 532.6771, y = -48.722107, z = 30.166992 },
            { aetheryteName = "Anyx Trine", x = -304.12756, y = -16.70868, z = 32.059082 }
        },
        fatesList = {
            collectionsFates = {},
            otherNpcFates = {},
            bossFates = {},
            blacklistedFates = {}
        }
    },
    {
        zoneName = "The Dravanian Hinterlands",
        zoneId = 399,
        aetheryteList = {
            { aetheryteName = "Idyllshire", x = 71.94617, y = 211.26111, z = -18.905945 }
        },
        fatesList = {
            collectionsFates = {},
            otherNpcFates = {},
            bossFates = {},
            blacklistedFates = {}
        }
    },
    {
        zoneName = "The Churning Mists",
        zoneId = 400,
        aetheryteList = {
            { aetheryteName = "Moghome", x = 259.20496, y = -37.70508, z = 596.85657 },
            { aetheryteName = "Zenith", x = -584.9546, y = 52.84192, z = 313.43542 }
        },
        fatesList = {
            collectionsFates = {},
            otherNpcFates = {},
            bossFates = {},
            blacklistedFates = {}
        }
    },
    -- Add additional zones similarly
}

-- Chocobo settings management
if ChocoboS then
    PandoraSetFeatureState("Auto-Summon Chocobo", true)
    PandoraSetFeatureConfigState("Auto-Summon Chocobo", "Use whilst in combat", true)
else
    PandoraSetFeatureState("Auto-Summon Chocobo", false)
    PandoraSetFeatureConfigState("Auto-Summon Chocobo", "Use whilst in combat", false)
end

-- Pandora sync management
if UsePandoraSync then
    PandoraSetFeatureState("Auto-Sync FATEs", true)
else
    PandoraSetFeatureState("Auto-Sync FATEs", false)
end

PandoraSetFeatureState("FATE Targeting Mode", true)
PandoraSetFeatureState("Action Combat Targeting", false)
yield("/wait 0.5")

-- Set sound properties function
function setSNDProperty(propertyName, value)
    local currentValue = GetSNDProperty(propertyName)
    if currentValue ~= value then
        SetSNDProperty(propertyName, tostring(value))
        LogInfo("[SetSNDProperty] " .. propertyName .. " set to " .. tostring(value))
    end
end

-- Initialize sound settings
setSNDProperty("UseItemStructsVersion", true)
setSNDProperty("UseSNDTargeting", true)
setSNDProperty("StopMacroIfTargetNotFound", false)
setSNDProperty("StopMacroIfCantUseItem", false)
setSNDProperty("StopMacroIfItemNotFound", false)
setSNDProperty("StopMacroIfAddonNotFound", false)

-- Required plugin checks
if not HasPlugin("vnavmesh") then
    yield("/echo [FATE] Please Install vnavmesh")
end
if not HasPlugin("RotationSolverReborn") and not HasPlugin("RotationSolver") then
    yield("/echo [FATE] Please Install Rotation Solver Reborn")
end
if not HasPlugin("PandorasBox") then
    yield("/echo [FATE] Please Install Pandora's Box")
end

-- Optional plugin checks
if EnableChangeInstance and not HasPlugin("Lifestream") then
    yield("/echo [FATE] Please Install Lifestream or Disable ChangeInstance in the settings")
end
if Retainers and not HasPlugin("AutoRetainer") then
    yield("/echo [FATE] Please Install AutoRetainer")
end
if ExtractMateria and not HasPlugin("YesAlready") then
    yield("/echo [FATE] Please Install YesAlready")
end
if useBMR and not (HasPlugin("BossModReborn") or HasPlugin("BossMod")) then

end
