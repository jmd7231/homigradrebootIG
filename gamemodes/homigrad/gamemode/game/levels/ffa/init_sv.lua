
function ffa.StartRoundSV()
    tdm.RemoveItems()
    local players = PlayersInGame()

    roundTimeStart = CurTime()
    roundTime = 55
    for i, ply in ipairs(players) do
        roundTime = roundTime + 15
    end 

    if roundTime > 235 then
        roundTime = 235 -- dont want it going on for like 10 minutes stright
    end
    
    --roundTime = 300 + math.random(0, 300)
    
    for i, ply in ipairs(players) do
        ply:SetTeam(1)
        ply:SetNWInt("KillCount", 0)
        ffa.PlayerSpawn2(ply)
    end

    local aviable = ReadDataMap("dm")
    aviable = #aviable ~= 0 and aviable or homicide.Spawns()

    tdm.SpawnCommand(team.GetPlayers(1), aviable, function(ply)
        ply:Freeze(true)
    end)

    freezing = true
    roundTimeRespawn = CurTime() + 10

    
    return {roundTimeStart, roundTime}
end

local function giveAmmoForWeapons(ply)
    for _, weapon in ipairs(ply:GetWeapons()) do
        local ammoType = weapon:GetPrimaryAmmoType()
        if ammoType >= 0 then 
            ply:SetAmmo(weapon:GetMaxClip1() * 3, ammoType) 
        end
    end
end

local primaryWeapons = {
    [1] = {"weapon_mp7", "weapon_ak74u", "weapon_akm", "weapon_uzi", "weapon_m4a1", "weapon_hk416", "weapon_galil"},
    [2] = {"weapon_spas12", "weapon_xm1014", "weapon_remington870", "weapon_m590"},
    [3] = {"weapon_mateba"},
    [4] = {"weapon_hk_usp", "weapon_p99", "weapon_beretta"}
}

local secondaryWeapons = {
    [2] = {"weapon_uzi", "weapon_p99", "weapon_glock", "weapon_fiveseven"}
}

local extraItems = {
    ["knife"] = "weapon_kabar",
    ["medkit"] = "medkit",
    ["bandage"] = "med_band_big",
    ["grenade"] = "weapon_hg_rgd5",
    ["molotov"] = "weapon_hg_molotov",
    ["radio"] = "weapon_radio",
    ["radar"] = "weapon_radar"
}

function ffa.PlayerSpawn2(ply)
    ply:SetModel(tdm.models[math.random(#tdm.models)])
    ply:SetPlayerColor(Vector(0, 1, 0.051))

    local roundDmType = math.random(1, 4)
    local primaryWeapon = primaryWeapons[roundDmType][math.random(#primaryWeapons[roundDmType])]
    ply:Give(primaryWeapon)


    if roundDmType == 2 then
        local secondaryWeapon = secondaryWeapons[2][math.random(#secondaryWeapons[2])]
        ply:Give(secondaryWeapon)
    end


    ply:Give(extraItems["knife"])
    ply:Give(extraItems["medkit"])
    ply:Give(extraItems["bandage"])
    ply:Give(extraItems["radio"])
    ply:Give(extraItems["radar"])


    if roundDmType == 2 or roundDmType == 4 then
        ply:Give(extraItems["grenade"])
    end

    if roundDmType == 4 then
        ply:Give(extraItems["molotov"])
    end


    giveAmmoForWeapons(ply)

    ply:SetLadderClimbSpeed(100)
    
    ply:Give("weapon_hands")
end



function ffa.RoundEndCheck()
    local winner = nil
    local highestKills = 0
    local topPlayer = nil

    for i, ply in ipairs(team.GetPlayers(1)) do
        local kills = ply:GetNWInt("KillCount", 0)

        if kills >= 30 then
            winner = ply
            break
        end

        if kills > highestKills then
            highestKills = kills
            topPlayer = ply
        end
    end

    if winner then
        EndRound(winner)
    elseif roundTimeStart + roundTime < CurTime() then
        EndRound(topPlayer)
    end
end


function ffa.EndRound(winner)
    if winner then
        PrintMessage(3, winner:GetName() .. " won with " .. winner:GetNWInt("KillCount") .. " kills!")
    else
        PrintMessage(3, "Time is up! No one reached 30 kills.")
    end

    for i, ply in ipairs(player.GetAll()) do
        ply:SetNWInt("KillCount", 0)
    end

    damageTracking = {}
end

--[[ -- could be used but instead the last hit that kills the victim gets the kill
function ffa.TrackPlayerDamage(target, dmgInfo)
    if target:IsPlayer() and dmgInfo:GetAttacker():IsPlayer() then
        local attacker = dmgInfo:GetAttacker()

        if not damageTracking[target] then
            damageTracking[target] = {}
        end

        if not damageTracking[target][attacker] then
            damageTracking[target][attacker] = 0
        end

        damageTracking[target][attacker] = damageTracking[target][attacker] + dmgInfo:GetDamage()
    end
end

]]

 hook.Add("PlayerDeath", "FFADeathHandler", function(victim, inflictor, attacker)
    ffa.HandlePlayerDeath(victim, inflictor, attacker)
end)

function ffa.HandlePlayerDeath(victim, inflictor, attacker)
    if victim:Team() == 1002 or roundActiveName ~= "ffa" then return end

    --PrintMessage(3, attacker:GetName().. " attacker")
    --wPrintMessage(3, inflictor:GetName().. " inflictor")
    if attacker:GetName() == "" or attacker:GetName() == victim:GetName() then attacker = "World" end

    if attacker ~= "World" then
        PrintMessage(3, victim:GetName().. " Was Killed By ".. (attacker:GetName()).. "!")
        attacker:SetNWInt("KillCount", attacker:GetNWInt("KillCount") + 1)
    else
        PrintMessage(3, victim:GetName().. " Suicided! (unknown)")
    end

    timer.Simple(6, function()
        if IsValid(victim) and victim:Team() ~= 1002 and roundActiveName == "ffa" and victim:Alive() == false then
            --victim:Spawn()

            --ffa.PlayerSpawn2(victim)

           	if victim:Alive() then victim:KillSilent() end

		    if func then func(victim) end
		
		    victim:Spawn()
		    victim.allowFlashlights = true

            local aviable = ReadDataMap("dm")
            aviable = #aviable ~= 0 and aviable or homicide.Spawns()

		    if #aviable > 0 then
			    local key = math.random(#aviable)
			    local point = ReadPoint(aviable[key])

			    if point then
				    victim:SetPos(point[1])

				    table.remove(aviable, key)

                    timer.Simple(3, function()
                        table.add(aviable, key)
                    end)
			    end
		    end
        end
    end)
end
    function ffa.PlayerInitialSpawn(ply)
    ply:SetTeam(1)
end

function ffa.PlayerCanJoinTeam(ply, teamID)
    if teamID ~= 1 then
        ply:ChatPrint("Only one team is available.")
        return false
    end
    return true
end

function ffa.GuiltLogic() return false end

damageTracking = {}
