if engine.ActiveGamemode() == "homigrad" then
SWEP.Base = 'salat_base' -- base

SWEP.PrintName 				= "Drum Shotgun"
SWEP.Author 				= "Homigrad"
SWEP.Instructions			= "test again"
SWEP.Category 				= "Weapon"

SWEP.Spawnable 				= true
SWEP.AdminOnly 				= false

------------------------------------------

SWEP.Primary.ClipSize		= 7
SWEP.Primary.DefaultClip	= 7
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "12/70 gauge"
SWEP.Primary.Cone = 0.1
SWEP.Primary.Damage = 55
SWEP.Primary.Spread = 0
SWEP.Primary.Sound = "snds_jack_gmod/ez_weapons/auto_shotgun.wav"
SWEP.Primary.SoundFar = "snds_jack_gmod/ez_weapons/shotgun_far.wav"
SWEP.Primary.Force = 30
SWEP.ReloadTime = 1
SWEP.ShootWait = 0.15
SWEP.NumBullet = 2
SWEP.Sight = true
SWEP.TwoHands = true
SWEP.shotgun = true

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

------------------------------------------

SWEP.Weight					= 5
SWEP.AutoSwitchTo			= false
SWEP.AutoSwitchFrom			= false

SWEP.HoldType = "ar2"

------------------------------------------

SWEP.Slot					= 2
SWEP.SlotPos				= 0
SWEP.DrawAmmo				= true
SWEP.DrawCrosshair			= false

SWEP.ViewModel				= "models/pwb/weapons/w_protecta.mdl"
SWEP.WorldModel				= "models/pwb/weapons/w_protecta.mdl"

SWEP.vbwPos = Vector(.5, -5.5, 4)
SWEP.vbwAng = Angle(80, -140, 20)

SWEP.addAng = Angle(-3,0,0)
SWEP.addPos = Vector(-14,-0.7,-0.5)

SWEP.SightPos = Vector(-26,1,-0.5)

function SWEP:ApplyEyeSpray()
    self.eyeSpray = self.eyeSpray - Angle(5,math.Rand(-2,2),0)
end
end