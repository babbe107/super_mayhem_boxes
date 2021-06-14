AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

ENT.Damage = 10

function ENT:Initialize()
	--self:SetModel("models/crossbow_bolt.mdl")
	self:SetModel("models/Weapons/w_bullet.mdl")
	self:DrawShadow(false)
	self:PhysicsInitSphere(1)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
	local phys = self:GetPhysicsObject()
	phys:EnableDrag(false)
	phys:EnableGravity(false)
	phys:SetBuoyancyRatio(0.075)
	phys:Wake()

	self.DeathTime = CurTime() + 5
end

function ENT:Think()
	if self.PhysicsThink then
		local data = self.PhysicsThink

		local ent = data.HitEntity
		if ent:IsValid() then
			ent:TakeDamage(self.Damage, self.Owner, self.Inflictor or self)
		end

		if self.HitEffect then
			local effectdata = EffectData()
				effectdata:SetOrigin(data.HitPos)
				effectdata:SetNormal(data.HitNormal)
				effectdata:SetMagnitude(self.TeamID)
			util.Effect(self.HitEffect, effectdata)
		end

		self:Remove()
	elseif self.DeathTime < CurTime() then
		self:Remove()
	end
end

function ENT:PhysicsCollide(data, phys)
	if 0 < self.DeathTime then
		self.DeathTime = 0
		self.PhysicsThink = data
		self:NextThink(CurTime())
	end
end
