if engine.ActiveGamemode() == "homigrad" then
SWEP.Base = 'weapon_scout' -- base

SWEP.PrintName 				= "Awp"
SWEP.Author 				= "Homigrad"
SWEP.Instructions			= "It's Just Like In Counter Strike! Wait A Minute..."
SWEP.Category 				= "Weapon"

SWEP.Spawnable 				= true
SWEP.AdminOnly 				= false

SWEP.Primary.ClipSize		= 6
SWEP.Primary.DefaultClip	= 6
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "XBowBolt"
SWEP.Primary.Damage = 255
SWEP.Primary.Sound = "snd_jack_hmcd_snp_close.wav"
SWEP.Primary.SoundFar = "snd_jack_hmcd_snp_far.wav"
SWEP.Primary.Force = 600
SWEP.Primary.Delay = 1

SWEP.ViewModel				= "models/weapons/cstrike/c_snip_awp.mdl"
SWEP.WorldModel				= "models/weapons/cstrike/c_snip_awp.mdl"

function SWEP:ApplyEyeSpray()
    self.eyeSpray = self.eyeSpray - Angle(math.random(20,-20)/ 40, math.random(20,-20) / 40,0)
end

if CLIENT then
    SWEP.opticpos = Vector(0, 0, 0)
    SWEP.opticang = Angle(0, 90, 0)

    SWEP.spos = Vector(0, 0, 3)
    SWEP.sang = Angle(0, 0, 0)

    SWEP.zoomfov = 9

    --SWEP.scope_mat = Material("")

    --SWEP.opticmodel = "models/weapons/arccw/atts/magnus.mdl"
    --SWEP.opticmodel2 = "models/weapons/arccw/atts/magnus_hsp.mdl"

    SWEP.addfov = 80
end

SWEP.vbwPos = Vector(-3,-5,-5)
SWEP.vbwAng = Vector(-80,-0,0)
SWEP.vbw = false

SWEP.CLR_Scope = 0.05
SWEP.CLR = 0.025

SWEP.addAng = Angle(0,0,90)
SWEP.addPos = Vector(0,0.7,0.5)

SWEP.SightPos = Vector(2, -7.5, -2)--Vector(-60, -0.68, -5.4)
end