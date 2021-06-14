AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self:DrawShadow(false)
	self:PhysicsInitSphere(2)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:EnableDrag(false)
		phys:EnableGravity(false)
		phys:Wake()
	end

	self.DeathTime = CurTime() + 10
	self.Target = NULL
end

function ENT:Think()
	if self.Exploded then
		self:Remove()
	elseif self.DeathTime < CurTime() or 0 < self:WaterLevel() then
		self:Explode()
	else
		if not self.Trailed then
			self.Trailed = true
			util.SpriteTrail(self, 0, Color(255, 255, 120, 160), false, 22, 16, 1, 42, "trails/smoke.vmt")
		end

		local owner = self.Owner
		if owner:IsValid() and owner:Alive() then
			self:GetPhysicsObject():SetVelocityInstantaneous(1000 * owner:GetAimVector())
			self:NextThink(CurTime())
			return true
		end
	end
end

function ENT:PhysicsCollide(data, physobj)
	if not (data.HitEntity:IsValid() and data.HitEntity:GetClass() == "projectile_grapplinghook") then -- Like the bazooka, don't explode if it hits a grappling hook.
		self:Explode(data.HitPos, data.HitNormal)
	end
end

function ENT:Explode(hitpos, hitnormal)
	if self.Exploded then return end
	self.Exploded = true
	self.DeathTime = -10

	local owner = self.Owner
	if not owner:IsValid() then owner = self end

	local effectdata = EffectData()
		if type(hitpos) == "table" then
			effectdata:SetOrigin(hitpos.HitPos)
			util.BlastDamage(self, owner, hitpos.HitPos, 100, 29)
		else
			hitpos = hitpos or self:GetPos()
			util.BlastDamage(self, owner, hitpos, 100, 29)
			effectdata:SetOrigin(hitpos)
		end
		effectdata:SetNormal(hitnormal or Vector(0,0,1))
	util.Effect("magicmissileexplosion", effectdata)

	self:NextThink(CurTime())
end

function ENT:UpdateTransmitState()
	return TRANSMIT_PVS
end
