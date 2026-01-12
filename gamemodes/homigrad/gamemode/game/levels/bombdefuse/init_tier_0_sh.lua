table.insert(LevelList,"bombdefuse")
bombdefuse = {}
bombdefuse.Name = "Bomb Defuse"

bombdefuse.terrorists = {"Terrorists",Color(176,0,0),
	weapons = {"megamedkit","weapon_binokle","weapon_hands","weapon_hg_hatchet","med_band_small","med_band_big","med_band_small","painkiller","weapon_handcuffs","weapon_radio"},
	main_weapon = {"weapon_asval", "weapon_mp5", "weapon_m3super"},
	secondary_weapon = {"weapon_beretta","weapon_p99","weapon_beretta"},
	models = {"models/player/leet.mdl","models/player/phoenix.mdl","models/player/arctic.mdl","models/player/guerilla.mdl"}
}

bombdefuse.counterterrorists = {"Counter-Terrorists",Color(79,59,187),
	weapons = {"megamedkit","weapon_binokle","weapon_hg_hatchet","weapon_hands","med_band_big","med_band_small","medkit","painkiller","weapon_handcuffs","weapon_radio"},
	main_weapon = {"weapon_m4a1","weapon_mp7","weapon_galil"},
	secondary_weapon = {"weapon_hk_usp", "weapon_mateba"},
	models = {"models/player/riot.mdl","models/player/gasmask.mdl","models/player/swat","models/player/urban.mdl"}
}

bombdefuse.teamEncoder = {
	[1] = "terrorists",
	[2] = "counterterrorists"
}

function bombdefuse.StartRound()
	game.CleanUpMap(false)

	team.SetColor(1,red)
	team.SetColor(2,blue)

	if CLIENT then

		bombdefuse.StartRoundCL()
		return
	end

	bombdefuse.StartRoundSV()
end
bombdefuse.RoundRandomDefalut = 1
bombdefuse.SupportCenter = true

bombdefuse.NoSelectRandom = true
