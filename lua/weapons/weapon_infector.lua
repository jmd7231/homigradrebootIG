
AddCSLuaFile()

SWEP.PrintName = "Infector's Hands"
SWEP.Author = "WhangaTy"
SWEP.Category = "[HG] Special"
SWEP.Slot = 0
SWEP.SlotPos = 4

SWEP.Spawnable = true

SWEP.ViewModel = "models/weapons/c_zombieswep.mdl"
SWEP.WorldModel = ""
SWEP.ViewModelFOV = 90
SWEP.UseHands = true

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Damage = 0
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Damage = 0
SWEP.Secondary.Automatic = true
SWEP.Secondary.Ammo = "none"

SWEP.DrawAmmo = false

SWEP.HitDistance = 75

local SwingSound = Sound( "WeaponFrag.Throw" )
local HitSound = Sound( "Flesh.ImpactHard" )

function SWEP:Initialize()

	self:SetHoldType( "normal" )
	
	self.ActivityTranslate[ ACT_MP_STAND_IDLE ]					= ACT_HL2MP_IDLE_ZOMBIE
	self.ActivityTranslate[ ACT_MP_WALK ]						= ACT_HL2MP_WALK_ZOMBIE_01
	self.ActivityTranslate[ ACT_MP_RUN ]						= ACT_HL2MP_RUN_ZOMBIE
	self.ActivityTranslate[ ACT_MP_CROUCH_IDLE ]				= ACT_HL2MP_IDLE_CROUCH_ZOMBIE
	self.ActivityTranslate[ ACT_MP_CROUCHWALK ]					= ACT_HL2MP_WALK_CROUCH_ZOMBIE_01
	self.ActivityTranslate[ ACT_MP_ATTACK_STAND_PRIMARYFIRE ]	= ACT_GMOD_GESTURE_RANGE_ZOMBIE
	self.ActivityTranslate[ ACT_MP_ATTACK_CROUCH_PRIMARYFIRE ]	= ACT_GMOD_GESTURE_RANGE_ZOMBIE
	self.ActivityTranslate[ ACT_MP_JUMP ]						= ACT_ZOMBIE_LEAPING
	self.ActivityTranslate[ ACT_RANGE_ATTACK1 ]					= ACT_GMOD_GESTURE_RANGE_ZOMBIE

end

function SWEP:SetupDataTables()

	self:NetworkVar( "Float", 0, "NextMeleeAttack" )
	self:NetworkVar( "Float", 1, "NextIdle" )
	self:NetworkVar( "Int", 2, "Combo" )

end

function SWEP:UpdateNextIdle()

	local vm = self.Owner:GetViewModel()
	self:SetNextIdle( CurTime() + vm:SequenceDuration() / vm:GetPlaybackRate() )

end

function SWEP:PrimaryAttack( right )

	self.Owner:SetAnimation( PLAYER_ATTACK1 )

	local anim = "fists_left"
	if ( right ) then anim = "fists_right" end
	if ( self:GetCombo() >= 2 ) then
		anim = "fists_uppercut"
	end
	
	self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )

	self:EmitSound( SwingSound )

	self:UpdateNextIdle()
	self:SetNextMeleeAttack( CurTime() + 0.2 )

	self:SetNextPrimaryFire( CurTime() + 0.9 )
	self:SetNextSecondaryFire( CurTime() + 0.9 )

end

function SWEP:SecondaryAttack()

	self:PrimaryAttack( true )

end

local phys_pushscale = GetConVar( "phys_pushscale" )

