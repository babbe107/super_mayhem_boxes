-- This is a very nice base for any explosive projectiles.

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/weapons/w_missile_closed.mdl")
	self:SetGravity(0.5)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	local phys = self:GetPhysicsObject()
	phys:EnableDrag(false)
	phys:SetMass(150)
	phys:Wake()

	self.DeathTime = CurTime() + 10
end

function ENT:Think()
	-- ToDo: Fix angle of bazooka missile
	-- local vel = self:GetVelocity()
	-- print(vel:AngleEx( Vector( 0, 0, 1 )))
	-- print(self:GetAngles())
	-- print("-----------")
	-- self:SetAngles(self:GetVelocity():AngleEx( Vector( 0, 0, 1 )))

	if self.Exploded then
		self:Remove()
	elseif self.PhysicsData then
		self:Explode(self.PhysicsData.HitPos, self.PhysicsData.HitNormal)
	elseif self.DeathTime < CurTime() or 0 < self:WaterLevel() then -- Hit water, explode. Probably not the most realistic thing.
		self:Explode()
	end
end

function ENT:PhysicsCollide(data, phys)
	if not (data.HitEntity:IsValid() and data.HitEntity:GetClass() == "projectile_grapplinghook") then -- Allow a grappling hook to hit us without exploding.
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

		util.BlastDamage(self, self.Owner, hitpos, 300, 120)

		local effectdata = EffectData()
		effectdata:SetOrigin(hitpos)
		effectdata:SetNormal(hitnormal)
		util.Effect("bazookaexplosion", effectdata)
	end
end
