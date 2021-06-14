AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/weapons/w_grenade.mdl")
	self:SetGravity(0.5)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	local phys = self:GetPhysicsObject()
	phys:EnableDrag(false)
	phys:SetMass(5)
	phys:Wake()

	self.DeathTime = self.DeathTime or CurTime() + 4
end

function ENT:Think()
	if self.DeathTime < CurTime() and not self.Exploded then
		self.Exploded = true

		local pos = self:GetPos()

		util.BlastDamage(self, self.Owner, pos, 300, 120)

		local effectdata = EffectData()
			effectdata:SetOrigin(pos)
		util.Effect("Explosion", effectdata)

		self:Remove()
	end
end

