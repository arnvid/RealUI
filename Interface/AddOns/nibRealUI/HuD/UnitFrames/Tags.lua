local nibRealUI = LibStub("AceAddon-3.0"):GetAddon("nibRealUI")

local MODNAME = "UnitFrames"
local UnitFrames = nibRealUI:GetModule(MODNAME)

local oUF = oUFembed
local tags = oUF.Tags

------------------
------ Tags ------
------------------
-- Name
tags.Methods["realui:name"] = function(unit)
    local isDead = false
    if UnitIsDead(unit) or UnitIsGhost(unit) or not(UnitIsConnected(unit)) then
        isDead = true
    end

    local unitTag = unit:match("(boss)%d?$") or unit
                            -- enUS,    zhTW,   zhCN,   ruRU, koKR
    --local test1, test2, test3, test4, test5 = "Account Level Mount", "帳號等級坐騎", "战网通行证通用坐骑", "Средство передвижения для всех персонажей учетной записи", "계정 공유 탈것"
    --local test = test3
    local name = UnitFrames:AbrvName(UnitName(unit)--[[test]], unitTag) --

    local nameColor = "ffffff"
    if isDead then
        nameColor = "3f3f3f"
    elseif UnitFrames.db.profile.overlay.classColorNames then 
        --print("Class color names", unit)
        local _, class = UnitClass(unit)
        nameColor = nibRealUI:ColorTableToStr(nibRealUI:GetClassColor(class))
    end
    return string.format("|cff%s%s|r", nameColor, name)
end
tags.Events["realui:name"] = "UNIT_NAME_UPDATE"

-- Level
tags.Methods["realui:level"] = function(unit)
    if UnitIsDead(unit) or UnitIsGhost(unit) or not(UnitIsConnected(unit)) then return end

    local level, levelColor
    if (UnitIsWildBattlePet(unit) or UnitIsBattlePetCompanion(unit)) then
        level = UnitBattlePetLevel(unit)
    else
        level = UnitLevel(unit)
    end
    if level <= 0 then
        level = "??"
        levelColor = GetQuestDifficultyColor(105)
    else
        levelColor = GetQuestDifficultyColor(level)
    end
    return string.format("|cff%02x%02x%02x%s|r", levelColor.r * 255, levelColor.g * 255, levelColor.b * 255, level)
end
tags.Events["realui:level"] = "UNIT_NAME_UPDATE"

-- PvP Timer
tags.Methods["realui:pvptimer"] = function(unit)
    --print("Tag:pvptimer", unit)
    if not IsPVPTimerRunning() then return "" end

    return nibRealUI:ConvertSecondstoTime(floor(GetPVPTimer() / 1000))
end
tags.Events["realui:pvptimer"] = "UNIT_FACTION PLAYER_FLAGS_CHANGED"



-- Health AbsValue
tags.Methods["realui:healthValue"] = function(unit)
    if UnitIsDead(unit) or UnitIsGhost(unit) or not(UnitIsConnected(unit)) then return end

    return nibRealUI:ReadableNumber(UnitHealth(unit))
end
tags.Events["realui:healthValue"] = "UNIT_HEALTH_FREQUENT UNIT_MAXHEALTH UNIT_TARGETABLE_CHANGED"

-- Health %
tags.Methods["realui:healthPercent"] = function(unit)
    if UnitIsDead(unit) or UnitIsGhost(unit) or not(UnitIsConnected(unit)) then return end

    local percent = UnitHealth(unit) / UnitHealthMax(unit) * 100
    return ("%.1f|cff%s%%|r"):format(percent, nibRealUI:ColorTableToStr(UnitFrames.db.profile.overlay.colors.health.normal))
end
tags.Events["realui:healthPercent"] = tags.Events["realui:healthValue"]

-- Health
tags.Methods["realui:health"] = function(unit)
    local statusText = UnitFrames.db.profile.misc.statusText
    if statusText == "both" then
        return tags.Methods["realui:healthPercent"](unit).." - "..tags.Methods["realui:healthValue"](unit)
    elseif statusText == "perc" then
        return tags.Methods["realui:healthPercent"](unit)
    else
        return tags.Methods["realui:healthValue"](unit)
    end
end
tags.Events["realui:health"] = tags.Events["realui:healthValue"]



-- Power AbsValue
tags.Methods["realui:powerValue"] = function(unit)
    if UnitIsDead(unit) or UnitIsGhost(unit) or not(UnitIsConnected(unit)) then return end

    return nibRealUI:ReadableNumber(UnitPower(unit))
end
tags.Events["realui:powerValue"] = "UNIT_POWER_FREQUENT UNIT_MAXPOWER UNIT_DISPLAYPOWER UNIT_TARGETABLE_CHANGED"

-- Power %
tags.Methods["realui:powerPercent"] = function(unit)
    if UnitIsDead(unit) or UnitIsGhost(unit) or not(UnitIsConnected(unit)) then return end

    local _, ptoken = UnitPowerType(unit)
    local percent = UnitPower(unit) / UnitPowerMax(unit) * 100
    return ("%.1f|cff%s%%|r"):format(percent, nibRealUI:ColorTableToStr(oUF.colors.power[ptoken]))
end
tags.Events["realui:powerPercent"] = tags.Events["realui:powerValue"]

-- Power
tags.Methods["realui:power"] = function(unit)
    local _, ptoken = UnitPowerType(unit)
    local statusText, power = UnitFrames.db.profile.misc.statusText
    if ptoken == "MANA" then
        if statusText == "both" then
            return tags.Methods["realui:powerPercent"](unit).." - "..tags.Methods["realui:powerValue"](unit)
        elseif statusText == "perc" then
            return tags.Methods["realui:powerPercent"](unit)
        else
            return tags.Methods["realui:powerValue"](unit)
        end
    else
        return tags.Methods["realui:powerValue"](unit)
    end
end
tags.Events["realui:power"] = tags.Events["realui:powerValue"]
