table.insert(LevelList,"kingkong")
kingkong = kingkong or {}
kingkong.Name = "KingKong"

kingkong.red = {"KingKong",Color(255,0,0),
    models = tdm.models
}

kingkong.green = {"Survivor",Color(55,255,55),
    models = tdm.models
}

kingkong.teamEncoder = {
    [1] = "red",
    [2] = "green"
}

kingkong.RoundRandomDefalut = 1
kingkong.CanRandomNext = false

local playsound = false
if SERVER then
    util.AddNetworkString("roundType2")
else
    net.Receive("roundType2",function(len)
        playsound = true
    end)
end

function kingkong.StartRound(data)
    team.SetColor(1,kingkong.red[2])

    game.CleanUpMap(false)

    if SERVER then
        net.Start("roundType2")
        net.Broadcast()
    end

    if CLIENT then

        return
    end

    return kingkong.StartRoundSV()
end

if SERVER then return end

local red,blue = Color(200,0,10),Color(75,75,255)
local gray = Color(122,122,122,255)
function kingkong.GetTeamName(ply)
    if ply.roleT then return "KingKong",red end

    local teamID = ply:Team()
    if teamID == 1 then
        return "Survivor",gray
    end
end

local black = Color(0,0,0,255)

net.Receive("homicide_roleget2",function()
    for i,ply in player.Iterator() do ply.roleT = nil end
    local role = net.ReadTable()
    for i,ply in pairs(role[1]) do ply.roleT = true end
end)

function kingkong.HUDPaint_Spectate(spec)
    local name,color = kingkong.GetTeamName(spec)
    draw.SimpleText(name,"HomigradFontBig",ScrW() / 2,ScrH() - 150,color,TEXT_ALIGN_CENTER)
end

function kingkong.Scoreboard_Status(ply)
    local lply = LocalPlayer()

     for i,ply in player.Iterator() do
        local color = ply.roleT and red or ply.roleCT and blue
        if not color or ply == lply or not ply:Alive() then continue end

        local pos = ply:GetPos() + ply:OBBCenter()
        local dis = lply_pos:Distance(pos)
        if dis > 1024 then continue end

        local pos = pos:ToScreen()
        if not pos.visible then continue end

        color.a = 255 * (1 - dis / 1024)
        draw.SimpleText("KingKong: "..ply:Nick(),"HomigradFontBig",pos.x,pos.y,color,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
    end

    return true
    --if not lply:Alive() or lply:Team() == 1002 then return true end

    --return "Неизвестно",ScoreboardSpec
end

local red,blue = Color(200,0,10),Color(75,75,255)
local roundSound = "snd_jack_hmcd_panic.mp3"

local humanDistance = 700

function kingkong.HUDPaint_RoundLeft(white2)
    if roundActiveName ~= "kingkong" then return end
    local lply = LocalPlayer()
    local name,color = kingkong.GetTeamName(lply)

    local startRound = roundTimeStart + 5 - CurTime()
    if startRound > 0 and lply:Alive() then
        if playsound then
            playsound = false
            surface.PlaySound(roundSound)
            lply:ScreenFade(SCREENFADE.IN,Color(0,0,0,220),0.5,4)
        end

        draw.DrawText( "You are " .. name, "HomigradRoundFont", ScrW() / 2, ScrH() / 2, Color( color.r,color.g,color.b,math.Clamp(startRound,0,1) * 255 ), TEXT_ALIGN_CENTER )
        draw.DrawText( "KingKong", "HomigradRoundFont", ScrW() / 2, ScrH() / 8, Color( color.r,color.g,color.b,math.Clamp(startRound,0,1) * 255 ), TEXT_ALIGN_CENTER )

        if lply:GetModel() == "models/vedatys/orangutan.mdl" then
            draw.DrawText( "You're surrounded by intruders! Press R To Activate Rage.", "HomigradRoundFont", ScrW() / 2, ScrH() / 1.2, Color( color.r,color.g,color.b,math.Clamp(startRound,0,1) * 255 ), TEXT_ALIGN_CENTER )
        else
            draw.DrawText( "Neutralize King Kong. You are not expected to come out alive.", "HomigradRoundFont", ScrW() / 2, ScrH() / 1.2, Color( color.r,color.g,color.b,math.Clamp(startRound,0,1) * 255 ), TEXT_ALIGN_CENTER )
        end
        return
    end

   --[[ if lply:GetModel() == "models/vedatys/orangutan.mdl" and lply.abilityTimer == false then -- fuck me
        draw.DrawText( "Press R To Activate Rage", "HomigradRoundFont", ScrW() / 2, ScrH() / 1.2, red, TEXT_ALIGN_CENTER )
    end]]

    local lply_pos = lply:GetPos()

    for i,ply in player.Iterator() do
        local color = ply.roleT and red
        if ply == lply or not ply:Alive() then continue end

        local pos = ply:GetPos() + ply:OBBCenter()
        local dis = lply_pos:Distance(pos)
        if ply:GetModel() == "models/vedatys/orangutan.mdl" then -- cheap way, dont judge
            if dis > 400 then continue end -- kingkong
        else
            if dis > humanDistance then continue end -- humans
        end

        local pos = pos:ToScreen()
        if not pos.visible then continue end

        if ply:GetModel() == "models/vedatys/orangutan.mdl" then
            draw.SimpleText("KingKong","HomigradFont",pos.x,pos.y,red,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
        else
            draw.SimpleText("Human","HomigradFont",pos.x,pos.y,red,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
            
        end
    end
end

net.Receive("PlayerActivatedRage", function(ply, abilityTimer)
    humanDistance = 100000

    timer.Simple(5, function()
        humanDistance = 700
    end)
end)
