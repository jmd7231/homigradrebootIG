table.insert(LevelList,"infected")
infected = infected or {}
infected.Name = "Infected"

infected.red = {"Infected",Color(255,75,75),
    weapons = {"weapon_infected_knife"},
    models = tdm.models
}

infected.blue = {"Survivors",Color(75,75,255),
    weapons = {"weapon_binokle","weapon_radio","weapon_hands","weapon_gurkha","med_band_big","med_band_small","medkit","painkiller"},
    main_weapon = tdm.red.main_weapon,
    secondary_weapon = tdm.red.secondary_weapon,
    models = tdm.models
}

infected.teamEncoder = {
    [1] = "red",
    [2] = "blue"
}

function infected.StartRound(data)
    team.SetColor(1,infected.red[2])
    team.SetColor(2,infected.blue[2])

    game.CleanUpMap(false)

    if CLIENT then
        roundTimeLoot = data.roundTimeLoot

        return
    end

    return infected.StartRoundSV()
end

infected.SupportCenter = false
