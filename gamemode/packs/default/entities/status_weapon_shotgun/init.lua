AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/weapons/w_shotgun.mdl")
	self:DrawShadow(false)
	self.NextPump = 0
	self.Pumped = true
end

function ENT:Think()
	if not self.Pumped and self.NextPump < CurTime() then
		local pl = self:GetOwner():GetOwner()
		pl:EmitSound("Weapon_Shotgun.Special1")
		self.Pumped = true
		local effectdata = EffectData()
			effectdata:SetOrigin(self:GetPos() + pl:GetAimVector() * 32)
		util.Effect("ShotgunShellEject", effectdata)
	end
end

function ENT:KeyPress(pl, box, key)
	if key == IN_ATTACK and self.Pumped and self:GetNextAttack() <= CurTime() then
		self:SetNextAttack(CurTime() + 2.25)
		self.NextPump = CurTime() + 0.7
		self.Pumped = false

		local aimvec = pl:GetAimVector()
		local boxpos = box:GetPos()
		local teamid = pl:Team()
		for i=1, 10 do
			local dir = aimvec
			dir:Rotate(Angle(0, 0, math.Rand(-7, 7)))
			local ent = ents.Create("projectile_physicalbullet")
			ent:SetAngles(dir:Angle())
			ent:SetPos(boxpos + dir * 8)
			ent:SetOwner(box)
			ent:SetColor(box:GetColor())
			ent:Spawn()
			ent.Owner = pl
			ent.Inflictor = self
			ent.Damage = 7
			ent.TeamID = teamid
			ent.HitEffect = "bullethit"
			ent:GetPhysicsObject():SetVelocityInstantaneous(dir * 1900)
		end

		pl:EmitSound("Weapon_Shotgun.Double")

		box:GetPhysicsObject():ApplyForceCenter(aimvec * -8100)

		self:NextThink(CurTime())
	end
end

function ENT:PlayerSet(pPlayer, eBox, bExists)
	pPlayer:RemoveStatus("weapon_*", true, true, "status_weapon_shotgun")
	eBox.Weapon = self
	if not bExists then
		pPlayer:EmitSound("mayhem/powerup.wav")
	end

	local effectdata = EffectData()
		effectdata:SetOrigin(eBox:GetPos())
		effectdata:SetEntity(eBox)
	util.Effect("boxpoweredup", effectdata)
end
