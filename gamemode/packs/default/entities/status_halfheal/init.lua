AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self:DrawShadow(false)
end

function ENT:Think()
	self:Remove()
end

function ENT:PlayerSet(pPlayer, eBox, bExists)
	pPlayer:EmitSound("mayhem/powerup.wav")
	pPlayer:SetHealth(math.min(pPlayer:Health() + pPlayer:GetMaxHealth() * 0.5, pPlayer:GetMaxHealth()))

	local effectdata = EffectData()
		effectdata:SetOrigin(eBox:GetPos())
		effectdata:SetEntity(eBox)
	util.Effect("fullheal", effectdata)
end
