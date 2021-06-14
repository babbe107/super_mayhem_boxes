AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/weapons/w_smg1.mdl")
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
		self:SetNextAttack(CurTime() + 0.18)

		local dir = pl:GetAimVector()
		dir:Rotate(Angle(0, 0, math.Rand(-5, 5)))
		local ent = ents.Create("projectile_physicalbullet")
		ent:SetAngles(dir:Angle())
		ent:SetPos(box:GetPos() + dir * 8)
		ent:SetOwner(box)
		ent:SetColor(box:GetColor())
		ent:Spawn()
		ent.Owner = pl
		ent.Inflictor = self
		ent.Damage = 6
		ent.TeamID = pl:Team()
		ent.HitEffect = "bullethit"
		ent:GetPhysicsObject():SetVelocityInstantaneous(dir * 1900)

		pl:EmitSound("Weapon_AR2.NPC_Single")

		self:NextThink(CurTime())
	end
end

function ENT:PlayerSet(pPlayer, eBox, bExists)
	pPlayer:RemoveStatus("weapon_*", true, true, "status_weapon_smg")
	eBox.Weapon = self
	if not bExists then
		pPlayer:EmitSound("mayhem/powerup.wav")
	end

	local effectdata = EffectData()
		effectdata:SetOrigin(eBox:GetPos())
		effectdata:SetEntity(eBox)
	util.Effect("boxpoweredup", effectdata)
end
