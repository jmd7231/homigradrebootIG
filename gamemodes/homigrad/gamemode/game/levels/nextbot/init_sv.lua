function nextbot.StartRoundSV()
    tdm.RemoveItems()

	roundTimeStart = CurTime()
	roundTime = 60 * (1 + math.min(#player.GetAll() / 8,2))

    local players = PlayersInGame()
    for i,ply in pairs(players) do ply:SetTeam(1) end

    local aviable = ReadDataMap("dm")
    aviable = #aviable ~= 0 and aviable or homicide.Spawns()
    tdm.SpawnCommand(team.GetPlayers(1),aviable,function(ply)
        ply:Freeze(true)
    end)

    freezing = true

    RTV_CountRound = RTV_CountRound - 1

    roundTimeRespawn = CurTime() + 15

    timer.Simple(15,function()
        if roundActiveName ~= "nextbot" then return end
        local npc = ents.Create("ah_thelocust")
        if not IsValid(npc) then PrintMessage(3, "Not Valid.") return end

        for i, point in pairs(ReadDataMap("points_nextbox")) do
            npc:SetPos(point[1])
        end
        
        npc:Spawn("ah_thelocust")

        PrintMessage(3, "7 days.")
    end)


    --roundDmType = math.random(1,4)

    return {roundTimeStart,roundTime}
end

function nextbot.RoundEndCheck()
    local Alive = 0

    for i,ply in pairs(team.GetPlayers(1)) do
        if ply:Alive() then Alive = Alive + 1 end
    end

    if freezing and roundTimeStart + nextbot.LoadScreenTime < CurTime() then
        freezing = nil

        for i,ply in pairs(team.GetPlayers(1)) do
            ply:Freeze(false)
        end
    end

    if Alive <= 1 then EndRound() return end

end

function nextbot.EndRound(winner)
    for i, ply in ipairs( player.GetAll() ) do
	    if ply:Alive() then
            PrintMessage(3,ply:GetName() .. " remains. They are victorious!")
        end
    end
end

local red = Color(255,0,0)

function nextbot.PlayerSpawn2(ply,teamID)
	ply:SetModel(tdm.models[math.random(#tdm.models)])
    ply:SetPlayerColor(Vector(0,0,0.6))


    ply:Give("weapon_hands")
    ply:Give("weapon_taser")
    ply:Give("adrenaline")
    ply:Give("splint")
    ply:Give("medkit")
    ply:Give("weapon_radio")

    ply:SetLadderClimbSpeed(100)

end

function nextbot.PlayerInitialSpawn(ply)
    ply:SetTeam(1)
end

function nextbot.PlayerCanJoinTeam(ply,teamID)
	if teamID == 2 or teamID == 3 then ply:ChatPrint("Pashol fuck") return false end

    return true
end

function nextbot.GuiltLogic() return false end

util.AddNetworkString("nextbot die")
function nextbot.PlayerDeath()
    net.Start("nextbot die")
    net.Broadcast()
end
