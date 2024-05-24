

function PartyPlanner:SplitGold(sourceValue)
    local gold = math.floor(sourceValue / 10000)
    local silver = math.floor((sourceValue - (gold * 10000)) / 100)
    local copper = sourceValue - (gold * 10000) - (silver * 100)
    return gold, silver, copper
end

function PartyPlanner:Reload()

    

    SetPortraitTexture(PartyPlanner.UI.characterPortrait.texture, "player");
    PartyPlanner.UI:UpdateChannelOptions()
end

