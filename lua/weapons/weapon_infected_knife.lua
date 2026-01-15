AddCSLuaFile()

SWEP.PrintName = "Infected Knife"
SWEP.Author = "Homigrad"
SWEP.Category = "[HG] Special"
SWEP.Slot = 0
SWEP.SlotPos = 4

SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.ViewModel = "models/weapons/cstrike/c_knife_t.mdl"
SWEP.WorldModel = "models/weapons/w_knife_t.mdl"
SWEP.ViewModelFOV = 70
SWEP.UseHands = true

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Damage = 10
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Damage = 0
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

SWEP.DrawAmmo = false

SWEP.HitDistance = 75

local SwingSound = Sound("WeaponFrag.Throw")
local HitSound = Sound("Flesh.ImpactHard")

function SWEP:Initialize()
	self:SetHoldType("knife")
end

function SWEP:SetupDataTables()
	self:NetworkVar("Float", 0, "NextMeleeAttack")
	self:NetworkVar("Float", 1, "NextIdle")
end

function SWEP:UpdateNextIdle()
	local vm = self.Owner:GetViewModel()
	self:SetNextIdle(CurTime() + vm:SequenceDuration() / vm:GetPlaybackRate())
end

function SWEP:PrimaryAttack()
	self.Owner:SetAnimation(PLAYER_ATTACK1)
	self:SendWeaponAnim(ACT_VM_HITCENTER)
	self:EmitSound(SwingSound)

	self:UpdateNextIdle()
	self:SetNextMeleeAttack(CurTime() + 0.1)
	self:SetNextPrimaryFire(CurTime() + 0.8)
	self:SetNextSecondaryFire(CurTime() + 0.8)
end

function SWEP:SecondaryAttack()
	return
end

local phys_pushscale = GetConVar("phys_pushscale")

function SWEP:DealDamage()
	self.Owner:LagCompensation(true)

	local tr = util.TraceLine({
		start = self.Owner:GetShootPos(),
		endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * self.HitDistance,
		filter = self.Owner,
		mask = MASK_SHOT_HULL
	})

	if not IsValid(tr.Entity) then
		tr = util.TraceHull({
			start = self.Owner:GetShootPos(),
			endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * self.HitDistance,
			filter = self.Owner,
			mins = Vector(-10, -10, -8),
			maxs = Vector(10, 10, 8),
			mask = MASK_SHOT_HULL
		})
	end

	if tr.Hit and not (game.SinglePlayer() and CLIENT) then
		self:EmitSound(HitSound)
	end

	local scale = phys_pushscale:GetFloat()

	if SERVER and IsValid(tr.Entity) and (tr.Entity:IsNPC() or tr.Entity:IsPlayer() or tr.Entity:Health() > 0) then
		local dmginfo = DamageInfo()
		local attacker = self.Owner
		if not IsValid(attacker) then attacker = self end
		dmginfo:SetAttacker(attacker)
		dmginfo:SetInflictor(self)
		dmginfo:SetDamage(self.Primary.Damage)
		dmginfo:SetDamageType(DMG_SLASH)
		dmginfo:SetDamageForce(self.Owner:GetForward() * 12000 * scale)

		SuppressHostEvents(NULL)
		tr.Entity:TakeDamageInfo(dmginfo)
		SuppressHostEvents(self.Owner)
	end

	if IsValid(tr.Entity) then
		local phys = tr.Entity:GetPhysicsObject()
		if IsValid(phys) then
			phys:ApplyForceOffset(self.Owner:GetAimVector() * 80 * phys:GetMass() * scale, tr.HitPos)
		end
	end

	self.Owner:LagCompensation(false)
end

function SWEP:OnDrop()
	self:Remove()
end

function SWEP:Deploy()
	local speed = GetConVarNumber("sv_defaultdeployspeed")
	local vm = self.Owner:GetViewModel()
	self:SendWeaponAnim(ACT_VM_DRAW)
	self:SetPlaybackRate(speed)
	self:SetNextPrimaryFire(CurTime() + vm:SequenceDuration() / speed)
	self:SetNextSecondaryFire(CurTime() + vm:SequenceDuration() / speed)
	self:UpdateNextIdle()
	return true
end

function SWEP:Holster()
	self:SetNextMeleeAttack(0)
	return true
end

function SWEP:Think()
	local curtime = CurTime()
	if self:GetNextMeleeAttack() > 0 and curtime > self:GetNextMeleeAttack() then
		self:DealDamage()
		self:SetNextMeleeAttack(0)
	end

	local idletime = self:GetNextIdle()
	if idletime > 0 and curtime > idletime then
		self:SendWeaponAnim(ACT_VM_IDLE)
		self:UpdateNextIdle()
	end
end
