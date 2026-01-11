hl2bodycam.GetTeamName = tdm.GetTeamName

local playsound = false
function hl2bodycam.StartRoundCL()
    playsound = true
end


function hl2bodycam.HUDPaint_RoundLeft(white)
    local lply = LocalPlayer()
	local name,color = hl2bodycam.GetTeamName(lply)

	local startRound = roundTimeStart + 5 - CurTime()
    if startRound > 0 and lply:Alive() then
        if playsound then
            playsound = false
            surface.PlaySound("snd_jack_hmcd_deathmatch.mp3")
            lply:ScreenFade(SCREENFADE.IN,Color(0,0,0,220),0.5,4)
        end
        

        draw.DrawText( "You are on team " .. name, "HomigradRoundFont", ScrW() / 2, ScrH() / 2, Color( color.r,color.g,color.b,math.Clamp(startRound,0,1) * 255 ), TEXT_ALIGN_CENTER )
        draw.DrawText( "HL2 Bodycam", "HomigradRoundFont", ScrW() / 2, ScrH() / 8, Color( 155,155,55,math.Clamp(startRound,0,1) * 255 ), TEXT_ALIGN_CENTER )
        draw.DrawText( "because im really bored tbh", "HomigradRoundFont", ScrW() / 2, ScrH() / 1.2, Color( 55,55,55,math.Clamp(startRound,0,1) * 255 ), TEXT_ALIGN_CENTER )
        return
    end
end
