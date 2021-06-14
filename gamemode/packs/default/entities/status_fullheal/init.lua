AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self:DrawShadow(false)
end

-- No point in keeping this entity. Just remove ourselves.
function ENT:Think()
	self:Remove()
end

function ENT:PlayerSet(pPlayer, eBox, bExists)
	pPlayer:EmitSound("mayhem/powerup.wav")
	pPlayer:SetHealth(pPlayer:GetMaxHealth())

	local effectdata = EffectData()
		effectdata:SetOrigin(eBox:GetPos())
		effectdata:SetEntity(eBox)
	util.Effect("fullheal", effectdata)
end
