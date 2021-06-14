AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/Combine_turrets/Floor_turret.mdl")
	self:DrawShadow(false)
end

function ENT:Think()
end

util.PrecacheSound("npc/dog/dog_servo2.wav")

function ENT:KeyPress(pl, box, key)
	if key == IN_ATTACK then
		local tr = util.TraceLine({start = box:GetPos(), endpos = box:GetPos() + pl:GetAimVector() * 64, filter={pl, box, self}})
		if tr.HitWorld and not tr.HitSky and not tr.HitNoDraw then
			if 0.85 < tr.HitNormal.z then
				local ent = ents.Create("turret")
				ent:SetPos(tr.HitPos + tr.HitNormal * 4)
				local ang = tr.HitNormal:Angle()
				ang.pitch = ang.pitch + 90
				if pl:GetAimVector().y < 0 then
					ang.yaw = 270
				else
					ang.yaw = 90
				end
				ent:SetAngles(ang)
				ent:SetColor(box:GetColor())
				ent:SetOwner(box)
				ent:Spawn()
				ent.Owner = pl
				ent.Team = pl:Team()

				ent:EmitSound("npc/dog/dog_servo2.wav")

				self:Remove()
			else
				pl:PrintMessage(HUD_PRINTCENTER, "Must be placed on the ground.")
			end
		end
	end
end

function ENT:PlayerSet(pPlayer, eBox, bExists)
	pPlayer:RemoveStatus("weapon_*", true, true, "status_weapon_turret")
	eBox.Weapon = self
	if not bExists then
		pPlayer:EmitSound("mayhem/powerup.wav")
	end

	local effectdata = EffectData()
		effectdata:SetOrigin(eBox:GetPos())
		effectdata:SetEntity(eBox)
	util.Effect("boxpoweredup", effectdata)
end
