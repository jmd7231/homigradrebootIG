if HG_PlayermodelManagerLoaded then return end
HG_PlayermodelManagerLoaded = true

util.AddNetworkString("hg_playermodel_permanent")
util.AddNetworkString("hg_playermodel_permanent_clear")

-- File path to store player models data
local playerModelsFilePath = "hg_player_models.txt"
local playerModels = {}
local dmRoundNames = {
    deathmatch = true,
    ffa = true,
    gravdm = true,
    gravteam = true,
    hl2dm = true,
    tier_0_tdm = true,
    tdm = true
}

local function IsDmRound()
    if dmRoundNames[roundActiveName] then
        return true
    end

    local roundTable = TableRound and TableRound()
    local roundName = roundTable and roundTable.Name

    if isstring(roundName) then
        local lowerName = string.lower(roundName)
        if string.find(lowerName, "deathmatch", 1, true) or string.find(lowerName, "tdm", 1, true) then
            return true
        end
    end

    return false
end

local function ApplyPlayerModel(ply, modelPath)
    if not modelPath then return end

    ply:SetSubMaterial()
    ply:SetModel(modelPath)
end

local function GetRandomRoundModel(ply)
    local roundTable = TableRound and TableRound()
    if not roundTable then return nil end

    local teamEncoder = roundTable.teamEncoder
    if teamEncoder then
        local teamKey = teamEncoder[ply:Team()]
        local teamTable = teamKey and roundTable[teamKey]
        if teamTable and teamTable.models and #teamTable.models > 0 then
            return teamTable.models[math.random(#teamTable.models)]
        end
    end

    if roundTable.models and #roundTable.models > 0 then
        return roundTable.models[math.random(#roundTable.models)]
    end

    return nil
end

local function ApplyRandomRoundModel(ply)
    local modelPath = GetRandomRoundModel(ply)
    if modelPath then
        ApplyPlayerModel(ply, modelPath)
        return
    end

    if EasyAppearance and EasyAppearance.SetAppearance then
        EasyAppearance.SetAppearance(ply)
    end
end

-- Function to load player models from file
local function LoadPlayerModels()
    if file.Exists(playerModelsFilePath, "DATA") then
        local data = file.Read(playerModelsFilePath, "DATA")
        playerModels = util.JSONToTable(data) or {}
        print("[HG] Player models loaded successfully.")
    else
        print("[HG] No existing player model data found. Starting fresh.")
    end
end

-- Function to save player models to file
local function SavePlayerModels()
    local data = util.TableToJSON(playerModels, true)
    file.Write(playerModelsFilePath, data)
    print("[HG] Player models saved successfully.")
end

-- Function to check if a player is authorized (servermanager or owner)
local function IsAuthorized(ply)
    return ply:IsUserGroup("servermanager") or ply:IsUserGroup("owner") or ply:IsUserGroup("superadmin")
end

-- Command to assign or overwrite a player model for a given SteamID
concommand.Add("hg_playermodel", function(ply, cmd, args)
    if not IsAuthorized(ply) then
        ply:ChatPrint("You do not have permission to use this command.")
        return
    end

    local steamID = args[1]
    local modelDir = args[2]

    if not steamID or not modelDir then
        ply:ChatPrint("Usage: hg_playermodel <SteamID> <Model Directory>")
        return
    end

    -- Store or overwrite the player model for the SteamID
    playerModels[steamID] = modelDir
    SavePlayerModels()
    ply:ChatPrint("Player model for " .. steamID .. " set to " .. modelDir)
end)

-- Command to remove a player model associated with a given SteamID
concommand.Add("hg_removemodel", function(ply, cmd, args)
    if not IsAuthorized(ply) then
        ply:ChatPrint("You do not have permission to use this command.")
        return
    end

    local steamID = args[1]

    if not steamID then
        ply:ChatPrint("Usage: hg_removemodel <SteamID>")
        return
    end

    if playerModels[steamID] then
        playerModels[steamID] = nil
        SavePlayerModels()
        ply:ChatPrint("Player model for " .. steamID .. " has been removed.")
    else
        ply:ChatPrint("No player model found for " .. steamID)
    end
end)

-- Command to list all SteamIDs and their assigned player models
concommand.Add("hg_listmodels", function(ply, cmd, args)
    if not IsAuthorized(ply) then
        ply:ChatPrint("You do not have permission to use this command.")
        return
    end

    if table.Count(playerModels) == 0 then
        ply:ChatPrint("No player models have been assigned.")
        return
    end

    ply:ChatPrint("Assigned Player Models:")
    for steamID, modelDir in pairs(playerModels) do
        ply:ChatPrint(steamID .. ": " .. modelDir)
    end
end)

-- Function to get the model directory for a given SteamID (useful for other parts of the code)
function GetPlayerModelBySteamID(steamID)
    --print(playerModels[steamID])
    return playerModels[steamID]
end

function HG_ApplyPermanentPlayermodel(ply)
    if not IsValid(ply) or not ply:IsPlayer() then return end

    local customModel = GetPlayerModelBySteamID(ply:SteamID())

    if not customModel or IsDmRound() then return end

    ApplyPlayerModel(ply, customModel)
end

function HG_ClearPermanentPlayermodel(ply)
    if not IsValid(ply) or not ply:IsPlayer() then return end

    playerModels[ply:SteamID()] = nil
    SavePlayerModels()
    ApplyRandomRoundModel(ply)
end

net.Receive("hg_playermodel_permanent", function(_, ply)
    if not IsValid(ply) or not ply:IsPlayer() then return end
    if not IsAuthorized(ply) then
        ply:ChatPrint("You do not have permission to use this.")
        return
    end

    local modelPath = net.ReadString()
    if modelPath == "" or not util.IsValidModel(modelPath) then
        ply:ChatPrint("Invalid model provided.")
        return
    end

    playerModels[ply:SteamID()] = modelPath
    SavePlayerModels()

    if IsDmRound() then
        ply:ChatPrint("Permanent model saved. It will apply after the current DM/TDM round.")
        return
    end

    ApplyPlayerModel(ply, modelPath)
    ply:ChatPrint("Permanent model set to " .. modelPath)
end)

net.Receive("hg_playermodel_permanent_clear", function(_, ply)
    if not IsValid(ply) or not ply:IsPlayer() then return end
    if not IsAuthorized(ply) then
        ply:ChatPrint("You do not have permission to use this.")
        return
    end

    HG_ClearPermanentPlayermodel(ply)
    ply:ChatPrint("Permanent model cleared. Reverted to round random.")
end)

-- Load player models when the script initializes
LoadPlayerModels()
