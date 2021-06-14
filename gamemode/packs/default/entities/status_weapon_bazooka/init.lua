AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

util.PrecacheSound("Missile.Ignite")

function ENT:Initialize()
	self:SetModel("models/weapons/w_rocket_launcher.mdl")
	self:DrawShadow(false)
end

function ENT:Think()
end

function ENT:KeyPress(pl, box, key)
	if key == IN_ATTACK and self:GetNextAttack() <= CurTime() then
		local dir = pl:GetAimVector()
		local pos = box:GetPos() + dir * 4 + dir:Angle():Up() * 16
		-- if util.PointContents(pos) and CONTENTS_WATER ~= 32 then
		if bit.band( util.PointContents(pos), CONTENTS_WATER ) ~= CONTENTS_WATER then
			self:SetNextAttack(CurTime() + 7.5)

			local ent = ents.Create("projectile_bazookamissile")
			ent:SetPos(pos)
			ent:SetAngles(dir:Angle())
			ent:SetOwner(box)
			ent:SetColor(box:GetColor())
			ent:Spawn()
			ent.Owner = pl

			ent:GetPhysicsObject():SetVelocityInstantaneous(dir * 1100)

			pl:EmitSound("Weapon_RPG.Single")

			self:NextThink(CurTime())
		end
	end
end

function ENT:PlayerSet(pPlayer, eBox, bExists)
	pPlayer:RemoveStatus("weapon_*", true, true, "status_weapon_bazooka")
	eBox.Weapon = self
	if not bExists then
		pPlayer:EmitSound("mayhem/powerup.wav")
	end

	local effectdata = EffectData()
		effectdata:SetOrigin(eBox:GetPos())
		effectdata:SetEntity(eBox)
	util.Effect("boxpoweredup", effectdata)
end
