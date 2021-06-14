AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self:DrawShadow(false)
end

function ENT:Think()
	if self.NextFire and self.NextFire < CurTime() then
		local box = self:GetOwner()
		local pl = box:GetOwner()
		local dir = pl:GetAimVector()
		local ent = ents.Create("projectile_kamehameha")
		local startpos = box:GetPos() + dir * 8
		ent:SetPos(startpos)
		ent:SetOwner(box)
		ent:SetColor(box:GetColor())
		ent:Spawn()
		ent.Owner = pl
		ent.Box = box
		ent:GetPhysicsObject():SetVelocityInstantaneous(dir * 750)
		ent:SetDTVector(0, startpos)

		box:GetPhysicsObject():EnableMotion(false)
		box:EmitSound("mayhem/kamehameha_fire.wav")

		self:Remove()
	end
end

function ENT:KeyPress(pl, box, key)
	if key == IN_ATTACK and not self.NextFire then
		self.NextFire = CurTime() + 5
		self:SetDTFloat(0, self.NextFire)

		pl:EmitSound("mayhem/kame_charge.wav", 92, 100)
	end
end

function ENT:PlayerSet(pPlayer, eBox, bExists)
	pPlayer:RemoveStatus("weapon_*", true, true, "status_weapon_kamehameha")
	eBox.Weapon = self
	if not bExists then
		pPlayer:EmitSound("mayhem/powerup.wav")
	end

	local effectdata = EffectData()
		effectdata:SetOrigin(eBox:GetPos())
		effectdata:SetEntity(eBox)
	util.Effect("boxpoweredup", effectdata)
end
