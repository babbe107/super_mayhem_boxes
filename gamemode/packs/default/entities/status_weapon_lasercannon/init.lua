AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/weapons/w_Physics.mdl")
	self:DrawShadow(false)
end

function ENT:Think()
	local box = self:GetOwner()
	if box:IsValid() then
		local owner = box:GetOwner()
		if owner:IsValid() and self:GetCharge() > 0 then
			if owner:KeyDown(IN_ATTACK) then
				self:SetCharge(self:GetCharge() + FrameTime() * 10)
			else
				local charged = self:GetCharge()
				self:SetCharge(0)
				self:SetNextAttack(CurTime() + 2)

				local dir = owner:GetAimVector()
				local startpos = box:GetPos() + dir * 8
				local tr = util.TraceLine({start=startpos, endpos=startpos + dir * 12000, filter=box})

				local effectdata = EffectData()
					effectdata:SetOrigin(tr.HitPos)
					effectdata:SetStart(startpos + dir * 14)
					effectdata:SetNormal(tr.HitNormal)
					effectdata:SetEntity(box)
					effectdata:SetMagnitude(charged)
				util.Effect("lasercannon", effectdata)

				if charged < 40 then
					local trent = tr.Entity
					if trent:IsValid() then
						if trent:GetMoveType() == MOVETYPE_VPHYSICS then
							trent:GetPhysicsObject():ApplyForceCenter(charged * 1000 * dir)
						end

						trent:TakeDamage(charged * 1.5, owner, self)
					end
				else
					util.BlastDamage(self, owner, tr.HitPos, charged * 1.5, charged * 1.5)
				end

				box:EmitSound("ambient/energy/zap9.wav", 75 + charged * 0.4, 120 + charged * -1.25)
			end

			self:NextThink(CurTime())
			return true
		end
	end
end

function ENT:KeyPress(pl, box, key)
	if key == IN_ATTACK and self:GetNextAttack() <= CurTime() and self:GetCharge() == 0 then
		self:SetCharge(0.1)
		self:NextThink(CurTime())
	end
end

function ENT:PlayerSet(pPlayer, eBox, bExists)
	pPlayer:RemoveStatus("weapon_*", true, true, "status_weapon_lasercannon")
	eBox.Weapon = self
	if not bExists then
		pPlayer:EmitSound("mayhem/powerup.wav")
	end

	local effectdata = EffectData()
		effectdata:SetOrigin(eBox:GetPos())
		effectdata:SetEntity(eBox)
	util.Effect("boxpoweredup", effectdata)
end
