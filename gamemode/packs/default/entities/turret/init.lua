AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/Combine_turrets/Floor_turret.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:GetPhysicsObject():EnableMotion(false)

	self.NextFire = 0
	self.Target = NULL
	self.PHealth = 50
end

function ENT:Think()
	local target = self.Target
	if self.Exploded then
		self:Remove()
	elseif target:IsValid() then
		local mypos = self:GetPos() + self:GetUp() * 64
		local searchpos = mypos + self:GetForward() * 500
		local targetpos = target:GetPos()
		if target:VisibleVec(mypos) and targetpos:Distance(searchpos) < 490 then
			local aimvec = (targetpos - mypos):GetNormalized()
			local dumang = Angle()
			local dir = aimvec
			dir:Rotate(Angle(0, 0, math.Rand(-10, 10)))
			local ent = ents.Create("projectile_physicalbullet")
			ent:SetAngles(dir:Angle())
			ent:SetPos(mypos + dir * 5)
			ent:SetOwner(self)
			ent:SetColor(self:GetColor())
			ent:Spawn()
			ent.Owner = self.Owner
			ent.Inflictor = self
			ent.Damage = 6
			ent.TeamID = self.Team
			ent.HitEffect = "bullethit"
			ent:GetPhysicsObject():SetVelocityInstantaneous(dir * 2000)

			self:EmitSound("Weapon_AR2.Single")
		else
			self.Target = NULL
		end

		self:NextThink(CurTime() + 0.1)
	else
		for _, ent in pairs(ents.FindInSphere(self:GetPos() + self:GetUp() * 64 + self:GetForward() * 500, 490)) do
			if ent:GetClass() == "boxplayer" and ent:Team() ~= self.Team and ent:VisibleVec(self:GetPos() + self:GetUp() * 64) then
				self.Target = ent
				break
			end
		end
		self:NextThink(CurTime() + 0.5)
	end

	return true
end

function ENT:Explode()
	if self.Exploded then return end
	self.Exploded = true
	self.Gone = true

	self:NextThink(CurTime())

	local effectdata = EffectData()
		local mypos = self:GetPos() + Vector(0,0,8)
		effectdata:SetOrigin(mypos)
	util.Effect("Explosion", effectdata, true, true)

	util.BlastDamage(self, self.Owner, mypos, 100, 80)
end

function ENT:OnTakeDamage(dmginfo)
	self.PHealth = self.PHealth - dmginfo:GetDamage()
	if self.PHealth <= 0 then
		self:Explode()
	end
end
