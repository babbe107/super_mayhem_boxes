AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/props_combine/combine_mine01.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:GetPhysicsObject():EnableMotion(false)

	self:SetTrigger(true)
end

function ENT:Think()
	if self.Exploded then self:Remove() end
end

function ENT:Explode()
	if self.Exploded then return end
	self.Exploded = true
	self.Gone = true

	local effectdata = EffectData()
		local mypos = self:GetPos() + Vector(0,0,8)
		effectdata:SetOrigin(mypos)
	util.Effect("Explosion", effectdata, true, true)

	util.BlastDamage(self, self.Owner, mypos, 200, 150)
end

function ENT:StartTouch(ent)
	if ent:GetClass() == "boxplayer" and ent:Team() ~= self.Team then
		self.ArmedBy = ent
		self:EmitSound("HL1/fvox/activated.wav")
	end
end

function ENT:Touch(ent)
end

-- Don't explode until they 'step off' the mine.
function ENT:EndTouch(ent)
	if self.ArmedBy and ent == self.ArmedBy then
		self:Explode()
	end
end

function ENT:OnTakeDamage(dmginfo)
	self:Explode()
end
