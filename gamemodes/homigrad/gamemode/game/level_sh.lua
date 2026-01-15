LevelList = {}

local roundCache = {}

function TableRound(name)
    local targetName = (name or roundActiveName) or "homicide"
    local cached = roundCache[targetName]

    if cached ~= nil then
        return cached
    end

    cached = _G[targetName]

    if cached ~= nil then
        roundCache[targetName] = cached
    end

    return cached
end

timer.Simple(0,function()
    if roundActiveName == nil then --and not (string.find(string.lower(game.GetMap()), "rp_desert_conflict")) then
        if GetConVar("sv_construct"):GetBool() == true then
            roundActiveName = "construct"
            roundActiveNameNext = "construct"
        else
            roundActiveName = "homicide"
            roundActiveNameNext = "homicide"
        end
    end
end)
