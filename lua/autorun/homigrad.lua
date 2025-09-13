if engine.ActiveGamemode() == "homigrad" then
    hg = hg or {}

    include("homigrad_scr/loader.lua")
    --if SERVER then include("homigrad_scr/run_serverside.lua") end
    include("homigrad_scr/run.lua")

    -- made poorly by whanga, fixes maps shitting bricks :P
    if CLIENT then
        local missing_fixes = {
            ["models/props_junk/physics_trash"] = "models/debug/debugwhite",
            ["models/props_junk/physics_trash_hospital"] = "models/debug/debugwhite",
            ["models/props_junk/cardboardboxes01"] = "models/debug/debugwhite",
            ["models/props_junk/cardboardboxes02"] = "models/debug/debugwhite",
            ["models/props_junk/cardboardboxes04"] = "models/debug/debugwhite",
            ["models/props_junk/metalcontainers01"] = "models/debug/debugwhite",
            ["models/props_junk/metalcontainers02"] = "models/debug/debugwhite"
        }

        -- Force-load replacement materials so Source doesn't precache spam
        for bad, replacement in pairs(missing_fixes) do
            local mat = Material(bad)
            if mat:IsError() then
                print("[whanga's entity crap] Redirecting " .. bad .. " to " .. replacement)
                mat:SetTexture("$basetexture", replacement)
            end
        end

        hook.Add("OnEntityCreated", "FixEntityIssues", function(ent)
            timer.Simple(0, function()
                if not IsValid(ent) then return end

                -- busted ass materials
                local mats = ent:GetMaterials()
                if mats and #mats > 0 then
                    for i, mat in ipairs(mats) do
                        local replacement = missing_fixes[mat]
                        if replacement then
                            ent:SetSubMaterial(i - 1, replacement)
                        end
                    end
                end

                -- movetype follow stuff
                if ent:GetMoveType() == MOVETYPE_FOLLOW and ent:GetModel() == "" then
                    ent:SetModel("models/error.mdl")
                end
            end)
        end)
    end

end