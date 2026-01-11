table.insert(LevelList,"gravteam")
gravteam = {}
gravteam.Name = "War of the Servers"

local models = {}

gravteam.red = {"GMod Players",Color(1,166,255),
	weapons = {"weapon_hands","weapon_physcannon","weapon_hg_shovel","medkit","med_band_big"},
	--main_weapon = {"weapon_sar2","weapon_spas12","weapon_akm","weapon_mp7"},
	--secondary_weapon = {"weapon_hk_usp","weapon_p220"},
	models = tdm.models
}


gravteam.blue = {"Mingebags",Color(255,255,255),
	weapons = {"weapon_hands","weapon_physcannon","weapon_hg_shovel","medkit","med_band_big"},
	--main_weapon = {"weapon_sar2","weapon_spas12","weapon_mp7"},
	--secondary_weapon = {"weapon_hk_usp"},
	models = {"models/player/kleiner.mdl"}
}

gravteam.teamEncoder = {
	[1] = "red",
	[2] = "blue"
}

function gravteam.StartRound()
	game.CleanUpMap(false)

	team.SetColor(1,gravteam.red[2])
	team.SetColor(2,gravteam.blue[2])

	if CLIENT then

		gravteam.StartRoundCL()
		return
	end

	gravteam.StartRoundSV()
end
gravteam.RoundRandomDefalut = 2
gravteam.SupportCenter = true
gravteam.NoSelectRandom = true
