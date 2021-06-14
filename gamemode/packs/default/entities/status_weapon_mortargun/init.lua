AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/props_trainstation/trashcan_indoor001b.mdl")
	self:DrawShadow(false)
end

function ENT:Think()
end

function ENT:KeyPress(pl, box, key)
	if key == IN_ATTACK and self:GetNextAttack() <= CurTime() then
		local dir = pl:GetAimVector()
		local pos = box:GetPos() + dir * 4

		self:SetNextAttack(CurTime() + 5)

		local ent = ents.Create("projectile_mortar")
		ent:SetPos(pos)
		ent:SetAngles(dir:Angle())
		ent:SetOwner(box)
		ent:SetColor(box:GetColor())
		ent:Spawn()
		ent.Owner = pl

		ent:GetPhysicsObject():SetVelocityInstantaneous(dir * 1100)

		pl:EmitSound("npc/env_headcrabcanister/launch.wav")

		self:NextThink(CurTime())
	end
end

function ENT:PlayerSet(pPlayer, eBox, bExists)
	pPlayer:RemoveStatus("weapon_*", true, true, "status_weapon_mortargun")
	eBox.Weapon = self
	if not bExists then
		pPlayer:EmitSound("mayhem/powerup.wav")
	end

	local effectdata = EffectData()
		effectdata:SetOrigin(eBox:GetPos())
		effectdata:SetEntity(eBox)
	util.Effect("boxpoweredup", effectdata)
end
