local addonName = "GliderMacro"

-- Caching
local InCombatLockdown = InCombatLockdown
local GetLocale = GetLocale
local UnitIsUnit = UnitIsUnit
local CreateMacro = CreateMacro
local EditMacro = EditMacro
local GetNumMacros = GetNumMacros


local listener = CreateFrame("FRAME", "GliderMacroListener")
listener:RegisterEvent("PLAYER_ENTERING_WORLD")
listener:RegisterEvent("UNIT_INVENTORY_CHANGED")

-- Tooltip reader frame
local myTooltipFrame = CreateFrame( "GameTooltip", "GliderMacroScanningTooltip", nil, "GameTooltipTemplate");
GliderMacroScanningTooltip:SetOwner( UIParent, "ANCHOR_NONE" );

-- Tooltip glider locale
local tooltipGliderText = {
    ["frFR"] = "Réduit votre vitesse de chute pendant 2 min.*",
    ["enUS"] = "^Use: Reduces your falling speed for 2 min.*",
    ["enGB"] = "^Use: Reduces your falling speed for 2 min.*",
}

local useText = {
    ["frFR"] = "^Utilise.*",
    ["enUS"] = "^Use:.*",
    ["enGB"] = "^Use:.*",
}

function cloakHasGlider()
    local cloakIsUsable = false

    -- Read tooltip
    local numSlot = 15
    GliderMacroScanningTooltip:SetInventoryItem("player", numSlot)

    -- Get correct pattern
    local locale = GetLocale()
    local gliderPattern = tooltipGliderText[locale] or ""
    local usePattern = useText[locale] or ""
    
    -- Look for pattern
    for i = 1, GliderMacroScanningTooltip:NumLines() do
        local GTTL = _G["GliderMacroScanningTooltipTextLeft"..i]
        if GTTL then
            local textLeft =  GTTL:GetText()
            if textLeft then
                if string.find(textLeft, gliderPattern) then
                    return true, true
                end

                if string.find(textLeft, usePattern) then
                    cloakIsUsable = true
                end
            end
        end             
    end
    return false, cloakIsUsable
end

-- Change macro on event
listener:SetScript("OnEvent", function(self, event,...)
    if InCombatLockdown() then return end
    if event == "UNIT_INVENTORY_CHANGED" then
        local unit = ...
        if not UnitIsUnit(unit, "player") then return end
    end

    local macroName = addonName
    local printHeader = "|TInterface\\Icons\\inv_misc_bag_07_red:0:0:0:0|t " .. WrapTextInColorCode("GliderMacro", "fffef367")

    local gliderItemID = 109076
    local icon = "INV_MISC_QUESTIONMARK"
    local body = ""

    local hasGlider, isUsable = cloakHasGlider()
    if hasGlider then
        body = "#showtooltip 15\n/use 15"
    else
        if isUsable then
            body = "#showtooltip [mod:alt] 15 ; item:" .. gliderItemID .. "\n/use [mod:alt] 15 ; item:"  .. gliderItemID
        else
            icon = "inv_misc_bag_07_red"
            body = "#showtooltip item:" .. gliderItemID .. "\n/use item:"  .. gliderItemID
        end
    end 
        
    -- Create macro if not exists
    if GetMacroIndexByName(macroName) == 0 then
        -- Check if there is space
        local numGlobal, numPerChar = GetNumMacros()
        if numGlobal < 100 then           
            CreateMacro(
                macroName,
                icon,
                body,
                nil
            )
          --  print(printHeader, ": Macro created")
        else
          --  print(printHeader, ": Not enough space to create macro")
        end
    else
        EditMacro(
            macroName,
            nil,
            icon,
            body,
            1,
            nil
        )
       -- print(printHeader, ": Macro updated")
    end   
end)