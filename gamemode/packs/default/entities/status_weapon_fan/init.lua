AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/props_citizen_tech/windmill_blade004a.mdl")
	self:DrawShadow(false)
end

function ENT:Think()
	local owner = self:GetOwner()
	local player = owner:GetOwner()
	if player:KeyDown(IN_ATTACK) then
		if not self:GetSpinning() then self:SetSpinning(true) end

		local aimvec = player:GetAimVector()
		local vel = 39000 * FrameTime() * aimvec
		local mypos = owner:GetPos()
		local pos = mypos + aimvec * owner:BoundingRadius()
		local plteam = player:Team()
		for _, ent in pairs(ents.FindInSphere(pos, 140)) do
			if not (ent == owner or string.sub(ent:GetClass(), 1, 5) == "func_" or ent:GetClass() == "boxplayer" and ent:Team() == plteam) then
				local phys = ent:GetPhysicsObject()
				if phys:IsValid() and phys:IsMoveable() then
					if ent:GetClass() == "projectile_bazookamissile" then
						phys:ApplyForceOffset(vel * 10, ent:NearestPoint(mypos))
					else
						phys:ApplyForceOffset(vel, ent:NearestPoint(mypos))
					end
					if ent:GetClass() == "boxplayer" then
						local enemy = ent:GetOwner()
						enemy.LastAttacker = player
						enemy.LastAttacked = CurTime()
					end
				end
			end
		end

		-- if util.PointContents(pos) & CONTENTS_WATER == 32 then
		if bit.band( util.PointContents(pos), CONTENTS_WATER ) == CONTENTS_WATER then
			owner:GetPhysicsObject():ApplyForceCenter(vel * -1)
		end
	elseif self:GetSpinning() then
		self:SetSpinning(false)
	end

	self:NextThink(CurTime())
	return true
end

function ENT:KeyPress(pl, box, key)
end

function ENT:PlayerSet(pPlayer, eBox, bExists)
	pPlayer:RemoveStatus("weapon_*", true, true, "status_weapon_fan")
	eBox.Weapon = self
	if not bExists then
		eBox:EmitSound("mayhem/powerup.wav")
	end

	local effectdata = EffectData()
		effectdata:SetOrigin(eBox:GetPos())
		effectdata:SetEntity(eBox)
	util.Effect("boxpoweredup", effectdata)
end
