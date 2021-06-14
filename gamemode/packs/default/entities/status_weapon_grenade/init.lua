AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/weapons/w_grenade.mdl")
	self:DrawShadow(false)
end

function ENT:Think()
end

function ENT:KeyPress(pl, box, key)
	if (key == IN_ATTACK or key == IN_ATTACK2) and self:GetNextAttack() <= CurTime() then
		self:SetNextAttack(CurTime() + 3.5)

		local dir = pl:GetAimVector()
		local ent = ents.Create("projectile_grenade")
		ent:SetPos(box:GetPos() + dir * 8)
		ent:SetColor(box:GetColor())
		ent:Spawn()
		ent.Owner = pl
		ent.Inflictor = self
		local phys = ent:GetPhysicsObject()
		local vel = box:GetVelocity()
		phys:SetVelocityInstantaneous(dir * 700 + vel)
		--print(vel:Length())
		--print(math.Clamp(vel:Length() * 0.005, 1.25, 8))
		phys:AddAngleVelocity(math.Clamp(vel:Length() * 0.005, 1.25, 8) * VectorRand():Angle():Forward()) --:Angle())
		if key == IN_ATTACK2 then
			ent.DeathTime = CurTime() + 3
		end

		pl:EmitSound("Weapon_Crowbar.Single")

		self:NextThink(CurTime())
	end
end

function ENT:PlayerSet(pPlayer, eBox, bExists)
	pPlayer:RemoveStatus("weapon_*", true, true, "status_weapon_grenade")
	eBox.Weapon = self
	if not bExists then
		pPlayer:EmitSound("mayhem/powerup.wav")
	end

	local effectdata = EffectData()
		effectdata:SetOrigin(eBox:GetPos())
		effectdata:SetEntity(eBox)
	util.Effect("boxpoweredup", effectdata)
end
