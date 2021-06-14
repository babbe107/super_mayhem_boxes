AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/airboatgun.mdl")
	self:DrawShadow(false)
end

function ENT:Think()
	local owner = self:GetOwner()
	local player = owner:GetOwner()
	if player:IsValid() and player:KeyDown(IN_ATTACK) then
		self:KeyPress(player, owner, IN_ATTACK)
		self:NextThink(CurTime())
		return true
	end
end

function ENT:KeyPress(pl, box, key)
	if key == IN_ATTACK and self:GetNextAttack() <= CurTime() then
		self:SetNextAttack(CurTime() + 0.085)

		local aimvec = pl:GetAimVector()
		local dumang = Angle()
		local boxpos = box:GetPos()
		local dir = aimvec
		dir:Rotate(Angle(0, 0, math.Rand(-8, 8)))
		local ent = ents.Create("projectile_physicalbullet")
		ent:SetAngles(dir:Angle())
		ent:SetPos(boxpos + dir * 8)
		ent:SetOwner(box)
		ent:SetColor(box:GetColor())
		ent:Spawn()
		ent.Owner = pl
		ent.Inflictor = self
		ent.Damage = 5
		ent.TeamID = pl:Team()
		ent.HitEffect = "bullethit"
		ent:GetPhysicsObject():SetVelocityInstantaneous(dir * 2000)

		pl:EmitSound("Weapon_AR2.Single")

		box:GetPhysicsObject():ApplyForceCenter(aimvec * -10)

		self:NextThink(CurTime())
	end
end

function ENT:PlayerSet(pPlayer, eBox, bExists)
	pPlayer:RemoveStatus("weapon_*", true, true, "status_weapon_minigun")
	eBox.Weapon = self
	if not bExists then
		pPlayer:EmitSound("mayhem/powerup.wav")
	end

	local effectdata = EffectData()
		effectdata:SetOrigin(eBox:GetPos())
		effectdata:SetEntity(eBox)
	util.Effect("boxpoweredup", effectdata)
end
