table.insert(LevelList,"infection")
infection = {}
infection.Name = "Infection"

infection.red = {"Seekers",Color(255,55,55),
    weapons = {"weapon_radio","weapon_gurkha","weapon_hands","med_band_big","med_band_small","medkit","painkiller"},
    main_weapon = {"weapon_m3super","weapon_remington870","weapon_xm1014"},
    secondary_weapon = {"weapon_p220","weapon_mateba","weapon_glock"},
    models = tdm.models
}

infection.green = {"Hiders",Color(55,255,55),
    weapons = {"weapon_hands"},
    models = tdm.models
}

infection.blue = {"Special Forces",Color(55,55,255),
    weapons = {"weapon_radio","weapon_hands","weapon_kabar","med_band_big","med_band_small","medkit","painkiller","weapon_hg_f1","weapon_handcuffs","weapon_taser",},
    main_weapon = {"weapon_hk416","weapon_m4a1","weapon_m3super","weapon_mp7","weapon_xm1014","weapon_fal","weapon_asval","weapon_m249","weapon_mp5","weapon_p90"},
    secondary_weapon = {"weapon_beretta","weapon_p99","weapon_hk_usp"},
    models = tdm.models
}

infection.teamEncoder = {
    [1] = "red",
    [2] = "green",
    [3] = "blue"
}

function infection.StartRound(data)
	team.SetColor(1,infection.red[2])
	team.SetColor(2,infection.green[2])
	team.SetColor(3,infection.blue[2])

	game.CleanUpMap(false)

    if CLIENT then
		roundTimeLoot = data.roundTimeLoot

		return
	end

    return infection.StartRoundSV()
end

infection.SupportCenter = true

infection.NoSelectRandom = true
