AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self:DrawShadow(false)
end

function ENT:Think()
end

function ENT:KeyPress(pl, box, key)
	if key == IN_ATTACK and self:GetNextAttack() <= CurTime() then
		local dir = pl:GetAimVector()
		local boxpos = box:GetPos()
		local pos = boxpos + dir * 2
		-- if util.PointContents(pos) and CONTENTS_WATER ~= 32 then
		if bit.band( util.PointContents(pos), CONTENTS_WATER ) ~= CONTENTS_WATER then	
			self:SetNextAttack(CurTime() + 2)
			local myteam = pl:Team()
			dir:Rotate(Angle(0, 0, math.Rand(-7, 7)))
			local ent = ents.Create("projectile_mom")
			ent:SetPos(pos)
			ent:SetOwner(box)
			ent:SetColor(box:GetColor())
			ent:Spawn()
			ent.Owner = pl
			ent.Team = myteam
			ent:GetPhysicsObject():SetVelocityInstantaneous(dir * 600)

			pl:EmitSound("nox/missilesofmagic.wav")

			self:NextThink(CurTime())
		end
	end
end

function ENT:PlayerSet(pPlayer, eBox, bExists)
	pPlayer:RemoveStatus("weapon_*", true, true, "status_weapon_mom")
	eBox.Weapon = self
	if not bExists then
		pPlayer:EmitSound("mayhem/powerup.wav")
	end

	local effectdata = EffectData()
		effectdata:SetOrigin(eBox:GetPos())
		effectdata:SetEntity(eBox)
	util.Effect("boxpoweredup", effectdata)
end
