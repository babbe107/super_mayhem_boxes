AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/props_combine/combine_mine01.mdl")
	self:DrawShadow(false)
end

function ENT:Think()
end

util.PrecacheSound("weapons/slam/mine_mode.wav")

function ENT:KeyPress(pl, box, key)
	if key == IN_ATTACK then
		local tr = util.TraceLine({start = box:GetPos(), endpos = box:GetPos() + pl:GetAimVector() * 64, filter={pl, box, self}})
		if tr.HitWorld and not tr.HitSky and not tr.HitNoDraw then
			local ent = ents.Create("mine")
			ent:SetPos(tr.HitPos + tr.HitNormal * 4)
			local ang = tr.HitNormal:Angle()
			ang.pitch = ang.pitch + 90
			ent:SetAngles(ang)
			ent:SetOwner(box)
			ent:SetColor(box:GetColor())
			ent:Spawn()
			ent.Owner = pl
			ent.Team = pl:Team()

			ent:EmitSound("weapons/slam/mine_mode.wav")

			self:Remove()
		end
	end
end

function ENT:PlayerSet(pPlayer, eBox, bExists)
	pPlayer:RemoveStatus("weapon_*", true, true, "status_weapon_mine")
	eBox.Weapon = self
	if not bExists then
		pPlayer:EmitSound("mayhem/powerup.wav")
	end

	local effectdata = EffectData()
		effectdata:SetOrigin(eBox:GetPos())
		effectdata:SetEntity(eBox)
	util.Effect("boxpoweredup", effectdata)
end
