-- This projectile explodes on contact but only 1 second after it has been created.

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/Combine_Helicopter/helicopter_bomb01.mdl")
	self:SetGravity(0.5)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	local phys = self:GetPhysicsObject()
	phys:EnableDrag(false)
	phys:SetMass(130)
	phys:SetBuoyancyRatio(0.3)
	phys:Wake()

	self.DeathTime = CurTime() + 15
	self.AllowExplode = CurTime() + 2
end

-- Don't explode just yet. Doing so in this function can crash the physics!
function ENT:PhysicsCollide(data, phys)
	if 64 <= data.Speed and 0.2 <= data.DeltaTime then
		self:EmitSound("physics/metal/metal_barrel_impact_hard"..math.random(5, 6)..".wav")
	end

	if self.AllowExplode <= CurTime() and not (data.HitEntity:IsValid() and data.HitEntity:GetClass() == "projectile_grapplinghook") then
		self.PhysicsData = data
		self:NextThink(CurTime())
	end
end

function ENT:Explode(hitpos, hitnormal)
	if not self.Exploded then
		self.Exploded = true
		self.DeathTime = 0
		self.PhysicsData = nil

		self:NextThink(CurTime())

		hitpos = hitpos or self:GetPos()
		hitnormal = hitnormal or Vector(0, 0, 1)

		self:GetPhysicsObject():EnableMotion(false)

		util.BlastDamage(self, self.Owner, hitpos, 420, 60)

		local effectdata = EffectData()
			effectdata:SetOrigin(hitpos)
			effectdata:SetNormal(hitnormal)
		util.Effect("explosion_mortar", effectdata)
	end
end

local trace = {mask = MASK_SOLID, mins = Vector(-8, -8, -2), maxs = Vector(8, 8, 2)}
function ENT:Think()
	if self.Exploded then
		self:Remove()
	elseif self.PhysicsData then
		self:Explode(self.PhysicsData.HitPos, self.PhysicsData.HitNormal)
	elseif self.DeathTime < CurTime() or self.AllowExplode <= CurTime() then
		trace.start = self:GetPos()
		trace.endpos = trace.start + Vector(0, 0, -16)
		trace.filter = self
		if util.TraceHull(trace).Hit then
			self:Explode(self:GetPos(), Vector(0, 0, -1))
		end
	end
end
