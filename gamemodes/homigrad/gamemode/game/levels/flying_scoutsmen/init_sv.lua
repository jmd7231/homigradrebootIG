include("../../playermodelmanager_sv.lua")

function flyingscoutsmen.StartRoundSV()
    tdm.RemoveItems()

	RunConsoleCommand("sv_gravity", "150")

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

    --roundDmType = math.random(1,4)

    return {roundTimeStart,roundTime}
end

function flyingscoutsmen.RoundEndCheck()
    local Alive = 0

    for i,ply in pairs(team.GetPlayers(1)) do
        if ply:Alive() then Alive = Alive + 1 end
    end

    if freezing and roundTimeStart + flyingscoutsmen.LoadScreenTime < CurTime() then
        freezing = nil

        for i,ply in pairs(team.GetPlayers(1)) do
            ply:Freeze(false)
        end
    end

    if Alive <= 1 then EndRound() return end

end

function flyingscoutsmen.EndRound(winner)
	RunConsoleCommand("sv_gravity", "600")
    for i, ply in ipairs( player.GetAll() ) do
	    if ply:Alive() then
            PrintMessage(3,ply:GetName() .. " remains. They are victorious!")
        end
    end
end

local red = Color(255,0,0)

function flyingscoutsmen.PlayerSpawn2(ply,teamID)
	local customModel = GetPlayerModelBySteamID(ply:SteamID())
    
    --if customModel == true then
    --    ply:SetSubMaterial()
        --ply:SetModel(customModel)
    --else
        ply:SetModel(tdm.models[math.random(#tdm.models)])
		ply:SetPlayerColor(Vector(0,0,0.6))
   -- end

	EasyAppearance.SetAppearance( ply )

	--ply:SetModel(tdm.models[math.random(#tdm.models)])
    --ply:SetPlayerColor(Vector(0,0,0.6))

    ply:Give("weapon_hands")
    ply:Give("weapon_scout")
    ply:Give("medkit")
    ply:Give("weapon_radio")

    ply:SetLadderClimbSpeed(100)

end

function flyingscoutsmen.PlayerInitialSpawn(ply)
    ply:SetTeam(1)
end

function flyingscoutsmen.PlayerCanJoinTeam(ply,teamID)
	if teamID == 2 or teamID == 3 then ply:ChatPrint("Pashol fuck") return false end

    return true
end

function flyingscoutsmen.GuiltLogic() return false end

util.AddNetworkString("flyingscoutsmen die")
function flyingscoutsmen.PlayerDeath()
    net.Start("flyingscoutsmen die")
    net.Broadcast()
end