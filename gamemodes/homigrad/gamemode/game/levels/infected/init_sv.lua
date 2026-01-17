function infected.StartRoundSV(data)
    tdm.RemoveItems()

    tdm.DirectOtherTeam(1,2)

    roundTimeStart = CurTime()
    roundTime = 60 * 4
    roundTimeLoot = 0

    local players = team.GetPlayers(2)
    local infectedCount = #players > 0 and math.max(1, math.floor(#players / 5)) or 0

    for i = 1, infectedCount do
        local ply, key = table.Random(players)
        if not IsValid(ply) then break end
        players[key] = nil

        ply:SetTeam(1)
        ply.roleT = true
    end

    local spawnsT, spawnsCT = tdm.SpawnsTwoCommand()
    tdm.SpawnCommand(team.GetPlayers(1), spawnsT)
    tdm.SpawnCommand(team.GetPlayers(2), spawnsCT)

    tdm.CenterInit()

    return {roundTimeLoot = roundTimeLoot}
end

local infectionWeaponClasses = {
    weapon_infected_knife = true,
    weapon_kabar = true,
    weapon_gurkha = true,
    weapon_knife = true
}

local function IsKnifeDamage(attacker, dmgInfo)
    local inflictor = dmgInfo:GetInflictor()
    local class = IsValid(inflictor) and inflictor:GetClass() or ""

    if infectionWeaponClasses[class] then
        return true
    end

    local active = IsValid(attacker) and attacker:GetActiveWeapon()
    if IsValid(active) and infectionWeaponClasses[active:GetClass()] then
        return true
    end

    if dmgInfo:IsDamageType(DMG_SLASH) or dmgInfo:IsDamageType(DMG_CLUB) then
        return true
    end

    return false
end

function infected.InfectPlayer(ply, attacker)
    if not IsValid(ply) or not ply:Alive() then return end
    if ply:Team() ~= 2 then return end

    ply.roleT = true
    ply:SetTeam(1)
    ply:StripWeapons()

    ply:Give("weapon_infected_knife")
    ply:SelectWeapon("weapon_infected_knife")

    ply:SetHealth(150)
    ply:SetMaxHealth(150)
    ply:SetPlayerColor(infected.red[2]:ToVector())

    for _, target in pairs(player.GetAll()) do
        target:ConCommand("hg_subtitle '" .. ply:Name() .. " has been infected!' red")
    end
end

hook.Add("HomigradDamage", "infected-infect", function(ply, hitGroup, dmgInfo)
    if TableRound() ~= infected then return end

    local attacker = dmgInfo:GetAttacker()
    if not IsValid(attacker) or not attacker:IsPlayer() then return end
    if attacker:Team() ~= 1 then return end
    if ply:Team() ~= 2 then return end

    if not IsKnifeDamage(attacker, dmgInfo) then return end

    dmgInfo:SetDamage(0)
    infected.InfectPlayer(ply, attacker)
end)

function infected.RoundEndCheck()
    if tdm.GetCountLive(team.GetPlayers(2)) == 0 then
        EndRound(1)
        return
    end

    if roundTimeStart + roundTime < CurTime() then
        EndRound(2)
        return
    end
end

function infected.EndRound(winner)
    if winner == 1 then
        PrintMessage(3,"The infected have spread to everyone!")
    elseif winner == 2 then
        PrintMessage(3,"Survivors lasted the whole 4 minutes!")
    else
        PrintMessage(3,"Nobody survived.")
    end
end

function infected.PlayerSpawn2(ply,teamID)
    local teamTbl = infected[infected.teamEncoder[teamID]]
    local color = teamTbl[2]

    ply:SetPlayerColor(color:ToVector())

    if teamID == 1 then
        ply:StripWeapons()
        ply:Give("weapon_infected_knife")
        ply:SelectWeapon("weapon_infected_knife")
        ply.roleT = true
    else
        ply.roleT = false

        for i,weapon in pairs(teamTbl.weapons) do ply:Give(weapon) end

        tdm.GiveSwep(ply, teamTbl.main_weapon)
        tdm.GiveSwep(ply, teamTbl.secondary_weapon)

        if math.random(1,4) == 4 then ply:Give("adrenaline") end
        if math.random(1,4) == 4 then ply:Give("morphine") end
        if math.random(1,5) == 5 then ply:Give("weapon_bat") end
    end

    ply.allowFlashlights = true
end

function infected.PlayerInitialSpawn(ply)
    ply:SetTeam(2)
end

function infected.PlayerCanJoinTeam(ply,teamID)
    if teamID == 3 then return false end
end

function infected.PlayerDeath(ply,inf,att)
    if ply:Team() == 1 then
        timer.Simple(2, function()
            if not roundActive or TableRound() ~= infected then return end
            if not IsValid(ply) or ply:Alive() then return end

            ply:Spawn()
        end)
    end

    return false
end