function SWEP:DealDamage() -- dont deal damage, just change thier pm and role

	local anim = self:GetSequenceName(self.Owner:GetViewModel():GetSequence())

	self.Owner:LagCompensation( true )

	local tr = util.TraceLine( {
		start = self.Owner:GetShootPos(),
		endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * self.HitDistance,
		filter = self.Owner,
		mask = MASK_SHOT_HULL
	} )

	if ( !IsValid( tr.Entity ) ) then
		tr = util.TraceHull( {
			start = self.Owner:GetShootPos(),
			endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * self.HitDistance,
			filter = self.Owner,
			mins = Vector( -10, -10, -8 ),
			maxs = Vector( 10, 10, 8 ),
			mask = MASK_SHOT_HULL
		} )
	end

	-- We need the second part for single player because SWEP:Think is ran shared in SP
	if ( tr.Hit && !( game.SinglePlayer() && CLIENT ) ) then
		self:EmitSound( HitSound )
	end

	local hit = false
	local scale = phys_pushscale:GetFloat()

	local victimPly = tr.Entity

	if ( SERVER && IsValid( tr.Entity ) --[[&& tr.Entity:IsNPC() || tr.Entity:IsPlayer()  || (tr.Entity:Health() > 0 )]] ) then
		local attacker = self.Owner
		if ( !IsValid( attacker ) ) then attacker = self end

		local function infectPly(turningPly)
			if turningPly:Team() ~= 2 then print(turningPly:GetName().. " is already infected or police.") return end
			turningPly.roleT = true
			turningPly:SetTeam(1)
			turningPly:StripWeapons()
			turningPly:Give("weapon_hands")
			turningPly:Give("weapon_infector")

			turningPly:SelectWeapon("weapon_infector")

			turningPly:SetHealth(150)
			turningPly:SetMaxHealth(150)
			turningPly:SetWalkSpeed(250)
			turningPly:SetRunSpeed(450)

			turningPly.adrenaline = 0

			turningPly.adrenaline = turningPly.adrenaline + 2

			turningPly:SetColor(Color(78, 194, 0, 255))

			for _, ply in pairs(player.GetAll()) do
				ply:ConCommand("hg_subtitle \"" ..victimPly:GetName().. " has been infected!\" red")
				ply:EmitSound("ambient/machines/thumper_hit.wav", 90, 70, 1)
			end
			
			turningPly:EmitSound("vo/npc/male01/pain0" ..math.random(1, 9).. ".wav", 100, 100, 1)
			util.ScreenShake(turningPly:GetPos(), 10, 5, 2, 1000)
		end

		if victimPly:IsPlayer() and victimPly:Alive() and victimPly ~= self.Owner then
			if victimPly:Team() ~= 3 then
				infectPly(victimPly)
			else

				local dmginfo = DamageInfo()
				dmginfo:SetAttacker( attacker )
				dmginfo:SetInflictor( self )

				dmginfo:SetDamageForce( self.Owner:GetForward() * 14910 * scale ) -- Yes we need those specific numbers
				dmginfo:SetDamage(1000)
				tr.Entity:TakeDamageInfo( dmginfo )
			end
		end
		
		SuppressHostEvents( NULL ) -- Let the breakable gibs spawn in multiplayer on client
		SuppressHostEvents( self.Owner )

		hit = true
	end

	if ( IsValid( tr.Entity ) ) then
		local phys = tr.Entity:GetPhysicsObject()
		if ( IsValid( phys ) ) then
			phys:ApplyForceOffset( self.Owner:GetAimVector() * 80 * phys:GetMass() * scale, tr.HitPos )
		end
	end

	if ( SERVER ) then
		if ( hit && anim != "fists_uppercut" ) then
			self:SetCombo( self:GetCombo() + 1 )
		else
			self:SetCombo( 0 )
		end
	end

	self.Owner:LagCompensation( false )

end

function SWEP:OnDrop()

	self:Remove() -- You can't drop the infection item

end

function SWEP:Deploy()

	local speed = GetConVarNumber( "sv_defaultdeployspeed" )
	
	local vm = self.Owner:GetViewModel()
	self:SetPlaybackRate( speed )

	self:SetNextPrimaryFire( CurTime() + vm:SequenceDuration() / speed )
	self:SetNextSecondaryFire( CurTime() + vm:SequenceDuration() / speed )
	self:UpdateNextIdle()

	if ( SERVER ) then
		self:SetCombo( 0 )
	end

	return true

end

function SWEP:Holster()

	self:SetNextMeleeAttack( 0 )

	return true

end

function SWEP:Think()

	local vm = self.Owner:GetViewModel()
	local curtime = CurTime()
	local idletime = self:GetNextIdle()

	if ( idletime > 0 && CurTime() > idletime ) then

		self:SendWeaponAnim( ACT_VM_IDLE )

		self:UpdateNextIdle()

	end

	local meleetime = self:GetNextMeleeAttack()

	if ( meleetime > 0 && CurTime() > meleetime ) then

		self:DealDamage()

		self:SetNextMeleeAttack( 0 )

	end

	if ( SERVER && CurTime() > self:GetNextPrimaryFire() + 0.1 ) then

		self:SetCombo( 0 )

	end

end
