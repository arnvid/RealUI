local _, private = ...

-- Lua Globals --
-- luacheck: globals wipe next tinsert sort tonumber

-- RealUI --
local RealUI = _G.RealUI
local Currency = RealUI:GetModule("Currency")
local characterInfo = RealUI.charInfo

local currencyDB
local function GetInlineFactionIcon(faction)
    local fIcon = {["HORDE"] = _G.QUEST_TAG_ATLAS["HORDE"],
                   ["ALLIANCE"] = _G.QUEST_TAG_ATLAS["ALLIANCE"],
                   ["NEUTRAL"] = "BattleMaster"}
    return _G.CreateAtlasMarkup(fIcon[faction:upper()],16,16)
end
local function CharSort(a, b)
    return a.name < b.name
end

local characterList, characterName = {}, "%s %s %s"
local function UpdateCharacterList(currencyID, includePlayer)
    wipe(characterList)
    local playerInfo
    for index, realm in next, RealUI.realmInfo.connectedRealms do
        local realmDB = currencyDB[realm]
        if realmDB then
            for faction, factionDB in next, realmDB do
                for name, data in next, factionDB do
                    if data[currencyID] then
                        if name ~= characterInfo.name then
                            tinsert(characterList, {
                                name = name,
                                class = data.class,
                                quantity = data[currencyID],
                                realm = characterInfo.realm == realm and "" or realm,
                                faction = GetInlineFactionIcon(faction)
                            })
                        elseif includePlayer then
                            playerInfo = {
                                name = name,
                                class = data.class,
                                quantity = data[currencyID],
                                realm = "",
                                faction = GetInlineFactionIcon(faction)
                            }
                        end
                    end
                end
            end
        end
    end

    sort(characterList, CharSort)
    if playerInfo then
        tinsert(characterList, 1, playerInfo)
    end

    return #characterList > 0
end
local function AddTooltipInfo(tooltip, currencyID, includePlayer)
    if currencyID and UpdateCharacterList(currencyID, includePlayer) then
        tooltip:AddLine(" ")
        for i = 1, #characterList do
            local charInfo = characterList[i]
            local r, g, b = _G.CUSTOM_CLASS_COLORS[charInfo.class]:GetRGB()
            local charName = characterName:format(charInfo.faction, charInfo.name, charInfo.realm)
            tooltip:AddDoubleLine(charName, charInfo.quantity, r, g, b, r, g, b)
        end
        tooltip:Show()
    end
end

local function GetCurrencyIDByIndex(index)
    return tonumber(_G.C_CurrencyInfo.GetCurrencyListLink(index):match("currency:(%d+)"))
end

local function SetUpHooks()
    private.AddHook("SetCurrencyByID", function(self, currencyID, quantity)
        AddTooltipInfo(self, currencyID, not _G.MerchantMoneyInset:IsMouseOver())
    end)
    private.AddHook("SetCurrencyToken", function(self, index)
        AddTooltipInfo(self, GetCurrencyIDByIndex(index), not _G.TokenFrame:IsMouseOver())
    end)
    private.AddHook("SetCurrencyTokenByID", function(self, currencyID)
        AddTooltipInfo(self, currencyID, not _G.TokenFrame:IsMouseOver())
    end)

    private.AddHook("SetLFGDungeonReward", function(self, dungeonID, rewardIndex)
        local name = _G.GetLFGDungeonRewardInfo(dungeonID, rewardIndex)
        AddTooltipInfo(self, Currency:GetCurrencyID(name), true)
    end)
    private.AddHook("SetLFGDungeonShortageReward", function(self, dungeonID, shortageIndex, rewardIndex)
        local name = _G.GetLFGDungeonShortageRewardInfo(dungeonID, shortageIndex, rewardIndex)
        AddTooltipInfo(self, Currency:GetCurrencyID(name), true)
    end)

    private.AddHook("SetMerchantCostItem", function(self, slotIndex, itemIndex)
        local _, _, _, name = _G.GetMerchantItemCostItem(slotIndex, itemIndex)
        AddTooltipInfo(self, Currency:GetCurrencyID(name), true)
    end)

    private.AddHook("SetHyperlink", function(self, link)
        local id = link:match("currency:(%d+)")
        if id then
            AddTooltipInfo(self, tonumber(id), true)
        end
    end)
end


function private.SetupCurrency()
    currencyDB = RealUI.db.global.currency

    SetUpHooks()
end
