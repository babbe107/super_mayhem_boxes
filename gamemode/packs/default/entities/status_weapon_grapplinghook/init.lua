AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/weapons/w_crossbow.mdl")
	self:DrawShadow(false)
end

function ENT:Think()
end

function ENT:OnRemove()
	for _, ent in pairs(ents.FindByClass("projectile_grapplinghook")) do
		if ent.Owner == self:GetOwner() then ent:Remove() end
	end
end

function ENT:KeyPress(pl, box, key)
	if CurTime() < self:GetNextAttack() then return end

	if key == IN_ATTACK then
		for _, ent in pairs(ents.FindByClass("projectile_grapplinghook")) do
			if ent.Owner == box then ent:Remove() end
		end

		self:SetNextAttack(CurTime() + 1)

		local dir = pl:GetAimVector()
		local ent = ents.Create("projectile_grapplinghook")
		ent:SetPos(box:GetPos() + dir * 8)
		ent:SetAngles(dir:Angle())
		ent:SetOwner(box)
		ent:SetColor(box:GetColor())
		ent:Spawn()
		ent.Owner = box

		--local cons, rope = constraint.Elastic(box, ent, 0, 0, Vector(0,0,0), dir * -4, 400, 40, 0, "cable/rope", 4.5, true)
		--cons:Fire("SetSpringLength", 225, 0)
		--rope:Fire("SetLength", 225, 0)

		--ent.Constraint, ent.Rope = cons, rope

		ent:GetPhysicsObject():SetVelocityInstantaneous(dir * 1400)

		pl:EmitSound("Weapon_Crossbow.Single")

		self:NextThink(CurTime())
	elseif key == IN_ATTACK2 or key == IN_RELOAD then
		for _, ent in pairs(ents.FindByClass("projectile_grapplinghook")) do
			if ent.Owner == box then ent:Remove() end
		end

		self:NextThink(CurTime())
	end
end

function ENT:PlayerSet(pPlayer, eBox, bExists)
	pPlayer:RemoveStatus("weapon_*", true, true, "status_weapon_grapplinghook")
	eBox.Weapon = self
	if not bExists then
		pPlayer:EmitSound("mayhem/powerup.wav")
	end

	local effectdata = EffectData()
		effectdata:SetOrigin(eBox:GetPos())
		effectdata:SetEntity(eBox)
	util.Effect("boxpoweredup", effectdata)
end
